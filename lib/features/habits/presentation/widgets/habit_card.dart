import 'package:flutter/material.dart';
import 'package:breakbot/core/theme/app_theme.dart';
import 'package:breakbot/features/habits/domain/entities/habit.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback onCheckIn;
  final VoidCallback onToggle;

  const HabitCard({
    super.key,
    required this.habit,
    required this.onCheckIn,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppTheme.primary.withValues(alpha: 0.12),
          child: Text(
            habit.name.isNotEmpty ? habit.name[0] : '',
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
            ),
          ),
        ),
        title: Text(
          habit.name,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: AppTheme.textPrimary,
          ),
        ),
        subtitle: Text(
          'سلسلة: ${habit.streak} يوم 🔥',
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: habit.isActive,
              onChanged: (_) => onToggle(),
              activeThumbColor: AppTheme.primary,
            ),
            IconButton(
              icon: const Icon(Icons.check_circle_outline, color: AppTheme.success),
              onPressed: onCheckIn,
            ),
          ],
        ),
      ),
    );
  }
}