import 'package:breakbot/core/di/injection_container.dart';
import 'package:breakbot/core/localisation/app_strings.dart';
import 'package:breakbot/core/storage/local_storage_manager.dart';
import 'package:breakbot/core/theme/app_theme.dart';
import 'package:breakbot/features/habits/domain/entities/habit.dart';
import 'package:breakbot/features/notifications/presentation/views/notifications_screen.dart';
import 'package:breakbot/shared/widgets/ds_widgets.dart';
import 'package:flutter/material.dart';

/// Today dashboard — Habit Pulse.
///
/// Mirrors the Stitch dashboard: brand header, daily overview ring, BreakBot
/// insight, a fully interactive check-in flow and today's habit protocols.
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.onNavigateTab,
    this.onAddHabit,
  });

  final Function(int)? onNavigateTab;
  final VoidCallback? onAddHabit;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final storage = getIt<LocalStorageManager>();

  bool _isDoneToday(Habit habit) {
    final last = habit.lastCheckin;
    if (last == null) return false;
    final now = DateTime.now();
    return now.year == last.year &&
        now.month == last.month &&
        now.day == last.day;
  }

  void _checkIn(Habit habit) {
    if (_isDoneToday(habit)) {
      showDsSnack(
        context,
        t('أنهيت هذه العادة اليوم بالفعل ✨', 'You already completed this today ✨'),
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
      t('أحسنت! سلسلتك الآن ${updated.streak} يوم 🔥',
          'Nice! Your streak is now ${updated.streak} days 🔥'),
      success: true,
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return t('صباح الخير', 'Good morning');
    if (hour < 17) return t('مساء النور', 'Good afternoon');
    return t('مساء الخير', 'Good evening');
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: LocalStorageManager.revision,
      builder: (context, _, _) {
        final user = storage.getUser();
        final habits = storage.getHabits();
        final active = habits.where((h) => h.isActive).toList();
        final done = active.where(_isDoneToday).length;
        final streak =
            habits.fold<int>(0, (sum, h) => sum > h.streak ? sum : h.streak);
        final progress = active.isEmpty ? 0.0 : done / active.length;
        final percentage = (progress * 100).round();
        final firstName = (user?.name.trim().isNotEmpty ?? false)
            ? user!.name.trim().split(RegExp(r'\s+')).first
            : t('أليكس', 'Alex');

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            bottom: false,
            child: RefreshIndicator(
              onRefresh: () async => setState(() {}),
              color: AppColors.primary,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                children: [
                  _Header(
                    streak: streak,
                    onNotifications: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotificationsScreen(),
                      ),
                    ),
                    onProfile: () => widget.onNavigateTab?.call(4),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '${_greeting()}، $firstName!',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    t(
                      'جاهز لتذويب الاحتكاك وتثبيت وقفاتك الصحية؟',
                      'Ready to dismantle friction and lock in healthy micro-breaks?',
                    ),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  _DailyOverviewCard(
                    progress: progress,
                    percentage: percentage,
                    done: done,
                    total: active.length,
                  ),
                  const SizedBox(height: 14),
                  _InsightCard(done: done, total: active.length),
                  const SizedBox(height: 18),
                  _CheckInCard(
                    habits: active.isEmpty ? habits : active,
                    isDoneToday: _isDoneToday,
                    onCheckIn: _checkIn,
                    onChat: () => widget.onNavigateTab?.call(2),
                    onOpenHabits: () => widget.onNavigateTab?.call(1),
                  ),
                  const SizedBox(height: 24),
                  DsSectionHeader(
                    title: t('عادات وبروتوكولات اليوم',
                        'Today’s Habits & Protocols'),
                    subtitle: t('روتينات دقيقة منظمة',
                        'Structured micro-routines'),
                    actionLabel: t('عرض الكل', 'View all'),
                    onAction: () => widget.onNavigateTab?.call(1),
                  ),
                  const SizedBox(height: 12),
                  if (active.isEmpty)
                    DsEmptyState(
                      title: t('لا توجد عادات بعد', 'No habits yet'),
                      message: t(
                        'ابدأ ببروتوكول واحد صغير — دقيقتان تكفيان للبدء.',
                        'Start with one tiny protocol — two minutes is enough.',
                      ),
                      action: TextButton(
                        onPressed: widget.onAddHabit ??
                            () => widget.onNavigateTab?.call(1),
                        child: Text(t('إضافة أول عادة', 'Add your first habit')),
                      ),
                    )
                  else
                    DsCard(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      child: Column(
                        children: [
                          for (var i = 0; i < active.take(3).length; i++) ...[
                            _HabitRow(
                              habit: active[i],
                              done: _isDoneToday(active[i]),
                              onCheckIn: () => _checkIn(active[i]),
                            ),
                            if (i != active.take(3).length - 1)
                              const DsHairline(vertical: 0),
                          ],
                        ],
                      ),
                    ),
                  const SizedBox(height: 18),
                  _CoachFooter(onTap: () => widget.onNavigateTab?.call(2)),
                ],
              ),
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
    required this.onNotifications,
    required this.onProfile,
  });

  final int streak;
  final VoidCallback onNotifications;
  final VoidCallback onProfile;

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
        const SizedBox(width: 8),
        _CircleAction(
          icon: Icons.notifications_none_rounded,
          onTap: onNotifications,
          badge: true,
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onProfile,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: AppTheme.heroGradient,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primaryFixed,
                width: 2,
              ),
            ),
            child: const Icon(Icons.person_rounded,
                color: Colors.white, size: 21),
          ),
        ),
      ],
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({
    required this.icon,
    required this.onTap,
    this.badge = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool badge;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: AppColors.surfaceContainerLowest,
          shape: const CircleBorder(
            side: BorderSide(color: AppColors.primaryFixed, width: 1),
          ),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(
              width: 40,
              height: 40,
              child: Icon(icon, size: 21, color: AppColors.onSurface),
            ),
          ),
        ),
        if (badge)
          Positioned(
            top: 8,
            right: 9,
            child: Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}

