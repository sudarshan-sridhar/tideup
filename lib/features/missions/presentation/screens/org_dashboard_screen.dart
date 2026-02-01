import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../home/presentation/providers/providers.dart';
import '../../data/models/mission_model.dart';
import 'create_mission_screen.dart';
import 'mission_detail_screen.dart';
import 'verification_screen.dart';

class OrgDashboardScreen extends ConsumerStatefulWidget {
  const OrgDashboardScreen({super.key});
  @override
  ConsumerState<OrgDashboardScreen> createState() => _OrgDashboardScreenState();
}

class _OrgDashboardScreenState extends ConsumerState<OrgDashboardScreen> {
  
  // Force refresh the missions list
  void _refreshMissions() {
    final user = ref.read(userProvider);
    if (user != null) {
      // Invalidate the provider to force a refetch
      ref.invalidate(organizationMissionsProvider(user.uid));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    if (user == null) return const Center(child: CircularProgressIndicator());

    final missionsAsync = ref.watch(organizationMissionsProvider(user.uid));
    final pendingCheckIns = ref.watch(pendingCheckInsProvider(user.uid));

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          _refreshMissions();
          // Wait a bit for the refresh to complete
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: CustomScrollView(
          slivers: [
            // Header
            SliverAppBar(
              expandedHeight: 180,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(gradient: AppColors.oceanGradient),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.organizationName ?? user.name,
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.event, color: Colors.white70, size: 16),
                              const SizedBox(width: 4),
                              Text('${user.totalMissionsCreated} Missions', style: const TextStyle(color: Colors.white70)),
                              const SizedBox(width: 16),
                              const Icon(Icons.people, color: Colors.white70, size: 16),
                              const SizedBox(width: 4),
                              Text('${user.totalVolunteers} Volunteers', style: const TextStyle(color: Colors.white70)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              actions: [
                // Refresh button in app bar
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: _refreshMissions,
                  tooltip: 'Refresh missions',
                ),
              ],
            ),

            // Pending Verifications Alert
            pendingCheckIns.when(
              data: (checkIns) => checkIns.isEmpty
                  ? const SliverToBoxAdapter(child: SizedBox.shrink())
                  : SliverToBoxAdapter(
                      child: GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VerificationScreen())),
                        child: Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.warningLight,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.warning),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(color: AppColors.warning, borderRadius: BorderRadius.circular(12)),
                                child: const Icon(Icons.pending_actions, color: Colors.white),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${checkIns.length} Pending Verification${checkIns.length > 1 ? 's' : ''}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    const Text('Tap to review check-ins', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.warning),
                            ],
                          ),
                        ),
                      ),
                    ),
              loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
              error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
            ),

            // Your Missions Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Your Missions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    TextButton.icon(
                      onPressed: () async {
                        // Navigate to create mission screen and wait for result
                        await Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateMissionScreen()));
                        // Refresh missions after returning
                        _refreshMissions();
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Create'),
                    ),
                  ],
                ),
              ),
            ),

            // Debug info (only in debug mode)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Your Org ID: ${user.uid.substring(0, 12)}...',
                  style: const TextStyle(fontSize: 10, color: AppColors.textLight),
                ),
              ),
            ),

            // Missions List
            missionsAsync.when(
              data: (missions) {
                if (missions.isEmpty) {
                  return SliverFillRemaining(
                    child: EmptyState(
                      icon: Icons.event,
                      title: 'No missions yet',
                      subtitle: 'Create your first cleanup event!\n\nPull down to refresh after creating.',
                      actionLabel: 'Create Mission',
                      onAction: () async {
                        await Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateMissionScreen()));
                        _refreshMissions();
                      },
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _MissionTile(
                        mission: missions[index],
                        onDeleted: _refreshMissions,
                      ),
                      childCount: missions.length,
                    ),
                  ),
                );
              },
              loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
              error: (e, _) => SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $e'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _refreshMissions,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'org_dashboard_fab',  // Unique hero tag to avoid conflicts
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateMissionScreen()));
          _refreshMissions();
        },
        icon: const Icon(Icons.add),
        label: const Text('New Mission'),
      ),
    );
  }
}

class _MissionTile extends ConsumerWidget {
  final MissionModel mission;
  final VoidCallback onDeleted;

  const _MissionTile({required this.mission, required this.onDeleted});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MissionDetailScreen(missionId: mission.id))),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.muted,
                  borderRadius: BorderRadius.circular(12),
                  image: mission.imageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(mission.imageUrl!), 
                          fit: BoxFit.cover,
                          onError: (_, __) {},
                        )
                      : null,
                ),
                child: mission.imageUrl == null ? const Icon(Icons.waves, color: AppColors.primary) : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(mission.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(DateFormat('MMM d, h:mm a').format(mission.dateTime), style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        DifficultyBadge(difficulty: mission.difficulty, small: true),
                        const SizedBox(width: 8),
                        Text('${mission.participants.length}/${mission.maxParticipants} joined', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
                onSelected: (value) async {
                  if (value == 'delete') await _deleteMission(context, ref);
                  if (value == 'view') Navigator.push(context, MaterialPageRoute(builder: (_) => MissionDetailScreen(missionId: mission.id)));
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(value: 'view', child: Row(children: [Icon(Icons.visibility, size: 20), SizedBox(width: 8), Text('View Details')])),
                  const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: AppColors.error, size: 20), SizedBox(width: 8), Text('Delete', style: TextStyle(color: AppColors.error))])),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteMission(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Mission'),
        content: Text('Are you sure you want to delete "${mission.title}"? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: AppColors.error))),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(firebaseServiceProvider).deleteMission(mission.id);
        // Call the callback to refresh
        onDeleted();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mission deleted'), backgroundColor: AppColors.success));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
        }
      }
    }
  }
}
