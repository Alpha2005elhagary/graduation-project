import 'package:equatable/equatable.dart';

class Habit extends Equatable {
  final String id;
  final String name;
  final String? description;
  final DateTime? targetTime;
  final int streak;
  final bool isActive;
  final bool photoRequired;
  final DateTime? lastCheckin;
  final DateTime? createdAt;

  const Habit({
    required this.id,
    required this.name,
    this.description,
    this.targetTime,
    this.streak = 0,
    this.isActive = true,
    this.photoRequired = false,
    this.lastCheckin,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        targetTime,
        streak,
        isActive,
        photoRequired,
        lastCheckin,
        createdAt,
      ];

  Habit copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? targetTime,
    int? streak,
    bool? isActive,
    bool? photoRequired,
    DateTime? lastCheckin,
    DateTime? createdAt,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      targetTime: targetTime ?? this.targetTime,
      streak: streak ?? this.streak,
      isActive: isActive ?? this.isActive,
      photoRequired: photoRequired ?? this.photoRequired,
      lastCheckin: lastCheckin ?? this.lastCheckin,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'targetTime': targetTime?.toIso8601String(),
      'streak': streak,
      'isActive': isActive,
      'photoRequired': photoRequired,
      'lastCheckin': lastCheckin?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      targetTime: json['targetTime'] != null ? DateTime.parse(json['targetTime']) : null,
      streak: json['streak'] ?? 0,
      isActive: json['isActive'] ?? true,
      photoRequired: json['photoRequired'] ?? false,
      lastCheckin: json['lastCheckin'] != null ? DateTime.parse(json['lastCheckin']) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }
}


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
