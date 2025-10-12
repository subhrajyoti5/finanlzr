import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;
import 'dart:convert';
import 'package:finanlzr/features/results/models/analysis_data.dart';

enum TimePeriod { day, week, month, threeYear, lifetime }

class ScreenerApiService {
  static const String _baseUrl = 'https://www.screener.in';
  static const String _yahooFinanceUrl =
      'https://query1.finance.yahoo.com/v8/finance/chart';

  // Helper method to get range and interval based on time period
  static Map<String, String> _getRangeAndInterval(TimePeriod period) {
    switch (period) {
      case TimePeriod.day:
        return {'range': '1d', 'interval': '5m'};
      case TimePeriod.week:
        return {'range': '5d', 'interval': '1h'};
      case TimePeriod.month:
        return {'range': '1mo', 'interval': '1d'};
      case TimePeriod.threeYear:
        return {'range': '3y', 'interval': '1mo'};
      case TimePeriod.lifetime:
        return {'range': 'max', 'interval': '1mo'};
    }
  }

  // Common Indian stock symbols (NSE/BSE)
  static const List<String> _indianStockSymbols = [
    // Banking & Financial Services
    'HDFCBANK', 'ICICIBANK', 'KOTAKBANK', 'AXISBANK', 'SBIN',
    'BAJFINANCE', 'BAJAJFINSV', 'HDFCLIFE', 'ICICILIFE', 'SBILIFE',

    // IT & Technology
    'TCS', 'INFY', 'WIPRO', 'HCLTECH', 'TECHM',
    'LTIM', 'MPHASIS', 'COFORGE', 'PERSISTENT', 'TATAELXSI',

    // Oil & Gas
    'RELIANCE', 'ONGC', 'NTPC', 'GAIL', 'IOC',
    'BPCL', 'HPCL', 'PETRONET', 'IGL', 'GUJGASLTD',

    // Pharmaceuticals
    'SUNPHARMA', 'DRREDDY', 'CIPLA', 'DIVISLAB', 'APOLLOHOSP',
    'LUPIN', 'AUROPHARMA', 'ALKEM', 'TORNTPHARM', 'GLENMARK',

    // FMCG
    'ITC', 'HINDUNILVR', 'NESTLEIND', 'BRITANNIA', 'DABUR',
    'MARICO', 'COLPAL', 'GODREJCP', 'EMAMILTD', 'BAJAJCON',

    // Auto & Auto Ancillaries
    'MARUTI', 'TATAMOTORS', 'BAJAJ-AUTO', 'HEROMOTOCO', 'M&M',
    'EICHERMOT', 'TVSMOTOR', 'BOSCHLTD', 'ASHOKLEY', 'AMARAJABAT',

    // Metals & Mining
    'TATASTEEL', 'JSWSTEEL', 'HINDALCO', 'NALCO', 'COALINDIA',
    'VEDL', 'HINDCOPPER', 'MOIL', 'NMDC', 'SAIL',

    // Cement
    'ULTRACEMCO', 'SHREECEM', 'AMBUJACEM', 'ACC', 'DALBHARAT',
    'JKCEMENT', 'RAMCOCEM', 'BIRLACORPN', 'HEIDELBERG', 'ORIENTCEM',

    // Power
    'NTPC', 'POWERGRID', 'ADANIPOWER', 'TATAPOWER', 'JSWENERGY',
    'NHPC', 'SJVN', 'GAIL', 'NLCINDIA', 'RECLTD',

    // Telecom
    'BHARTIARTL', 'IDEA', 'VODAFONE', 'TATACOMM', 'MTNL',

    // Retail
    'DMART', 'TRENT', 'VBL', 'ABFRL', 'SHOPERSTOP',

    // Top 50 by Market Cap (additional)
    'ADANIPORTS', 'ADANIENT', 'ADANIGREEN', 'ADANITRANS', 'ATGL',
    'AWL', 'ABB', 'ADVENZYMES', 'AEGISCHEM', 'AFFLE',
    'AJANTPHARM', 'AKZOINDIA', 'APLLTD', 'APLAPOLLO', 'AUBANK',
    'AARTIDRUGS', 'AARTIIND', 'AAVAS', 'ABBOTINDIA', 'ADANIGAS',
    'ABCAPITAL', 'ABFRL', 'ACCELYA', 'ACC', 'ACE', 'ADANIENSOL',
    'ADANIPOWER', 'ADANIPORTS', 'ADANITRANS', 'ATGL', 'AWL',
    'DMART', 'TRENT', 'VBL', 'SHOPERSTOP', 'NYKAA', 'POLYCAB',
    'CAMS', 'CDSL', 'CROMPTON', 'CUB', 'CYIENT', 'DIXON',
    'LICI', 'LODHA', 'MOTHERSON', 'MRF', 'OIL', 'PAYTM',
    'PIIND', 'PVRINOX', 'RAIN', 'RAILTEL', 'RBLBANK', 'RVNL',
    'SAFARI', 'SAPPHIRE', 'SUMICHEM', 'SUNTV', 'SUPREMEIND',
    'SUVENPHAR', 'SWANENERGY', 'SYNGENE', 'TANLA', 'TEAMLEASE',
    'TECHNOE', 'THERMAX', 'THYROCARE', 'TIINDIA', 'TIMKEN',
    'TITAN', 'TORNTPOWER', 'TRENT', 'TRIDENT', 'TRIVENI',
    'TTKPRESTIG', 'TV18BRDCST', 'TVSMOTOR', 'UBL', 'UCOBANK',
    'UFLEX', 'UJJIVAN', 'UJJIVANSFB', 'ULTRACEMCO', 'UNIONBANK',
    'UNOMINDA', 'UPL', 'UTIAMC', 'VAIBHAVGBL', 'VARROC',
    'VBL', 'VEDL', 'VENKEYS', 'VIJAYA', 'VINATIORGA',
    'VIPIND', 'VMART', 'VOLTAS', 'VTL', 'WELCORP', 'WELSPUNIND',
    'WESTLIFE', 'WHIRLPOOL', 'WIPRO', 'WOCKPHARMA', 'YESBANK',
    'ZEEL', 'ZENSARTECH', 'ZFCVINDIA', 'ZOMATO', 'ZYDUSLIFE',
  ];

