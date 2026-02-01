import 'package:cloud_firestore/cloud_firestore.dart';

/// Check-in model for mission participation verification
class CheckInModel {
  final String id;
  final String missionId;
  final String missionTitle;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final DateTime checkInTime;
  final DateTime? checkOutTime;
  final String status; // 'pending', 'verified', 'rejected'
  
  // Location verification
  final double? latitude;
  final double? longitude;
  final bool locationVerified;
  
  // Photo proof
  final String? beforePhotoUrl;
  final String? afterPhotoUrl;
  final List<String> additionalPhotos;
  
  // AI verification
  final bool aiVerified;
  final double? aiConfidenceScore;
  final String? aiAnalysis;
  final String? aiRecommendation;
  final List<String>? detectedTrashTypes;
  final double? estimatedTrashKg;
  
  // Manual verification
  final String? verifiedBy;
  final DateTime? verifiedAt;
  final String? verificationNote;
  
  // Rewards
  final int xpAwarded;
  final int coinsAwarded;
  final double? trashCollectedKg;

  const CheckInModel({
    required this.id,
    required this.missionId,
    required this.missionTitle,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.checkInTime,
    this.checkOutTime,
    required this.status,
    this.latitude,
    this.longitude,
    this.locationVerified = false,
    this.beforePhotoUrl,
    this.afterPhotoUrl,
    this.additionalPhotos = const [],
    this.aiVerified = false,
    this.aiConfidenceScore,
    this.aiAnalysis,
    this.aiRecommendation,
    this.detectedTrashTypes,
    this.estimatedTrashKg,
    this.verifiedBy,
    this.verifiedAt,
    this.verificationNote,
    this.xpAwarded = 0,
    this.coinsAwarded = 0,
    this.trashCollectedKg,
  });

  bool get hasBothPhotos => beforePhotoUrl != null && afterPhotoUrl != null;
  bool get isPending => status == 'pending';
  bool get isVerified => status == 'verified';
  bool get isRejected => status == 'rejected';

  factory CheckInModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CheckInModel(
      id: doc.id,
      missionId: data['missionId'] ?? '',
      missionTitle: data['missionTitle'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userPhotoUrl: data['userPhotoUrl'],
      checkInTime: (data['checkInTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      checkOutTime: (data['checkOutTime'] as Timestamp?)?.toDate(),
      status: data['status'] ?? 'pending',
      latitude: data['latitude']?.toDouble(),
      longitude: data['longitude']?.toDouble(),
      locationVerified: data['locationVerified'] ?? false,
      beforePhotoUrl: data['beforePhotoUrl'],
      afterPhotoUrl: data['afterPhotoUrl'],
      additionalPhotos: List<String>.from(data['additionalPhotos'] ?? []),
      aiVerified: data['aiVerified'] ?? false,
      aiConfidenceScore: data['aiConfidenceScore']?.toDouble(),
      aiAnalysis: data['aiAnalysis'],
      aiRecommendation: data['aiRecommendation'],
      detectedTrashTypes: data['detectedTrashTypes'] != null ? List<String>.from(data['detectedTrashTypes']) : null,
      estimatedTrashKg: data['estimatedTrashKg']?.toDouble(),
      verifiedBy: data['verifiedBy'],
      verifiedAt: (data['verifiedAt'] as Timestamp?)?.toDate(),
      verificationNote: data['verificationNote'],
      xpAwarded: data['xpAwarded'] ?? 0,
      coinsAwarded: data['coinsAwarded'] ?? 0,
      trashCollectedKg: data['trashCollectedKg']?.toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'missionId': missionId,
      'missionTitle': missionTitle,
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'checkInTime': Timestamp.fromDate(checkInTime),
      'checkOutTime': checkOutTime != null ? Timestamp.fromDate(checkOutTime!) : null,
      'status': status,
      'latitude': latitude,
      'longitude': longitude,
      'locationVerified': locationVerified,
      'beforePhotoUrl': beforePhotoUrl,
      'afterPhotoUrl': afterPhotoUrl,
      'additionalPhotos': additionalPhotos,
      'aiVerified': aiVerified,
      'aiConfidenceScore': aiConfidenceScore,
      'aiAnalysis': aiAnalysis,
      'aiRecommendation': aiRecommendation,
      'detectedTrashTypes': detectedTrashTypes,
      'estimatedTrashKg': estimatedTrashKg,
      'verifiedBy': verifiedBy,
      'verifiedAt': verifiedAt != null ? Timestamp.fromDate(verifiedAt!) : null,
      'verificationNote': verificationNote,
      'xpAwarded': xpAwarded,
      'coinsAwarded': coinsAwarded,
      'trashCollectedKg': trashCollectedKg,
    };
  }
}
