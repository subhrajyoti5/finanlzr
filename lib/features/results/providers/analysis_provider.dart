import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finanlzr/core/services/coinbase_api_service.dart';
import 'package:finanlzr/features/results/models/analysis_data.dart';

// Provider for the API service
final coinbaseApiServiceProvider = Provider<CoinbaseApiService>((ref) {
  return CoinbaseApiService();
});

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
  final CoinbaseApiService _apiService;

  AnalysisNotifier(this._apiService) : super(const AnalysisState());

  Future<void> fetchAnalysis(String ticker) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final data = await _apiService.getAnalysisData(ticker);
      if (data != null) {
        state = state.copyWith(data: data, isLoading: false);
      } else {
        // Try quick raw checks to provide a clearer error message
        String reason = 'Failed to fetch data for $ticker.';
        try {
          final stockRaw = await _apiService.getStockData(ticker);
          if (stockRaw != null) {
            reason =
                'Received raw stock data for $ticker but failed to process it.';
          } else {
            final cryptoRaw = await _apiService.getCryptoData(ticker);
            if (cryptoRaw != null) {
              reason =
                  'Received raw crypto data for $ticker but failed to process it.';
            } else {
              reason =
                  'No data found for $ticker. Please check the ticker symbol (e.g. AAPL for Apple).';
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
    final apiService = ref.watch(coinbaseApiServiceProvider);
    return AnalysisNotifier(apiService);
  },
);
