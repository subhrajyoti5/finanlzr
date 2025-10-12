import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finanlzr/core/services/coinbase_api_service.dart';
import 'package:finanlzr/core/services/screener_api_service.dart';
import 'package:finanlzr/core/services/screener_web_scraper_service.dart';
import 'package:finanlzr/core/providers/api_provider.dart';
import 'package:finanlzr/features/results/models/analysis_data.dart';

// State class for analysis data
class AnalysisState {
  final AnalysisData? data;
  final bool isLoading;
  final String? error;

  const AnalysisState({this.data, this.isLoading = false, this.error});

  AnalysisState copyWith({AnalysisData? data, bool? isLoading, String? error}) {
    return AnalysisState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// StateNotifier for analysis data
class AnalysisNotifier extends StateNotifier<AnalysisState> {
  final CoinbaseApiService _coinbaseApiService;
  final ScreenerApiService _screenerApiService;
  final ScreenerWebScraperService _webScraperService;

  AnalysisNotifier(
    this._coinbaseApiService,
    this._screenerApiService,
    this._webScraperService,
  ) : super(const AnalysisState());

  Future<void> fetchAnalysis(
    String ticker, {
    TimePeriod period = TimePeriod.month,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      AnalysisData? data;

      // Check if it's an Indian stock and use Screener API for fundamentals + Yahoo Finance for price and historical data
      if (_screenerApiService.isIndianStock(ticker)) {
        print(
          'Detected Indian stock: $ticker, using Screener.in for fundamentals + Yahoo Finance for price and historical data',
        );
        data = await _screenerApiService.getIndianAnalysisData(
          ticker,
          period: period,
        );

        // Fetch additional detailed data from web scraping
        if (data != null) {
          print(
            'Fetching additional data from Screener.in web scraping for: $ticker',
          );
          final scrapedData = await _webScraperService.scrapeCompanyData(
            ticker,
          );
          if (scrapedData != null) {
            data = AnalysisData(
              price: data.price,
              prediction: data.prediction,
              sentiment: data.sentiment,
              historicalPrices: data.historicalPrices,
              candlestickData: data.candlestickData,
              currency: data.currency,
              companyOverview: scrapedData['overview'] as Map<String, dynamic>?,
              keyMetrics: scrapedData['keyMetrics'] as Map<String, dynamic>?,
              quarterlyResults:
                  scrapedData['quarterlyResults']
                      as List<Map<String, dynamic>>?,
              profitLoss: scrapedData['profitLoss'] as Map<String, dynamic>?,
              balanceSheet:
                  scrapedData['balanceSheet'] as Map<String, dynamic>?,
              cashFlow: scrapedData['cashFlow'] as Map<String, dynamic>?,
              ratios: scrapedData['ratios'] as Map<String, dynamic>?,
              shareholding:
                  scrapedData['shareholding'] as Map<String, dynamic>?,
              peers: scrapedData['peers'] as List<Map<String, dynamic>>?,
            );
          }
        }
      } else {
        // Use Coinbase/Yahoo Finance for international stocks/crypto
        print('Using Yahoo Finance for: $ticker with period: $period');
        data = await _coinbaseApiService.getAnalysisData(
          ticker,
          period: period,
        );
      }

      if (data != null) {
        state = state.copyWith(data: data, isLoading: false);
      } else {
        // Try quick raw checks to provide a clearer error message
        String reason = 'Failed to fetch data for $ticker.';
        try {
          final stockRaw = await _coinbaseApiService.getStockData(ticker);
          if (stockRaw != null) {
            reason =
                'Received raw stock data for $ticker but failed to process it.';
          } else {
            final cryptoRaw = await _coinbaseApiService.getCryptoData(ticker);
            if (cryptoRaw != null) {
              reason =
                  'Received raw crypto data for $ticker but failed to process it.';
            } else {
              reason =
                  'No data found for $ticker. Please check the ticker symbol (e.g. AAPL for Apple, RELIANCE for Reliance Industries).';
            }
          }
        } catch (e) {
          reason =
              'Failed to fetch data for $ticker due to an API error. ${e.toString()}';
        }

        state = state.copyWith(isLoading: false, error: reason);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An error occurred: ${e.toString()}',
      );
    }
  }
}

// Provider for the analysis state
final analysisProvider = StateNotifierProvider<AnalysisNotifier, AnalysisState>(
  (ref) {
    final coinbaseApiService = ref.watch(coinbaseApiServiceProvider);
    final screenerApiService = ref.watch(screenerApiServiceProvider);
    final webScraperService = ref.watch(screenerWebScraperServiceProvider);
    return AnalysisNotifier(
      coinbaseApiService,
      screenerApiService,
      webScraperService,
    );
  },
);
