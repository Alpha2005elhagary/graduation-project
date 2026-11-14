import 'package:breakbot/shared/widgets/shared_widgets.dart';
import 'package:flutter/material.dart';

class BreathingScreen extends StatelessWidget {
  const BreathingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const ArabicText('تمرين التنفس'),
      ),
      body: const Center(
        child: ArabicText('تمرين التنفس - قيد التطوير'),
      ),
    );
  }
}
