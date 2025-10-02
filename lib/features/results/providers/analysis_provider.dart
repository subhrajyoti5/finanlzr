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
        state = state.copyWith(
          isLoading: false,
          error:
              'Failed to fetch data for $ticker. Please check the ticker symbol.',
        );
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
