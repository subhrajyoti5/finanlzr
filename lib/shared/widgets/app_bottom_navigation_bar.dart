import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:finanlzr/core/providers/navigation_provider.dart';

class AppBottomNavigationBar extends ConsumerWidget {
  const AppBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigationState = ref.watch(navigationProvider);
    final navigationNotifier = ref.read(navigationProvider.notifier);

    return BottomNavigationBar(
      currentIndex: navigationState.currentTab.index,
      onTap: (index) {
        final tab = NavigationTab.values[index];
        navigationNotifier.setTab(tab);

        // Navigate to the route corresponding to the selected tab
        String route;
        switch (tab) {
          case NavigationTab.home:
            route = '/';
            break;
          case NavigationTab.portfolio:
            route = '/portfolio';
            break;
          case NavigationTab.comparison:
            route = '/comparison';
            break;
        }
        context.go(route);
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet),
          label: 'Portfolio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.compare_arrows),
          label: 'Compare',
        ),
      ],
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Theme.of(
        context,
      ).colorScheme.onSurface.withOpacity(0.6),
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
    );
  }
}
