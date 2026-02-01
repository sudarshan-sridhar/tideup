import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/config/env.dart';
import '../../../../services/solana/solana_service.dart';
import '../../../home/presentation/providers/providers.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});
  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  final _coinsController = TextEditingController(text: '100');
  bool _isConverting = false;

  @override
  void initState() {
    super.initState();
    // Initialize wallet with user's existing balance from Firebase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(userProvider);
      if (user != null && user.solanaBalance > 0) {
        final solana = ref.read(solanaServiceProvider.notifier);
        solana.initializeFromFirebase(user.solanaBalance, user.solanaAddress ?? '');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final solana = ref.watch(solanaServiceProvider);
    
    // Use Firebase balance as source of truth
    final displayBalance = user?.solanaBalance ?? solana.balance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Solana Wallet'),
        actions: [
          if (solana.isConnected)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _syncWallet(),
              tooltip: 'Sync Wallet',
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _syncWallet(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Wallet Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(gradient: AppColors.solanaGradient, borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('TideUp Wallet', style: TextStyle(color: Colors.white70)),
                            Row(
                              children: [
                                Container(
                                  width: 8, height: 8,
                                  decoration: BoxDecoration(
                                    color: solana.isConnected ? AppColors.solanaGreen : Colors.white54,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  solana.isConnected ? 'Connected' : 'Not Connected',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (solana.isConnected)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
                          child: const Text('Devnet', style: TextStyle(color: Colors.white, fontSize: 11)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('Balance', style: TextStyle(color: Colors.white70)),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        displayBalance.toStringAsFixed(4),
                        style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 4, left: 4),
                        child: Text('SOL', style: TextStyle(color: Colors.white70, fontSize: 18)),
                      ),
                    ],
                  ),
                  if (displayBalance > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      '≈ \$${(displayBalance * 150).toStringAsFixed(2)} USD',  // Approximate SOL price
                      style: const TextStyle(color: Colors.white60, fontSize: 14),
                    ),
                  ],
                  if (solana.isConnected && solana.address != null) ...[
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => _copyAddress(solana.address!),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                solana.address!,
                                style: const TextStyle(color: Colors.white70, fontSize: 11, fontFamily: 'monospace'),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.copy, color: Colors.white54, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Quick Stats
            Row(
              children: [
                Expanded(
                  child: _QuickStat(
                    icon: Icons.monetization_on,
                    label: 'Available Coins',
                    value: '${user?.coins ?? 0}',
                    color: AppColors.coinColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickStat(
                    icon: Icons.swap_horiz,
                    label: 'Total Converted',
                    value: '${user?.totalCoinsConverted ?? 0}',
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Create/Convert Section
            if (!solana.isConnected) ...[
              const Text('Get Started', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Create a wallet to convert your TideUp coins to SOL', style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: solana.isLoading ? null : () => _createWallet(),
                icon: solana.isLoading
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.add),
                label: Text(solana.isLoading ? 'Creating...' : 'Create Wallet'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.solanaColor, minimumSize: const Size(double.infinity, 52)),
              ),
            ] else ...[
              // Convert Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: AppColors.coinColor.withAlpha(30), borderRadius: BorderRadius.circular(10)),
                            child: const Icon(Icons.swap_horiz, color: AppColors.coinColor),
                          ),
                          const SizedBox(width: 12),
                          const Text('Convert Coins to SOL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: AppColors.muted, borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Exchange Rate:', style: TextStyle(color: AppColors.textSecondary)),
                            Text('${Env.coinsPerSol} coins = 1 SOL', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _coinsController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Coins to convert',
                          suffixText: 'coins',
                          prefixIcon: const Icon(Icons.monetization_on, color: AppColors.coinColor),
                          helperText: 'Min: ${Env.minCoinsToConvert} coins',
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: AppColors.solanaGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('You will receive:', style: TextStyle(color: Colors.white70)),
                            Text(
                              '${((int.tryParse(_coinsController.text) ?? 0) / Env.coinsPerSol).toStringAsFixed(6)} SOL',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _isConverting ? null : () => _convert(user?.coins ?? 0, user?.uid),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.solanaColor, minimumSize: const Size(double.infinity, 52)),
                        child: _isConverting
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                                  SizedBox(width: 12),
                                  Text('Converting...'),
                                ],
                              )
                            : const Text('Convert to SOL', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Transaction History
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Transaction History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('${solana.transactions.length} transactions', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 12),
              if (solana.transactions.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(color: AppColors.muted, borderRadius: BorderRadius.circular(16)),
                  child: const Column(
                    children: [
                      Icon(Icons.receipt_long, size: 40, color: AppColors.textLight),
                      SizedBox(height: 12),
                      Text('No transactions yet', style: TextStyle(color: AppColors.textSecondary)),
                      Text('Convert coins to see history', style: TextStyle(color: AppColors.textLight, fontSize: 12)),
                    ],
                  ),
                )
              else
                ...solana.transactions.map((tx) => _TransactionTile(transaction: tx)),
            ],
            const SizedBox(height: 20),

            // Info Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.infoLight, borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [Icon(Icons.info, color: AppColors.info), const SizedBox(width: 8), Text('About Solana Integration', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.info))]),
                  const SizedBox(height: 8),
                  const Text('• Demonstrates coin-to-SOL conversion\n• Built for Solana hackathon track\n• Shows high-frequency, low-fee potential\n• Production would use real devnet/mainnet', style: TextStyle(fontSize: 13, height: 1.5)),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _createWallet() async {
    final result = await ref.read(solanaServiceProvider.notifier).createWallet();
    if (result.success && mounted) {
      // Save to Firebase
      final user = ref.read(userProvider);
      if (user != null) {
        await ref.read(firebaseServiceProvider).updateUserField(user.uid, {
          'solanaAddress': result.address,
          'solanaBalance': 0.01, // Initial airdrop
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message), backgroundColor: AppColors.success),
      );
    }
  }

  Future<void> _convert(int availableCoins, String? uid) async {
    if (uid == null) return;
    
    final coins = int.tryParse(_coinsController.text) ?? 0;
    if (coins < Env.minCoinsToConvert) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Minimum ${Env.minCoinsToConvert} coins required')));
      return;
    }
    if (coins > availableCoins) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Not enough coins')));
      return;
    }

    setState(() => _isConverting = true);
    
    try {
      final result = await ref.read(solanaServiceProvider.notifier).convertCoins(coins);
      if (result.success && result.solReceived != null) {
        // Update Firebase - this is the source of truth
        await ref.read(firebaseServiceProvider).convertCoinsToSol(uid, coins, result.solReceived!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('✓ ${result.message}'), backgroundColor: AppColors.success),
          );
          _coinsController.text = '100';
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result.message), backgroundColor: AppColors.error),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isConverting = false);
    }
  }

  void _syncWallet() {
    final user = ref.read(userProvider);
    if (user != null) {
      ref.read(solanaServiceProvider.notifier).syncBalance(user.solanaBalance);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Wallet synced')));
    }
  }

  void _copyAddress(String address) {
    Clipboard.setData(ClipboardData(text: address));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Address copied!')));
  }

  @override
  void dispose() {
    _coinsController.dispose();
    super.dispose();
  }
}

class _QuickStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _QuickStat({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final SolanaTransaction transaction;

  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    switch (transaction.type) {
      case TxType.conversion:
        icon = Icons.swap_horiz;
        color = AppColors.primary;
        break;
      case TxType.airdrop:
        icon = Icons.card_giftcard;
        color = AppColors.success;
        break;
      case TxType.reward:
        icon = Icons.star;
        color = AppColors.xpColor;
        break;
      default:
        icon = Icons.arrow_downward;
        color = AppColors.info;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withAlpha(30), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(transaction.typeLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateFormat('MMM d, h:mm a').format(transaction.timestamp), style: const TextStyle(fontSize: 11)),
            if (transaction.coinsConverted != null)
              Text('${transaction.coinsConverted} coins converted', style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
          ],
        ),
        trailing: Text(
          '+${transaction.amount.toStringAsFixed(4)} SOL',
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
