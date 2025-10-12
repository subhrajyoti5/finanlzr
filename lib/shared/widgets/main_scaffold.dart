import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:finanlzr/core/providers/theme_provider.dart';
import 'package:finanlzr/core/providers/navigation_provider.dart';
import 'package:finanlzr/shared/widgets/app_bottom_navigation_bar.dart';

class MainScaffold extends ConsumerStatefulWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> {
  @override
  void initState() {
    super.initState();
    // Update navigation state when route changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateNavigationFromRoute();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Sync navigation state whenever dependencies change (including route changes)
    // Delay the update to avoid modifying provider during build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateNavigationFromRoute();
    });
  }

  void _updateNavigationFromRoute() {
    final currentRoute = GoRouterState.of(context).uri.toString();
    ref.read(navigationProvider.notifier).navigateToRoute(currentRoute);
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    // Check if current route should show bottom navigation
    final currentRoute = GoRouterState.of(context).uri.toString();
    final showBottomNav = _shouldShowBottomNav(currentRoute);

    return Scaffold(
      appBar: AppBar(
        title: const Text('finanlzr'),
        actions: [
          IconButton(
            icon: Icon(
              themeMode == ThemeMode.light ? Icons.dark_mode : Icons.light_mode,
            ),
            onPressed: () => ref.read(themeModeProvider.notifier).toggleTheme(),
          ),
        ],
        // Hide app bar for results screen
        automaticallyImplyLeading: currentRoute != '/results',
      ),
      body: widget.child,
      bottomNavigationBar: showBottomNav
          ? const AppBottomNavigationBar()
          : null,
    );
  }

  bool _shouldShowBottomNav(String route) {
    // Show bottom nav for main tabs, hide for results screen
    return route == '/' || route == '/portfolio' || route == '/comparison';
  }
}
