import 'package:breakbot/core/di/injection_container.dart';
import 'package:breakbot/core/localisation/app_strings.dart';
import 'package:breakbot/core/storage/local_storage_manager.dart';
import 'package:breakbot/core/theme/app_theme.dart';
import 'package:breakbot/features/habits/domain/entities/habit.dart';
import 'package:breakbot/shared/widgets/ds_widgets.dart';
import 'package:flutter/material.dart';

/// Habit protocols and stacks.
///
/// The screen combines the Stitch habits reference (filters, protocol cards,
/// weekly checkmarks, habit-loop builder) with the existing on-device storage
/// model so every action actually persists.
class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key, this.onAddRequested});

  final VoidCallback? onAddRequested;

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  final storage = getIt<LocalStorageManager>();
  final _scrollController = ScrollController();
  final _builderKey = GlobalKey();
  final _whenController = TextEditingController();
  final _actionController = TextEditingController();
  final _feelController = TextEditingController();

  String _filter = 'all';

  @override
  void dispose() {
    _scrollController.dispose();
    _whenController.dispose();
    _actionController.dispose();
    _feelController.dispose();
    super.dispose();
  }

  bool _isDoneToday(Habit habit) {
    final last = habit.lastCheckin;
    if (last == null) return false;
    final now = DateTime.now();
    return now.year == last.year &&
        now.month == last.month &&
        now.day == last.day;
  }

  bool _isCraving(Habit habit) {
    final n = habit.name.toLowerCase();
    return n.contains('سكر') ||
        n.contains('رغبة') ||
        n.contains('شهية') ||
        n.contains('craving') ||
        n.contains('sugar') ||
        n.contains('urge');
  }

  bool _isEvening(Habit habit) =>
      !_isCraving(habit) && (habit.targetTime?.hour ?? 12) >= 17;

  bool _isMorning(Habit habit) =>
      !_isCraving(habit) && (habit.targetTime?.hour ?? 12) < 12;

  String _labelFor(Habit habit) {
    if (_isCraving(habit)) return t('اعتراض الرغبة', 'Craving Intervention');
    if (_isEvening(habit)) return t('تهدئة مسائية', 'Evening Wind-Down');
    return t('حزمة صباحية', 'Morning Stack');
  }

  void _checkIn(Habit habit) {
    if (_isDoneToday(habit)) {
      showDsSnack(
        context,
        t('تم إنجازها اليوم بالفعل', 'Already completed today'),
        success: true,
      );
      return;
    }
    final habits = storage.getHabits();
    final index = habits.indexWhere((h) => h.id == habit.id);
    if (index == -1) return;
    final updated = habit.copyWith(
      streak: habit.streak + 1,
      lastCheckin: DateTime.now(),
    );
    final list = List<Habit>.from(habits)..[index] = updated;
    storage.saveHabits(list);
    setState(() {});
    showDsSnack(
      context,
      t('رائع! سلسلتك الآن ${updated.streak} يوم 🔥',
          'Great! Your streak is now ${updated.streak} days 🔥'),
      success: true,
    );
  }

  void _toggleHabit(Habit habit) {
    final habits = storage.getHabits();
    final index = habits.indexWhere((h) => h.id == habit.id);
    if (index == -1) return;
    final list = List<Habit>.from(habits)
      ..[index] = habit.copyWith(isActive: !habit.isActive);
    storage.saveHabits(list);
    setState(() {});
    showDsSnack(
      context,
      habit.isActive
          ? t('تم إيقاف البروتوكول مؤقتًا', 'Protocol paused')
          : t('تم تنشيط البروتوكول', 'Protocol activated'),
    );
  }

  void _deleteHabit(Habit habit) {
    final list = storage.getHabits().where((h) => h.id != habit.id).toList();
    storage.saveHabits(list);
    setState(() {});
    showDsSnack(context, t('تم حذف البروتوكول', 'Protocol deleted'));
  }

  void _deployStack() {
    final action = _actionController.text.trim();
    if (action.isEmpty) {
      showDsSnack(
        context,
        t('اكتب إجراءً صغيرًا في خانة "سأفعل" أولًا.',
            'Add a tiny action in the “I will” field first.'),
      );
      return;
    }
    final when = _whenController.text.trim();
    final feel = _feelController.text.trim();
    final description = [
      if (when.isNotEmpty) '${t('عندما', 'WHEN')}: $when',
      if (feel.isNotEmpty) '${t('لأشعر بـ', 'TO FEEL')}: $feel',
    ].join(' • ');

    final habit = Habit(
      id: 'habit_${DateTime.now().millisecondsSinceEpoch}',
      name: action,
      description: description.isEmpty ? null : description,
      targetTime: DateTime.now(),
      createdAt: DateTime.now(),
    );
    final list = List<Habit>.from(storage.getHabits())..add(habit);
    storage.saveHabits(list);
    _whenController.clear();
    _actionController.clear();
    _feelController.clear();
    setState(() {});
    showDsSnack(
      context,
      t('تم نشر الحزمة! ستظهر في بروتوكولاتك اليومية ✨',
          'Stack deployed! It now appears in your daily protocols ✨'),
      success: true,
    );
  }

  void _scrollToBuilder() {
    final context = _builderKey.currentContext;
    if (context == null) return;
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      alignment: 0.05,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: LocalStorageManager.revision,
      builder: (context, _, _) {
        final habits = storage.getHabits();
        final active = habits.where((h) => h.isActive).toList();
        final done = active.where(_isDoneToday).length;
        final adherence =
            active.isEmpty ? 0 : ((done / active.length) * 100).round();
        final maxStreak = habits.fold<int>(
            0, (max, h) => h.streak > max ? h.streak : max);

        final filtered = switch (_filter) {
          'morning' => active.where(_isMorning).toList(),
          'craving' => active.where(_isCraving).toList(),
          'evening' => active.where(_isEvening).toList(),
          _ => active,
        };

        return Scaffold(
          backgroundColor: AppColors.background,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _scrollToBuilder,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 4,
            icon: const Icon(Icons.add_rounded),
            label: Text(t('عادة جديدة', 'New Habit')),
          ),
          body: SafeArea(
            bottom: false,
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
              physics: const BouncingScrollPhysics(),
              children: [
                _Header(
                  streak: maxStreak,
                  onNewHabit: _scrollToBuilder,
                ),
                const SizedBox(height: 22),
                Text(
                  t('البروتوكولات والحزم', 'Protocols & Stacks'),
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  t(
                    'روتينات صغيرة مرتبة بإشاراتها، مصممة لتقليل الاحتكاك وبناء الزخم.',
                    'Micro-routines ordered by cue, designed to reduce friction and build momentum.',
                  ),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                _FilterBar(
                  filter: _filter,
                  counts: {
                    'all': active.length,
                    'morning': active.where(_isMorning).length,
                    'craving': active.where(_isCraving).length,
                    'evening': active.where(_isEvening).length,
                  },
                  onChanged: (value) => setState(() => _filter = value),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _MiniStat(
                        icon: Icons.layers_rounded,
                        tone: DsTone.primary,
                        value: '${active.length}',
                        label: t('حزم نشطة', 'Active stacks'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MiniStat(
                        icon: Icons.insights_rounded,
                        tone: DsTone.success,
                        value: '$adherence%',
                        label: t('التزام اليوم', 'Today adherence'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MiniStat(
                        icon: Icons.local_fire_department_rounded,
                        tone: DsTone.tertiary,
                        value: '$maxStreak',
                        label: t('أيام متتالية', 'Day streak'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _WeekCard(activeDays: (done + 2).clamp(0, 7).toInt()),
                const SizedBox(height: 24),
                DsSectionHeader(
                  title: t('البروتوكولات النشطة', 'Active Protocols'),
                  subtitle: t('مرتبة حسب الإشارة', 'Ordered by cue'),
                  actionLabel: t('الكل (${active.length})',
                      'All (${active.length})'),
                  onAction: () {
                    setState(() => _filter = 'all');
                  },
                ),
                const SizedBox(height: 12),
                if (filtered.isEmpty)
                  DsEmptyState(
                    title: t('لا توجد بروتوكولات هنا',
                        'No protocols in this filter'),
                    message: t(
                      'جرّب فلترًا آخر أو أنشئ حزمة جديدة من الأسفل.',
                      'Try another filter or build a new stack below.',
                    ),
                    icon: Icons.tune_rounded,
                    action: TextButton(
                      onPressed: _scrollToBuilder,
                      child: Text(t('بناء حزمة', 'Build a stack')),
                    ),
                  )
                else
                  for (final habit in filtered) ...[
                    _ProtocolCard(
                      habit: habit,
                      done: _isDoneToday(habit),
                      label: _labelFor(habit),
                      visual: HabitVisual.forName(habit.name),
                      onCheckIn: () => _checkIn(habit),
                      onToggle: () => _toggleHabit(habit),
                      onDelete: () => _deleteHabit(habit),
                    ),
                    const SizedBox(height: 12),
                  ],
                const SizedBox(height: 12),
                Container(
                  key: _builderKey,
                  child: _HabitLoopBuilder(
                    whenController: _whenController,
                    actionController: _actionController,
                    feelController: _feelController,
                    onDeploy: _deployStack,
                  ),
                ),
                const SizedBox(height: 16),
                DsCard(
                  radius: 22,
                  padding: const EdgeInsets.all(16),
                  color: AppColors.secondaryFixed.withValues(alpha: 0.55),
                  borderColor: AppColors.secondaryFixedDim,
                  shadow: false,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const DsIconBadge(
                        icon: Icons.smart_toy_rounded,
                        tone: DsTone.secondary,
                        size: 38,
                        radius: 12,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(height: 1.6),
                            children: [
                              TextSpan(
                                text: t('نصيحة BreakBot: ',
                                    'BreakBot Tip: '),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              TextSpan(
                                text: t(
                                  'تكديس إشارات الدوبامين مباشرة بعد عادات موجودة يخلق زخمًا سلوكيًا تلقائيًا خلال 14 يومًا!',
                                  'Stacking dopamine cues directly after existing habits creates automatic behavioral momentum within 14 days!',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.streak,
    required this.onNewHabit,
  });

  final int streak;
  final VoidCallback onNewHabit;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: DsBrandLockup(size: 36, showTagline: true),
          ),
        ),
        DsPill(
          label: '$streak 🔥',
          tone: DsTone.tertiary,
          compact: true,
          bold: true,
        ),
        const SizedBox(width: 10),
        FilledButton.tonalIcon(
          onPressed: onNewHabit,
          icon: const Icon(Icons.add_rounded, size: 18),
          label: Text(t('جديد', 'New')),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primaryFixed,
            foregroundColor: AppColors.primary,
            minimumSize: const Size(0, 40),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.filter,
    required this.counts,
    required this.onChanged,
  });

  final String filter;
  final Map<String, int> counts;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('all', t('الكل', 'All')),
      ('morning', t('صباحية', 'Morning')),
      ('craving', t('الرغبة', 'Craving')),
      ('evening', t('مسائية', 'Evening')),
    ];
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (key, label) = items[index];
          final selected = filter == key;
          return GestureDetector(
            onTap: () => onChanged(key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary
                    : AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: selected
                      ? AppColors.primary
                      : AppColors.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: selected
                              ? Colors.white
                              : AppColors.onSurfaceVariant,
                          fontWeight:
                              selected ? FontWeight.w800 : FontWeight.w600,
                        ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: selected
                          ? Colors.white.withValues(alpha: 0.22)
                          : AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      '${counts[key] ?? 0}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: selected
                                ? Colors.white
                                : AppColors.onSurfaceVariant,
                            fontSize: 10,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.icon,
    required this.tone,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final DsTone tone;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return DsCard(
      radius: 18,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DsIconBadge(icon: icon, tone: tone, size: 30, radius: 9),
          const SizedBox(height: 8),
          Text(
            value,
            style: text.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: tone.foreground,
              fontSize: 22,
            ),
          ),
          Text(
            label,
            maxLines: 2,
            style: text.labelSmall?.copyWith(fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _WeekCard extends StatelessWidget {
  const _WeekCard({required this.activeDays});

  final int activeDays;

  static const _daysAr = ['س', 'ح', 'ن', 'ث', 'ر', 'خ', 'ج'];
  static const _daysEn = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final days = isArabic ? _daysAr : _daysEn;
    return DsCard(
      radius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t('اتساق آخر 7 أيام', '7-Day Consistency'),
                    style: text.labelMedium),
                const SizedBox(height: 2),
                Text(t('استمرارية بصرية', 'Visual streak rhythm'),
                    style: text.bodySmall),
              ],
            ),
          ),
          Row(
            children: List.generate(7, (index) {
              final active = index < activeDays;
              return Padding(
                padding: EdgeInsets.only(left: index == 0 ? 0 : 5),
                child: Column(
                  children: [
                    Text(days[index], style: text.labelSmall),
                    const SizedBox(height: 4),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: active
                            ? AppColors.success
                            : AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: active
                          ? const Icon(Icons.check_rounded,
                              size: 14, color: Colors.white)
                          : null,
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _ProtocolCard extends StatelessWidget {
  const _ProtocolCard({
    required this.habit,
    required this.done,
    required this.label,
    required this.visual,
    required this.onCheckIn,
    required this.onToggle,
    required this.onDelete,
  });

  final Habit habit;
  final bool done;
  final String label;
  final HabitVisual visual;
  final VoidCallback onCheckIn;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  String _trigger() {
    if (habit.description != null &&
        habit.description!.toLowerCase().contains('when')) {
      return habit.description!.split('•').first.replaceAll('WHEN:', '').trim();
    }
    final hour = habit.targetTime?.hour ?? 8;
    if (hour < 12) return t('بعد الاستيقاظ وترتيب السرير', 'After waking up & making the bed');
    if (hour < 17) return t('كل 90 دقيقة من وقت الشاشة', 'Every 90 minutes of screen time');
    return t('رغبات المساء حوالي 8 مساءً', 'Evening cravings around 8:00 PM');
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return DsCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DsIconBadge(
                icon: visual.icon,
                color: visual.foreground,
                background: visual.background,
                size: 46,
                radius: 14,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.name,
                      style: text.titleMedium?.copyWith(
                        decoration:
                            done ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      habit.description ??
                          t('بروتوكول دقيق', 'Micro protocol'),
                      style: text.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded,
                    size: 20, color: AppColors.outline),
                onSelected: (value) {
                  if (value == 'toggle') onToggle();
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'toggle',
                    child: Row(
                      children: [
                        Icon(
                          habit.isActive
                              ? Icons.pause_circle_outline_rounded
                              : Icons.play_circle_outline_rounded,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          habit.isActive
                              ? t('إيقاف مؤقت', 'Pause protocol')
                              : t('تنشيط', 'Activate'),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Icons.delete_outline_rounded,
                            size: 18, color: AppColors.error),
                        const SizedBox(width: 8),
                        Text(t('حذف', 'Delete'),
                            style:
                                const TextStyle(color: AppColors.error)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              DsPill(
                label: label,
                icon: Icons.layers_rounded,
                tone: DsTone.neutral,
                compact: true,
              ),
              DsPill(
                label: done
                    ? t('مكتملة اليوم', 'Completed today')
                    : t('سلسلة ${habit.streak} يوم',
                        '${habit.streak} days streak'),
                icon: done
                    ? Icons.check_circle_rounded
                    : Icons.local_fire_department_rounded,
                tone: done ? DsTone.success : DsTone.tertiary,
                compact: true,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _LoopRow(
            label: t('الإشارة', 'Trigger'),
            text: _trigger(),
            icon: Icons.arrow_downward_rounded,
          ),
          const SizedBox(height: 6),
          _LoopRow(
            label: t('الإجراء', 'Action'),
            text: habit.description ?? habit.name,
            icon: Icons.bolt_rounded,
            highlight: true,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: done
                    ? Container(
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.successContainer,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle_rounded,
                                size: 18, color: AppColors.success),
                            const SizedBox(width: 6),
                            Text(t('تم التحقق اليوم', 'Checked in today'),
                                style: text.labelMedium
                                    ?.copyWith(color: AppColors.success)),
                          ],
                        ),
                      )
                    : SizedBox(
                        height: 42,
                        child: FilledButton.icon(
                          onPressed: onCheckIn,
                          icon: const Icon(Icons.check_rounded, size: 18),
                          label: Text(t('تحقق الآن', 'Check in')),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(0, 42),
                            backgroundColor: AppColors.primaryFixed,
                            foregroundColor: AppColors.primary,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LoopRow extends StatelessWidget {
  const _LoopRow({
    required this.label,
    required this.text,
    required this.icon,
    this.highlight = false,
  });

  final String label;
  final String text;
  final IconData icon;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.primaryFixed.withValues(alpha: 0.5)
            : AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon,
              size: 15,
              color: highlight ? AppColors.primary : AppColors.outline),
          const SizedBox(width: 8),
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color:
                  highlight ? AppColors.primary : AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.onSurface,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HabitLoopBuilder extends StatelessWidget {
  const _HabitLoopBuilder({
    required this.whenController,
    required this.actionController,
    required this.feelController,
    required this.onDeploy,
  });

  final TextEditingController whenController;
  final TextEditingController actionController;
  final TextEditingController feelController;
  final VoidCallback onDeploy;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return DsCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const DsIconBadge(
                icon: Icons.architecture_rounded,
                tone: DsTone.primary,
                size: 42,
                radius: 13,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t('ابنِ حلقة عادة سلوكية',
                        'Build a Behavioral Habit Loop'),
                        style: text.titleMedium),
                    Text(t('تكديس مبني على المثير والاستجابة',
                        'Empirical stimulus-response stack'),
                        style: text.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _LoopField(
            label: t('عندما', 'WHEN'),
            icon: Icons.schedule_rounded,
            hint: t('إشارة البدء', 'Trigger cue'),
            controller: whenController,
          ),
          const SizedBox(height: 10),
          _LoopField(
            label: t('سأفعل', 'I WILL'),
            icon: Icons.bolt_rounded,
            hint: t('إجراء صغير', 'Micro action'),
            controller: actionController,
          ),
          const SizedBox(height: 10),
          _LoopField(
            label: t('لأشعر بـ', 'TO FEEL'),
            icon: Icons.sentiment_very_satisfied_rounded,
            hint: t('المكافأة', 'Reward'),
            controller: feelController,
          ),
          const SizedBox(height: 16),
          DsPrimaryButton(
            label: t('احفظ وانشر الحزمة', 'Save & Deploy Stack'),
            icon: Icons.rocket_launch_rounded,
            onPressed: onDeploy,
          ),
        ],
      ),
    );
  }
}

class _LoopField extends StatelessWidget {
  const _LoopField({
    required this.label,
    required this.icon,
    required this.hint,
    required this.controller,
  });

  final String label;
  final IconData icon;
  final String hint;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 78,
          child: Row(
            children: [
              Icon(icon, size: 14, color: AppColors.primary),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: controller,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.onSurface),
            decoration: InputDecoration(
              hintText: hint,
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            ),
          ),
        ),
      ],
    );
  }
}
