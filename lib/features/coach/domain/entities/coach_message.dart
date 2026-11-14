import 'package:equatable/equatable.dart';

class CoachMessage extends Equatable {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const CoachMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [text, isUser, timestamp];

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory CoachMessage.fromJson(Map<String, dynamic> json) {
    return CoachMessage(
      text: json['text'] ?? '',
      isUser: json['isUser'] ?? false,
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }
}
