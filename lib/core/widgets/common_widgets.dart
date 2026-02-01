import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({super.key, required this.icon, required this.title, required this.subtitle, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.muted, shape: BoxShape.circle),
              child: Icon(icon, size: 48, color: AppColors.textLight),
            ),
            const SizedBox(height: 20),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(subtitle, style: const TextStyle(color: AppColors.textSecondary), textAlign: TextAlign.center),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              ElevatedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

class DifficultyBadge extends StatelessWidget {
  final String difficulty;
  final bool small;

  const DifficultyBadge({super.key, required this.difficulty, this.small = false});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (difficulty.toLowerCase()) {
      case 'easy': color = AppColors.difficultyEasy; break;
      case 'hard': color = AppColors.difficultyHard; break;
      default: color = AppColors.difficultyMedium;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: small ? 8 : 12, vertical: small ? 2 : 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(small ? 6 : 8)),
      child: Text(difficulty.toUpperCase(), style: TextStyle(color: Colors.white, fontSize: small ? 10 : 12, fontWeight: FontWeight.bold)),
    );
  }
}

class XpProgressBar extends StatelessWidget {
  final int currentXp;
  final int level;

  const XpProgressBar({super.key, required this.currentXp, required this.level});

  @override
  Widget build(BuildContext context) {
    final nextLevelXp = level < 20 ? [0, 100, 250, 500, 850, 1300, 1900, 2600, 3500, 4600, 5900, 7400, 9200, 11300, 13700, 16500, 19700, 23300, 27400, 32000][level] : 32000;
    final prevLevelXp = level > 1 ? [0, 100, 250, 500, 850, 1300, 1900, 2600, 3500, 4600, 5900, 7400, 9200, 11300, 13700, 16500, 19700, 23300, 27400, 32000][level - 1] : 0;
    final progress = (currentXp - prevLevelXp) / (nextLevelXp - prevLevelXp);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Level $level', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('$currentXp / $nextLevelXp XP', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(value: progress.clamp(0.0, 1.0), backgroundColor: AppColors.muted, color: AppColors.xpColor, minHeight: 8),
        ),
      ],
    );
  }
}

class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const StatsCard({super.key, required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 10)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withAlpha(30), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 20)),
          const SizedBox(height: 10),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color), maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class AchievementBadge extends StatelessWidget {
  final String emoji;
  final String name;
  final String description;
  final bool unlocked;

  const AchievementBadge({super.key, required this.emoji, required this.name, required this.description, required this.unlocked});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: unlocked ? Colors.white : AppColors.muted, borderRadius: BorderRadius.circular(12), border: unlocked ? Border.all(color: AppColors.primary.withAlpha(50)) : null),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: TextStyle(fontSize: 24, color: unlocked ? null : Colors.grey)),
          const SizedBox(height: 4),
          Text(name, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: unlocked ? AppColors.textPrimary : AppColors.textLight), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class MissionCard extends StatelessWidget {
  final String title;
  final String location;
  final String difficulty;
  final int xpReward;
  final int coinReward;
  final String? imageUrl;
  final VoidCallback? onTap;

  const MissionCard({super.key, required this.title, required this.location, required this.difficulty, required this.xpReward, required this.coinReward, this.imageUrl, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 10)]),
        child: Row(
          children: [
            Container(
              width: 70, height: 70,
              decoration: BoxDecoration(color: AppColors.muted, borderRadius: BorderRadius.circular(12), image: imageUrl != null ? DecorationImage(image: NetworkImage(imageUrl!), fit: BoxFit.cover) : null),
              child: imageUrl == null ? const Icon(Icons.waves, color: AppColors.primary) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(location, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      DifficultyBadge(difficulty: difficulty, small: true),
                      const SizedBox(width: 8),
                      Icon(Icons.star, size: 14, color: AppColors.xpColor),
                      Text(' $xpReward', style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 8),
                      Icon(Icons.monetization_on, size: 14, color: AppColors.coinColor),
                      Text(' $coinReward', style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
