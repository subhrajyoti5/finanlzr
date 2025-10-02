import 'package:finanlzr/features/results/models/analysis_data.dart';

class MockData {
  static AnalysisData getMockAnalysis(String ticker) {
    // Mock analysis data
    final random = DateTime.now().millisecondsSinceEpoch % 3;
    final sentiments = ['Positive', 'Negative', 'Neutral'];
    final prices = ['150.25', '75.80', '320.45'];
    final predictions = ['155.30', '72.15', '335.60'];

    return AnalysisData(
      price: prices[random],
      prediction: predictions[random],
      sentiment: sentiments[random],
    );
  }
}
