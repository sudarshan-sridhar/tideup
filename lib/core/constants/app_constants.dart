class AppConstants {
  // Collections
  static const String usersCollection = 'users';
  static const String missionsCollection = 'missions';
  static const String checkInsCollection = 'checkIns';
  static const String postsCollection = 'posts';
  static const String chatsCollection = 'chats';
  static const String transactionsCollection = 'transactions';
  static const String notificationsCollection = 'notifications';

  // Storage paths
  static const String profileImagesPath = 'profile_images';
  static const String missionImagesPath = 'mission_images';
  static const String cleanupProofsPath = 'cleanup_proofs';
  static const String postImagesPath = 'post_images';

  // Michigan locations
  static const List<Map<String, dynamic>> michiganLocations = [
    {'name': 'Grand Haven State Park', 'lat': 43.0567, 'lng': -86.2556, 'address': 'Grand Haven State Park, MI', 'region': 'Michigan'},
    {'name': 'Holland State Park', 'lat': 42.7731, 'lng': -86.2106, 'address': 'Holland State Park, MI', 'region': 'Michigan'},
    {'name': 'Sleeping Bear Dunes', 'lat': 44.8654, 'lng': -86.0553, 'address': 'Sleeping Bear Dunes, Empire, MI', 'region': 'Michigan'},
    {'name': 'Warren Dunes State Park', 'lat': 41.9064, 'lng': -86.5992, 'address': 'Warren Dunes State Park, Sawyer, MI', 'region': 'Michigan'},
    {'name': 'Silver Beach', 'lat': 42.1125, 'lng': -86.4542, 'address': 'Silver Beach, St. Joseph, MI', 'region': 'Michigan'},
    {'name': 'Ludington State Park', 'lat': 44.0420, 'lng': -86.5089, 'address': 'Ludington State Park, MI', 'region': 'Michigan'},
    {'name': 'Traverse City Beach', 'lat': 44.7631, 'lng': -85.6206, 'address': 'Traverse City State Park, MI', 'region': 'Michigan'},
    {'name': 'Belle Isle', 'lat': 42.3436, 'lng': -82.9686, 'address': 'Belle Isle, Detroit, MI', 'region': 'Michigan'},
  ];

  // California locations
  static const List<Map<String, dynamic>> californiaLocations = [
    {'name': 'Santa Monica State Beach', 'lat': 34.0195, 'lng': -118.4912, 'address': 'Santa Monica State Beach, CA', 'region': 'California'},
    {'name': 'Venice Beach', 'lat': 33.9850, 'lng': -118.4695, 'address': 'Venice Beach, Los Angeles, CA', 'region': 'California'},
    {'name': 'Malibu Lagoon State Beach', 'lat': 34.0345, 'lng': -118.6801, 'address': 'Malibu Lagoon State Beach, CA', 'region': 'California'},
    {'name': 'Manhattan Beach', 'lat': 33.8847, 'lng': -118.4109, 'address': 'Manhattan Beach, CA', 'region': 'California'},
    {'name': 'Long Beach', 'lat': 33.7701, 'lng': -118.1937, 'address': 'Long Beach, CA', 'region': 'California'},
  ];

  // Combined (Michigan first)
  static List<Map<String, dynamic>> get demoLocations => [...michiganLocations, ...californiaLocations];
}

class XpCalculator {
  static const List<int> levelThresholds = [0, 100, 250, 500, 850, 1300, 1900, 2600, 3500, 4600, 5900, 7400, 9200, 11300, 13700, 16500, 19700, 23300, 27400, 32000];

  static int getLevelFromXp(int xp) {
    for (int i = levelThresholds.length - 1; i >= 0; i--) {
      if (xp >= levelThresholds[i]) return i + 1;
    }
    return 1;
  }

  static int getXpForNextLevel(int level) => level >= levelThresholds.length ? levelThresholds.last : levelThresholds[level];
  static int getXpForCurrentLevel(int level) => level <= 1 ? 0 : levelThresholds[level - 1];

  static double getProgressToNextLevel(int xp, int level) {
    if (level >= levelThresholds.length) return 1.0;
    final current = levelThresholds[level - 1];
    final next = levelThresholds[level];
    return (xp - current) / (next - current);
  }

  static int getXpNeededForNextLevel(int xp, int level) => level >= levelThresholds.length ? 0 : levelThresholds[level] - xp;

  static int calculateXp(String difficulty) => difficulty == 'easy' ? 100 : difficulty == 'hard' ? 200 : 150;
  static int calculateCoins(String difficulty) => difficulty == 'easy' ? 50 : difficulty == 'hard' ? 100 : 75;
}

class LevelTitles {
  static String getTitle(int level) {
    if (level <= 2) return 'Beach Newbie';
    if (level <= 4) return 'Wave Walker';
    if (level <= 6) return 'Sand Sweeper';
    if (level <= 8) return 'Tide Turner';
    if (level <= 10) return 'Ocean Guardian';
    if (level <= 12) return 'Reef Protector';
    if (level <= 14) return 'Marine Champion';
    if (level <= 16) return 'Sea Sentinel';
    if (level <= 18) return 'Coastal Hero';
    return 'Ocean Legend';
  }

