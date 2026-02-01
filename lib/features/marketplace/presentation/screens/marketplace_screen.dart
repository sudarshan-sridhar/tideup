import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../home/presentation/providers/providers.dart';

class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({super.key});
  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rewards Shop'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Available'),
            Tab(text: 'My Rewards'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Coin Balance Header
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)]),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: const Color(0xFFF59E0B).withAlpha(60), blurRadius: 15, offset: const Offset(0, 5))],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white.withAlpha(50), borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.monetization_on, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Your Balance', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text('${user?.coins ?? 0} Coins', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Available Rewards Tab
                _AvailableRewardsTab(userCoins: user?.coins ?? 0, purchasedItems: user?.purchasedItems ?? []),
                
                // My Rewards Tab
                _MyRewardsTab(purchasedItems: user?.purchasedItems ?? []),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AvailableRewardsTab extends ConsumerWidget {
  final int userCoins;
  final List<String> purchasedItems;

  const _AvailableRewardsTab({required this.userCoins, required this.purchasedItems});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final giftCards = MarketplaceItems.items.where((i) => i['category'] == 'gift_card').toList();
    final merch = MarketplaceItems.items.where((i) => i['category'] == 'merch').toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        const Text('Gift Cards', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...giftCards.map((item) => _RewardCard(item: item, userCoins: userCoins, isPurchased: purchasedItems.contains(item['id']))),
        
        const SizedBox(height: 24),
        const Text('TideUp Merch', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...merch.map((item) => _RewardCard(item: item, userCoins: userCoins, isPurchased: purchasedItems.contains(item['id']))),
        
        const SizedBox(height: 100),
      ],
    );
  }
}

class _MyRewardsTab extends StatelessWidget {
  final List<String> purchasedItems;

  const _MyRewardsTab({required this.purchasedItems});

  @override
  Widget build(BuildContext context) {
    final redeemedItems = MarketplaceItems.items.where((i) => purchasedItems.contains(i['id'])).toList();

    if (redeemedItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.muted, shape: BoxShape.circle),
              child: const Icon(Icons.card_giftcard, size: 48, color: AppColors.textLight),
            ),
            const SizedBox(height: 16),
            const Text('No rewards yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Redeem your coins for gift cards and merch!', style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: redeemedItems.length,
      itemBuilder: (_, i) {
        final item = redeemedItems[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.successLight, borderRadius: BorderRadius.circular(12)),
                  child: Text(item['icon'] as String, style: const TextStyle(fontSize: 28)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(item['brand'] as String, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.successLight, borderRadius: BorderRadius.circular(8)),
                        child: const Text('Redeemed ✓', style: TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Text('\$${(item['value'] as double).toStringAsFixed(0)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.success)),
                    const Text('value', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RewardCard extends ConsumerWidget {
  final Map<String, dynamic> item;
  final int userCoins;
  final bool isPurchased;

  const _RewardCard({required this.item, required this.userCoins, required this.isPurchased});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final price = item['price'] as int;
    final canAfford = userCoins >= price;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.muted, borderRadius: BorderRadius.circular(12)),
              child: Text(item['icon'] as String, style: const TextStyle(fontSize: 28)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(item['description'] as String, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            isPurchased
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(color: AppColors.successLight, borderRadius: BorderRadius.circular(12)),
                    child: const Text('Owned', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600, fontSize: 12)),
                  )
                : ElevatedButton(
                    onPressed: canAfford ? () => _purchase(context, ref) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.coinColor,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('$price', style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 4),
                        const Icon(Icons.monetization_on, size: 16),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> _purchase(BuildContext context, WidgetRef ref) async {
    final price = item['price'] as int;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [Text(item['icon'] as String, style: const TextStyle(fontSize: 32)), const SizedBox(width: 12), const Expanded(child: Text('Confirm Redemption'))]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Text('Spend $price coins to redeem this reward?'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.infoLight, borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                const Icon(Icons.info_outline, color: AppColors.info, size: 20),
                const SizedBox(width: 8),
                const Expanded(child: Text('Gift card codes will be sent to your email.', style: TextStyle(fontSize: 12, color: AppColors.info))),
              ]),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), style: ElevatedButton.styleFrom(backgroundColor: AppColors.coinColor), child: const Text('Redeem')),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final user = ref.read(userProvider);
        await ref.read(firebaseServiceProvider).purchaseItem(user!.uid, item['id'] as String, price);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Row(children: [const Icon(Icons.check_circle, color: Colors.white), const SizedBox(width: 8), Text('${item['name']} redeemed! 🎉')]),
            backgroundColor: AppColors.success,
          ));
        }
      } catch (e) {
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
      }
    }
  }
}
