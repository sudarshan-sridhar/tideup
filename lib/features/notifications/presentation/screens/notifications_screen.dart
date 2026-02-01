import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/providers/providers.dart';
import '../../../community/presentation/screens/community_screen.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});
  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  List<_NotificationItem> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    final user = ref.read(userProvider);
    final isOrg = user?.isOrganization ?? false;

    if (isOrg) {
      _notifications = [
        _NotificationItem(
          id: '1', icon: Icons.person_add, iconColor: AppColors.success,
          title: 'New Volunteer Joined!',
          message: 'Alex Johnson joined your "Grand Haven Beach Cleanup" mission.',
          time: DateTime.now().subtract(const Duration(minutes: 30)),
          isRead: false, actionType: 'mission',
        ),
        _NotificationItem(
          id: '2', icon: Icons.pending_actions, iconColor: AppColors.warning,
          title: 'Check-in Pending Review',
          message: 'Sarah Miller submitted a check-in for verification.',
          time: DateTime.now().subtract(const Duration(hours: 1)),
          isRead: false, actionType: 'verify',
        ),
        _NotificationItem(
          id: '3', icon: Icons.check_circle, iconColor: AppColors.success,
          title: 'Mission Completed',
          message: 'Your "Holland State Park Cleanup" completed successfully!',
          time: DateTime.now().subtract(const Duration(hours: 3)),
          isRead: true, actionType: 'stats',
        ),
      ];
    } else {
      _notifications = [
        _NotificationItem(
          id: '1', icon: Icons.verified, iconColor: AppColors.success,
          title: 'Check-in Approved!',
          message: 'Your cleanup at Grand Haven State Park was verified. You earned 100 XP and 50 coins!',
          time: DateTime.now().subtract(const Duration(hours: 2)),
          isRead: false, actionType: 'rewards',
        ),
        _NotificationItem(
          id: '2', icon: Icons.emoji_events, iconColor: AppColors.coinColor,
          title: 'Achievement Unlocked!',
          message: 'You earned the "First Wave" badge for completing your first cleanup. +50 XP bonus!',
          time: DateTime.now().subtract(const Duration(hours: 5)),
          isRead: false, actionType: 'achievement',
        ),
        _NotificationItem(
          id: '3', icon: Icons.trending_up, iconColor: AppColors.xpColor,
          title: 'Level Up! 🎉',
          message: 'Congratulations! You reached Level 5 - Sand Sweeper. New rewards unlocked!',
          time: DateTime.now().subtract(const Duration(days: 1)),
          isRead: true, actionType: 'level',
        ),
        _NotificationItem(
          id: '4', icon: Icons.event, iconColor: AppColors.primary,
          title: 'New Mission Nearby',
          message: 'Beach Buddies is hosting a cleanup at Sleeping Bear Dunes this Saturday.',
          time: DateTime.now().subtract(const Duration(days: 2)),
          isRead: true, actionType: 'mission',
        ),
        _NotificationItem(
          id: '5', icon: Icons.favorite, iconColor: AppColors.error,
          title: 'Your post was liked',
          message: 'Ocean Warrior and 3 others liked your cleanup story.',
          time: DateTime.now().subtract(const Duration(days: 3)),
          isRead: true, actionType: 'post',
        ),
        _NotificationItem(
          id: '6', icon: Icons.local_fire_department, iconColor: Colors.orange,
          title: 'Streak Alert! 🔥',
          message: 'You\'re on a 5-day cleanup streak! Keep it going for bonus rewards.',
          time: DateTime.now().subtract(const Duration(days: 4)),
          isRead: true, actionType: null,
        ),
      ];
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Notifications'),
            if (unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(10)),
                child: Text('$unreadCount', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
        actions: [
          if (unreadCount > 0)
            TextButton(onPressed: _markAllRead, child: const Text('Mark all read')),
        ],
      ),
      body: _notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: AppColors.muted, shape: BoxShape.circle),
                    child: const Icon(Icons.notifications_off, size: 48, color: AppColors.textLight),
                  ),
                  const SizedBox(height: 16),
                  const Text('No notifications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('You\'re all caught up!', style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _notifications.length,
              itemBuilder: (_, i) => Dismissible(
                key: Key(_notifications[i].id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: AppColors.error,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) => _deleteNotification(i),
                child: _NotificationTile(
                  notification: _notifications[i],
                  onTap: () => _handleNotificationTap(context, _notifications[i], i),
                ),
              ),
            ),
    );
  }

  void _markAllRead() {
    setState(() {
      for (var i = 0; i < _notifications.length; i++) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All notifications marked as read')));
  }

  void _markAsRead(int index) {
    setState(() {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
    });
  }

  void _deleteNotification(int index) {
    final deleted = _notifications[index];
    setState(() => _notifications.removeAt(index));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Notification deleted'),
        action: SnackBarAction(label: 'Undo', onPressed: () => setState(() => _notifications.insert(index, deleted))),
      ),
    );
  }

  void _handleNotificationTap(BuildContext context, _NotificationItem notification, int index) {
    // Mark as read
    if (!notification.isRead) _markAsRead(index);

    // Handle action based on type
    switch (notification.actionType) {
      case 'rewards':
        _showRewardsDialog(context);
        break;
      case 'achievement':
        _showAchievementDialog(context);
        break;
      case 'level':
        _showLevelUpDialog(context);
        break;
      case 'mission':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Go to Map tab to view missions'), duration: Duration(seconds: 2)),
        );
        break;
      case 'post':
        // Navigate to community screen
        Navigator.push(context, MaterialPageRoute(builder: (_) => const CommunityScreen()));
        break;
      case 'verify':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Go to Dashboard to verify check-ins'), duration: Duration(seconds: 2)),
        );
        break;
      case 'stats':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mission statistics viewed'), duration: Duration(seconds: 2)),
        );
        break;
      default:
        // No action
        break;
    }
  }

  void _showRewardsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [Icon(Icons.celebration, color: AppColors.coinColor), SizedBox(width: 8), Text('Rewards Earned!')]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(children: const [Icon(Icons.star, color: AppColors.xpColor, size: 40), SizedBox(height: 4), Text('100 XP', style: TextStyle(fontWeight: FontWeight.bold))]),
                Column(children: const [Icon(Icons.monetization_on, color: AppColors.coinColor, size: 40), SizedBox(height: 4), Text('50 Coins', style: TextStyle(fontWeight: FontWeight.bold))]),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Great job completing your cleanup!', style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Awesome!'))],
      ),
    );
  }

  void _showAchievementDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [Text('🌊', style: TextStyle(fontSize: 28)), SizedBox(width: 8), Text('Achievement!')]),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('First Wave', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Complete your first cleanup mission'),
            SizedBox(height: 16),
            Text('+50 XP Bonus', style: TextStyle(color: AppColors.xpColor, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Nice!'))],
      ),
    );
  }

  void _showLevelUpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('🎉 Level Up!', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🐠', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 8),
            const Text('Level 5', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const Text('Sand Sweeper', style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.successLight, borderRadius: BorderRadius.circular(12)),
              child: const Text('🎁 Unlocked: 10% bonus coins!', style: TextStyle(color: AppColors.success)),
            ),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Let\'s Go!'))],
      ),
    );
  }
}

