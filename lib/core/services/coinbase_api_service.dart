import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:finanlzr/features/results/models/analysis_data.dart';

class CoinbaseApiService {
  static const String _coinMarketCapUrl =
      'https://pro-api.coinmarketcap.com/v1';
  static const String _yahooFinanceUrl =
      'https://query1.finance.yahoo.com/v8/finance/chart';

  String get _apiKey => dotenv.env['COINMARKETCAP_API_KEY'] ?? '';

  // Comprehensive list of top 100+ crypto symbols from CoinMarketCap
  static const List<String> _cryptoSymbols = [
    // Top 10
    'BTC', 'ETH', 'XRP', 'USDT', 'BNB', 'SOL', 'USDC', 'DOGE', 'TRX', 'ADA',

    // Top 11-30
    'HYPE', 'LINK', 'USDE', 'SUI', 'XLM', 'AVAX', 'BCH', 'HBAR', 'LTC', 'LEO',
    'CRO', 'SHIB', 'TON', 'DOT', 'MNT', 'XMR', 'DAI', 'UNI', 'WLFI', 'ENA',

    // Top 31-60
    'AAVE', 'PEPE', 'OKB', 'NEAR', 'BGB', 'APT', 'TAO', 'ETC', 'ASTER', 'ONDO',
    'WLD', 'IP', 'USD1', 'POL', 'MATIC', 'PUMP', 'PYUSD', 'ICP', 'ARB', 'M',
    '2Z', 'PI', 'KAS', 'ZEC', 'VET', 'KCS', 'ATOM', 'PENGU', 'ALGO', 'MYX',

    // Top 61-100
    'FLR', 'RENDER', 'SEI', 'XPL', 'BONK', 'FIL', 'SKY', 'TRUMP', 'JUP', 'FET',
    'IMX', 'XDC', 'GT', 'OP', 'QNT', 'INJ', 'TIA', 'SPX', 'PAXG', 'STX',
    'LDO',
    'FDUSD',
    'AERO',
    'CRV',
    'DEXE',
    'CAKE',
    'KAIA',
    'XAUT',
    'GRT',
    'PYTH',
    'ETHFI',
    'PENDLE',
    'FLOKI',
    'ENS',
    'RAY',
    'S',
    'NEXO',
    'RLUSD',
    'WIF',
    'CFX',

    // Additional popular cryptos
    'XTZ', 'THETA', 'FTM', 'SAND', 'MANA', 'AXS', 'GALA', 'CHZ', 'LRC', 'ENJ',
    'ENJIN', 'BAT', 'ZRX', 'COMP', 'MKR', 'SNX', 'YFI', 'SUSHI', 'LUNA', 'UST',
    'BUSD',
    'TUSD',
    'PAXS',
    'GUSD',
    'HUSD',
    'RSR',
    'RUNE',
    'EGLD',
    'ZIL',
    'IOST',
    'ONT', 'ICX', 'QTUM', 'WAVES', 'RVN', 'DASH', 'DCR', 'BTG', 'ZEN', 'DGB',
    'SC', 'LSK', 'STEEM', 'NANO', 'DENT', 'IOTA', 'HOT', 'ANKR', 'ONE', 'CELO',
  ];

  /// Determines if the ticker is a cryptocurrency
  bool _isCrypto(String ticker) {
    return _cryptoSymbols.contains(ticker.toUpperCase());
  }

