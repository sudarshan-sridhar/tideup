import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../home/presentation/providers/providers.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';
import '../../data/post_model.dart';
import 'create_post_screen.dart';

class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(postsStreamProvider);
    final user = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
          ),
        ],
      ),
      body: postsAsync.when(
        data: (posts) => posts.isEmpty
            ? const EmptyState(icon: Icons.forum, title: 'No posts yet', subtitle: 'Be the first to share your cleanup story!')
            : RefreshIndicator(
                onRefresh: () async => ref.invalidate(postsStreamProvider),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: posts.length,
                  itemBuilder: (_, i) => _PostCard(post: posts[i], currentUserId: user?.uid),
                ),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreatePostScreen())),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _PostCard extends ConsumerWidget {
  final PostModel post;
  final String? currentUserId;

  const _PostCard({required this.post, this.currentUserId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLiked = post.isLikedBy(currentUserId ?? '');
    final isOwner = post.authorId == currentUserId;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author Row
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: post.authorRole == 'organization' ? AppColors.secondary : AppColors.primary,
                  radius: 20,
                  child: Text(
                    post.authorName.isNotEmpty ? post.authorName[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              post.authorName,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (post.authorRole == 'organization') ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.verified, size: 16, color: AppColors.secondary),
                          ],
                        ],
                      ),
                      Text(
                        timeago.format(post.createdAt),
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                if (isOwner)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
                    onSelected: (value) {
                      if (value == 'delete') _deletePost(context, ref);
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: AppColors.error, size: 20), SizedBox(width: 8), Text('Delete', style: TextStyle(color: AppColors.error))])),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Content
            Text(post.content, style: const TextStyle(height: 1.5)),

            // Image
            if (post.imageUrls.isNotEmpty) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  post.imageUrls.first,
                  fit: BoxFit.cover,
                  height: 200,
                  width: double.infinity,
                  errorBuilder: (_, __, ___) => Container(
                    height: 200,
                    color: AppColors.muted,
                    child: const Icon(Icons.image, size: 48, color: AppColors.textLight),
                  ),
                ),
              ),
            ],

            // Mission Tag
            if (post.missionTitle != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: AppColors.primary.withAlpha(20), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.waves, size: 14, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Flexible(child: Text(post.missionTitle!, style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),

            // Actions Row
            Row(
              children: [
                InkWell(
                  onTap: () => ref.read(firebaseServiceProvider).togglePostLike(post.id, currentUserId ?? ''),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        Icon(isLiked ? Icons.favorite : Icons.favorite_border, size: 22, color: isLiked ? AppColors.error : AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Text('${post.likeCount}', style: TextStyle(color: isLiked ? AppColors.error : AppColors.textSecondary, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                InkWell(
                  onTap: () {/* Show comments */},
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        const Icon(Icons.chat_bubble_outline, size: 20, color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Text('${post.commentCount}', style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.share_outlined, size: 20, color: AppColors.textSecondary),
                  onPressed: () {/* Share */},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deletePost(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(firebaseServiceProvider).deletePost(post.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post deleted'), backgroundColor: AppColors.success),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
          );
        }
      }
    }
  }
}
