// lib/seed_data.dart
// =====================================================
// SEED DATA WITH WORKING IMAGE URLS
// =====================================================

import 'package:cloud_firestore/cloud_firestore.dart';

class SeedData {
  static Future<void> seed() async {
    final db = FirebaseFirestore.instance;
    
    print('🌊 TideUp: Starting seed...');
    
    final existing = await db.collection('missions').get();
    print('📊 Found ${existing.docs.length} existing missions');
    
    if (existing.docs.isNotEmpty) {
      print('⚠️ Missions exist. Deleting old missions first...');
      for (final doc in existing.docs) {
        await doc.reference.delete();
      }
      print('🗑️ Cleared existing missions');
    }

    final now = DateTime.now();
    int count = 0;

    // Working Unsplash image URLs (direct format)
    const beachImg1 = 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800&q=80';
    const beachImg2 = 'https://images.unsplash.com/photo-1519046904884-53103b34b206?w=800&q=80';
    const beachImg3 = 'https://images.unsplash.com/photo-1505142468610-359e7d316be0?w=800&q=80';
    const beachImg4 = 'https://images.unsplash.com/photo-1473116763249-2faaef81ccda?w=800&q=80';
    const beachImg5 = 'https://images.unsplash.com/photo-1510414842594-a61c69b5ae57?w=800&q=80';
    const beachImg6 = 'https://images.unsplash.com/photo-1471922694854-ff1b63b20054?w=800&q=80';
    const beachImg7 = 'https://images.unsplash.com/photo-1520942702018-0862200e6873?w=800&q=80';

    // Michigan Mission 1
    await db.collection('missions').add({
      'title': 'Grand Haven Beach Cleanup',
      'description': 'Join us at Grand Haven State Park for a morning beach cleanup. Beautiful Lake Michigan views! All supplies provided including gloves, bags, and refreshments.',
      'organizationId': 'seed_org_mi',
      'organizationName': 'Great Lakes Guardians',
      'location': {'lat': 43.0567, 'lng': -86.2556, 'address': 'Grand Haven State Park, MI'},
      'dateTime': Timestamp.fromDate(now.add(const Duration(days: 3))),
      'durationMinutes': 120,
      'createdAt': Timestamp.now(),
      'difficulty': 'easy',
      'status': 'upcoming',
      'xpReward': 100,
      'coinReward': 50,
      'maxParticipants': 50,
      'participants': [],
      'completedBy': [],
      'imageUrl': beachImg1,
      'targetTrashKg': 75.0,
      'collectedTrashKg': 0.0,
      'tags': ['michigan', 'lake-michigan', 'beginner-friendly'],
      'isDemo': false,
    });
    count++;
    print('✅ Added: Grand Haven Beach Cleanup');

    // Michigan Mission 2
    await db.collection('missions').add({
      'title': 'Holland State Park - Big Red',
      'description': 'Help clean up near the iconic Big Red Lighthouse! Medium difficulty with sandy terrain. All experience levels welcome.',
      'organizationId': 'seed_org_mi',
      'organizationName': 'Michigan Clean Shores',
      'location': {'lat': 42.7731, 'lng': -86.2106, 'address': 'Holland State Park, MI'},
      'dateTime': Timestamp.fromDate(now.add(const Duration(days: 5))),
      'durationMinutes': 150,
      'createdAt': Timestamp.now(),
      'difficulty': 'medium',
      'status': 'upcoming',
      'xpReward': 150,
      'coinReward': 75,
      'maxParticipants': 40,
      'participants': [],
      'completedBy': [],
      'imageUrl': beachImg2,
      'targetTrashKg': 100.0,
      'collectedTrashKg': 0.0,
      'tags': ['michigan', 'lighthouse'],
      'isDemo': false,
    });
    count++;
    print('✅ Added: Holland State Park');

    // Michigan Mission 3
    await db.collection('missions').add({
      'title': 'Sleeping Bear Dunes Challenge',
      'description': 'Advanced cleanup at Sleeping Bear Dunes National Lakeshore. Challenging sandy terrain but amazing views! Requires good fitness.',
      'organizationId': 'seed_org_mi',
      'organizationName': 'Great Lakes Guardians',
      'location': {'lat': 44.8654, 'lng': -86.0553, 'address': 'Sleeping Bear Dunes, Empire, MI'},
      'dateTime': Timestamp.fromDate(now.add(const Duration(days: 7))),
      'durationMinutes': 240,
      'createdAt': Timestamp.now(),
      'difficulty': 'hard',
      'status': 'upcoming',
      'xpReward': 200,
      'coinReward': 100,
      'maxParticipants': 25,
      'participants': [],
      'completedBy': [],
      'imageUrl': beachImg3,
      'targetTrashKg': 60.0,
      'collectedTrashKg': 0.0,
      'tags': ['michigan', 'national-park', 'advanced'],
      'isDemo': false,
    });
    count++;
    print('✅ Added: Sleeping Bear Dunes');

    // Michigan Mission 4
    await db.collection('missions').add({
      'title': 'Silver Beach Family Day',
      'description': 'Family-friendly cleanup at Silver Beach, St. Joseph. Games and prizes for kids! All equipment provided including kid-sized gloves.',
      'organizationId': 'seed_org_mi',
      'organizationName': 'Beach Buddies MI',
      'location': {'lat': 42.1125, 'lng': -86.4542, 'address': 'Silver Beach, St. Joseph, MI'},
      'dateTime': Timestamp.fromDate(now.add(const Duration(days: 10))),
      'durationMinutes': 90,
      'createdAt': Timestamp.now(),
      'difficulty': 'easy',
      'status': 'upcoming',
      'xpReward': 80,
      'coinReward': 40,
      'maxParticipants': 100,
      'participants': [],
      'completedBy': [],
      'imageUrl': beachImg4,
      'targetTrashKg': 120.0,
      'collectedTrashKg': 0.0,
      'tags': ['michigan', 'family', 'kids'],
      'isDemo': false,
    });
    count++;
    print('✅ Added: Silver Beach Family Day');

    // Michigan Mission 5
    await db.collection('missions').add({
      'title': 'Traverse City Beach Blitz',
      'description': 'Monthly community cleanup in beautiful Traverse City. Free T-shirts for all volunteers! Refreshments provided.',
      'organizationId': 'seed_org_mi',
      'organizationName': 'TC Clean Water',
      'location': {'lat': 44.7631, 'lng': -85.6206, 'address': 'Traverse City State Park, MI'},
      'dateTime': Timestamp.fromDate(now.add(const Duration(days: 12))),
      'durationMinutes': 180,
      'createdAt': Timestamp.now(),
      'difficulty': 'medium',
      'status': 'upcoming',
      'xpReward': 150,
      'coinReward': 75,
      'maxParticipants': 60,
      'participants': [],
      'completedBy': [],
      'imageUrl': beachImg5,
      'targetTrashKg': 100.0,
      'collectedTrashKg': 0.0,
      'tags': ['michigan', 'community'],
      'isDemo': false,
    });
    count++;
    print('✅ Added: Traverse City Beach Blitz');

    // California Mission 1
    await db.collection('missions').add({
      'title': 'Venice Beach Morning Cleanup',
      'description': 'Join us for a morning cleanup at iconic Venice Beach, LA. All supplies provided. Perfect for beginners!',
      'organizationId': 'seed_org_ca',
      'organizationName': 'Ocean Warriors LA',
      'location': {'lat': 33.985, 'lng': -118.469, 'address': 'Venice Beach, Los Angeles, CA'},
      'dateTime': Timestamp.fromDate(now.add(const Duration(days: 4))),
      'durationMinutes': 120,
      'createdAt': Timestamp.now(),
      'difficulty': 'easy',
      'status': 'upcoming',
      'xpReward': 100,
      'coinReward': 50,
      'maxParticipants': 30,
      'participants': [],
      'completedBy': [],
      'imageUrl': beachImg6,
      'targetTrashKg': 50.0,
      'collectedTrashKg': 0.0,
      'tags': ['california', 'la'],
      'isDemo': false,
    });
    count++;
    print('✅ Added: Venice Beach');

    // California Mission 2
    await db.collection('missions').add({
      'title': 'Santa Monica Pier Cleanup',
      'description': 'Clean up around the famous Santa Monica Pier. Medium difficulty with some rocky areas. Experience helpful but not required.',
      'organizationId': 'seed_org_ca',
      'organizationName': 'Clean Seas Foundation',
      'location': {'lat': 34.0083, 'lng': -118.4989, 'address': 'Santa Monica Pier, CA'},
      'dateTime': Timestamp.fromDate(now.add(const Duration(days: 6))),
      'durationMinutes': 180,
      'createdAt': Timestamp.now(),
      'difficulty': 'medium',
      'status': 'upcoming',
      'xpReward': 150,
      'coinReward': 75,
      'maxParticipants': 50,
      'participants': [],
      'completedBy': [],
      'imageUrl': beachImg7,
      'targetTrashKg': 80.0,
      'collectedTrashKg': 0.0,
      'tags': ['california', 'santa-monica'],
      'isDemo': false,
    });
    count++;
    print('✅ Added: Santa Monica Pier');

    print('');
    print('🎉 SUCCESS! Seeded $count missions with working images');
    print('');
    print('📱 NOW: Remove seed() call and restart app');
  }

  // Update existing missions with working image URLs
  static Future<void> fixImages() async {
    final db = FirebaseFirestore.instance;
    final missions = await db.collection('missions').get();
    
    print('🔧 Fixing image URLs for ${missions.docs.length} missions...');
    
    final workingUrls = [
      'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800&q=80',
      'https://images.unsplash.com/photo-1519046904884-53103b34b206?w=800&q=80',
      'https://images.unsplash.com/photo-1505142468610-359e7d316be0?w=800&q=80',
      'https://images.unsplash.com/photo-1473116763249-2faaef81ccda?w=800&q=80',
      'https://images.unsplash.com/photo-1510414842594-a61c69b5ae57?w=800&q=80',
      'https://images.unsplash.com/photo-1471922694854-ff1b63b20054?w=800&q=80',
      'https://images.unsplash.com/photo-1520942702018-0862200e6873?w=800&q=80',
    ];
    
    int i = 0;
    for (final doc in missions.docs) {
      await doc.reference.update({
        'imageUrl': workingUrls[i % workingUrls.length],
      });
      print('✅ Fixed: ${doc.data()['title']}');
      i++;
    }
    
    print('🎉 Done! All images fixed.');
  }
}