  static String getEmoji(int level) {
    if (level <= 2) return '🐚';
    if (level <= 4) return '🦀';
    if (level <= 6) return '🐠';
    if (level <= 8) return '🐬';
    if (level <= 10) return '🦈';
    if (level <= 12) return '🐋';
    if (level <= 14) return '🧜';
    if (level <= 16) return '🔱';
    if (level <= 18) return '👑';
    return '🌊';
  }

  static String getReward(int level) {
    switch (level) {
      case 2: return '🎁 Basic profile badge';
      case 5: return '🎁 10% bonus coins';
      case 7: return '🎁 Hard missions access';
      case 10: return '🎁 20% bonus XP';
      case 15: return '🎁 Exclusive avatar frame';
      case 20: return '🎁 Ocean Legend badge';
      default: return '';
    }
  }
}

class Achievements {
  static const List<Map<String, dynamic>> all = [
    {'id': 'first_cleanup', 'name': 'First Wave', 'description': 'Complete first cleanup', 'icon': '🌊', 'xpReward': 50},
    {'id': 'cleanup_5', 'name': 'Ocean Friend', 'description': 'Complete 5 cleanups', 'icon': '🐠', 'xpReward': 100},
    {'id': 'cleanup_10', 'name': 'Beach Hero', 'description': 'Complete 10 cleanups', 'icon': '🦸', 'xpReward': 200},
    {'id': 'trash_1kg', 'name': 'Litter Lifter', 'description': 'Collect 1kg trash', 'icon': '🗑️', 'xpReward': 50},
    {'id': 'trash_10kg', 'name': 'Trash Terminator', 'description': 'Collect 10kg trash', 'icon': '💪', 'xpReward': 150},
    {'id': 'streak_3', 'name': 'Committed', 'description': '3-day streak', 'icon': '🔥', 'xpReward': 75},
    {'id': 'streak_7', 'name': 'Dedicated', 'description': '7-day streak', 'icon': '⭐', 'xpReward': 200},
    {'id': 'first_post', 'name': 'Storyteller', 'description': 'Share first post', 'icon': '📝', 'xpReward': 25},
    {'id': 'level_5', 'name': 'Rising Tide', 'description': 'Reach level 5', 'icon': '📈', 'xpReward': 100},
    {'id': 'level_10', 'name': 'Ocean Master', 'description': 'Reach level 10', 'icon': '🎯', 'xpReward': 300},
  ];
}

class MarketplaceItems {
  static const List<Map<String, dynamic>> items = [
    {'id': 'amazon_5', 'name': '\$5 Amazon Gift Card', 'description': 'Redeem for a \$5 Amazon.com gift card', 'icon': '🛒', 'price': 500, 'category': 'gift_card', 'brand': 'Amazon', 'value': 5.00},
    {'id': 'amazon_10', 'name': '\$10 Amazon Gift Card', 'description': 'Redeem for a \$10 Amazon.com gift card', 'icon': '🛒', 'price': 950, 'category': 'gift_card', 'brand': 'Amazon', 'value': 10.00},
    {'id': 'target_5', 'name': '\$5 Target Gift Card', 'description': 'Redeem for a \$5 Target gift card', 'icon': '🎯', 'price': 500, 'category': 'gift_card', 'brand': 'Target', 'value': 5.00},
    {'id': 'starbucks_5', 'name': '\$5 Starbucks Gift Card', 'description': 'Redeem for a \$5 Starbucks gift card', 'icon': '☕', 'price': 500, 'category': 'gift_card', 'brand': 'Starbucks', 'value': 5.00},
    {'id': 'meijer_10', 'name': '\$10 Meijer Gift Card', 'description': 'Michigan local grocery store', 'icon': '🛒', 'price': 950, 'category': 'gift_card', 'brand': 'Meijer', 'value': 10.00},
    {'id': 'cleanup_kit', 'name': 'TideUp Cleanup Kit', 'description': 'Eco-friendly gloves, bags & grabber tool', 'icon': '🧤', 'price': 300, 'category': 'merch', 'brand': 'TideUp', 'value': 15.00},
    {'id': 'tideup_tshirt', 'name': 'TideUp T-Shirt', 'description': 'Organic cotton Ocean Warrior tee', 'icon': '👕', 'price': 400, 'category': 'merch', 'brand': 'TideUp', 'value': 20.00},
    {'id': 'water_bottle', 'name': 'Reusable Water Bottle', 'description': 'Stainless steel TideUp bottle', 'icon': '🍶', 'price': 350, 'category': 'merch', 'brand': 'TideUp', 'value': 18.00},
  ];
}

class DemoDefaults {
  static const Map<String, dynamic> player = {
    'xp': 2450, 'level': 7, 'coins': 850, 'totalCleanups': 23, 'totalTrashKg': 45.5,
    'currentStreak': 5, 'longestStreak': 12, 'solanaBalance': 0.0234, 'totalCoinsConverted': 500,
    'achievements': ['first_cleanup', 'cleanup_5', 'cleanup_10', 'trash_1kg', 'trash_10kg', 'streak_3', 'first_post', 'level_5'],
  };
  static const Map<String, dynamic> organization = {'totalMissionsCreated': 15, 'totalVolunteers': 342};
}
