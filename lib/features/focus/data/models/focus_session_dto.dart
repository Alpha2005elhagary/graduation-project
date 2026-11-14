import 'package:breakbot/features/focus/domain/entities/focus_session.dart';

class FocusSessionDto {
  final String id;
  final int durationMinutes;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int distractions;

  FocusSessionDto({
    required this.id,
    required this.durationMinutes,
    required this.startedAt,
    this.endedAt,
    this.distractions = 0,
  });

  factory FocusSessionDto.fromJson(Map<String, dynamic> json) {
    return FocusSessionDto(
      id: json['id'] ?? '',
      durationMinutes: json['duration_minutes'] ?? 0,
      startedAt: DateTime.parse(json['started_at'] ?? DateTime.now().toIso8601String()),
      endedAt: json['ended_at'] != null ? DateTime.parse(json['ended_at']) : null,
      distractions: json['distractions'] ?? 0,
    );
  }

  FocusSession toEntity() {
    return FocusSession(
      id: id,
      durationMinutes: durationMinutes,
      startedAt: startedAt,
      endedAt: endedAt,
      distractions: distractions,
    );
  }
}