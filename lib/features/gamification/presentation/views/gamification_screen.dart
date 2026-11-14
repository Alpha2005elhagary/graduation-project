import 'package:breakbot/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class GamificationScreen extends StatelessWidget {
  const GamificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'التحفيز',
                      style: TextStyle(
                        color: AppColors.onSurface,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.tertiaryFixedDim.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        'المستوى 1',
                        style: TextStyle(
                          color: AppColors.tertiaryFixedDim,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _statCard('نقاط الخبرة', '1250 XP', Icons.star, AppColors.tertiaryFixedDim),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _statCard('الشارات', '3 شارات', Icons.emoji_events, Colors.blue),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Badges
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'الشارات المحققة',
                    style: TextStyle(
                      color: AppColors.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: 6,
                      itemBuilder: (context, index) {
                        return _badgeCard(index);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _badgeCard(int index) {
    final badges = [
      {'icon': Icons.local_fire_department, 'title': 'نار السلسلة', 'desc': '7 أيام متتالية', 'unlocked': true},
      {'icon': Icons.check_circle, 'title': 'منجز المهام', 'desc': '10 مهام مكتملة', 'unlocked': true},
      {'icon': Icons.timer, 'title': 'تركيز عميق', 'desc': '5 جلسات تركيز', 'unlocked': true},
      {'icon': Icons.person, 'title': 'مستمر', 'desc': '30 يوماً في التطبيق', 'unlocked': false},
      {'icon': Icons.lightbulb, 'title': 'فكرة ذكية', 'desc': '5 رسائل للمدرب', 'unlocked': false},
      {'icon': Icons.rocket, 'title': 'انطلاق سريع', 'desc': 'أسبوع أول مثالي', 'unlocked': false},
    ];
    final badge = badges[index];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (badge['unlocked'] as bool) ? Colors.white : AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (badge['unlocked'] as bool) ? AppColors.tertiaryFixedDim : AppColors.surfaceContainerHigh,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: (badge['unlocked'] as bool) ? AppColors.tertiaryFixedDim : AppColors.surfaceContainerHigh,
              shape: BoxShape.circle,
            ),
            child: Icon(
              badge['icon'] as IconData,
              color: (badge['unlocked'] as bool) ? Colors.white : AppColors.outline,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            badge['title'] as String,
            style: TextStyle(
              color: AppColors.onSurface,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            badge['desc'] as String,
            style: TextStyle(
              color: (badge['unlocked'] as bool) ? AppColors.onSurfaceVariant : AppColors.outline,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
