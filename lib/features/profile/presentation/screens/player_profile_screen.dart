import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../home/presentation/providers/providers.dart';
import '../../../wallet/presentation/screens/wallet_screen.dart';
import '../../../marketplace/presentation/screens/marketplace_screen.dart';
import '../../../ai_assistant/presentation/screens/ai_chat_screen.dart';
import 'edit_profile_screen.dart';

class PlayerProfileScreen extends ConsumerWidget {
  const PlayerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    if (user == null) return const Center(child: CircularProgressIndicator());

    final progress = XpCalculator.getProgressToNextLevel(user.xp, user.level);
    final xpNeeded = XpCalculator.getXpNeededForNextLevel(user.xp, user.level);
    final currentLevelXp = XpCalculator.getXpForCurrentLevel(user.level);
    final nextLevelXp = XpCalculator.getXpForNextLevel(user.level);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            actions: [
              IconButton(icon: const Icon(Icons.edit, color: Colors.white), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()))),
              IconButton(icon: const Icon(Icons.logout, color: Colors.white), onPressed: () => _signOut(context, ref)),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: Colors.white,
                          child: Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary)),
                        ),
                        const SizedBox(height: 10),
                        Text(user.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 6),

                        // LEVEL BADGE
                        GestureDetector(
                          onTap: () => _showLevelSheet(context, user.level, user.xp),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(40),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(LevelTitles.getEmoji(user.level), style: const TextStyle(fontSize: 16)),
                                const SizedBox(width: 6),
                                Text('Level ${user.level} • ${LevelTitles.getTitle(user.level)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
                                const SizedBox(width: 4),
                                const Icon(Icons.info_outline, color: Colors.white70, size: 14),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // XP Progress Bar - FIXED: No overflow
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${user.xp} XP', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                Text('$xpNeeded XP to Level ${user.level + 1}', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: progress.clamp(0.0, 1.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('$currentLevelXp', style: const TextStyle(color: Colors.white54, fontSize: 9)),
                                Text('$nextLevelXp', style: const TextStyle(color: Colors.white54, fontSize: 9)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      _StatsCard(title: 'Total XP', value: '${user.xp}', icon: Icons.star, color: AppColors.xpColor),
                      _StatsCard(title: 'Coins', value: '${user.coins}', icon: Icons.monetization_on, color: AppColors.coinColor),
                      _StatsCard(title: 'Cleanups', value: '${user.totalCleanups}', icon: Icons.waves, color: AppColors.primary),
                      _StatsCard(title: 'Trash (kg)', value: user.totalTrashKg.toStringAsFixed(1), icon: Icons.delete, color: AppColors.accent),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Solana Wallet Card
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletScreen())),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(gradient: AppColors.solanaGradient, borderRadius: BorderRadius.circular(16)),
                      child: Row(
                        children: [
                          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 22)),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Solana Wallet', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                Text('${user.solanaBalance.toStringAsFixed(4)} SOL', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Achievements
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Achievements', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () => _showAchievementsSheet(context, user.achievements),
                        child: Text('${user.achievements.length}/${Achievements.all.length}'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: Achievements.all.length > 5 ? 5 : Achievements.all.length,
                      itemBuilder: (_, i) {
                        final a = Achievements.all[i];
                        final unlocked = user.achievements.contains(a['id']);
                        return Container(
                          width: 70,
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: unlocked ? Colors.white : AppColors.muted,
                            borderRadius: BorderRadius.circular(12),
                            border: unlocked ? Border.all(color: AppColors.primary.withAlpha(50)) : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(a['icon'] as String, style: TextStyle(fontSize: 22, color: unlocked ? null : Colors.grey)),
                              const SizedBox(height: 4),
                              Text(
                                a['name'] as String,
                                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: unlocked ? AppColors.textPrimary : AppColors.textLight),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Buttons
                  OutlinedButton.icon(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MarketplaceScreen())),
                    icon: const Icon(Icons.storefront),
                    label: const Text('Rewards Marketplace'),
                    style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 46)),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AiChatScreen())),
                    icon: const Icon(Icons.smart_toy),
                    label: const Text('AI Assistant'),
                    style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 46)),
                  ),

                  // Reset Demo Button (only show for demo accounts)
                  if (user.isDemo) ...[
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () => _resetDemoAccount(context, ref),
                      icon: const Icon(Icons.refresh, color: AppColors.warning),
                      label: const Text('Reset Demo Stats', style: TextStyle(color: AppColors.warning)),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 46),
                        side: const BorderSide(color: AppColors.warning),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Resets to: 850 coins, Level 7, 23 cleanups',
                      style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLevelSheet(BuildContext context, int currentLevel, int currentXp) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (_, controller) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 16),
                  const Text('Level Progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: controller,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 20,
                itemBuilder: (_, i) {
                  final level = i + 1;
                  final isCurrentLevel = level == currentLevel;
                  final isUnlocked = level <= currentLevel;
                  final xpNeeded = XpCalculator.levelThresholds[i];
                  final reward = LevelTitles.getReward(level);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isCurrentLevel ? AppColors.primary.withAlpha(20) : (isUnlocked ? Colors.white : AppColors.muted),
                      borderRadius: BorderRadius.circular(14),
                      border: isCurrentLevel ? Border.all(color: AppColors.primary, width: 2) : null,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isUnlocked ? AppColors.primary.withAlpha(30) : AppColors.muted,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: isUnlocked
                                ? Text(LevelTitles.getEmoji(level), style: const TextStyle(fontSize: 20))
                                : const Icon(Icons.lock, color: AppColors.textLight, size: 18),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text('Level $level', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isUnlocked ? AppColors.textPrimary : AppColors.textLight)),
                                  if (isCurrentLevel) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(6)),
                                      child: const Text('YOU', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ],
                              ),
                              Text(LevelTitles.getTitle(level), style: TextStyle(fontSize: 11, color: isUnlocked ? AppColors.textSecondary : AppColors.textLight)),
                              if (reward.isNotEmpty)
                                Text(reward, style: const TextStyle(fontSize: 10, color: AppColors.success)),
                            ],
                          ),
                        ),
                        Text('$xpNeeded XP', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: isUnlocked ? AppColors.xpColor : AppColors.textLight)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAchievementsSheet(BuildContext context, List<String> unlockedIds) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.85,
        minChildSize: 0.4,
        expand: false,
        builder: (_, controller) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 16),
                  Text('Achievements (${unlockedIds.length}/${Achievements.all.length})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                controller: controller,
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 0.95),
                itemCount: Achievements.all.length,
                itemBuilder: (_, i) {
                  final a = Achievements.all[i];
                  final unlocked = unlockedIds.contains(a['id']);
                  return Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: unlocked ? Colors.white : AppColors.muted,
                      borderRadius: BorderRadius.circular(14),
                      border: unlocked ? Border.all(color: AppColors.primary.withAlpha(50)) : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(a['icon'] as String, style: TextStyle(fontSize: 26, color: unlocked ? null : Colors.grey)),
                        const SizedBox(height: 4),
                        Text(a['name'] as String, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: unlocked ? AppColors.textPrimary : AppColors.textLight), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                        if (!unlocked) const Icon(Icons.lock, size: 10, color: AppColors.textLight),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _resetDemoAccount(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Demo Stats?'),
        content: const Text('This will restore:\n\n• 850 Coins\n• Level 7 (2,450 XP)\n• 23 Cleanups'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final user = ref.read(userProvider);
        if (user == null) return;
        await ref.read(firebaseServiceProvider).resetDemoAccount(user.uid, isPlayer: user.role == 'player');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Demo stats reset! 🔄'), backgroundColor: AppColors.success),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
        }
      }
    }
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sign Out')),
        ],
      ),
    );
    if (confirm == true) await ref.read(firebaseServiceProvider).signOut();
  }
}

class _StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatsCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 10)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: color.withAlpha(30), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 18)),
          const Spacer(),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          Text(title, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
