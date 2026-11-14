import 'package:equatable/equatable.dart';

class Task extends Equatable {
  final String id;
  final String title;
  final String priority;
  final DateTime deadline;
  final String? suggestedSlot;
  final bool isCompleted;
  final DateTime? createdAt;

  const Task({
    required this.id,
    required this.title,
    required this.priority,
    required this.deadline,
    this.suggestedSlot,
    this.isCompleted = false,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        priority,
        deadline,
        suggestedSlot,
        isCompleted,
        createdAt,
      ];

  Task copyWith({
    String? id,
    String? title,
    String? priority,
    DateTime? deadline,
    String? suggestedSlot,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      priority: priority ?? this.priority,
      deadline: deadline ?? this.deadline,
      suggestedSlot: suggestedSlot ?? this.suggestedSlot,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'priority': priority,
      'deadline': deadline.toIso8601String(),
      'suggestedSlot': suggestedSlot,
      'isCompleted': isCompleted,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      priority: json['priority'] ?? 'low',
      deadline: DateTime.parse(json['deadline'] ?? DateTime.now().toIso8601String()),
      suggestedSlot: json['suggestedSlot'],
      isCompleted: json['isCompleted'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }
}
