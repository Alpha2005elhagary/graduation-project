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
}
