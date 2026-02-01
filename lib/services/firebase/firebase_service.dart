import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../core/constants/app_constants.dart';
import '../../features/auth/data/user_model.dart';
import '../../features/missions/data/models/mission_model.dart';
import '../../features/missions/data/models/checkin_model.dart';
import '../../features/community/data/post_model.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // ==================== AUTH ====================
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signInWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> signUpWithEmail(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // ==================== DEMO LOGIN ====================
  Future<UserCredential> signInAsDemo(bool isPlayer) async {
    final email = isPlayer ? 'demo.player@tideup.app' : 'demo.org@tideup.app';
    const password = 'demo123456';
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await _setupDemoAccount(credential.user!.uid, isPlayer);
      return credential;
    }
  }

  Future<void> _setupDemoAccount(String uid, bool isPlayer) async {
    final now = DateTime.now();
    if (isPlayer) {
      final user = UserModel(
        uid: uid, email: 'demo.player@tideup.app', name: 'Demo Player', role: 'player',
        createdAt: now, lastActive: now, isDemo: true,
        xp: DemoDefaults.player['xp'] as int,
        level: DemoDefaults.player['level'] as int,
        coins: DemoDefaults.player['coins'] as int,
        totalCleanups: DemoDefaults.player['totalCleanups'] as int,
        totalTrashKg: DemoDefaults.player['totalTrashKg'] as double,
        currentStreak: DemoDefaults.player['currentStreak'] as int,
        longestStreak: DemoDefaults.player['longestStreak'] as int,
        achievements: List<String>.from(DemoDefaults.player['achievements'] as List),
        solanaAddress: 'DemoP1ayer...7xYz',
        solanaBalance: DemoDefaults.player['solanaBalance'] as double,
        totalCoinsConverted: DemoDefaults.player['totalCoinsConverted'] as int,
      );
      await saveUser(user);
    } else {
      final user = UserModel(
        uid: uid, email: 'demo.org@tideup.app', name: 'Beach Buddies Organization', role: 'organization',
        createdAt: now, lastActive: now, isDemo: true,
        organizationName: 'Beach Buddies',
        organizationDescription: 'Dedicated to keeping Michigan and LA beaches clean since 2020.',
        isVerifiedOrganization: true,
        totalMissionsCreated: DemoDefaults.organization['totalMissionsCreated'] as int,
        totalVolunteers: DemoDefaults.organization['totalVolunteers'] as int,
      );
      await saveUser(user);
    }
  }

  Future<void> resetDemoAccount(String uid, {required bool isPlayer}) async {
    if (isPlayer) {
      await _firestore.collection(AppConstants.usersCollection).doc(uid).update({
        'xp': DemoDefaults.player['xp'],
        'level': DemoDefaults.player['level'],
        'coins': DemoDefaults.player['coins'],
        'totalCleanups': DemoDefaults.player['totalCleanups'],
        'totalTrashKg': DemoDefaults.player['totalTrashKg'],
        'currentStreak': DemoDefaults.player['currentStreak'],
        'longestStreak': DemoDefaults.player['longestStreak'],
        'achievements': DemoDefaults.player['achievements'],
        'solanaBalance': DemoDefaults.player['solanaBalance'],
        'totalCoinsConverted': DemoDefaults.player['totalCoinsConverted'],
        'purchasedItems': [],
        'joinedMissions': [],
        'completedMissions': [],
      });
    } else {
      await _firestore.collection(AppConstants.usersCollection).doc(uid).update({
        'totalMissionsCreated': DemoDefaults.organization['totalMissionsCreated'],
        'totalVolunteers': DemoDefaults.organization['totalVolunteers'],
      });
    }
  }

  // ==================== USER ====================
  Future<void> saveUser(UserModel user) async {
    await _firestore.collection(AppConstants.usersCollection).doc(user.uid).set(user.toFirestore(), SetOptions(merge: true));
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _firestore.collection(AppConstants.usersCollection).doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Stream<UserModel?> getUserStream(String uid) {
    return _firestore.collection(AppConstants.usersCollection).doc(uid).snapshots().map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }

  Future<bool> userProfileExists(String uid) async {
    final doc = await _firestore.collection(AppConstants.usersCollection).doc(uid).get();
    return doc.exists;
  }

  Future<void> updateUserField(String uid, Map<String, dynamic> updates) async {
    updates['lastActive'] = Timestamp.now();
    await _firestore.collection(AppConstants.usersCollection).doc(uid).update(updates);
  }

  Future<void> updateUserStats({required String uid, int? xpToAdd, int? coinsToAdd, double? trashKgToAdd, String? missionId, bool completed = false}) async {
    final updates = <String, dynamic>{'lastActive': Timestamp.now()};
    if (xpToAdd != null && xpToAdd > 0) {
      updates['xp'] = FieldValue.increment(xpToAdd);
      final user = await getUser(uid);
      if (user != null) {
        final newXp = user.xp + xpToAdd;
        final newLevel = XpCalculator.getLevelFromXp(newXp);
        if (newLevel > user.level) updates['level'] = newLevel;
      }
    }
    if (coinsToAdd != null && coinsToAdd > 0) updates['coins'] = FieldValue.increment(coinsToAdd);
    if (trashKgToAdd != null && trashKgToAdd > 0) updates['totalTrashKg'] = FieldValue.increment(trashKgToAdd);
    if (missionId != null) {
      if (completed) {
        updates['completedMissions'] = FieldValue.arrayUnion([missionId]);
        updates['totalCleanups'] = FieldValue.increment(1);
      } else {
        updates['joinedMissions'] = FieldValue.arrayUnion([missionId]);
      }
    }
    await _firestore.collection(AppConstants.usersCollection).doc(uid).update(updates);
  }

  Future<void> convertCoinsToSol(String uid, int coins, double solAmount) async {
    await _firestore.collection(AppConstants.usersCollection).doc(uid).update({
      'coins': FieldValue.increment(-coins),
      'solanaBalance': FieldValue.increment(solAmount),
      'totalCoinsConverted': FieldValue.increment(coins),
    });
  }

  Future<void> purchaseItem(String uid, String itemId, int cost) async {
    await _firestore.collection(AppConstants.usersCollection).doc(uid).update({
      'coins': FieldValue.increment(-cost),
      'purchasedItems': FieldValue.arrayUnion([itemId]),
    });
  }

  Future<List<UserModel>> getLeaderboard({int limit = 50}) async {
    final snapshot = await _firestore.collection(AppConstants.usersCollection).where('role', isEqualTo: 'player').orderBy('xp', descending: true).limit(limit).get();
    return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
  }

  // ==================== MISSIONS ====================
  Future<String> createMission(MissionModel mission) async {
    final data = mission.toFirestore();
    print('DEBUG createMission: Creating mission with organizationId=${data['organizationId']}');
    final docRef = await _firestore.collection(AppConstants.missionsCollection).add(data);
    print('DEBUG createMission: Created mission with id=${docRef.id}');
    await _firestore.collection(AppConstants.usersCollection).doc(mission.organizationId).update({'totalMissionsCreated': FieldValue.increment(1)});
    return docRef.id;
  }

  Future<void> updateMission(String missionId, Map<String, dynamic> updates) async {
    await _firestore.collection(AppConstants.missionsCollection).doc(missionId).update(updates);
  }

  Future<void> deleteMission(String missionId) async {
    final mission = await getMission(missionId);
    await _firestore.collection(AppConstants.missionsCollection).doc(missionId).delete();
    if (mission != null) {
      await _firestore.collection(AppConstants.usersCollection).doc(mission.organizationId).update({
        'totalMissionsCreated': FieldValue.increment(-1),
      });
    }
  }

  Future<MissionModel?> getMission(String missionId) async {
    final doc = await _firestore.collection(AppConstants.missionsCollection).doc(missionId).get();
    if (!doc.exists) return null;
    return MissionModel.fromFirestore(doc);
  }

  Stream<MissionModel?> getMissionStream(String missionId) {
    return _firestore.collection(AppConstants.missionsCollection).doc(missionId).snapshots().map((doc) => doc.exists ? MissionModel.fromFirestore(doc) : null);
  }

  // Get all missions, filter in memory
  Stream<List<MissionModel>> getMissionsStream({String? status, String? organizationId}) {
    return _firestore.collection(AppConstants.missionsCollection).snapshots().map((snapshot) {
      var missions = snapshot.docs.map((doc) {
        try {
          return MissionModel.fromFirestore(doc);
        } catch (e) {
          print('Error parsing mission: $e');
          return null;
        }
      }).whereType<MissionModel>().toList();
      
      if (status != null) {
        missions = missions.where((m) => m.status == status).toList();
      }
      if (organizationId != null) {
        missions = missions.where((m) => m.organizationId == organizationId).toList();
      }
      return missions;
    });
  }

  // Get all missions, filter in memory (no Firestore index needed)
  Future<List<MissionModel>> getUpcomingMissions({int limit = 50}) async {
    try {
      final snapshot = await _firestore.collection(AppConstants.missionsCollection).get();
      print('DEBUG getUpcomingMissions: Found ${snapshot.docs.length} total missions');
      
      var missions = snapshot.docs.map((doc) {
        try {
          return MissionModel.fromFirestore(doc);
        } catch (e) {
          print('DEBUG: Error parsing mission ${doc.id}: $e');
          return null;
        }
      }).whereType<MissionModel>().toList();
      
      // Filter for upcoming/active in memory
      missions = missions.where((m) => m.status == 'upcoming' || m.status == 'active').toList();
      print('DEBUG: ${missions.length} missions are upcoming/active');
      
      // Sort by date
      missions.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      
      // Limit results
      if (missions.length > limit) {
        missions = missions.take(limit).toList();
      }
      
      return missions;
    } catch (e) {
      print('DEBUG: Error getting missions: $e');
      return [];
    }
  }

  // FIXED: Get organization missions - fetch all, filter in memory
  Future<List<MissionModel>> getOrganizationMissions(String orgId) async {
    try {
      print('DEBUG getOrganizationMissions: Looking for orgId=$orgId');
      
      // Get ALL missions first
      final snapshot = await _firestore.collection(AppConstants.missionsCollection).get();
      print('DEBUG: Total missions in Firestore: ${snapshot.docs.length}');
      
      final allMissions = <MissionModel>[];
      for (final doc in snapshot.docs) {
        try {
          final data = doc.data();
          print('DEBUG: Mission ${doc.id} has organizationId=${data['organizationId']}');
          final mission = MissionModel.fromFirestore(doc);
          allMissions.add(mission);
        } catch (e) {
          print('DEBUG: Error parsing mission ${doc.id}: $e');
        }
      }
      
      // Filter by organization ID
      final orgMissions = allMissions.where((m) => m.organizationId == orgId).toList();
      print('DEBUG: Found ${orgMissions.length} missions for org $orgId');
      
      return orgMissions;
    } catch (e) {
      print('DEBUG getOrganizationMissions error: $e');
      return [];
    }
  }

  Future<void> joinMission(String missionId, String userId) async {
    await _firestore.collection(AppConstants.missionsCollection).doc(missionId).update({'participants': FieldValue.arrayUnion([userId])});
    await _firestore.collection(AppConstants.usersCollection).doc(userId).update({'joinedMissions': FieldValue.arrayUnion([missionId])});
  }

  Future<void> leaveMission(String missionId, String userId) async {
    await _firestore.collection(AppConstants.missionsCollection).doc(missionId).update({'participants': FieldValue.arrayRemove([userId])});
    await _firestore.collection(AppConstants.usersCollection).doc(userId).update({'joinedMissions': FieldValue.arrayRemove([missionId])});
  }

  // ==================== CHECK-INS ====================
  Future<String> createCheckIn(CheckInModel checkIn) async {
    final docRef = await _firestore.collection(AppConstants.checkInsCollection).add(checkIn.toFirestore());
    return docRef.id;
  }

  Future<void> updateCheckIn(String checkInId, Map<String, dynamic> updates) async {
    await _firestore.collection(AppConstants.checkInsCollection).doc(checkInId).update(updates);
  }

  Future<CheckInModel?> getCheckIn(String checkInId) async {
    final doc = await _firestore.collection(AppConstants.checkInsCollection).doc(checkInId).get();
    if (!doc.exists) return null;
    return CheckInModel.fromFirestore(doc);
  }

  Stream<List<CheckInModel>> getMissionCheckIns(String missionId) {
    return _firestore.collection(AppConstants.checkInsCollection).where('missionId', isEqualTo: missionId).snapshots().map((s) => s.docs.map((doc) => CheckInModel.fromFirestore(doc)).toList());
  }

  Stream<List<CheckInModel>> getOrganizationPendingCheckIns(String orgId) {
    return _firestore.collection(AppConstants.checkInsCollection).where('status', isEqualTo: 'pending').snapshots().asyncMap((snapshot) async {
      final checkIns = <CheckInModel>[];
      for (final doc in snapshot.docs) {
        final checkIn = CheckInModel.fromFirestore(doc);
        final mission = await getMission(checkIn.missionId);
        if (mission?.organizationId == orgId) {
          checkIns.add(checkIn);
        }
      }
      return checkIns;
    });
  }

  Future<void> verifyCheckIn({required String checkInId, required String verifiedBy, required String status, required int xpAwarded, required int coinsAwarded, double? trashCollectedKg, String? note}) async {
    final checkIn = await getCheckIn(checkInId);
    if (checkIn == null) return;
    await updateCheckIn(checkInId, {
      'status': status, 'verifiedBy': verifiedBy, 'verifiedAt': Timestamp.now(),
      'verificationNote': note, 'xpAwarded': xpAwarded, 'coinsAwarded': coinsAwarded, 'trashCollectedKg': trashCollectedKg,
    });
    if (status == 'verified') {
      await updateUserStats(uid: checkIn.userId, xpToAdd: xpAwarded, coinsToAdd: coinsAwarded, trashKgToAdd: trashCollectedKg, missionId: checkIn.missionId, completed: true);
      await _firestore.collection(AppConstants.missionsCollection).doc(checkIn.missionId).update({
        'completedBy': FieldValue.arrayUnion([checkIn.userId]),
        if (trashCollectedKg != null) 'collectedTrashKg': FieldValue.increment(trashCollectedKg),
      });
      final mission = await getMission(checkIn.missionId);
      if (mission != null) {
        await _firestore.collection(AppConstants.usersCollection).doc(mission.organizationId).update({'totalVolunteers': FieldValue.increment(1)});
      }
    }
  }

  // ==================== COMMUNITY ====================
  Future<String> createPost(PostModel post) async {
    final docRef = await _firestore.collection(AppConstants.postsCollection).add(post.toFirestore());
    return docRef.id;
  }

  Future<void> deletePost(String postId) async {
    await _firestore.collection(AppConstants.postsCollection).doc(postId).delete();
  }

  Stream<List<PostModel>> getPostsStream({int limit = 20}) {
    return _firestore.collection(AppConstants.postsCollection).orderBy('createdAt', descending: true).limit(limit).snapshots().map((s) => s.docs.map((doc) => PostModel.fromFirestore(doc)).toList());
  }

  Future<void> togglePostLike(String postId, String userId) async {
    final doc = await _firestore.collection(AppConstants.postsCollection).doc(postId).get();
    if (!doc.exists) return;
    final post = PostModel.fromFirestore(doc);
    await _firestore.collection(AppConstants.postsCollection).doc(postId).update({
      'likes': post.likes.contains(userId) ? FieldValue.arrayRemove([userId]) : FieldValue.arrayUnion([userId])
    });
  }

  Stream<List<CommentModel>> getCommentsStream(String postId) {
    return _firestore.collection(AppConstants.postsCollection).doc(postId).collection('comments').orderBy('createdAt').snapshots().map((s) => s.docs.map((doc) => CommentModel.fromFirestore(doc)).toList());
  }

  // ==================== CHAT ====================
  Stream<List<ChatRoomModel>> getUserChats(String userId) {
    return _firestore.collection(AppConstants.chatsCollection).where('participantIds', arrayContains: userId).snapshots().map((s) => s.docs.map((doc) => ChatRoomModel.fromFirestore(doc)).toList());
  }

  Stream<List<MessageModel>> getChatMessages(String chatRoomId) {
    return _firestore.collection(AppConstants.chatsCollection).doc(chatRoomId).collection('messages').orderBy('timestamp').snapshots().map((s) => s.docs.map((doc) => MessageModel.fromFirestore(doc)).toList());
  }

  // ==================== STORAGE ====================
  Future<String> uploadPostImage(String postId, Uint8List bytes) async {
    final path = '${AppConstants.postImagesPath}/$postId/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage.ref().child(path);
    await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
    return await ref.getDownloadURL();
  }

  Future<String> uploadMissionImage(String missionId, Uint8List bytes) async {
    final path = '${AppConstants.missionImagesPath}/$missionId/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage.ref().child(path);
    await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
    return await ref.getDownloadURL();
  }

  Future<String> uploadCleanupProof(String checkInId, String type, Uint8List bytes) async {
    final path = '${AppConstants.cleanupProofsPath}/$checkInId/${type}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage.ref().child(path);
    await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
    return await ref.getDownloadURL();
  }

  // ==================== TRANSACTIONS ====================
  Stream<List<TransactionModel>> getUserTransactions(String uid) {
    return _firestore.collection(AppConstants.transactionsCollection).where('userId', isEqualTo: uid).snapshots().map((s) => s.docs.map((doc) => TransactionModel.fromFirestore(doc)).toList());
  }

  Future<Map<String, dynamic>> getGlobalStats() async {
    final users = await _firestore.collection(AppConstants.usersCollection).where('role', isEqualTo: 'player').get();
    double totalTrash = 0;
    int totalCleanups = 0;
    for (final doc in users.docs) {
      final data = doc.data();
      totalTrash += (data['totalTrashKg'] ?? 0).toDouble();
      totalCleanups += (data['totalCleanups'] ?? 0) as int;
    }
    return {'totalPlayers': users.docs.length, 'totalTrashKg': totalTrash, 'totalCleanups': totalCleanups};
  }

  // ==================== DEBUG HELPER ====================
  Future<void> debugPrintMissions() async {
    print('========== DEBUG: ALL MISSIONS IN FIRESTORE ==========');
    final snapshot = await _firestore.collection('missions').get();
    print('Total documents: ${snapshot.docs.length}');
    for (final doc in snapshot.docs) {
      final data = doc.data();
      print('---');
      print('ID: ${doc.id}');
      print('Title: ${data['title']}');
      print('Status: ${data['status']}');
      print('OrgId: ${data['organizationId']}');
    }
    print('======================================================');
  }
}
