class AnalysisData {
  final String price;
  final String prediction;
  final String sentiment;
  final List<double> historicalPrices;
  final List<Map<String, dynamic>> candlestickData;
  final String currency;

  // Additional scraped data from Screener.in
  final Map<String, dynamic>? companyOverview;
  final Map<String, dynamic>? keyMetrics;
  final List<Map<String, dynamic>>? quarterlyResults;
  final Map<String, dynamic>? profitLoss;
  final Map<String, dynamic>? balanceSheet;
  final Map<String, dynamic>? cashFlow;
  final Map<String, dynamic>? ratios;
  final Map<String, dynamic>? shareholding;
  final List<Map<String, dynamic>>? peers;

  const AnalysisData({
    required this.price,
    required this.prediction,
    required this.sentiment,
    this.historicalPrices = const [],
    this.candlestickData = const [],
    this.currency = 'USD',
    this.companyOverview,
    this.keyMetrics,
    this.quarterlyResults,
    this.profitLoss,
    this.balanceSheet,
    this.cashFlow,
    this.ratios,
    this.shareholding,
    this.peers,
  });

  factory AnalysisData.fromJson(Map<String, dynamic> json) {
    return AnalysisData(
      price: json['price'] as String,
      prediction: json['prediction'] as String,
      sentiment: json['sentiment'] as String,
      historicalPrices:
          (json['historicalPrices'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
      candlestickData:
          (json['candlestickData'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [],
      currency: json['currency'] as String? ?? 'USD',
      companyOverview: json['companyOverview'] as Map<String, dynamic>?,
      keyMetrics: json['keyMetrics'] as Map<String, dynamic>?,
      quarterlyResults: (json['quarterlyResults'] as List<dynamic>?)
          ?.map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      profitLoss: json['profitLoss'] as Map<String, dynamic>?,
      balanceSheet: json['balanceSheet'] as Map<String, dynamic>?,
      cashFlow: json['cashFlow'] as Map<String, dynamic>?,
      ratios: json['ratios'] as Map<String, dynamic>?,
      shareholding: json['shareholding'] as Map<String, dynamic>?,
      peers: (json['peers'] as List<dynamic>?)
          ?.map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'price': price,
      'prediction': prediction,
      'sentiment': sentiment,
      'historicalPrices': historicalPrices,
      'candlestickData': candlestickData,
      'currency': currency,
      'companyOverview': companyOverview,
      'keyMetrics': keyMetrics,
      'quarterlyResults': quarterlyResults,
      'profitLoss': profitLoss,
      'balanceSheet': balanceSheet,
      'cashFlow': cashFlow,
      'ratios': ratios,
      'shareholding': shareholding,
      'peers': peers,
    };
  }
}
