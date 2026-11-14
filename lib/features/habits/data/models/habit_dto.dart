import 'package:breakbot/features/habits/domain/entities/habit.dart';

class HabitDto {
  final String id;
  final String name;
  final String? description;
  final String? targetTime;
  final int streak;
  final bool isActive;
  final bool photoRequired;
  final String? lastCheckin;
  final String? createdAt;

  HabitDto({
    required this.id,
    required this.name,
    this.description,
    this.targetTime,
    required this.streak,
    required this.isActive,
    required this.photoRequired,
    this.lastCheckin,
    this.createdAt,
  });

  factory HabitDto.fromJson(Map<String, dynamic> json) {
    return HabitDto(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      targetTime: json['target_time'],
      streak: json['streak'] ?? 0,
      isActive: json['is_active'] ?? true,
      photoRequired: json['photo_required'] ?? false,
      lastCheckin: json['last_checkin'],
      createdAt: json['created_at'],
    );
  }

  Habit toEntity() {
    return Habit(
      id: id,
      name: name,
      description: description,
      targetTime: targetTime != null ? DateTime.parse(targetTime!) : null,
      streak: streak,
      isActive: isActive,
      photoRequired: photoRequired,
      lastCheckin: lastCheckin != null ? DateTime.parse(lastCheckin!) : null,
      createdAt: createdAt != null ? DateTime.parse(createdAt!) : null,
    );
  }
}

class CheckInDto {
  final String habitId;

  CheckInDto({required this.habitId});

  Map<String, dynamic> toJson() => {'habit_id': habitId};

  factory CheckInDto.fromJson(Map<String, dynamic> json) {
    return CheckInDto(habitId: json['habit_id'] ?? '');
  }
}

class CheckInResponseDto {
  final String habitId;
  final int newStreak;
  final bool success;

  CheckInResponseDto({
    required this.habitId,
    required this.newStreak,
    required this.success,
  });

  factory CheckInResponseDto.fromJson(Map<String, dynamic> json) {
    return CheckInResponseDto(
      habitId: json['habit_id'] ?? '',
      newStreak: json['new_streak'] ?? 0,
      success: json['success'] ?? false,
    );
  }
}

class VerificationDto {
  final bool isValid;
  final double confidence;
  final String? feedback;

  VerificationDto({
    required this.isValid,
    required this.confidence,
    this.feedback,
  });

  factory VerificationDto.fromJson(Map<String, dynamic> json) {
    return VerificationDto(
      isValid: json['is_valid'] ?? false,
      confidence: (json['confidence'] ?? 0).toDouble(),
      feedback: json['feedback'],
    );
  }
}