class _NotificationItem {
  final String id;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final DateTime time;
  final bool isRead;
  final String? actionType;

  _NotificationItem({
    required this.id, required this.icon, required this.iconColor,
    required this.title, required this.message, required this.time,
    required this.isRead, this.actionType,
  });

  _NotificationItem copyWith({bool? isRead}) => _NotificationItem(
    id: id, icon: icon, iconColor: iconColor, title: title,
    message: message, time: time, isRead: isRead ?? this.isRead, actionType: actionType,
  );
}

class _NotificationTile extends StatelessWidget {
  final _NotificationItem notification;
  final VoidCallback onTap;

  const _NotificationTile({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: notification.isRead ? Colors.white : AppColors.primary.withAlpha(10),
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: notification.iconColor.withAlpha(30), borderRadius: BorderRadius.circular(12)),
                child: Icon(notification.icon, color: notification.iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(notification.title, style: TextStyle(fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold, fontSize: 14)),
                        ),
                        if (!notification.isRead)
                          Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(notification.message, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(_formatTime(notification.time), style: const TextStyle(color: AppColors.textLight, fontSize: 11)),
                        if (notification.actionType != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: AppColors.primary.withAlpha(20), borderRadius: BorderRadius.circular(8)),
                            child: const Text('Tap to view', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w500)),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${time.month}/${time.day}';
  }
}
