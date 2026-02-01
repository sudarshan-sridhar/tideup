import 'package:cloud_firestore/cloud_firestore.dart';

/// Mission model for cleanup events
class MissionModel {
  final String id;
  final String title;
  final String description;
  final String organizationId;
  final String organizationName;
  final double latitude;
  final double longitude;
  final String address;
  final DateTime dateTime;
  final int durationMinutes;
  final DateTime createdAt;
  final String difficulty;
  final String status; // 'upcoming', 'active', 'completed', 'cancelled'
  final int xpReward;
  final int coinReward;
  final String? imageUrl;
  final List<String> participants;
  final List<String> completedBy;
  final int maxParticipants;
  final double targetTrashKg;
  final double collectedTrashKg;
  final String? qrCode;
  final List<String> tags;
  final bool isDemo;

  const MissionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.organizationId,
    required this.organizationName,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.dateTime,
    required this.durationMinutes,
    required this.createdAt,
    required this.difficulty,
    required this.status,
    required this.xpReward,
    required this.coinReward,
    this.imageUrl,
    this.participants = const [],
    this.completedBy = const [],
    this.maxParticipants = 50,
    this.targetTrashKg = 0.0,
    this.collectedTrashKg = 0.0,
    this.qrCode,
    this.tags = const [],
    this.isDemo = false,
  });

  int get currentParticipants => participants.length;
  bool get hasSpots => currentParticipants < maxParticipants;
  int get availableSpots => maxParticipants - currentParticipants;
  bool get isUpcoming => status == 'upcoming';
  bool get isActive => status == 'active';
  bool get isCompleted => status == 'completed';

  double get progressPercentage {
    if (targetTrashKg <= 0) return 0.0;
    return (collectedTrashKg / targetTrashKg).clamp(0.0, 1.0);
  }

  bool isUserJoined(String? userId) => userId != null && participants.contains(userId);
  bool isUserCompleted(String? userId) => userId != null && completedBy.contains(userId);

  factory MissionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Handle nested location object or flat lat/lng
    double lat = 0.0;
    double lng = 0.0;
    String address = '';
    
    if (data['location'] != null) {
      final location = data['location'] as Map<String, dynamic>;
      lat = (location['lat'] ?? 0.0).toDouble();
      lng = (location['lng'] ?? 0.0).toDouble();
      address = location['address'] ?? '';
    } else {
      lat = (data['latitude'] ?? 0.0).toDouble();
      lng = (data['longitude'] ?? 0.0).toDouble();
      address = data['address'] ?? '';
    }

    return MissionModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      organizationId: data['organizationId'] ?? '',
      organizationName: data['organizationName'] ?? '',
      latitude: lat,
      longitude: lng,
      address: address,
      dateTime: (data['dateTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      durationMinutes: data['durationMinutes'] ?? 120,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      difficulty: data['difficulty'] ?? 'medium',
      status: data['status'] ?? 'upcoming',
      xpReward: data['xpReward'] ?? 100,
      coinReward: data['coinReward'] ?? 50,
      imageUrl: data['imageUrl'],
      participants: List<String>.from(data['participants'] ?? []),
      completedBy: List<String>.from(data['completedBy'] ?? []),
      maxParticipants: data['maxParticipants'] ?? 50,
      targetTrashKg: (data['targetTrashKg'] ?? 0.0).toDouble(),
      collectedTrashKg: (data['collectedTrashKg'] ?? 0.0).toDouble(),
      qrCode: data['qrCode'],
      tags: List<String>.from(data['tags'] ?? []),
      isDemo: data['isDemo'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'organizationId': organizationId,
      'organizationName': organizationName,
      'location': {
        'lat': latitude,
        'lng': longitude,
        'address': address,
      },
      'dateTime': Timestamp.fromDate(dateTime),
      'durationMinutes': durationMinutes,
      'createdAt': Timestamp.fromDate(createdAt),
      'difficulty': difficulty,
      'status': status,
      'xpReward': xpReward,
      'coinReward': coinReward,
      'imageUrl': imageUrl,
      'participants': participants,
      'completedBy': completedBy,
      'maxParticipants': maxParticipants,
      'targetTrashKg': targetTrashKg,
      'collectedTrashKg': collectedTrashKg,
      'qrCode': qrCode,
      'tags': tags,
      'isDemo': isDemo,
    };
  }

  MissionModel copyWith({
    String? status,
    List<String>? participants,
    List<String>? completedBy,
    double? collectedTrashKg,
  }) {
    return MissionModel(
      id: id, title: title, description: description,
      organizationId: organizationId, organizationName: organizationName,
      latitude: latitude, longitude: longitude, address: address,
      dateTime: dateTime, durationMinutes: durationMinutes, createdAt: createdAt,
      difficulty: difficulty, status: status ?? this.status,
      xpReward: xpReward, coinReward: coinReward, imageUrl: imageUrl,
      participants: participants ?? this.participants,
      completedBy: completedBy ?? this.completedBy,
      maxParticipants: maxParticipants,
      targetTrashKg: targetTrashKg,
      collectedTrashKg: collectedTrashKg ?? this.collectedTrashKg,
      qrCode: qrCode, tags: tags, isDemo: isDemo,
    );
  }
}
