import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../services/firebase/firebase_service.dart';
import '../../../../services/gemini/gemini_service.dart';
import '../../../../services/solana/solana_service.dart';
import '../../../auth/data/user_model.dart';
import '../../../missions/data/models/mission_model.dart';
import '../../../missions/data/models/checkin_model.dart';
import '../../../community/data/post_model.dart';

// ==================== SERVICE PROVIDERS ====================

final firebaseServiceProvider = Provider<FirebaseService>((ref) => FirebaseService());
final geminiServiceProvider = Provider<GeminiService>((ref) => GeminiService());
final solanaServiceProvider = StateNotifierProvider<SolanaNotifier, SolanaState>((ref) => SolanaNotifier());

// ==================== AUTH PROVIDERS ====================

final authStateProvider = StreamProvider<User?>((ref) => ref.watch(firebaseServiceProvider).authStateChanges);
final currentUserProvider = Provider<User?>((ref) => ref.watch(authStateProvider).value);

// ==================== USER PROVIDERS ====================

final userStreamProvider = StreamProvider.family<UserModel?, String>((ref, uid) => ref.watch(firebaseServiceProvider).getUserStream(uid));

final userProvider = Provider<UserModel?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  return ref.watch(userStreamProvider(user.uid)).value;
});

final leaderboardProvider = FutureProvider<List<UserModel>>((ref) => ref.watch(firebaseServiceProvider).getLeaderboard());

// ==================== MISSION PROVIDERS ====================

final missionsStreamProvider = StreamProvider<List<MissionModel>>((ref) => ref.watch(firebaseServiceProvider).getMissionsStream());
final upcomingMissionsProvider = FutureProvider<List<MissionModel>>((ref) => ref.watch(firebaseServiceProvider).getUpcomingMissions());
final missionStreamProvider = StreamProvider.family<MissionModel?, String>((ref, id) => ref.watch(firebaseServiceProvider).getMissionStream(id));
final organizationMissionsProvider = FutureProvider.family<List<MissionModel>, String>((ref, id) => ref.watch(firebaseServiceProvider).getOrganizationMissions(id));

final missionSearchQueryProvider = StateProvider<String>((ref) => '');
final missionDifficultyFilterProvider = StateProvider<String?>((ref) => null);

final filteredMissionsProvider = Provider<List<MissionModel>>((ref) {
  final missions = ref.watch(missionsStreamProvider).value ?? [];
  final query = ref.watch(missionSearchQueryProvider).toLowerCase();
  final difficulty = ref.watch(missionDifficultyFilterProvider);
  return missions.where((m) {
    final matchesQuery = query.isEmpty || m.title.toLowerCase().contains(query) || m.address.toLowerCase().contains(query);
    final matchesDifficulty = difficulty == null || m.difficulty == difficulty;
    return matchesQuery && matchesDifficulty;
  }).toList();
});

// ==================== CHECK-IN PROVIDERS ====================

final missionCheckInsProvider = StreamProvider.family<List<CheckInModel>, String>((ref, id) => ref.watch(firebaseServiceProvider).getMissionCheckIns(id));
final pendingCheckInsProvider = StreamProvider.family<List<CheckInModel>, String>((ref, id) => ref.watch(firebaseServiceProvider).getOrganizationPendingCheckIns(id));

// ==================== COMMUNITY PROVIDERS ====================

final postsStreamProvider = StreamProvider<List<PostModel>>((ref) => ref.watch(firebaseServiceProvider).getPostsStream());
final commentsStreamProvider = StreamProvider.family<List<CommentModel>, String>((ref, id) => ref.watch(firebaseServiceProvider).getCommentsStream(id));

// ==================== CHAT PROVIDERS ====================

final userChatsProvider = StreamProvider<List<ChatRoomModel>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);
  return ref.watch(firebaseServiceProvider).getUserChats(user.uid);
});

final chatMessagesProvider = StreamProvider.family<List<MessageModel>, String>((ref, id) => ref.watch(firebaseServiceProvider).getChatMessages(id));

// ==================== TRANSACTIONS & STATS ====================

final transactionsProvider = StreamProvider<List<TransactionModel>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);
  return ref.watch(firebaseServiceProvider).getUserTransactions(user.uid);
});

final globalStatsProvider = FutureProvider<Map<String, dynamic>>((ref) => ref.watch(firebaseServiceProvider).getGlobalStats());

// ==================== SOLANA STATE ====================

class SolanaState {
  final bool isConnected;
  final String? address;
  final double balance;
  final List<SolanaTransaction> transactions;
  final bool isLoading;

  SolanaState({this.isConnected = false, this.address, this.balance = 0.0, this.transactions = const [], this.isLoading = false});

  SolanaState copyWith({bool? isConnected, String? address, double? balance, List<SolanaTransaction>? transactions, bool? isLoading}) =>
    SolanaState(isConnected: isConnected ?? this.isConnected, address: address ?? this.address, balance: balance ?? this.balance, transactions: transactions ?? this.transactions, isLoading: isLoading ?? this.isLoading);
}

class SolanaNotifier extends StateNotifier<SolanaState> {
  final SolanaService _service = SolanaService();
  SolanaNotifier() : super(SolanaState());

  // Initialize wallet from Firebase data
  void initializeFromFirebase(double balance, String? address) {
    _service.initializeFromFirebase(balance, address);
    if (balance > 0 || (address != null && address.isNotEmpty)) {
      state = state.copyWith(
        isConnected: true,
        balance: balance,
        address: address ?? _service.walletAddress,
      );
    }
  }

  // Sync balance from Firebase
  void syncBalance(double firebaseBalance) {
    _service.syncBalance(firebaseBalance);
    state = state.copyWith(balance: firebaseBalance);
  }

  Future<WalletResult> createWallet() async {
    state = state.copyWith(isLoading: true);
    final result = await _service.createWallet();
    state = result.success 
      ? state.copyWith(isConnected: true, address: result.address, balance: _service.balance, transactions: _service.transactions, isLoading: false)
      : state.copyWith(isLoading: false);
    return result;
  }

  void disconnect() { _service.disconnect(); state = SolanaState(); }

  Future<AirdropResult> requestAirdrop({double amount = 0.01}) async {
    state = state.copyWith(isLoading: true);
    final result = await _service.requestAirdrop(amount: amount);
    state = result.success ? state.copyWith(balance: _service.balance, transactions: _service.transactions, isLoading: false) : state.copyWith(isLoading: false);
    return result;
  }

  Future<ConversionResult> convertCoins(int coins) async {
    state = state.copyWith(isLoading: true);
    final result = await _service.convertCoinsToSol(coins);
    state = result.success ? state.copyWith(balance: _service.balance, transactions: _service.transactions, isLoading: false) : state.copyWith(isLoading: false);
    return result;
  }

  Future<void> addReward(double sol, String description) async {
    await _service.addReward(sol, description);
    state = state.copyWith(balance: _service.balance, transactions: _service.transactions);
  }

  double calculateSol(int coins) => _service.calculateSol(coins);
  String get rateDisplay => _service.rateDisplay;
}
