import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finanlzr/core/providers/portfolio_provider.dart';
import 'package:finanlzr/shared/models/portfolio_stock.dart';

class PortfolioScreen extends ConsumerStatefulWidget {
  const PortfolioScreen({super.key});

  @override
  ConsumerState<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends ConsumerState<PortfolioScreen> {
  final TextEditingController _tickerController = TextEditingController();

  @override
  void dispose() {
    _tickerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final portfolio = ref.watch(portfolioProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      body: portfolio.stocks.isEmpty
          ? Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.account_balance_wallet,
                      size: isSmallScreen ? 48 : 64,
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No stocks in portfolio',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add stocks to track your investments',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: isSmallScreen ? double.infinity : 200,
                      child: ElevatedButton.icon(
                        onPressed: _showAddStockDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Stock'),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 16 : screenWidth * 0.1,
                vertical: 16,
              ),
              itemCount: portfolio.stocks.length,
              itemBuilder: (context, index) {
                final stock = portfolio.stocks[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(
                      stock.symbol,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: stock.name.isNotEmpty ? Text(stock.name) : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (stock.currentPrice != null)
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$${stock.currentPrice!.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              if (stock.changePercent != null)
                                Text(
                                  '${stock.changePercent! >= 0 ? '+' : ''}${stock.changePercent!.toStringAsFixed(2)}%',
                                  style: TextStyle(
                                    color: stock.changePercent! >= 0
                                        ? Colors.green
                                        : Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeStock(stock.symbol),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: portfolio.stocks.isNotEmpty
          ? _buildFloatingActionButtons()
          : null,
    );
  }

  Widget _buildFloatingActionButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          onPressed: () => ref.read(portfolioProvider.notifier).refreshPrices(),
          heroTag: 'refresh',
          child: const Icon(Icons.refresh),
        ),
        const SizedBox(height: 16),
        FloatingActionButton(
          onPressed: _showAddStockDialog,
          heroTag: 'add',
          child: const Icon(Icons.add),
        ),
      ],
    );
  }

  void _showAddStockDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Stock to Portfolio'),
        content: TextField(
          controller: _tickerController,
          decoration: const InputDecoration(
            hintText: 'Enter ticker symbol (e.g., AAPL)',
            labelText: 'Ticker Symbol',
          ),
          textCapitalization: TextCapitalization.characters,
          maxLength: 10,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(onPressed: _addStock, child: const Text('Add')),
        ],
      ),
    );
  }

  void _addStock() {
    final symbol = _tickerController.text.trim().toUpperCase();
    if (symbol.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a ticker symbol')),
      );
      return;
    }

    final stock = PortfolioStock(symbol: symbol);
    ref.read(portfolioProvider.notifier).addStock(stock);

    _tickerController.clear();
    Navigator.of(context).pop();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$symbol added to portfolio')));
  }

  void _removeStock(String symbol) {
    ref.read(portfolioProvider.notifier).removeStock(symbol);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$symbol removed from portfolio')));
  }
}
