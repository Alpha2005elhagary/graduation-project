import 'package:equatable/equatable.dart';

class FocusSession extends Equatable {
  final String id;
  final int durationMinutes;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int distractions;

  const FocusSession({
    required this.id,
    required this.durationMinutes,
    required this.startedAt,
    this.endedAt,
    this.distractions = 0,
  });

  @override
  List<Object?> get props => [id, durationMinutes, startedAt, endedAt, distractions];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'durationMinutes': durationMinutes,
      'startedAt': startedAt.toIso8601String(),
      'endedAt': endedAt?.toIso8601String(),
      'distractions': distractions,
    };
  }

  factory FocusSession.fromJson(Map<String, dynamic> json) {
    return FocusSession(
      id: json['id'] ?? '',
      durationMinutes: json['durationMinutes'] ?? 0,
      startedAt: DateTime.parse(json['startedAt'] ?? DateTime.now().toIso8601String()),
      endedAt: json['endedAt'] != null ? DateTime.parse(json['endedAt']) : null,
      distractions: json['distractions'] ?? 0,
    );
  }
}
