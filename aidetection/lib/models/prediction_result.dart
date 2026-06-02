class PredictionResult {
  final String label;       // "AI" or "Human"
  final double confidence;

  const PredictionResult({
    required this.label,
    required this.confidence,
  });

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    return PredictionResult(
      label: json['label'] as String,
      confidence: (json['confidence'] as num).toDouble(),
    );
  }

  bool get isAI => label == 'AI';
  int get confidencePct => (confidence * 100).round();
}
