class AnalysisData {
  final String price;
  final String prediction;
  final String sentiment;

  const AnalysisData({
    required this.price,
    required this.prediction,
    required this.sentiment,
  });

  factory AnalysisData.fromJson(Map<String, dynamic> json) {
    return AnalysisData(
      price: json['price'] as String,
      prediction: json['prediction'] as String,
      sentiment: json['sentiment'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'price': price, 'prediction': prediction, 'sentiment': sentiment};
  }
}
