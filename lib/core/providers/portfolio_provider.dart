import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:finanlzr/shared/models/portfolio_stock.dart';
import 'package:finanlzr/core/services/coinbase_api_service.dart';
import 'package:finanlzr/core/providers/api_provider.dart';

final portfolioProvider =
    StateNotifierProvider<PortfolioNotifier, PortfolioState>((ref) {
      final apiService = ref.watch(coinbaseApiServiceProvider);
      return PortfolioNotifier(apiService);
    });

class PortfolioState {
  final List<PortfolioStock> stocks;
  final bool isLoading;

  const PortfolioState({required this.stocks, this.isLoading = false});

  PortfolioState copyWith({List<PortfolioStock>? stocks, bool? isLoading}) {
    return PortfolioState(
      stocks: stocks ?? this.stocks,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class PortfolioNotifier extends StateNotifier<PortfolioState> {
  final CoinbaseApiService _apiService;

  PortfolioNotifier(this._apiService)
    : super(const PortfolioState(stocks: [])) {
    _loadPortfolio();
  }

  static const String _portfolioKey = 'portfolio_stocks';

  Future<void> _loadPortfolio() async {
    final prefs = await SharedPreferences.getInstance();
    final portfolioJson = prefs.getStringList(_portfolioKey) ?? [];
    final stocks = portfolioJson
        .map((json) => PortfolioStock.fromJson(jsonDecode(json)))
        .toList();
    state = PortfolioState(stocks: stocks);
    // Fetch current prices for all stocks
    await _updatePrices();
  }

  Future<void> _updatePrices() async {
    if (state.stocks.isEmpty) return;

    state = state.copyWith(isLoading: true);
    final updatedStocks = <PortfolioStock>[];
    for (final stock in state.stocks) {
      final priceData = await _apiService.getCurrentPrice(stock.symbol);
      if (priceData != null) {
        updatedStocks.add(
          stock.copyWith(
            currentPrice: priceData['price'],
            changePercent: priceData['changePercent'],
          ),
        );
      } else {
        updatedStocks.add(stock);
      }
    }
    state = state.copyWith(stocks: updatedStocks, isLoading: false);
  }

  Future<void> _savePortfolio() async {
    final prefs = await SharedPreferences.getInstance();
    final portfolioJson = state.stocks
        .map((stock) => jsonEncode(stock.toJson()))
        .toList();
    await prefs.setStringList(_portfolioKey, portfolioJson);
  }

  Future<void> addStock(PortfolioStock stock) async {
    if (!state.stocks.any((s) => s.symbol == stock.symbol)) {
      // Fetch current price for the new stock
      final priceData = await _apiService.getCurrentPrice(stock.symbol);
      final updatedStock = stock.copyWith(
        currentPrice: priceData?['price'],
        changePercent: priceData?['changePercent'],
      );
      state = state.copyWith(stocks: [...state.stocks, updatedStock]);
      await _savePortfolio();
    }
  }

  Future<void> removeStock(String symbol) async {
    state = state.copyWith(
      stocks: state.stocks.where((stock) => stock.symbol != symbol).toList(),
    );
    await _savePortfolio();
  }

  Future<void> updateStockPrices(List<PortfolioStock> updatedStocks) async {
    state = state.copyWith(stocks: updatedStocks);
    await _savePortfolio();
  }

  Future<void> refreshPrices() async {
    await _updatePrices();
    await _savePortfolio();
  }
}
