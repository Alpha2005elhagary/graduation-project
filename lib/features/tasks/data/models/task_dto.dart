import 'package:breakbot/features/tasks/domain/entities/task.dart';

class TaskDto {
  final String id;
  final String title;
  final String priority;
  final DateTime deadline;
  final String? suggestedSlot;
  final bool isCompleted;
  final String? createdAt;

  TaskDto({
    required this.id,
    required this.title,
    required this.priority,
    required this.deadline,
    this.suggestedSlot,
    required this.isCompleted,
    this.createdAt,
  });

  factory TaskDto.fromJson(Map<String, dynamic> json) {
    return TaskDto(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      priority: json['priority'] ?? 'low',
      deadline: DateTime.parse(
        json['deadline'] ?? DateTime.now().toIso8601String(),
      ),
      suggestedSlot: json['suggested_slot'],
      isCompleted: json['is_completed'] ?? false,
      createdAt: json['created_at'],
    );
  }

  Task toEntity() {
    return Task(
      id: id,
      title: title,
      priority: priority,
      deadline: deadline,
      suggestedSlot: suggestedSlot,
      isCompleted: isCompleted,
      createdAt: createdAt != null ? DateTime.parse(createdAt!) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'priority': priority,
      'deadline': deadline.toIso8601String(),
      'suggested_slot': suggestedSlot,
      'is_completed': isCompleted,
      'created_at': createdAt,
    };
  }
}