import 'package:flutter_riverpod/flutter_riverpod.dart';

enum NavigationTab { home, portfolio, comparison }

final navigationProvider =
    StateNotifierProvider<NavigationNotifier, NavigationState>((ref) {
      return NavigationNotifier();
    });

class NavigationState {
  final NavigationTab currentTab;
  final List<String> navigationHistory;
  final bool isLoading;

  const NavigationState({
    required this.currentTab,
    this.navigationHistory = const [],
    this.isLoading = false,
  });

  NavigationState copyWith({
    NavigationTab? currentTab,
    List<String>? navigationHistory,
    bool? isLoading,
  }) {
    return NavigationState(
      currentTab: currentTab ?? this.currentTab,
      navigationHistory: navigationHistory ?? this.navigationHistory,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  String get currentRoute {
    switch (currentTab) {
      case NavigationTab.home:
        return '/';
      case NavigationTab.portfolio:
        return '/portfolio';
      case NavigationTab.comparison:
        return '/comparison';
    }
  }
}

class NavigationNotifier extends StateNotifier<NavigationState> {
  NavigationNotifier()
    : super(const NavigationState(currentTab: NavigationTab.home));

  void setTab(NavigationTab tab) {
    if (tab != state.currentTab) {
      state = state.copyWith(
        currentTab: tab,
        navigationHistory: [...state.navigationHistory, state.currentRoute],
      );
    }
  }

  void navigateToRoute(String route) {
    NavigationTab tab;
    switch (route) {
      case '/':
        tab = NavigationTab.home;
        break;
      case '/portfolio':
        tab = NavigationTab.portfolio;
        break;
      case '/comparison':
        tab = NavigationTab.comparison;
        break;
      default:
        return; // Don't change tab for unknown routes
    }
    setTab(tab);
  }

  void goBack() {
    if (state.navigationHistory.isNotEmpty) {
      final previousRoute = state.navigationHistory.last;
      final newHistory = List<String>.from(state.navigationHistory)
        ..removeLast();

      NavigationTab tab;
      switch (previousRoute) {
        case '/':
          tab = NavigationTab.home;
          break;
        case '/portfolio':
          tab = NavigationTab.portfolio;
          break;
        case '/comparison':
          tab = NavigationTab.comparison;
          break;
        default:
          tab = NavigationTab.home;
      }

      state = state.copyWith(currentTab: tab, navigationHistory: newHistory);
    }
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  bool get canGoBack => state.navigationHistory.isNotEmpty;
}
