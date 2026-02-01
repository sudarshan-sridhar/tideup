import 'dart:math';
import '../../core/config/env.dart';

class SolanaService {
  bool _isConnected = false;
  String? _walletAddress;
  double _balance = 0.0;
  final List<SolanaTransaction> _transactions = [];

  bool get isConnected => _isConnected;
  String? get walletAddress => _walletAddress;
  double get balance => _balance;
  List<SolanaTransaction> get transactions => List.unmodifiable(_transactions);

  String _generateAddress() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz123456789';
    return List.generate(44, (_) => chars[Random().nextInt(chars.length)]).join();
  }

  String _generateSignature() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz123456789';
    return List.generate(88, (_) => chars[Random().nextInt(chars.length)]).join();
  }

  // Initialize from Firebase data (for existing users)
  void initializeFromFirebase(double balance, String? address) {
    if (balance > 0 || (address != null && address.isNotEmpty)) {
      _isConnected = true;
      _balance = balance;
      _walletAddress = address ?? _generateAddress();
    }
  }

  // Sync balance from Firebase
  void syncBalance(double firebaseBalance) {
    _balance = firebaseBalance;
  }

  Future<WalletResult> createWallet() async {
    await Future.delayed(const Duration(milliseconds: 800));
    _walletAddress = _generateAddress();
    _isConnected = true;
    _balance = 0.01;
    _transactions.insert(0, SolanaTransaction(
      type: TxType.airdrop, amount: 0.01, timestamp: DateTime.now(),
      description: 'Welcome airdrop', signature: _generateSignature(),
    ));
    return WalletResult(success: true, address: _walletAddress!, message: 'Wallet created! +0.01 SOL airdrop');
  }

  void disconnect() {
    _isConnected = false;
    _walletAddress = null;
    _balance = 0.0;
    _transactions.clear();
  }

  Future<AirdropResult> requestAirdrop({double amount = 0.01}) async {
    if (!_isConnected) return AirdropResult(success: false, message: 'Not connected');
    await Future.delayed(const Duration(milliseconds: 800));
    _balance += amount;
    final sig = _generateSignature();
    _transactions.insert(0, SolanaTransaction(
      type: TxType.airdrop, amount: amount, timestamp: DateTime.now(),
      description: 'Devnet airdrop', signature: sig,
    ));
    return AirdropResult(success: true, amount: amount, message: '+$amount SOL', signature: sig);
  }

  Future<ConversionResult> convertCoinsToSol(int coins) async {
    if (!_isConnected) return ConversionResult(success: false, message: 'Not connected');
    if (coins < Env.minCoinsToConvert) {
      return ConversionResult(success: false, message: 'Min ${Env.minCoinsToConvert} coins required');
    }
    await Future.delayed(const Duration(milliseconds: 1000));
    final sol = coins / Env.coinsPerSol;
    _balance += sol;
    final sig = _generateSignature();
    _transactions.insert(0, SolanaTransaction(
      type: TxType.conversion, amount: sol, coinsConverted: coins, timestamp: DateTime.now(),
      description: 'Converted $coins coins', signature: sig,
    ));
    return ConversionResult(success: true, coinsSpent: coins, solReceived: sol, 
      message: 'Converted to ${sol.toStringAsFixed(6)} SOL!', signature: sig);
  }

  Future<void> addReward(double sol, String description) async {
    if (!_isConnected) return;
    _balance += sol;
    _transactions.insert(0, SolanaTransaction(
      type: TxType.reward, amount: sol, timestamp: DateTime.now(),
      description: description, signature: _generateSignature(),
    ));
  }

  double calculateSol(int coins) => coins / Env.coinsPerSol;
  int calculateCoins(double sol) => (sol * Env.coinsPerSol).ceil();
  String get rateDisplay => '${Env.coinsPerSol} coins = 1 SOL';
}

class WalletResult {
  final bool success;
  final String? address;
  final String message;
  WalletResult({required this.success, this.address, required this.message});
}

class AirdropResult {
  final bool success;
  final double? amount;
  final String message;
  final String? signature;
  AirdropResult({required this.success, this.amount, required this.message, this.signature});
}

class ConversionResult {
  final bool success;
  final int? coinsSpent;
  final double? solReceived;
  final String message;
  final String? signature;
  ConversionResult({required this.success, this.coinsSpent, this.solReceived, required this.message, this.signature});
}

enum TxType { airdrop, conversion, reward, transfer }

class SolanaTransaction {
  final TxType type;
  final double amount;
  final int? coinsConverted;
  final DateTime timestamp;
  final String description;
  final String signature;
  SolanaTransaction({required this.type, required this.amount, this.coinsConverted, 
    required this.timestamp, required this.description, required this.signature});
  String get typeLabel => type == TxType.airdrop ? 'Airdrop' : type == TxType.conversion ? 'Conversion' : type == TxType.reward ? 'Reward' : 'Transfer';
  String get shortSig => '${signature.substring(0, 8)}...${signature.substring(signature.length - 8)}';
}
