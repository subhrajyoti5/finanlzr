import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finanlzr/core/services/coinbase_api_service.dart';
import 'package:finanlzr/core/services/screener_api_service.dart';
import 'package:finanlzr/core/services/screener_web_scraper_service.dart';

// Provider for the API service
final coinbaseApiServiceProvider = Provider<CoinbaseApiService>((ref) {
  return CoinbaseApiService();
});

// Provider for the Screener API service
final screenerApiServiceProvider = Provider<ScreenerApiService>((ref) {
  return ScreenerApiService();
});

// Provider for the Screener Web Scraper service
final screenerWebScraperServiceProvider = Provider<ScreenerWebScraperService>((
  ref,
) {
  return ScreenerWebScraperService();
});
