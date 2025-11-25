import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taskflow/l10n/app_localizations.dart';

/// Provider for tracking current bottom navigation index
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

/// Main navigation screen with bottom navigation bar
class MainNavigationScreen extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainNavigationScreen({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          // Map nav index to path explicitly to avoid misalignment with shell branches
          const paths = ['/home', '/groups', '/profile'];
          if (index >= 0 && index < paths.length) {
            // Use goRouter to navigate directly — this ensures the correct branch is selected
            GoRouter.of(context).go(paths[index]);
            ref.read(bottomNavIndexProvider.notifier).state = index;
          }
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: AppLocalizations.of(context)!.home,
          ),
          // Task tab removed from main navigation — tasks are shown in group context
          NavigationDestination(
            icon: const Icon(Icons.group_outlined),
            selectedIcon: const Icon(Icons.group),
            label: AppLocalizations.of(context)!.groups,
          ),
          // NavigationDestination(
          //   icon: const Icon(Icons.card_giftcard_outlined),
          //   selectedIcon: const Icon(Icons.card_giftcard),
          //   label: AppLocalizations.of(context)!.rewards,
          // ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: AppLocalizations.of(context)!.navigationProfileLabel,
          ),
        ],
      ),
    );
  }
}
