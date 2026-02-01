import 'package:cloud_firestore/cloud_firestore.dart';

/// User model for players and organizations
class UserModel {
  final String uid;
  final String email;
  final String name;
  final String role; // 'player' or 'organization'
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime lastActive;
  final bool isDemo;

  // Player-only stats
  final int xp;
  final int level;
  final int coins;
  final int totalCleanups;
  final double totalTrashKg;
  final int currentStreak;
  final int longestStreak;
  final List<String> achievements;
  final List<String> joinedMissions;
  final List<String> completedMissions;
  final List<String> purchasedItems;

  // Organization-only fields
  final String? organizationName;
  final String? organizationDescription;
  final String? website;
  final bool isVerifiedOrganization;
  final int totalMissionsCreated;
  final int totalVolunteers;

  // Solana wallet
  final String? solanaAddress;
  final double solanaBalance;
  final int totalCoinsConverted;
  final List<String> nftBadges;

  // Settings
  final bool notificationsEnabled;
  final String? fcmToken;
  final String? bio;

  const UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.photoUrl,
    required this.createdAt,
    required this.lastActive,
    this.isDemo = false,
    this.xp = 0,
    this.level = 1,
    this.coins = 0,
    this.totalCleanups = 0,
    this.totalTrashKg = 0.0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.achievements = const [],
    this.joinedMissions = const [],
    this.completedMissions = const [],
    this.purchasedItems = const [],
    this.organizationName,
    this.organizationDescription,
    this.website,
    this.isVerifiedOrganization = false,
    this.totalMissionsCreated = 0,
    this.totalVolunteers = 0,
    this.solanaAddress,
    this.solanaBalance = 0.0,
    this.totalCoinsConverted = 0,
    this.nftBadges = const [],
    this.notificationsEnabled = true,
    this.fcmToken,
    this.bio,
  });

  bool get isPlayer => role == 'player';
  bool get isOrganization => role == 'organization';

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      role: data['role'] ?? 'player',
      photoUrl: data['photoUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastActive: (data['lastActive'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isDemo: data['isDemo'] ?? false,
      xp: data['xp'] ?? 0,
      level: data['level'] ?? 1,
      coins: data['coins'] ?? 0,
      totalCleanups: data['totalCleanups'] ?? 0,
      totalTrashKg: (data['totalTrashKg'] ?? 0.0).toDouble(),
      currentStreak: data['currentStreak'] ?? 0,
      longestStreak: data['longestStreak'] ?? 0,
      achievements: List<String>.from(data['achievements'] ?? []),
      joinedMissions: List<String>.from(data['joinedMissions'] ?? []),
      completedMissions: List<String>.from(data['completedMissions'] ?? []),
      purchasedItems: List<String>.from(data['purchasedItems'] ?? []),
      organizationName: data['organizationName'],
      organizationDescription: data['organizationDescription'],
      website: data['website'],
      isVerifiedOrganization: data['isVerifiedOrganization'] ?? false,
      totalMissionsCreated: data['totalMissionsCreated'] ?? 0,
      totalVolunteers: data['totalVolunteers'] ?? 0,
      solanaAddress: data['solanaAddress'],
      solanaBalance: (data['solanaBalance'] ?? 0.0).toDouble(),
      totalCoinsConverted: data['totalCoinsConverted'] ?? 0,
      nftBadges: List<String>.from(data['nftBadges'] ?? []),
      notificationsEnabled: data['notificationsEnabled'] ?? true,
      fcmToken: data['fcmToken'],
      bio: data['bio'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'role': role,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActive': Timestamp.fromDate(lastActive),
      'isDemo': isDemo,
      'xp': xp,
      'level': level,
      'coins': coins,
      'totalCleanups': totalCleanups,
      'totalTrashKg': totalTrashKg,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'achievements': achievements,
      'joinedMissions': joinedMissions,
      'completedMissions': completedMissions,
      'purchasedItems': purchasedItems,
      'organizationName': organizationName,
      'organizationDescription': organizationDescription,
      'website': website,
      'isVerifiedOrganization': isVerifiedOrganization,
      'totalMissionsCreated': totalMissionsCreated,
      'totalVolunteers': totalVolunteers,
      'solanaAddress': solanaAddress,
      'solanaBalance': solanaBalance,
      'totalCoinsConverted': totalCoinsConverted,
      'nftBadges': nftBadges,
      'notificationsEnabled': notificationsEnabled,
      'fcmToken': fcmToken,
      'bio': bio,
    };
  }

  UserModel copyWith({
    String? name,
    String? photoUrl,
    int? xp,
    int? level,
    int? coins,
    int? totalCleanups,
    double? totalTrashKg,
    int? currentStreak,
    int? longestStreak,
    List<String>? achievements,
    List<String>? joinedMissions,
    List<String>? completedMissions,
    List<String>? purchasedItems,
    String? organizationName,
    String? organizationDescription,
    int? totalMissionsCreated,
    int? totalVolunteers,
    String? solanaAddress,
    double? solanaBalance,
    int? totalCoinsConverted,
    List<String>? nftBadges,
    bool? notificationsEnabled,
    String? fcmToken,
    String? bio,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      name: name ?? this.name,
      role: role,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt,
      lastActive: DateTime.now(),
      isDemo: isDemo,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      coins: coins ?? this.coins,
      totalCleanups: totalCleanups ?? this.totalCleanups,
      totalTrashKg: totalTrashKg ?? this.totalTrashKg,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      achievements: achievements ?? this.achievements,
      joinedMissions: joinedMissions ?? this.joinedMissions,
      completedMissions: completedMissions ?? this.completedMissions,
      purchasedItems: purchasedItems ?? this.purchasedItems,
      organizationName: organizationName ?? this.organizationName,
      organizationDescription: organizationDescription ?? this.organizationDescription,
      website: website,
      isVerifiedOrganization: isVerifiedOrganization,
      totalMissionsCreated: totalMissionsCreated ?? this.totalMissionsCreated,
      totalVolunteers: totalVolunteers ?? this.totalVolunteers,
      solanaAddress: solanaAddress ?? this.solanaAddress,
      solanaBalance: solanaBalance ?? this.solanaBalance,
      totalCoinsConverted: totalCoinsConverted ?? this.totalCoinsConverted,
      nftBadges: nftBadges ?? this.nftBadges,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      fcmToken: fcmToken ?? this.fcmToken,
      bio: bio ?? this.bio,
    );
  }
}
