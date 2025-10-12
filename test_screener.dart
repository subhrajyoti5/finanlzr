import 'package:finanlzr/core/services/screener_api_service.dart';

void main() async {
  final screenerService = ScreenerApiService();

  // Test with a popular Indian stock
  print('Testing Screener.in API with RELIANCE...');
  final data = await screenerService.getIndianStockData('RELIANCE');

  if (data != null) {
    print('✅ Successfully fetched data for RELIANCE');
    print('Company Name: ${data['companyName']}');
    print('Current Price: ${data['currentPrice']}');
    print('Market Cap: ${data['marketCap']}');
    print('P/E Ratio: ${data['peRatio']}');
    print('ROE: ${data['roe']}');
  } else {
    print('❌ Failed to fetch data for RELIANCE');
  }

  // Test analysis data
  print('\nTesting analysis data...');
  final analysisData = await screenerService.getIndianAnalysisData('TCS');

  if (analysisData != null) {
    print('✅ Successfully fetched analysis data for TCS');
    print('Price: ${analysisData.price}');
    print('Prediction: ${analysisData.prediction}');
    print('Sentiment: ${analysisData.sentiment}');
    print('Currency: ${analysisData.currency}');
  } else {
    print('❌ Failed to fetch analysis data for TCS');
  }

  // Test stock detection
  print('\nTesting stock detection...');
  print(
    'Is RELIANCE an Indian stock? ${screenerService.isIndianStock('RELIANCE')}',
  );
  print('Is AAPL an Indian stock? ${screenerService.isIndianStock('AAPL')}');
  print('Is BTC an Indian stock? ${screenerService.isIndianStock('BTC')}');
}