class _DailyOverviewCard extends StatelessWidget {
  const _DailyOverviewCard({
    required this.progress,
    required this.percentage,
    required this.done,
    required this.total,
  });

  final double progress;
  final int percentage;
  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final remaining = total - done;
    return DsCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t('نظرة عامة على اليوم', 'Daily Overview'),
                        style: text.titleMedium),
                    Text(t('إيقاع عاداتك الاستشفائي',
                        'Restorative habit rhythm'),
                        style: text.bodySmall),
                  ],
                ),
              ),
              DsPill(
                label: t('مزامنة مباشرة', 'Real-time Sync'),
                icon: Icons.sync_rounded,
                tone: DsTone.success,
                compact: true,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              DsProgressRing(
                value: progress,
                size: 96,
                strokeWidth: 10,
                center: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$percentage%',
                        style: text.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        )),
                    Text(t('مكتمل', 'complete'), style: text.labelSmall),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t('$done من $total مكتملة', '$done of $total Done'),
                      style: text.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      remaining <= 0
                          ? t(
                              'مذهل! أكملت كل عادات اليوم. حافظ على هذا الزخم.',
                              'Amazing! You completed every habit today. Keep the momentum.',
                            )
                          : t(
                              'طاقتك الذهنية بعد الظهر مستقرة. بقي $remaining تسجيل فقط لإكمال إيقاعك اليومي!',
                              'Your afternoon cognitive energy is stable. Just $remaining quick check-ins left to hit your daily rhythm goal!',
                            ),
                      style: text.bodySmall,
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 7,
                        backgroundColor: AppColors.primaryFixed,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.done, required this.total});

  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return DsCard(
      padding: const EdgeInsets.all(16),
      radius: 22,
      gradient: const LinearGradient(
        colors: [Color(0xFFE9EEFF), Color(0xFFF6F4FF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderColor: AppColors.primaryFixedDim,
      shadow: false,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DsIconBadge(
            icon: Icons.smart_toy_rounded,
            tone: DsTone.primary,
            size: 42,
            radius: 13,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t('رؤية BreakBot', 'BreakBot Insight'),
                    style: text.labelMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    )),
                const SizedBox(height: 4),
                Text(
                  done >= total && total > 0
                      ? t(
                          '«الوقفات الدقيقة أعادت ضبط إيقاع عينيك وتنفسك. خذ رشفة ماء الآن واحتفظ بهذا الإحساس.»',
                          '“Your micro-pauses reset blink rate and ocular strain. Take a sip of water and keep this feeling.”',
                        )
                      : t(
                          '«وقفات 90 ثانية تعيد ضبط معدل الرمش وإجهاد العين حتى 42%. خذ رشفة ماء الآن!»',
                          '“Micro-pauses of 90 seconds reset your blink rate and ocular strain by up to 42%. Take a sip now!”',
                        ),
                  style: text.bodySmall?.copyWith(
                    color: AppColors.onSurface,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HabitRow extends StatelessWidget {
  const _HabitRow({
    required this.habit,
    required this.done,
    required this.onCheckIn,
  });

  final Habit habit;
  final bool done;
  final VoidCallback onCheckIn;

  String _timeLabel() {
    final time = habit.targetTime;
    if (time == null) return t('عادة يومية', 'Daily habit');
    final hour = time.hour == 0
        ? 12
        : time.hour > 12
            ? time.hour - 12
            : time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final suffix = time.hour >= 12 ? t('م', 'PM') : t('ص', 'AM');
    return '${t('الهدف', 'Target')}: $hour:$minute $suffix';
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final visual = HabitVisual.forName(habit.name);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          DsIconBadge(
            icon: visual.icon,
            color: visual.foreground,
            background: visual.background,
            size: 44,
            radius: 14,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.titleSmall?.copyWith(
                    decoration: done ? TextDecoration.lineThrough : null,
                    color: done
                        ? AppColors.onSurfaceVariant
                        : AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    if (done)
                      Text(
                        t('مكتملة +10 XP', 'Completed +10 XP'),
                        style: text.labelSmall
                            ?.copyWith(color: AppColors.success),
                      )
                    else ...[
                      Icon(Icons.schedule_rounded,
                          size: 12, color: AppColors.outline),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(_timeLabel(),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: text.labelSmall),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (done)
            const DsPill(
              label: 'Done',
              icon: Icons.check_circle_rounded,
              tone: DsTone.success,
              compact: true,
            )
          else
            _CheckButton(onTap: onCheckIn),
        ],
      ),
    );
  }
}

class _CheckButton extends StatelessWidget {
  const _CheckButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primaryFixed,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const SizedBox(
          width: 36,
          height: 36,
          child: Icon(Icons.check_rounded, size: 20, color: AppColors.primary),
        ),
      ),
    );
  }
}

class _CoachFooter extends StatelessWidget {
  const _CoachFooter({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return DsCard(
      radius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      onTap: onTap,
      child: Row(
        children: [
          const DsIconBadge(
            icon: Icons.forum_rounded,
            tone: DsTone.secondary,
            size: 40,
            radius: 12,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t('تحدث مع BreakBot', 'Chat with BreakBot'),
                    style: text.titleSmall),
                Text(
                  t('جاهز لإشارات سريعة عندما تحتاجها.',
                      'Standing by for quick nudges when you need them.'),
                  style: text.bodySmall,
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_rounded,
              size: 18, color: AppColors.primary),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Interactive check-in
// ---------------------------------------------------------------------------

class _CheckInCard extends StatefulWidget {
  const _CheckInCard({
    required this.habits,
    required this.isDoneToday,
    required this.onCheckIn,
    required this.onChat,
    required this.onOpenHabits,
  });

  final List<Habit> habits;
  final bool Function(Habit) isDoneToday;
  final void Function(Habit) onCheckIn;
  final VoidCallback onChat;
  final VoidCallback onOpenHabits;

  @override
  State<_CheckInCard> createState() => _CheckInCardState();
}

class _CheckInCardState extends State<_CheckInCard> {
  String? _habitId;
  String _status = 'done';
  int _mood = 1;
  double _craving = 6;

  static const _moods = <(String, String, String)>[
    ('🤩', 'رائع', 'Great'),
    ('😊', 'جيد', 'Good'),
    ('😐', 'محايد', 'Neutral'),
    ('😰', 'قلق', 'Anxious'),
    ('🤯', 'متوتر', 'Stressed'),
  ];

  Habit? get _selected {
    if (widget.habits.isEmpty) return null;
    return widget.habits.firstWhere(
      (h) => h.id == _habitId,
      orElse: () => widget.habits.first,
    );
  }

  @override
  void initState() {
    super.initState();
    _syncSelection();
  }

  @override
  void didUpdateWidget(covariant _CheckInCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncSelection();
  }

  void _syncSelection() {
    final selected = _selected;
    if (selected == null) {
      _habitId = null;
      return;
    }
    _habitId = selected.id;
  }

  double get _risk => (0.08 + _craving * 0.1).clamp(0.0, 1.0);

  String get _riskLabel {
    if (_risk >= 0.7) return t('خطورة مرتفعة', 'High Risk');
    if (_risk >= 0.45) return t('خطورة متوسطة', 'Moderate Risk');
    return t('خطورة منخفضة', 'Low Risk');
  }

  Future<void> _pickHabit() async {
    if (widget.habits.isEmpty) return;
    final chosen = await showModalBottomSheet<Habit>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  child: Text(
                    t('اختر عادة للتحقق', 'Choose a habit to check in'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                for (final habit in widget.habits)
                  ListTile(
                    leading: DsIconBadge(
                      icon: HabitVisual.forName(habit.name).icon,
                      color: HabitVisual.forName(habit.name).foreground,
                      background: HabitVisual.forName(habit.name).background,
                      size: 40,
                      radius: 12,
                    ),
                    title: Text(habit.name),
                    subtitle: Text(
                      widget.isDoneToday(habit)
                          ? t('مكتملة اليوم', 'Completed today')
                          : t('بانتظار التحقق', 'Awaiting check-in'),
                    ),
                    trailing: habit.id == _habitId
                        ? const Icon(Icons.check_circle_rounded,
                            color: AppColors.primary)
                        : null,
                    onTap: () => Navigator.pop(context, habit),
                  ),
              ],
            ),
          ),
        );
      },
    );
    if (chosen == null) return;
    setState(() {
      _habitId = chosen.id;
      _status = widget.isDoneToday(chosen) ? 'done' : 'skipped';
    });
  }

  void _selectStatus(String status, Habit? habit) {
    setState(() => _status = status);
    if (habit == null) return;
    if (status == 'done') {
      widget.onCheckIn(habit);
    } else if (status == 'skipped') {
      showDsSnack(context,
          t('تم تسجيل تخطي اليوم. لا بأس، غدًا فرصة جديدة.',
              'Skipped today. That’s okay — tomorrow is a fresh start.'));
    } else {
      showDsSnack(
          context,
          t('تم تسجيل انتكاسة. تذكّر: لا تفوّت مرتين متتاليتين.',
              'Relapse logged. Remember: never miss twice in a row.'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final habit = _selected;
    final visual = habit == null
        ? HabitVisual.forName('')
        : HabitVisual.forName(habit.name);

    return DsCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DsIconBadge(
                icon: Icons.edit_calendar_rounded,
                tone: DsTone.primary,
                size: 42,
                radius: 13,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t('تسجيل تفاعلي', 'Interactive Check-In'),
                        style: text.titleMedium),
                    Text(t('تحقق فوري من العادة', 'Real-time habit verification'),
                        style: text.bodySmall),
                  ],
                ),
              ),
              DsPill(
                label: t('تدفق مباشر', 'Active Flow'),
                tone: DsTone.success,
                compact: true,
                icon: Icons.bolt_rounded,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _LabelRow(
            icon: Icons.task_alt_rounded,
            label: t('العادة المستهدفة', 'Selected Habit Target'),
            trailing: TextButton(
              onPressed: _pickHabit,
              style: TextButton.styleFrom(
                minimumSize: const Size(0, 30),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(t('تغيير', 'Change')),
                  const Icon(Icons.expand_more_rounded, size: 16),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.45),
              ),
            ),
            child: Row(
              children: [
                DsIconBadge(
                  icon: visual.icon,
                  color: visual.foreground,
                  background: visual.background,
                  size: 42,
                  radius: 13,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit?.name ?? t('لا توجد عادات بعد', 'No habits yet'),
                        style: text.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        habit?.description ??
                            t('أضف عادة لبدء التحقق', 'Add a habit to start'),
                        style: text.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (habit != null)
                  Text(
                    t('${habit.streak} يوم', '${habit.streak} days'),
                    style: text.labelSmall?.copyWith(
                      color: AppColors.tertiary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _LabelRow(
            icon: Icons.checklist_rounded,
            label: t('حالة العادة', 'Habit Status'),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _StatusButton(
                  label: t('تم', 'Done'),
                  icon: Icons.check_circle_rounded,
                  active: _status == 'done',
                  tone: DsTone.success,
                  onTap: () => _selectStatus('done', habit),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatusButton(
                  label: t('تخطي', 'Skipped'),
                  icon: Icons.skip_next_rounded,
                  active: _status == 'skipped',
                  tone: DsTone.neutral,
                  onTap: () => _selectStatus('skipped', habit),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatusButton(
                  label: t('انتكاسة', 'Relapsed'),
                  icon: Icons.replay_rounded,
                  active: _status == 'relapsed',
                  tone: DsTone.danger,
                  onTap: () => _selectStatus('relapsed', habit),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _LabelRow(
            icon: Icons.mood_rounded,
            label: t('الحالة الذهنية الآن', 'Current Mindset / Emotion'),
            trailing: Text(t('اختر 1', 'Pick 1'), style: text.labelSmall),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (var i = 0; i < _moods.length; i++)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: i == 0 ? 0 : 4,
                      right: i == _moods.length - 1 ? 0 : 4,
                    ),
                    child: _MoodButton(
                      emoji: _moods[i].$1,
                      label: t(_moods[i].$2, _moods[i].$3),
                      active: _mood == i,
                      onTap: () => setState(() => _mood = i),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          _LabelRow(
            icon: Icons.speed_rounded,
            label: t('شدة الرغبة / الاندفاع', 'Craving / Urge Intensity'),
            trailing: DsPill(
              label: t('المستوى ${_craving.round()} / 10',
                  'Level ${_craving.round()} / 10'),
              tone: DsTone.primary,
              compact: true,
              bold: true,
            ),
          ),
          Slider(
            value: _craving,
            min: 1,
            max: 10,
            divisions: 9,
            label: _craving.round().toString(),
            onChanged: (value) => setState(() => _craving = value),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ScaleLabel(t('1 · خفيف', '1 · Mild')),
              _ScaleLabel(t('5 · مشتت', '5 · Distracting')),
              _ScaleLabel(t('10 · غالب', '10 · Overwhelming')),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _risk >= 0.7
                  ? AppColors.warningContainer
                  : AppColors.primaryFixed.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: _risk >= 0.7
                    ? AppColors.tertiaryFixedDim
                    : AppColors.primaryFixedDim,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.monitor_heart_rounded,
                      size: 18,
                      color: _risk >= 0.7
                          ? AppColors.tertiary
                          : AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        t('درجة الخطورة: ${_risk.toStringAsFixed(2)}',
                            'Risk Score: ${_risk.toStringAsFixed(2)}'),
                        style: text.titleSmall?.copyWith(
                          color: _risk >= 0.7
                              ? AppColors.tertiary
                              : AppColors.primary,
                        ),
                      ),
                    ),
                    DsPill(
                      label: _riskLabel,
                      tone: _risk >= 0.7 ? DsTone.tertiary : DsTone.primary,
                      compact: true,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  t(
                    'رصد BreakBot حلقة احتكاك بعد العمل والنظر المطوّل للشاشة.',
                    'BreakBot detected a post-work friction loop and prolonged static screen gaze.',
                  ),
                  style: text.bodySmall?.copyWith(
                    color: _risk >= 0.7
                        ? AppColors.onWarningContainer
                        : AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const DsIconBadge(
                  icon: Icons.psychology_alt_rounded,
                  tone: DsTone.secondary,
                  size: 36,
                  radius: 11,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t('لطيفة تكيفية', 'Adaptive Coping Nudge'),
                          style: text.labelLarge),
                      const SizedBox(height: 3),
                      Text(
                        t(
                          'دماغك يبحث عن الدوبامين من عادة الراحة. استبدل الحلقة بتدفق أكسجين أعلى وتأريض بصري الآن.',
                          'Your brain seeks dopamine from routine inertia. Replace the loop with high oxygen flow and visual grounding right now.',
                        ),
                        style: text.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          DsPrimaryButton(
            label: t('ابدأ إعادة ضبط دقيقتين', 'Start 2-Min Guided Reset'),
            icon: Icons.play_circle_fill_rounded,
            onPressed: () => showDialog<void>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(t('إعادة ضبط دقيقتين', '2-Minute Reset')),
                content: Text(
                  t(
                    'استنشق 4 ثوانٍ، احبس 4، ازفر 4، ثم احبس 4. كرر 4 مرات. أنت الآن تكسر حلقة الرغبة.',
                    'Inhale 4s, hold 4s, exhale 4s, hold 4s. Repeat 4 times. You are interrupting the craving loop right now.',
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(t('تم', 'Done')),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          DsOutlinedButton(
            label: t('تحدث مع BreakBot', 'Chat with BreakBot'),
            icon: Icons.forum_outlined,
            onPressed: widget.onChat,
          ),
        ],
      ),
    );
  }
}

class _LabelRow extends StatelessWidget {
  const _LabelRow({
    required this.icon,
    required this.label,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.onSurfaceVariant),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class _StatusButton extends StatelessWidget {
  const _StatusButton({
    required this.label,
    required this.icon,
    required this.active,
    required this.tone,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final DsTone tone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = active ? Colors.white : tone.foreground;
    final bg = active ? tone.foreground : tone.background;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 6),
          child: Column(
            children: [
              Icon(icon, size: 19, color: fg),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: fg,
                      fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoodButton extends StatelessWidget {
  const _MoodButton({
    required this.emoji,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: active
              ? AppColors.primaryFixed
              : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active
                ? AppColors.primary
                : AppColors.outlineVariant.withValues(alpha: 0.35),
            width: active ? 1.6 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color:
                        active ? AppColors.primary : AppColors.onSurfaceVariant,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 10,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScaleLabel extends StatelessWidget {
  const _ScaleLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context)
          .textTheme
          .labelSmall
          ?.copyWith(fontSize: 9.5, color: AppColors.outline),
    );
  }
}