  /// Check if a symbol is an Indian stock
  bool isIndianStock(String symbol) {
    return _indianStockSymbols.contains(symbol.toUpperCase());
  }

  /// Get comprehensive stock data from Screener.in
  Future<Map<String, dynamic>?> getIndianStockData(String symbol) async {
    try {
      final url = '$_baseUrl/company/$symbol/consolidated/';
      print('Fetching Indian stock data for: $symbol from $url');

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final document = html_parser.parse(response.body);
        return _parseStockData(document, symbol);
      } else {
        print(
          'Failed to fetch data for $symbol. Status: ${response.statusCode}',
        );
        return null;
      }
    } catch (e) {
      print('Error fetching Indian stock data for $symbol: $e');
      return null;
    }
  }

  /// Parse stock data from Screener.in HTML
  Map<String, dynamic> _parseStockData(dom.Document document, String symbol) {
    final data = <String, dynamic>{};

    try {
      // Extract company name
      final companyNameElement = document.querySelector('h1');
      data['companyName'] = companyNameElement?.text.trim() ?? symbol;

      // Extract current price - look for span containing ₹
      final priceSpans = document
          .querySelectorAll('span')
          .where(
            (span) =>
                span.text.contains('₹') &&
                RegExp(r'₹\s*[\d,]+').hasMatch(span.text),
          )
          .toList();

      if (priceSpans.isNotEmpty) {
        final priceText = priceSpans.first.text.trim();
        data['currentPrice'] = _extractPrice(priceText);
      }

      // Extract financial data from the ratios section
      final ratioItems = document.querySelectorAll(
        'li.flex.flex-space-between',
      );
      for (final item in ratioItems) {
        final nameElement = item.querySelector('.name');
        final name = nameElement?.text.trim() ?? '';

        if (name.contains('Market Cap')) {
          final numberElement = item.querySelector('.number');
          if (numberElement != null) {
            data['marketCap'] = numberElement.text.trim();
          }
        } else if (name.contains('Stock P/E')) {
          final numberElement = item.querySelector('.number');
          if (numberElement != null) {
            data['peRatio'] = numberElement.text.trim();
          }
        } else if (name.contains('ROE')) {
          final numberElement = item.querySelector('.number');
          if (numberElement != null) {
            data['roe'] = numberElement.text.trim();
          }
        } else if (name.contains('ROCE')) {
          final numberElement = item.querySelector('.number');
          if (numberElement != null) {
            data['roce'] = numberElement.text.trim();
          }
        } else if (name.contains('Dividend Yield')) {
          final numberElement = item.querySelector('.number');
          if (numberElement != null) {
            data['dividendYield'] = numberElement.text.trim();
          }
        }
      }

      // Extract profit growth
      final profitGrowthElement = document.querySelector('.profit-growth');
      data['profitGrowth'] = profitGrowthElement?.text.trim() ?? 'N/A';

      // Extract quarterly results (if available)
      final quarterlyData = _extractQuarterlyResults(document);
      data['quarterlyResults'] = quarterlyData;

      // Extract balance sheet data (if available)
      final balanceSheetData = _extractBalanceSheet(document);
      data['balanceSheet'] = balanceSheetData;

      // Extract cash flow data (if available)
      final cashFlowData = _extractCashFlow(document);
      data['cashFlow'] = cashFlowData;

      print('Successfully parsed data for $symbol');
      print('Current Price: ${data['currentPrice']}');
      print('Market Cap: ${data['marketCap']}');
      print('P/E Ratio: ${data['peRatio']}');
    } catch (e) {
      print('Error parsing data for $symbol: $e');
    }

    return data;
  }

  /// Extract price from text (remove currency symbols, etc.)
  String _extractPrice(String priceText) {
    // Remove currency symbols and extra text
    final cleaned = priceText.replaceAll('₹', '').replaceAll(',', '').trim();
    final priceMatch = RegExp(r'(\d+\.?\d*)').firstMatch(cleaned);
    return priceMatch?.group(1) ?? priceText;
  }

  /// Extract quarterly results data
  List<Map<String, dynamic>> _extractQuarterlyResults(dom.Document document) {
    final results = <Map<String, dynamic>>[];

    try {
      final quarterlyTable = document.querySelector('.quarterly-results table');
      if (quarterlyTable != null) {
        final rows = quarterlyTable.querySelectorAll('tr');
        for (final row in rows.skip(1)) {
          // Skip header row
          final cells = row.querySelectorAll('td');
          if (cells.length >= 4) {
            results.add({
              'quarter': cells[0].text.trim(),
              'sales': cells[1].text.trim(),
              'expenses': cells[2].text.trim(),
              'profit': cells[3].text.trim(),
            });
          }
        }
      }
    } catch (e) {
      print('Error extracting quarterly results: $e');
    }

    return results;
  }

  /// Extract balance sheet data
  Map<String, dynamic> _extractBalanceSheet(dom.Document document) {
    final balanceSheet = <String, dynamic>{};

    try {
      final bsTable = document.querySelector('.balance-sheet table');
      if (bsTable != null) {
        final rows = bsTable.querySelectorAll('tr');
        for (final row in rows) {
          final cells = row.querySelectorAll('td, th');
          if (cells.length >= 2) {
            final key = cells[0].text.trim();
            final value = cells[1].text.trim();
            balanceSheet[key] = value;
          }
        }
      }
    } catch (e) {
      print('Error extracting balance sheet: $e');
    }

    return balanceSheet;
  }

  /// Extract cash flow data
  Map<String, dynamic> _extractCashFlow(dom.Document document) {
    final cashFlow = <String, dynamic>{};

    try {
      final cfTable = document.querySelector('.cash-flow table');
      if (cfTable != null) {
        final rows = cfTable.querySelectorAll('tr');
        for (final row in rows) {
          final cells = row.querySelectorAll('td, th');
          if (cells.length >= 2) {
            final key = cells[0].text.trim();
            final value = cells[1].text.trim();
            cashFlow[key] = value;
          }
        }
      }
    } catch (e) {
      print('Error extracting cash flow: $e');
    }

    return cashFlow;
  }

  /// Get analysis data for Indian stocks (integrates with existing AnalysisData model)
  Future<AnalysisData?> getIndianAnalysisData(
    String ticker, {
    TimePeriod period = TimePeriod.month,
  }) async {
    try {
      final stockData = await getIndianStockData(ticker);
      if (stockData == null) return null;

      // Fetch historical data and current price from Yahoo Finance
      final yahooData = await _getYahooFinanceData(ticker, period: period);

      // Use Yahoo Finance current price if available, otherwise fallback to screener.in
      final yahooPrice = yahooData?['currentPrice'] as double?;
      final price = yahooPrice != null
          ? yahooPrice.toStringAsFixed(2)
          : (stockData['currentPrice']?.toString() ?? 'N/A');

      // Generate basic prediction based on financial ratios
      final prediction = _generatePrediction(stockData);

      // Generate sentiment based on key metrics
      final sentiment = _generateSentiment(stockData);

      // Use Yahoo Finance data for historical prices and candlestick data
      final historicalPrices =
          yahooData?['historicalPrices'] as List<double>? ?? <double>[];
      final candlestickData =
          yahooData?['candlestickData'] as List<Map<String, dynamic>>? ??
          <Map<String, dynamic>>[];

      return AnalysisData(
        price: price,
        prediction: prediction,
        sentiment: sentiment,
        historicalPrices: historicalPrices,
        candlestickData: candlestickData,
        currency: 'INR',
      );
    } catch (e) {
      print('Error getting Indian analysis data for $ticker: $e');
      return null;
    }
  }

  /// Generate prediction based on financial metrics
  String _generatePrediction(Map<String, dynamic> data) {
    try {
      final peRatio = _parseDouble(data['peRatio']);
      final roe = _parseDouble(data['roe']);
      final salesGrowth = _parseDouble(data['salesGrowth']);

      // Simple prediction logic based on valuation and growth
      if (peRatio != null && peRatio < 20 && roe != null && roe > 15) {
        if (salesGrowth != null && salesGrowth > 10) {
          return 'Strong Buy - Undervalued with good growth';
        } else {
          return 'Buy - Undervalued with stable growth';
        }
      } else if (peRatio != null && peRatio > 30) {
        return 'Hold/Sell - Potentially overvalued';
      } else {
        return 'Hold - Fair valuation';
      }
    } catch (e) {
      return 'Unable to generate prediction - insufficient data';
    }
  }

  /// Generate sentiment based on key metrics
  String _generateSentiment(Map<String, dynamic> data) {
    try {
      final roe = _parseDouble(data['roe']);
      final roce = _parseDouble(data['roce']);
      final debtToEquity = _parseDouble(data['debtToEquity']);
      final dividendYield = _parseDouble(data['dividendYield']);

      int score = 0;

      // ROE > 15 is good
      if (roe != null && roe > 15)
        score += 2;
      else if (roe != null && roe > 10)
        score += 1;

      // ROCE > 15 is good
      if (roce != null && roce > 15)
        score += 2;
      else if (roce != null && roce > 10)
        score += 1;

      // Debt to equity < 1 is good
      if (debtToEquity != null && debtToEquity < 1) score += 1;

      // Dividend yield > 2% is good
      if (dividendYield != null && dividendYield > 2) score += 1;

      if (score >= 4)
        return 'Bullish';
      else if (score >= 2)
        return 'Neutral';
      else
        return 'Bearish';
    } catch (e) {
      return 'Neutral';
    }
  }

  /// Parse string to double safely
  double? _parseDouble(dynamic value) {
    if (value == null || value == 'N/A' || value == '') return null;
    try {
      final str = value.toString().replaceAll(',', '').replaceAll('%', '');
      return double.parse(str);
    } catch (e) {
      return null;
    }
  }

  /// Get list of popular Indian stocks
  List<String> getPopularIndianStocks() {
    return _indianStockSymbols.take(50).toList();
  }

  /// Search for Indian stocks by name or symbol
  List<String> searchIndianStocks(String query) {
    final upperQuery = query.toUpperCase();
    return _indianStockSymbols
        .where((symbol) => symbol.contains(upperQuery))
        .toList();
  }

  /// Fetches historical data from Yahoo Finance for Indian stocks
  /// Uses .NS suffix for NSE stocks (e.g., RELIANCE.NS, TCS.NS)
  Future<Map<String, dynamic>?> _getYahooFinanceData(
    String ticker, {
    TimePeriod period = TimePeriod.month,
  }) async {
    try {
      // Add .NS suffix for Indian stocks on Yahoo Finance
      final yahooTicker = ticker.endsWith('.NS') ? ticker : '$ticker.NS';
      print('Fetching Yahoo Finance data for: $yahooTicker');

      final rangeAndInterval = _getRangeAndInterval(period);
      final url = Uri.parse(
        '$_yahooFinanceUrl/$yahooTicker?range=${rangeAndInterval['range']}&interval=${rangeAndInterval['interval']}',
      );
      print('Yahoo Finance URL: $url');

      final response = await http
          .get(url)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              print('Yahoo Finance request timed out');
              throw Exception('Timeout');
            },
          );

      print('Yahoo Finance response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Yahoo Finance data received');

        final result = data['chart']?['result'];
        if (result == null || result.isEmpty) {
          print('No Yahoo Finance data for ticker: $yahooTicker');
          return null;
        }

        final quote = result[0];
        final meta = quote['meta'];

        // Extract current price from meta data
        double? currentPrice;
        try {
          currentPrice =
              meta?['regularMarketPrice']?.toDouble() ??
              meta?['previousClose']?.toDouble() ??
              meta?['chartPreviousClose']?.toDouble();
        } catch (e) {
          print('Error extracting current price from Yahoo Finance: $e');
        }

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

          // Create candlestick data and extract close prices
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

        print('Yahoo Finance historical data count: ${candlestickData.length}');

        return {
          'currentPrice': currentPrice,
          'candlestickData': candlestickData,
          'historicalPrices': historicalPrices,
        };
      } else {
        print('Yahoo Finance API error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching Yahoo Finance data for $ticker: $e');
      return null;
    }
  }
}
