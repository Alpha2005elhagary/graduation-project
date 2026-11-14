import 'package:flutter/material.dart';

class HabitDetailScreen extends StatelessWidget {
  final String habitId;

  const HabitDetailScreen({super.key, required this.habitId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل العادة'),
      ),
      body: Center(
        child: Text('تفاصيل العادة - قيد التطوير'),
      ),
    );
  }
}
