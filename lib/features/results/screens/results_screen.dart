import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:finanlzr/features/results/providers/analysis_provider.dart';
import 'package:fl_chart/fl_chart.dart';

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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 2,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          '${widget.ticker} Analysis',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPriceCard(context, state.data!),
          const SizedBox(height: 16),
          _buildPriceChartCard(context, state.data!),
          const SizedBox(height: 16),
          _buildPredictionCard(context, state.data!),
          const SizedBox(height: 16),
          _buildSentimentCard(context, state.data!),
        ],
      ),
    );
  }

  Widget _buildPriceCard(BuildContext context, dynamic data) {
    // compute 24h percent change from historicalPrices when available
    final historical = (data.historicalPrices as List<double>?) ?? [];
    double percentChange24h = 0.0;
    if (historical.length >= 2) {
      final last = historical.last;
      final prev = historical[historical.length - 2];
      if (prev != 0) percentChange24h = ((last - prev) / prev) * 100;
    }
    final percentText = (percentChange24h.isNaN)
        ? '—'
        : '${percentChange24h >= 0 ? '+' : ''}${percentChange24h.toStringAsFixed(2)}%';
    final percentColor = percentChange24h >= 0
        ? Colors.green[700]
        : Colors.red[700];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Price',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                ),
                const SizedBox(height: 8),
                Text(
                  '${data.price} ${data.currency}',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            // small badge showing computed 24h percent change
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: (percentChange24h >= 0
                    ? Colors.green[50]
                    : Colors.red[50]),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    percentText,
                    style: TextStyle(
                      color: percentColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '24h',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceChartCard(BuildContext context, dynamic data) {
    final historicalPrices = data.historicalPrices as List<double>;

    if (historicalPrices.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Price Trend',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              const Text('No historical data available for chart'),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Price Trend (30 Days)',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Container(
              height: 300,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // compute sensible axis intervals based on data range
                  final xCount = historicalPrices.length;
                  final currencySymbol = (data.currency ?? 'USD') == 'INR'
                      ? '₹'
                      : '\$';

                  final minYRaw = historicalPrices.reduce(
                    (a, b) => a < b ? a : b,
                  );
                  final maxYRaw = historicalPrices.reduce(
                    (a, b) => a > b ? a : b,
                  );
                  final yPadding = (maxYRaw - minYRaw) * 0.05;
                  var minY = minYRaw - yPadding;
                  var maxY = maxYRaw + yPadding;

                  // compute x interval trying to show ~4 labels across the axis
                  final rawRange = ((xCount - 1) <= 0)
                      ? 1.0
                      : (xCount - 1).toDouble();
                  final xInterval = (rawRange / 4.0).clamp(1.0, rawRange);
                  final ySteps = ((maxY - minY) / 4.0).clamp(
                    1e-6,
                    double.infinity,
                  );

                  // predicted price (if available) - show as next point
                  final rawPrediction = data.prediction?.toString() ?? '';
                  final predictedValue =
                      double.tryParse(rawPrediction) ?? double.nan;
                  final hasPrediction = !predictedValue.isNaN;
                  final predictedX = xCount; // next index after historical data

                  // expand vertical range if prediction outside current range
                  if (hasPrediction) {
                    if (predictedValue < minY) {
                      minY =
                          predictedValue -
                          (yPadding > 0 ? yPadding : predictedValue * 0.02);
                    }
                    if (predictedValue > maxY) {
                      maxY =
                          predictedValue +
                          (yPadding > 0 ? yPadding : predictedValue * 0.02);
                    }
                  }

                  final maxX = hasPrediction
                      ? predictedX + 0.5
                      : (xCount - 1).toDouble() + 0.5;

                  return LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: true,
                        horizontalInterval: ySteps,
                        verticalInterval: xInterval,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.grey.withOpacity(0.18),
                          strokeWidth: 1,
                        ),
                        getDrawingVerticalLine: (value) => FlLine(
                          color: Colors.grey.withOpacity(0.12),
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            interval: xInterval,
                            getTitlesWidget: (value, meta) {
                              final idx = value.round();
                              final maxIndex = hasPrediction
                                  ? predictedX
                                  : (xCount - 1);
                              if (idx < 0 || idx > maxIndex)
                                return const SizedBox.shrink();

                              // pick a few meaningful indices: first, quartiles, mid, last (and predicted)
                              final candidates = <int>{
                                0,
                                (xCount / 4).floor(),
                                (xCount / 2).floor(),
                                ((3 * xCount) / 4).floor(),
                                xCount - 1,
                              }..removeWhere((i) => i < 0 || i > xCount - 1);
                              if (hasPrediction) candidates.add(predictedX);

                              if (!candidates.contains(idx))
                                return const SizedBox.shrink();

                              final label = (hasPrediction && idx == predictedX)
                                  ? 'Pred'
                                  : 'Day ${idx + 1}';
                              return Padding(
                                padding: const EdgeInsets.only(top: 6.0),
                                child: Text(
                                  label,
                                  style: const TextStyle(fontSize: 11),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: ySteps,
                            reservedSize: 64,
                            getTitlesWidget: (value, meta) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Text(
                                  '$currencySymbol${value.toStringAsFixed(0)}',
                                  style: const TextStyle(fontSize: 11),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.22),
                        ),
                      ),
                      // small horizontal padding so endpoint markers don't sit on the card border
                      minX: -0.5,
                      maxX: maxX,
                      minY: minY,
                      maxY: maxY,
                      lineBarsData: [
                        // historical series
                        LineChartBarData(
                          spots: historicalPrices.asMap().entries.map((entry) {
                            return FlSpot(entry.key.toDouble(), entry.value);
                          }).toList(),
                          isCurved: true,
                          color: Theme.of(context).primaryColor,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.06),
                          ),
                        ),
                        // predicted connector (last historical -> predicted)
                        if (hasPrediction)
                          LineChartBarData(
                            spots: [
                              FlSpot(
                                (xCount - 1).toDouble(),
                                historicalPrices.last,
                              ),
                              FlSpot(predictedX.toDouble(), predictedValue),
                            ],
                            isCurved: false,
                            color: Colors.deepOrange,
                            barWidth: 2,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, bar, index) {
                                // highlight only the predicted point
                                if (spot.x == predictedX.toDouble()) {
                                  return FlDotCirclePainter(
                                    radius: 5,
                                    color: Colors.deepOrange,
                                    strokeWidth: 2,
                                    strokeColor: Colors.white,
                                  );
                                }
                                // keep last historical dot small/transparent
                                return FlDotCirclePainter(
                                  radius: 0,
                                  color: Colors.transparent,
                                  strokeWidth: 0,
                                );
                              },
                            ),
                            belowBarData: BarAreaData(show: false),
                          ),
                      ],
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((spot) {
                              return LineTooltipItem(
                                '${currencySymbol}${spot.y.toStringAsFixed(2)}',
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }).toList();
                          },
                        ),
                        handleBuiltInTouches: true,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionCard(BuildContext context, dynamic data) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Prediction',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                ),
                const SizedBox(height: 6),
                Text(
                  '${data.prediction} ${data.currency}',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
            Icon(
              Icons.insights,
              color: Theme.of(context).primaryColor,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSentimentCard(BuildContext context, dynamic data) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getSentimentColor(data.sentiment).withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getSentimentIcon(data.sentiment),
                color: _getSentimentColor(data.sentiment),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sentiment',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                ),
                const SizedBox(height: 6),
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
