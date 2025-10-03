class AnalysisData {
  final String price;
  final String prediction;
  final String sentiment;
  final List<double> historicalPrices;
  final List<Map<String, dynamic>> candlestickData;
  final String currency;

  const AnalysisData({
    required this.price,
    required this.prediction,
    required this.sentiment,
    this.historicalPrices = const [],
    this.candlestickData = const [],
    this.currency = 'USD',
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
    };
  }
}
