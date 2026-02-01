import 'package:cloud_firestore/cloud_firestore.dart';

/// Post model for community feed
class PostModel {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorPhotoUrl;
  final String authorRole;
  final String content;
  final List<String> imageUrls;
  final DateTime createdAt;
  final String? missionId;
  final String? missionTitle;
  final List<String> likes;
  final int commentCount;
  final List<String> tags;
  final bool isPublic;
  final bool isPinned;

  const PostModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorPhotoUrl,
    required this.authorRole,
    required this.content,
    this.imageUrls = const [],
    required this.createdAt,
    this.missionId,
    this.missionTitle,
    this.likes = const [],
    this.commentCount = 0,
    this.tags = const [],
    this.isPublic = true,
    this.isPinned = false,
  });

  int get likeCount => likes.length;
  bool isLikedBy(String userId) => likes.contains(userId);

  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostModel(
      id: doc.id,
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '',
      authorPhotoUrl: data['authorPhotoUrl'],
      authorRole: data['authorRole'] ?? 'player',
      content: data['content'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      missionId: data['missionId'],
      missionTitle: data['missionTitle'],
      likes: List<String>.from(data['likes'] ?? []),
      commentCount: data['commentCount'] ?? 0,
      tags: List<String>.from(data['tags'] ?? []),
      isPublic: data['isPublic'] ?? true,
      isPinned: data['isPinned'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'authorId': authorId,
      'authorName': authorName,
      'authorPhotoUrl': authorPhotoUrl,
      'authorRole': authorRole,
      'content': content,
      'imageUrls': imageUrls,
      'createdAt': Timestamp.fromDate(createdAt),
      'missionId': missionId,
      'missionTitle': missionTitle,
      'likes': likes,
      'commentCount': commentCount,
      'tags': tags,
      'isPublic': isPublic,
      'isPinned': isPinned,
    };
  }
}

/// Comment model
class CommentModel {
  final String id;
  final String postId;
  final String authorId;
  final String authorName;
  final String? authorPhotoUrl;
  final String content;
  final DateTime createdAt;
  final List<String> likes;

  const CommentModel({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.authorName,
    this.authorPhotoUrl,
    required this.content,
    required this.createdAt,
    this.likes = const [],
  });

  factory CommentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommentModel(
      id: doc.id,
      postId: data['postId'] ?? '',
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '',
      authorPhotoUrl: data['authorPhotoUrl'],
      content: data['content'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      likes: List<String>.from(data['likes'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'postId': postId,
      'authorId': authorId,
      'authorName': authorName,
      'authorPhotoUrl': authorPhotoUrl,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'likes': likes,
    };
  }
}

/// Chat room model
class ChatRoomModel {
  final String id;
  final List<String> participantIds;
  final Map<String, String> participantNames;
  final String? missionId;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final Map<String, int> unreadCount;

  const ChatRoomModel({
    required this.id,
    required this.participantIds,
    required this.participantNames,
    this.missionId,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = const {},
  });

  factory ChatRoomModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatRoomModel(
      id: doc.id,
      participantIds: List<String>.from(data['participantIds'] ?? []),
      participantNames: Map<String, String>.from(data['participantNames'] ?? {}),
      missionId: data['missionId'],
      lastMessage: data['lastMessage'],
      lastMessageTime: (data['lastMessageTime'] as Timestamp?)?.toDate(),
      unreadCount: Map<String, int>.from(data['unreadCount'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'participantIds': participantIds,
      'participantNames': participantNames,
      'missionId': missionId,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime != null ? Timestamp.fromDate(lastMessageTime!) : null,
      'unreadCount': unreadCount,
    };
  }
}

/// Message model
class MessageModel {
  final String id;
  final String chatRoomId;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;
  final String type; // 'text', 'image', 'system'
  final String? imageUrl;

  const MessageModel({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    this.type = 'text',
    this.imageUrl,
  });

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageModel(
      id: doc.id,
      chatRoomId: data['chatRoomId'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      content: data['content'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      type: data['type'] ?? 'text',
      imageUrl: data['imageUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'chatRoomId': chatRoomId,
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'type': type,
      'imageUrl': imageUrl,
    };
  }
}

/// Transaction model for Solana conversions
class TransactionModel {
  final String id;
  final String oderId;
  final String type; // 'coin_to_sol', 'reward', 'nft_mint'
  final int coinsAmount;
  final double solAmount;
  final String status; // 'pending', 'completed', 'failed'
  final DateTime createdAt;
  final String? transactionHash;
  final String? description;

  const TransactionModel({
    required this.id,
    required this.oderId,
    required this.type,
    required this.coinsAmount,
    required this.solAmount,
    required this.status,
    required this.createdAt,
    this.transactionHash,
    this.description,
  });

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      oderId: data['userId'] ?? '',
      type: data['type'] ?? '',
      coinsAmount: data['coinsAmount'] ?? 0,
      solAmount: (data['solAmount'] ?? 0.0).toDouble(),
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      transactionHash: data['transactionHash'],
      description: data['description'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': oderId,
      'type': type,
      'coinsAmount': coinsAmount,
      'solAmount': solAmount,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'transactionHash': transactionHash,
      'description': description,
    };
  }
}
