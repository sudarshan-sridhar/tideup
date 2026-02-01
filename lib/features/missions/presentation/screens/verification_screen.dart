import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../home/presentation/providers/providers.dart';

class VerificationScreen extends ConsumerWidget {
  const VerificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final pendingAsync = ref.watch(pendingCheckInsProvider(user?.uid ?? ''));

    return Scaffold(
      appBar: AppBar(title: const Text('Verify Check-ins')),
      body: pendingAsync.when(
        data: (checkIns) => checkIns.isEmpty
            ? const EmptyState(icon: Icons.check_circle, title: 'All caught up!', subtitle: 'No pending verifications')
            : ListView.builder(padding: const EdgeInsets.all(16), itemCount: checkIns.length, itemBuilder: (_, i) {
                final c = checkIns[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      CircleAvatar(backgroundColor: AppColors.primary, child: Text(c.userName[0], style: const TextStyle(color: Colors.white))),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(c.userName, style: const TextStyle(fontWeight: FontWeight.bold)), Text(DateFormat('MMM d, h:mm a').format(c.checkInTime), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))])),
                      if (c.aiConfidenceScore != null) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: c.aiConfidenceScore! >= 0.7 ? AppColors.successLight : AppColors.warningLight, borderRadius: BorderRadius.circular(8)), child: Text('AI: ${(c.aiConfidenceScore! * 100).toStringAsFixed(0)}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: c.aiConfidenceScore! >= 0.7 ? AppColors.success : AppColors.warning))),
                    ]),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(8), child: c.beforePhotoUrl != null ? CachedNetworkImage(imageUrl: c.beforePhotoUrl!, height: 100, fit: BoxFit.cover) : Container(height: 100, color: AppColors.muted, child: const Icon(Icons.image)))),
                      const SizedBox(width: 8),
                      Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(8), child: c.afterPhotoUrl != null ? CachedNetworkImage(imageUrl: c.afterPhotoUrl!, height: 100, fit: BoxFit.cover) : Container(height: 100, color: AppColors.muted, child: const Icon(Icons.image)))),
                    ]),
                    if (c.aiAnalysis != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(c.aiAnalysis!, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(child: OutlinedButton(onPressed: () => _verify(ref, c.id, false), child: const Text('Reject'), style: OutlinedButton.styleFrom(foregroundColor: AppColors.error))),
                      const SizedBox(width: 12),
                      Expanded(child: ElevatedButton(onPressed: () => _verify(ref, c.id, true), child: const Text('Approve'), style: ElevatedButton.styleFrom(backgroundColor: AppColors.success))),
                    ]),
                  ])),
                );
              }),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Future<void> _verify(WidgetRef ref, String checkInId, bool approve) async {
    final checkIn = await ref.read(firebaseServiceProvider).getCheckIn(checkInId);
    if (checkIn == null) return;
    final mission = await ref.read(firebaseServiceProvider).getMission(checkIn.missionId);
    if (mission == null) return;
    final user = ref.read(userProvider);
    await ref.read(firebaseServiceProvider).verifyCheckIn(
      checkInId: checkInId, verifiedBy: user?.uid ?? '', status: approve ? 'verified' : 'rejected',
      xpAwarded: approve ? mission.xpReward : 0, coinsAwarded: approve ? mission.coinReward : 0, trashCollectedKg: approve ? 1.5 : null,
    );
  }
}
