import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../home/presentation/providers/providers.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(leaderboardProvider);
    final currentUser = ref.watch(userProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      const Icon(Icons.emoji_events, size: 48, color: Colors.white),
                      const SizedBox(height: 12),
                      const Text('Leaderboard', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text('Top Ocean Warriors', style: TextStyle(color: Colors.white.withAlpha(200))),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Current User Position
          if (currentUser != null)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withAlpha(50)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(child: Text(currentUser.name[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20))),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Your Ranking', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          const SizedBox(height: 4),
                          Text(currentUser.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${currentUser.xp} XP', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.xpColor, fontSize: 16)),
                        Text('Level ${currentUser.level}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          // Leaderboard List
          leaderboardAsync.when(
            data: (users) {
              if (users.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: Text('No players yet')),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final user = users[index];
                      final rank = index + 1;
                      final isCurrentUser = currentUser?.uid == user.uid;
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isCurrentUser ? AppColors.primary.withAlpha(15) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: isCurrentUser ? Border.all(color: AppColors.primary.withAlpha(50)) : null,
                          boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 5)],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 32,
                                child: Center(child: _buildRankWidget(rank)),
                              ),
                              const SizedBox(width: 12),
                              CircleAvatar(
                                backgroundColor: _getAvatarColor(rank),
                                radius: 22,
                                child: Text(
                                  user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  user.name,
                                  style: TextStyle(fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.w600),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(LevelTitles.getEmoji(user.level), style: const TextStyle(fontSize: 16)),
                            ],
                          ),
                          subtitle: Text('Level ${user.level} • ${user.totalCleanups} cleanups', style: const TextStyle(fontSize: 12)),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('${user.xp}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.xpColor)),
                              const Text('XP', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: users.length,
                  ),
                ),
              );
            },
            loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
            error: (e, _) => SliverFillRemaining(child: Center(child: Text('Error: $e'))),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildRankWidget(int rank) {
    if (rank == 1) return const Text('🥇', style: TextStyle(fontSize: 24));
    if (rank == 2) return const Text('🥈', style: TextStyle(fontSize: 24));
    if (rank == 3) return const Text('🥉', style: TextStyle(fontSize: 24));
    return Text('#$rank', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary));
  }

  Color _getAvatarColor(int rank) {
    if (rank == 1) return const Color(0xFFFFD700);
    if (rank == 2) return const Color(0xFFC0C0C0);
    if (rank == 3) return const Color(0xFFCD7F32);
    return AppColors.primary;
  }
}
