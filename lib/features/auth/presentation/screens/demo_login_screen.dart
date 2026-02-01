import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../home/presentation/providers/providers.dart';

class DemoLoginScreen extends ConsumerStatefulWidget {
  const DemoLoginScreen({super.key});
  @override
  ConsumerState<DemoLoginScreen> createState() => _DemoLoginScreenState();
}

class _DemoLoginScreenState extends ConsumerState<DemoLoginScreen> {
  bool _isLoading = false;
  String? _loadingRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF22D3EE), Color(0xFF3B82F6), Color(0xFF2563EB)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Back Button
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [BoxShadow(color: Colors.black.withAlpha(40), blurRadius: 20)],
                        ),
                        child: const Icon(Icons.science, size: 56, color: Color(0xFF0891B2)),
                      ),
                      const SizedBox(height: 24),
                      const Text('Demo Mode', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(color: Colors.white.withAlpha(50), borderRadius: BorderRadius.circular(20)),
                        child: const Text('For Hackathon Judges', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(height: 32),
                      Text('Try the app with pre-populated data.\nNo sign-up required!', textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withAlpha(230), fontSize: 16, height: 1.5)),
                      const SizedBox(height: 48),

                      // Demo Player Card
                      _DemoCard(
                        icon: Icons.person,
                        iconColor: const Color(0xFF10B981),
                        title: 'Demo Player',
                        subtitle: 'Level 7 • 850 coins • 23 cleanups',
                        features: const ['Join cleanup missions', 'Earn XP & rewards', 'Convert coins to SOL', 'Track achievements'],
                        isLoading: _loadingRole == 'player',
                        onTap: () => _loginAsDemo(true),
                      ),
                      const SizedBox(height: 20),

                      // Demo Organization Card
                      _DemoCard(
                        icon: Icons.business,
                        iconColor: const Color(0xFF8B5CF6),
                        title: 'Demo Organization',
                        subtitle: 'Beach Buddies • 15 missions • 342 volunteers',
                        features: const ['Create cleanup events', 'Verify check-ins', 'Track volunteers', 'Community engagement'],
                        isLoading: _loadingRole == 'organization',
                        onTap: () => _loginAsDemo(false),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loginAsDemo(bool isPlayer) async {
    setState(() { _isLoading = true; _loadingRole = isPlayer ? 'player' : 'organization'; });
    try {
      await ref.read(firebaseServiceProvider).signInAsDemo(isPlayer);
      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() { _isLoading = false; _loadingRole = null; });
    }
  }
}

class _DemoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final List<String> features;
  final bool isLoading;
  final VoidCallback onTap;

  const _DemoCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.features,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: iconColor.withAlpha(30), borderRadius: BorderRadius.circular(16)),
              child: Icon(icon, color: iconColor, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: features.map((f) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
                      child: Text(f, style: const TextStyle(fontSize: 10, color: Color(0xFF475569))),
                    )).toList(),
                  ),
                ],
              ),
            ),
            isLoading
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                : Icon(Icons.arrow_forward_ios, color: iconColor, size: 20),
          ],
        ),
      ),
    );
  }
}
