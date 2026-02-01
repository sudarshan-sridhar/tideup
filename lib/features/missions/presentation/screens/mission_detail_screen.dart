import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../home/presentation/providers/providers.dart';
import 'checkin_screen.dart';

class MissionDetailScreen extends ConsumerWidget {
  final String missionId;
  const MissionDetailScreen({super.key, required this.missionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final missionAsync = ref.watch(missionStreamProvider(missionId));
    final user = ref.watch(userProvider);

    return missionAsync.when(
      data: (mission) {
        if (mission == null) return const Scaffold(body: Center(child: Text('Mission not found')));

        final isJoined = mission.isUserJoined(user?.uid);
        final isCompleted = mission.isUserCompleted(user?.uid);
        final spotsLeft = mission.maxParticipants - mission.participants.length;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: _MissionImage(imageUrl: mission.imageUrl),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title & Difficulty
                      Row(
                        children: [
                          Expanded(child: Text(mission.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
                          DifficultyBadge(difficulty: mission.difficulty),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Organization
                      Row(
                        children: [
                          CircleAvatar(radius: 16, backgroundColor: AppColors.primary.withAlpha(30), child: const Icon(Icons.business, size: 16, color: AppColors.primary)),
                          const SizedBox(width: 8),
                          Text(mission.organizationName, style: const TextStyle(color: AppColors.textSecondary)),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Info Cards
                      Row(
                        children: [
                          Expanded(child: _InfoCard(icon: Icons.calendar_today, title: 'Date', value: DateFormat('MMM d, yyyy').format(mission.dateTime))),
                          const SizedBox(width: 12),
                          Expanded(child: _InfoCard(icon: Icons.access_time, title: 'Time', value: DateFormat('h:mm a').format(mission.dateTime))),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _InfoCard(icon: Icons.timer, title: 'Duration', value: '${mission.durationMinutes} min')),
                          const SizedBox(width: 12),
                          Expanded(child: _InfoCard(icon: Icons.people, title: 'Spots', value: '$spotsLeft left')),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Location
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: AppColors.muted, borderRadius: BorderRadius.circular(16)),
                        child: Row(
                          children: [
                            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.primary.withAlpha(30), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.location_on, color: AppColors.primary)),
                            const SizedBox(width: 12),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              const Text('Location', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                              Text(mission.address, style: const TextStyle(fontWeight: FontWeight.w600)),
                            ])),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Rewards
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(gradient: AppColors.goldGradient, borderRadius: BorderRadius.circular(16)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(children: [
                              const Icon(Icons.star, color: Colors.white, size: 32),
                              const SizedBox(height: 4),
                              Text('${mission.xpReward} XP', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                            ]),
                            Container(width: 1, height: 50, color: Colors.white30),
                            Column(children: [
                              const Icon(Icons.monetization_on, color: Colors.white, size: 32),
                              const SizedBox(height: 4),
                              Text('${mission.coinReward} Coins', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                            ]),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Description
                      const Text('About this Mission', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(mission.description, style: const TextStyle(color: AppColors.textSecondary, height: 1.5)),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 10, offset: const Offset(0, -5))]),
            child: SafeArea(
              child: isCompleted
                  ? Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AppColors.successLight, borderRadius: BorderRadius.circular(12)),
                      child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.check_circle, color: AppColors.success), SizedBox(width: 8), Text('Completed!', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold))]),
                    )
                  : isJoined
                      ? Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _leaveMission(context, ref, user?.uid),
                                child: const Text('Leave'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: ElevatedButton(
                                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CheckInScreen(missionId: missionId))),
                                child: const Text('Check In'),
                              ),
                            ),
                          ],
                        )
                      : ElevatedButton(
                          onPressed: spotsLeft > 0 ? () => _joinMission(context, ref, user?.uid) : null,
                          style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52)),
                          child: Text(spotsLeft > 0 ? 'Join Mission' : 'Mission Full'),
                        ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }

  Future<void> _joinMission(BuildContext context, WidgetRef ref, String? uid) async {
    if (uid == null) return;
    try {
      await ref.read(firebaseServiceProvider).joinMission(missionId, uid);
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Joined mission! 🎉'), backgroundColor: AppColors.success));
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
    }
  }

  Future<void> _leaveMission(BuildContext context, WidgetRef ref, String? uid) async {
    if (uid == null) return;
    try {
      await ref.read(firebaseServiceProvider).leaveMission(missionId, uid);
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Left mission')));
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
    }
  }
}

// Image widget with error handling and fallback
class _MissionImage extends StatelessWidget {
  final String? imageUrl;

  const _MissionImage({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildFallback();
    }

    return Image.network(
      imageUrl!,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          decoration: const BoxDecoration(gradient: AppColors.oceanGradient),
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
              color: Colors.white,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        // Image failed to load - show fallback
        return _buildFallback();
      },
    );
  }

  Widget _buildFallback() {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.oceanGradient),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.waves, size: 64, color: Colors.white54),
            SizedBox(height: 8),
            Text('TideUp Mission', style: TextStyle(color: Colors.white54, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoCard({required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.muted, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
