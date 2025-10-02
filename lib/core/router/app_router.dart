import 'package:go_router/go_router.dart';
import 'package:finanlzr/features/home/screens/home_screen.dart';
import 'package:finanlzr/features/results/screens/results_screen.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/results',
      builder: (context, state) {
        final ticker = state.uri.queryParameters['ticker'] ?? '';
        return ResultsScreen(ticker: ticker);
      },
    ),
  ],
);
