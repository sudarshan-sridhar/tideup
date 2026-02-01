import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/providers.dart';
import 'home_screen.dart';
import '../../../map/presentation/screens/map_screen.dart';
import '../../../community/presentation/screens/community_screen.dart';
import '../../../profile/presentation/screens/player_profile_screen.dart';
import '../../../profile/presentation/screens/org_profile_screen.dart';
import '../../../missions/presentation/screens/org_dashboard_screen.dart';
import '../../../leaderboard/presentation/screens/leaderboard_screen.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});
  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final isOrg = user?.isOrganization ?? false;

    final playerScreens = [
      const HomeScreen(),
      const MapScreen(),
      const LeaderboardScreen(),
      const CommunityScreen(),
      const PlayerProfileScreen(),
    ];

    final orgScreens = [
      const OrgDashboardScreen(),
      const MapScreen(),
      const CommunityScreen(),
      const OrgProfileScreen(),
    ];

    final screens = isOrg ? orgScreens : playerScreens;

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: isOrg
            ? const [
                NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
                NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map), label: 'Map'),
                NavigationDestination(icon: Icon(Icons.forum_outlined), selectedIcon: Icon(Icons.forum), label: 'Community'),
                NavigationDestination(icon: Icon(Icons.business_outlined), selectedIcon: Icon(Icons.business), label: 'Profile'),
              ]
            : const [
                NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
                NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map), label: 'Map'),
                NavigationDestination(icon: Icon(Icons.leaderboard_outlined), selectedIcon: Icon(Icons.leaderboard), label: 'Ranks'),
                NavigationDestination(icon: Icon(Icons.forum_outlined), selectedIcon: Icon(Icons.forum), label: 'Community'),
                NavigationDestination(icon: Icon(Icons.person_outlined), selectedIcon: Icon(Icons.person), label: 'Profile'),
              ],
      ),
    );
  }
}
