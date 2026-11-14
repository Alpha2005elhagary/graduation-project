import 'package:equatable/equatable.dart';

class VerificationResult extends Equatable {
  final bool isValid;
  final double confidence;
  final String? feedback;

  const VerificationResult({
    required this.isValid,
    required this.confidence,
    this.feedback,
  });

  @override
  List<Object?> get props => [isValid, confidence, feedback];

  Map<String, dynamic> toJson() {
    return {
      'isValid': isValid,
      'confidence': confidence,
      'feedback': feedback,
    };
  }

  factory VerificationResult.fromJson(Map<String, dynamic> json) {
    return VerificationResult(
      isValid: json['isValid'] ?? false,
      confidence: json['confidence'] ?? 0.0,
      feedback: json['feedback'],
    );
  }
}