  /// Fetches real cryptocurrency price data from CoinMarketCap
  /// Works with crypto symbols: BTC, ETH, etc.
  Future<Map<String, dynamic>?> getCryptoData(String symbol) async {
    try {
      print('Fetching crypto data for: $symbol');
      final url = Uri.parse(
        '$_coinMarketCapUrl/cryptocurrency/quotes/latest?symbol=$symbol',
      );
      print('URL: $url');

      final response = await http
          .get(
            url,
            headers: {
              'X-CMC_PRO_API_KEY': _apiKey,
              'Accept': 'application/json',
            },
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              print('Request timed out');
              throw Exception('Timeout');
            },
          );
      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Response data received');

        final cryptoData = data['data'][symbol];
        if (cryptoData == null) {
          print('No data for symbol: $symbol');
          return null;
        }

        final quote = cryptoData['quote']['USD'];
        final currentPrice = quote['price']?.toDouble();
        final percentChange24h = quote['percent_change_24h']?.toDouble() ?? 0.0;
        final percentChange7d = quote['percent_change_7d']?.toDouble() ?? 0.0;

        if (currentPrice == null) {
          return null;
        }

        print('Current price: $currentPrice');
        print('24h change: $percentChange24h%');
        print('7d change: $percentChange7d%');

        return {
          'currentPrice': currentPrice,
          'percentChange24h': percentChange24h,
          'percentChange7d': percentChange7d,
          'symbol': symbol,
          'name': cryptoData['name'] ?? symbol,
        };
      } else {
        print('Failed with status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error in getCryptoData: $e');
      return null;
    }
  }

  /// Fetches stock data from Yahoo Finance
  /// Works with stock tickers: AAPL, GOOGL, RELIANCE.NS, TCS.NS, etc.
  Future<Map<String, dynamic>?> getStockData(String ticker) async {
    try {
      print('Fetching stock data for: $ticker');
      final url = Uri.parse('$_yahooFinanceUrl/$ticker?range=1mo&interval=1d');
      print('URL: $url');

      final response = await http
          .get(url)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              print('Request timed out');
              throw Exception('Timeout');
            },
          );
      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Response data received');

        final result = data['chart']?['result'];
        if (result == null || result.isEmpty) {
          print('No data for ticker: $ticker');
          return null;
        }

        final quote = result[0];
        final meta = quote['meta'];

        // Debug: Print meta keys to see what's available
        print('Meta keys: ${meta?.keys.toList()}');

        // Try different field names for current price
        double? currentPrice =
            meta?['regularMarketPrice']?.toDouble() ??
            meta?['previousClose']?.toDouble() ??
            meta?['chartPreviousClose']?.toDouble();

        double? previousClose =
            meta?['previousClose']?.toDouble() ??
            meta?['chartPreviousClose']?.toDouble();

        // Get historical OHLC data for candlestick charts
        final indicators = quote['indicators'];
        final quoteData = indicators?['quote'];
        List<Map<String, dynamic>> candlestickData = [];
        List<double> historicalPrices = [];

        if (quoteData != null && quoteData.isNotEmpty) {
          final quoteItem = quoteData[0];
          final openPrices = quoteItem['open'] as List?;
          final highPrices = quoteItem['high'] as List?;
          final lowPrices = quoteItem['low'] as List?;
          final closePrices = quoteItem['close'] as List?;

          // Create candlestick data and extract close prices for backward compatibility
          if (openPrices != null &&
              highPrices != null &&
              lowPrices != null &&
              closePrices != null) {
            final maxLength = [
              openPrices.length,
              highPrices.length,
              lowPrices.length,
              closePrices.length,
            ].reduce((a, b) => a < b ? a : b);
            for (int i = 0; i < maxLength; i++) {
              if (openPrices[i] != null &&
                  highPrices[i] != null &&
                  lowPrices[i] != null &&
                  closePrices[i] != null) {
                final closePrice = (closePrices[i] as num).toDouble();
                candlestickData.add({
                  'open': (openPrices[i] as num).toDouble(),
                  'high': (highPrices[i] as num).toDouble(),
                  'low': (lowPrices[i] as num).toDouble(),
                  'close': closePrice,
                  'volume':
                      0, // Yahoo Finance doesn't provide volume in this endpoint
                });
                historicalPrices.add(closePrice);
              }
            }
          }
        }

        print('Candlestick data count: ${candlestickData.length}');
        if (candlestickData.isNotEmpty) {
          print('Sample candlestick: ${candlestickData.last}');
        }

        // If we have historical prices but no current price, use the last historical price
        if (currentPrice == null && historicalPrices.isNotEmpty) {
          currentPrice = historicalPrices.last;
          print('Using last historical price as current: $currentPrice');
        }

        // If we have historical prices but no previous close, use second to last
        if (previousClose == null && historicalPrices.length > 1) {
          previousClose = historicalPrices[historicalPrices.length - 2];
          print(
            'Using second to last historical price as previous: $previousClose',
          );
        }

        if (currentPrice == null) {
          print('Missing price data - currentPrice is null');
          print('Full meta data: $meta');
          return null;
        }

        // Use current price as previous close if previous close is still null
        previousClose ??= currentPrice;

        print('Current price: $currentPrice');
        print('Previous close: $previousClose');
        print('Historical prices count: ${historicalPrices.length}');

        return {
          'currentPrice': currentPrice,
          'previousClose': previousClose,
          'historicalPrices': historicalPrices,
          'candlestickData': candlestickData,
          'symbol': ticker,
          'name': meta?['symbol'] ?? ticker,
          'currency': meta?['currency'] ?? 'USD',
        };
      } else {
        print('Failed with status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error in getStockData: $e');
      return null;
    }
  }

  /// Fetches analysis data - automatically detects stock vs crypto
  Future<AnalysisData?> getAnalysisData(String ticker) async {
    print('getAnalysisData called for: $ticker');

    // Detect if it's a crypto or stock
    if (_isCrypto(ticker)) {
      print('Detected as cryptocurrency, using CoinMarketCap');
      return _getCryptoAnalysis(ticker);
    } else {
      print('Detected as stock, using Yahoo Finance');
      return _getStockAnalysis(ticker);
    }
  }

  /// Fetches cryptocurrency analysis data from CoinMarketCap
  Future<AnalysisData?> _getCryptoAnalysis(String ticker) async {
    final cryptoData = await getCryptoData(ticker);

    if (cryptoData == null) {
      print('Crypto data is null');
      return null;
    }
    print('Crypto data received, processing...');

    final currentPrice = cryptoData['currentPrice'] as double;
    final percentChange24h = cryptoData['percentChange24h'] as double;
    final percentChange7d = cryptoData['percentChange7d'] as double;

    // Calculate prediction based on recent trends
    final prediction = _calculatePredictionFromPercentChange(
      currentPrice,
      percentChange24h,
      percentChange7d,
    );

    // Calculate sentiment based on price movement
    final sentiment = _calculateSentimentFromPercentChange(
      percentChange24h,
      percentChange7d,
    );

    return AnalysisData(
      price: currentPrice.toStringAsFixed(2),
      prediction: prediction.toStringAsFixed(2),
      sentiment: sentiment,
      historicalPrices: [], // Crypto API doesn't provide historical prices
      currency: 'USD',
    );
  }

  /// Fetches stock analysis data from Yahoo Finance
  Future<AnalysisData?> _getStockAnalysis(String ticker) async {
    final stockData = await getStockData(ticker);

    if (stockData == null) {
      print('Stock data is null');
      return null;
    }
    print('Stock data received, processing...');

    final currentPrice = stockData['currentPrice'] as double;
    final previousClose = stockData['previousClose'] as double;
    final historicalPrices = stockData['historicalPrices'] as List<double>;
    final candlestickData =
        stockData['candlestickData'] as List<Map<String, dynamic>>;
    final currency = stockData['currency'] as String? ?? 'USD';

    // Try external predictor first (tunneled service). Fallback to local heuristic.
    double? externalPrediction;
    if (historicalPrices.isNotEmpty) {
      externalPrediction = await _callExternalPredictor(
        historicalPrices,
        periods: 1,
      );
    }
    final double predictionValue =
        externalPrediction ??
        _calculatePredictionFromHistory(currentPrice, historicalPrices);

    // Calculate sentiment based on price movement
    final sentiment = _calculateSentimentFromHistory(
      currentPrice,
      previousClose,
      historicalPrices,
    );

    return AnalysisData(
      price: currentPrice.toStringAsFixed(2),
      prediction: predictionValue.toStringAsFixed(2),
      sentiment: sentiment,
      historicalPrices: historicalPrices,
      candlestickData: candlestickData,
      currency: currency,
    );
  }

  /// Calls an external predictor service (configured via PREDICTOR_URL in .env).
  /// Returns the predicted next value or null on error/unavailable.
  Future<double?> _callExternalPredictor(
    List<double> history, {
    int periods = 1,
  }) async {
    try {
      final url =
          dotenv.env['PREDICTOR_URL'] ?? 'http://127.0.0.1:5000/predict';
      final resp = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'historical': history, 'periods': periods}),
          )
          .timeout(const Duration(seconds: 8));

      if (resp.statusCode == 200) {
        final Map<String, dynamic> body =
            jsonDecode(resp.body) as Map<String, dynamic>;
        final preds = (body['predictions'] as List<dynamic>?)
            ?.map((e) => (e as num).toDouble())
            .toList();
        if (preds != null && preds.isNotEmpty) {
          return preds.first;
        }
      } else {
        print('Predictor returned ${resp.statusCode}: ${resp.body}');
      }
    } catch (e) {
      print('Error calling predictor service: $e');
    }
    return null;
  }

  /// Calculate prediction based on recent percent changes (for crypto)
  double _calculatePredictionFromPercentChange(
    double currentPrice,
    double percentChange24h,
    double percentChange7d,
  ) {
    // Use weighted average of 24h and 7d trends
    final shortTermTrend = percentChange24h / 100;
    final longTermTrend = percentChange7d / 100;
    final combinedTrend = (shortTermTrend * 0.7) + (longTermTrend * 0.3);
    return currentPrice * (1 + combinedTrend * 0.5);
  }

  /// Calculate sentiment from percent changes (for crypto)
  String _calculateSentimentFromPercentChange(
    double percentChange24h,
    double percentChange7d,
  ) {
    if (percentChange24h > 5 && percentChange7d > 10) return 'Bullish';
    if (percentChange24h < -5 && percentChange7d < -10) return 'Bearish';
    if (percentChange24h > 2 || percentChange7d > 5) return 'Bullish';
    if (percentChange24h < -2 || percentChange7d < -5) return 'Bearish';
    return 'Neutral';
  }

  /// Calculate prediction from historical prices (for stocks)
  double _calculatePredictionFromHistory(
    double currentPrice,
    List<double> historicalPrices,
  ) {
    if (historicalPrices.length < 2) {
      return currentPrice * 1.02; // Default 2% increase
    }

    // Calculate simple moving average
    final sum = historicalPrices.reduce((a, b) => a + b);
    final average = sum / historicalPrices.length;

    // Calculate trend
    final trend = currentPrice - average;

    // Project forward based on trend
    return currentPrice + (trend * 0.5);
  }

  /// Calculate sentiment from historical prices (for stocks)
  String _calculateSentimentFromHistory(
    double currentPrice,
    double previousClose,
    List<double> historicalPrices,
  ) {
    if (historicalPrices.length < 2) {
      return 'Neutral';
    }

    // Calculate percentage change from previous close
    final dayChange = ((currentPrice - previousClose) / previousClose) * 100;

    // Calculate trend over recent prices
    final recentPrices = historicalPrices.length > 5
        ? historicalPrices.sublist(historicalPrices.length - 5)
        : historicalPrices;
    final avgPrice = recentPrices.reduce((a, b) => a + b) / recentPrices.length;
    final trendChange = ((currentPrice - avgPrice) / avgPrice) * 100;

    // Determine sentiment
    if (dayChange > 2 && trendChange > 3) return 'Bullish';
    if (dayChange < -2 && trendChange < -3) return 'Bearish';
    if (dayChange > 1 || trendChange > 2) return 'Bullish';
    if (dayChange < -1 || trendChange < -2) return 'Bearish';
    return 'Neutral';
  }
}
