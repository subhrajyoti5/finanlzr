import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:finanlzr/features/results/providers/analysis_provider.dart';

class ResultsScreen extends ConsumerStatefulWidget {
  const ResultsScreen({super.key, required this.ticker});

  final String ticker;

  @override
  ConsumerState<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends ConsumerState<ResultsScreen> {
  bool _hasFetched = false;

  @override
  void initState() {
    super.initState();
    // Schedule the fetch to run after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
    if (_hasFetched) return;
    _hasFetched = true;
    ref.read(analysisProvider.notifier).fetchAnalysis(widget.ticker);
  }

  @override
  Widget build(BuildContext context) {
    final analysisState = ref.watch(analysisProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.ticker} Analysis'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildContent(analysisState),
        ),
      ),
    );
  }

  Widget _buildContent(AnalysisState state) {
    if (state.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Fetching analysis data...'),
          ],
        ),
      );
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              state.error!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(analysisProvider.notifier)
                    .fetchAnalysis(widget.ticker);
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (state.data == null) {
      return const Center(child: Text('No data available'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPriceCard(context, state.data!),
        const SizedBox(height: 16),
        _buildPredictionCard(context, state.data!),
        const SizedBox(height: 16),
        _buildSentimentCard(context, state.data!),
      ],
    );
  }

  Widget _buildPriceCard(BuildContext context, dynamic data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Price',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '\$${data.price}',
              style: Theme.of(
                context,
              ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionCard(BuildContext context, dynamic data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI Prediction',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '\$${data.prediction}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSentimentCard(BuildContext context, dynamic data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sentiment', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  _getSentimentIcon(data.sentiment),
                  color: _getSentimentColor(data.sentiment),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  data.sentiment,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: _getSentimentColor(data.sentiment),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getSentimentIcon(String sentiment) {
    switch (sentiment) {
      case 'Positive':
        return Icons.trending_up;
      case 'Negative':
        return Icons.trending_down;
      default:
        return Icons.trending_flat;
    }
  }

  Color _getSentimentColor(String sentiment) {
    switch (sentiment) {
      case 'Positive':
        return Colors.green;
      case 'Negative':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
