import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:finanlzr/core/providers/api_provider.dart';

class ComparisonScreen extends ConsumerStatefulWidget {
  const ComparisonScreen({super.key});

  @override
  ConsumerState<ComparisonScreen> createState() => _ComparisonScreenState();
}

class _ComparisonScreenState extends ConsumerState<ComparisonScreen> {
  final List<String> _selectedStocks = [];
  final Map<String, List<FlSpot>> _stockData = {};
  bool _isLoading = false;

  final List<String> _popularStocks = ['AAPL', 'GOOGL', 'MSFT', 'TSLA', 'AMZN'];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
        child: Column(
          children: [
            // Stock selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Stocks to Compare (Max 3)',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _popularStocks.map((stock) {
                        final isSelected = _selectedStocks.contains(stock);
                        return FilterChip(
                          label: Text(stock),
                          selected: isSelected,
                          onSelected: (selected) =>
                              _toggleStock(stock, selected),
                        );
                      }).toList(),
                    ),
                    if (_selectedStocks.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Selected: ${_selectedStocks.join(', ')}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          TextButton(
                            onPressed: _clearSelection,
                            child: const Text('Clear All'),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Chart area
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _selectedStocks.isEmpty
                      ? Center(
                          child: Text(
                            'Select stocks to view comparison chart',
                            style: Theme.of(context).textTheme.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                        )
                      : _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildChart(),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _selectedStocks.isNotEmpty
          ? FloatingActionButton(
              onPressed: () {
                setState(() {
                  _stockData.clear();
                });
                for (final stock in _selectedStocks) {
                  _loadStockData(stock);
                }
              },
              child: const Icon(Icons.refresh),
            )
          : null,
    );
  }

  void _toggleStock(String stock, bool selected) {
    setState(() {
      if (selected && _selectedStocks.length < 3) {
        _selectedStocks.add(stock);
        _loadStockData(stock);
      } else if (!selected) {
        _selectedStocks.remove(stock);
        _stockData.remove(stock);
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedStocks.clear();
      _stockData.clear();
    });
  }

  Future<void> _loadStockData(String symbol) async {
    if (_stockData.containsKey(symbol)) return;

    setState(() => _isLoading = true);

    try {
      final apiService = ref.read(coinbaseApiServiceProvider);
      final stockData = await apiService.getStockData(symbol);

      if (stockData != null && stockData['historicalPrices'] != null) {
        final historicalPrices = stockData['historicalPrices'] as List<double>;
        final spots = <FlSpot>[];

        for (int i = 0; i < historicalPrices.length && i < 30; i++) {
          spots.add(FlSpot(i.toDouble(), historicalPrices[i]));
        }

        if (mounted) {
          setState(() {
            _stockData[symbol] = spots;
          });
        }
      } else {
        // Fallback: create mock data for demo purposes
        final spots = <FlSpot>[];
        final basePrice =
            100.0 + (symbol.hashCode % 200); // Random-ish base price

        for (int i = 0; i < 30; i++) {
          final price = basePrice + (i * 0.5) + ((symbol.hashCode % 10) - 5);
          spots.add(FlSpot(i.toDouble(), price));
        }

        if (mounted) {
          setState(() {
            _stockData[symbol] = spots;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load data for $symbol')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildChart() {
    if (_stockData.isEmpty) return const SizedBox.shrink();

    final colors = [Colors.blue, Colors.red, Colors.green];

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Text(
                '\$${value.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final days = ['1', '7', '14', '21', '28'];
                final index = value.toInt();
                if (index >= 0 && index < days.length) {
                  return Text(
                    days[index],
                    style: const TextStyle(fontSize: 12),
                  );
                }
                return const Text('');
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: _selectedStocks.asMap().entries.map((entry) {
          final index = entry.key;
          final symbol = entry.value;
          final data = _stockData[symbol];
          if (data == null) return LineChartBarData();

          return LineChartBarData(
            spots: data,
            isCurved: true,
            color: colors[index % colors.length],
            barWidth: 3,
            belowBarData: BarAreaData(
              show: true,
              color: colors[index % colors.length].withOpacity(0.1),
            ),
            dotData: FlDotData(show: false),
          );
        }).toList(),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final symbol = _selectedStocks[spot.barIndex];
                return LineTooltipItem(
                  '$symbol: \$${spot.y.toStringAsFixed(2)}',
                  TextStyle(color: colors[spot.barIndex % colors.length]),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}
