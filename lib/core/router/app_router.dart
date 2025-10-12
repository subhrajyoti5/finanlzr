import 'package:go_router/go_router.dart';
import 'package:finanlzr/features/home/screens/home_screen.dart';
import 'package:finanlzr/features/results/screens/results_screen.dart';
import 'package:finanlzr/features/portfolio/screens/portfolio_screen.dart';
import 'package:finanlzr/features/comparison/screens/comparison_screen.dart';
import 'package:finanlzr/shared/widgets/main_scaffold.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MainScaffold(child: HomeScreen()),
    ),
    GoRoute(
      path: '/results',
      builder: (context, state) {
        final ticker = state.uri.queryParameters['ticker'] ?? '';
        return ResultsScreen(ticker: ticker);
      },
    ),
    GoRoute(
      path: '/portfolio',
      builder: (context, state) => const MainScaffold(child: PortfolioScreen()),
    ),
    GoRoute(
      path: '/comparison',
      builder: (context, state) =>
          const MainScaffold(child: ComparisonScreen()),
    ),
  ],
);
