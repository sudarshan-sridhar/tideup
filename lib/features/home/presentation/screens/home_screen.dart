import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../providers/providers.dart';
import '../../../missions/presentation/screens/mission_detail_screen.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final missionsAsync = ref.watch(upcomingMissionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppColors.primary.withAlpha(20), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.waves, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            const Text('TideUp', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(upcomingMissionsProvider);
          // Debug: print missions to console
          await ref.read(firebaseServiceProvider).debugPrintMissions();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Welcome Card
            if (user != null)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(gradient: AppColors.oceanGradient, borderRadius: BorderRadius.circular(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Welcome back, ${user.name.split(' ').first}!', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                              Text('Level ${user.level} • ${user.xp} XP', style: const TextStyle(color: Colors.white70)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatItem(icon: Icons.star, value: '${user.xp}', label: 'XP'),
                        _StatItem(icon: Icons.monetization_on, value: '${user.coins}', label: 'Coins'),
                        _StatItem(icon: Icons.waves, value: '${user.totalCleanups}', label: 'Cleanups'),
                      ],
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),

            // Upcoming Missions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Upcoming Missions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () => ref.invalidate(upcomingMissionsProvider),
                  child: const Text('Refresh'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            missionsAsync.when(
              data: (missions) {
                if (missions.isEmpty) {
                  return Column(
                    children: [
                      const EmptyState(
                        icon: Icons.event,
                        title: 'No missions found',
                        subtitle: 'Pull down to refresh or check your Firestore database',
                      ),
                      const SizedBox(height: 16),
                      // Debug button
                      OutlinedButton.icon(
                        onPressed: () async {
                          await ref.read(firebaseServiceProvider).debugPrintMissions();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Check console/logcat for debug output')),
                            );
                          }
                        },
                        icon: const Icon(Icons.bug_report),
                        label: const Text('Debug: Print All Missions'),
                      ),
                    ],
                  );
                }
                return Column(
                  children: [
                    Text('Found ${missions.length} missions', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    const SizedBox(height: 8),
                    ...missions.take(10).map((mission) => MissionCard(
                      title: mission.title,
                      location: mission.address,
                      difficulty: mission.difficulty,
                      xpReward: mission.xpReward,
                      coinReward: mission.coinReward,
                      imageUrl: mission.imageUrl,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MissionDetailScreen(missionId: mission.id))),
                    )),
                  ],
                );
              },
              loading: () => const Center(child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              )),
              error: (e, stack) => Column(
                children: [
                  const Icon(Icons.error, color: AppColors.error, size: 48),
                  const SizedBox(height: 16),
                  Text('Error loading missions', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('$e', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(upcomingMissionsProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}
