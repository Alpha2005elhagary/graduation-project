import 'package:breakbot/core/di/injection_container.dart';
import 'package:breakbot/core/localisation/app_strings.dart';
import 'package:breakbot/core/storage/local_storage_manager.dart';
import 'package:breakbot/core/theme/app_theme.dart';
import 'package:breakbot/features/coach/domain/entities/coach_message.dart';
import 'package:breakbot/shared/widgets/ds_widgets.dart';
import 'package:flutter/material.dart';

/// AI coach conversation with risk banner, voice-journal message, a two-step
/// micro-intervention, quick actions and a voice/text composer.
class CoachScreen extends StatefulWidget {
  const CoachScreen({super.key, this.onNavigateTab});

  final Function(int)? onNavigateTab;

  @override
  State<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends State<CoachScreen> {
  final storage = getIt<LocalStorageManager>();
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  List<CoachMessage> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    if (_messages.isEmpty) _addWelcomeMessage();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadMessages() {
    _messages = storage.getCoachMessages();
  }

  String _welcomeText() => t(
        'مرحبًا! لاحظت ارتفاع إشارة الرغبة بعد اجتماعات بعد الظهر. ما الذي يبدو أكثر إلحاحًا الآن؟',
        'Hi! I noticed your craving signal surged right after your afternoon meetings. What feels most urgent right now?',
      );

  void _addWelcomeMessage() {
    _sendMessage(CoachMessage(
      text: _welcomeText(),
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  void _sendMessage(CoachMessage message) {
    final updated = List<CoachMessage>.from(_messages)..add(message);
    storage.saveCoachMessages(updated);
    setState(() => _messages = updated);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _sendUserMessage([String? customText]) {
    final text = (customText ?? _messageController.text).trim();
    if (text.isEmpty) return;
    _messageController.clear();
    _sendMessage(CoachMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    ));
    setState(() => _isTyping = true);

    Future.delayed(const Duration(milliseconds: 1100), () {
      if (!mounted) return;
      setState(() => _isTyping = false);
      _sendMessage(CoachMessage(
        text: _aiResponse(text),
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
  }

  String _aiResponse(String input) {
    final lower = input.toLowerCase();
    bool has(List<String> keys) => keys.any(lower.contains);

    if (has(['عادة', 'عادات', 'habit'])) {
      return t(
        'بناء العادات يحتاج استمرارية لا كثافة. ابدأ بقاعدة الدقيقتين: نسخة صغيرة جدًا من العادة، واربطها بعادة موجودة بالفعل. الأسبوع الأول للثبات فقط.',
        'Habit building needs consistency, not intensity. Start with the two-minute rule: a tiny version of the habit, anchored to something you already do. Week one is only about showing up.',
      );
    }
    if (has(['تركيز', 'focus', 'بومودورو', 'pomodoro'])) {
      return t(
        'جرّب 25 دقيقة تركيز عميق ثم 5 دقائق استراحة. ضع هاتفك خارج الغرفة، واكتب أي فكرة عابرة على ورقة حتى لا تقطع تسلسل أفكارك.',
        'Try 25 minutes of deep focus, then a 5-minute break. Keep your phone out of the room and jot stray thoughts on paper so they don’t break your flow.',
      );
    }
    if (has(['تسويف', 'تأجيل', 'procrastinat'])) {
      return t(
        'التسويف غالبًا خوف من ثقل البداية. استخدم قاعدة الخمس ثوانٍ: 5-4-3-2-1 ثم ابدأ فورًا بأصغر خطوة ممكنة. لا تفكر في المهمة كلها.',
        'Procrastination is usually the weight of starting. Use the five-second rule: 5-4-3-2-1, then take the smallest possible first step. Don’t think about the whole task.',
      );
    }
    if (has(['انتكاس', 'انقطاع', 'relapse', 'فشل'])) {
      return t(
        'التعثر طبيعي. القاعدة الذهبية: لا تفوّت مرتين متتاليتين. اعتبر اليوم استراحة، وعُد غدًا بخطوة أصغر ولطف أكبر مع نفسك.',
        'A slip is normal. The golden rule: never miss twice in a row. Treat today as a pause and return tomorrow with a smaller step and more kindness to yourself.',
      );
    }
    if (has(['رغبة', 'craving', 'سكر', 'sugar', 'شهية'])) {
      return t(
        'الرغبة موجة — تصل للذروة ثم تنخفض خلال 3 إلى 5 دقائق. اشرب 250 مل ماء، وتنفس 4-4-4-4، وانتظر 5 دقائق قبل أي قرار. 68% من الرغبات تخف بعد الترطيب.',
        'A craving is a wave — it peaks then falls within 3–5 minutes. Drink 250ml of water, breathe 4-4-4-4, and wait five minutes before deciding. 68% of cravings fade after hydration.',
      );
    }
    if (has(['مرحبا', 'أهلا', 'السلام', 'hello', 'hi ', 'hey'])) {
      return t(
        'أهلًا بك! سعيد بتواصلك. أخبرني عن التحدي الذي تواجهه الآن، وسنحوّله إلى خطوة صغيرة قابلة للتنفيذ.',
        'Hello! Glad you’re here. Tell me the challenge you’re facing right now and we’ll turn it into one small, doable step.',
      );
    }
    return t(
      'فهمت. التركيز والاستمرار رحلة تدريجية. هل نضع خطة سريعة لليوم، أو نراجع أحد بروتوكولاتك الحالية معًا؟',
      'Got it. Focus and consistency are a gradual journey. Shall we set a quick plan for today, or review one of your current protocols together?',
    );
  }

  void _clearChat() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t('مسح المحادثة', 'Clear conversation')),
        content: Text(t(
          'هل تريد حذف جميع رسائل المحادثة؟ ستبدأ برسالة ترحيب جديدة.',
          'Delete every message in this conversation? You’ll start again with a fresh greeting.',
        )),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t('إلغاء', 'Cancel')),
          ),
          FilledButton(
            onPressed: () {
              storage.saveCoachMessages([]);
              setState(() => _messages = []);
              Navigator.pop(context);
              _addWelcomeMessage();
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(t('مسح', 'Clear')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final user = storage.getUser();
    final firstName = (user?.name.trim().isNotEmpty ?? false)
        ? user!.name.trim().split(RegExp(r'\s+')).first
        : t('أليكس', 'Alex');
    final streak = storage
        .getHabits()
        .fold<int>(0, (max, h) => h.streak > max ? h.streak : max);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const DsBrandMark(size: 40, radius: 13),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t('المدرب الذكي', 'AI Coach'),
                                style: text.titleLarge),
                            Row(
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: const BoxDecoration(
                                    color: AppColors.success,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    t('متصل · مزامنة العادات نشطة',
                                        'Online · Habit Sync Active'),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: text.labelSmall
                                        ?.copyWith(color: AppColors.success),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      DsPill(
                        label: '$streak 🔥',
                        tone: DsTone.tertiary,
                        compact: true,
                        bold: true,
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        tooltip: t('مسح المحادثة', 'Clear conversation'),
                        onPressed: _clearChat,
                        icon: const Icon(Icons.settings_outlined, size: 21),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _RiskBanner(
                    onAnalytics: () => widget.onNavigateTab?.call(3),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      DsPill(
                        label: t('هادئ', 'Calm'),
                        icon: Icons.spa_outlined,
                        tone: DsTone.secondary,
                        compact: true,
                      ),
                      const Spacer(),
                      Text(
                        t('اليوم • 3:42 م', 'Today • 3:42 PM'),
                        style: text.labelSmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                physics: const BouncingScrollPhysics(),
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (_isTyping && index == _messages.length) {
                    return _TypingBubble(text: text);
                  }
                  final message = _messages[index];
                  final isFirstAi = !message.isUser &&
                      _messages.indexWhere((m) => !m.isUser) == index;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _MessageBubble(
                        message: message,
                        firstName: firstName,
                      ),
                      if (isFirstAi) ...[
                        const SizedBox(height: 10),
                        _VoiceJournalCard(text: text),
                        const SizedBox(height: 10),
                        _MicroInterventionCard(
                          text: text,
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
            _Composer(
              controller: _messageController,
              onSend: _sendUserMessage,
              onMic: () => showDsSnack(
                context,
                t('المذكرات الصوتية التجريبية جاهزة — اضغط للتسجيل في النسخة الكاملة.',
                    'Voice journaling is wired for the full build — tap to record there.'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _QuickAction(
                      icon: Icons.air_rounded,
                      label: t('تنفس موجّه', 'Guided Sigh'),
                      onTap: () => _sendUserMessage(
                          t('أحتاج تمرين تنفس سريع', 'I need a quick breathing exercise')),
                    ),
                    const SizedBox(width: 8),
                    _QuickAction(
                      icon: Icons.auto_awesome_rounded,
                      label: t('أعد صياغة الرغبة', 'Reframe Craving'),
                      onTap: () => _sendUserMessage(
                          t('ساعدني في إعادة صياغة هذه الرغبة',
                              'Help me reframe this craving')),
                    ),
                    const SizedBox(width: 8),
                    _QuickAction(
                      icon: Icons.bookmark_add_outlined,
                      label: t('سجّل الإشارة', 'Log Trigger'),
                      onTap: () => _sendUserMessage(
                          t('أريد تسجيل إشارة الرغبة', 'I want to log a trigger')),
                    ),
                    const SizedBox(width: 8),
                    _QuickAction(
                      icon: Icons.explore_outlined,
                      label: t('بروتوكولاتي', 'My Protocols'),
                      onTap: () => widget.onNavigateTab?.call(1),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 76),
          ],
        ),
      ),
    );
  }
}

class _RiskBanner extends StatelessWidget {
  const _RiskBanner({required this.onAnalytics});

  final VoidCallback onAnalytics;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warningContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.tertiaryFixedDim),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DsIconBadge(
            icon: Icons.warning_amber_rounded,
            tone: DsTone.tertiary,
            size: 40,
            radius: 12,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        t('رصد ارتفاع في الرغبة', 'Elevated Craving Detected'),
                        style: text.titleSmall
                            ?.copyWith(color: AppColors.tertiary),
                      ),
                    ),
                    DsPill(
                      label: t('خطورة 0.72', 'Risk 0.72'),
                      tone: DsTone.tertiary,
                      compact: true,
                      bold: true,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  t(
                    'انخفاض دوباميني بعد ذروة التقويم بـ 12 دقيقة.',
                    'Dopamine dip flagged 12 mins post-calendar peak.',
                  ),
                  style: text.bodySmall
                      ?.copyWith(color: AppColors.onWarningContainer),
                ),
                const SizedBox(height: 6),
                InkWell(
                  onTap: onAnalytics,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        t('التحليلات', 'Analytics'),
                        style: text.labelSmall?.copyWith(
                          color: AppColors.tertiary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 3),
                      const Icon(Icons.north_east_rounded,
                          size: 12, color: AppColors.tertiary),
                    ],
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

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.firstName});

  final CoachMessage message;
  final String firstName;

  String get _time {
    final hour = message.timestamp.hour;
    final h = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final m = message.timestamp.minute.toString().padLeft(2, '0');
    final suffix = hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $suffix';
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final user = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        mainAxisAlignment:
            user ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!user) ...[
            const DsBrandMark(size: 30, radius: 10),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  user ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      user ? firstName : 'BreakBot',
                      style: text.labelSmall?.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(_time, style: text.labelSmall),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                  decoration: BoxDecoration(
                    color: user
                        ? AppColors.primary
                        : AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(user ? 18 : 5),
                      bottomRight: Radius.circular(user ? 5 : 18),
                    ),
                    border: user
                        ? null
                        : Border.all(
                            color: AppColors.outlineVariant
                                .withValues(alpha: 0.45),
                          ),
                    boxShadow: user
                        ? null
                        : [
                            BoxShadow(
                              color: AppColors.onSurface
                                  .withValues(alpha: 0.03),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                  ),
                  child: Text(
                    message.text,
                    style: text.bodyMedium?.copyWith(
                      color: user ? Colors.white : AppColors.onSurface,
                      height: 1.55,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (user) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 15,
              backgroundColor: AppColors.surfaceContainerHigh,
              child: Text(
                firstName.isNotEmpty ? firstName[0].toUpperCase() : 'U',
                style: text.labelSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble({required this.text});

  final TextTheme text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 8),
      child: Row(
        children: [
          const DsBrandMark(size: 30, radius: 10),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.45),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 13,
                  height: 13,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 8),
                Text(t('المدرب يكتب…', 'Coach is typing…'),
                    style: text.labelSmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VoiceJournalCard extends StatefulWidget {
  const _VoiceJournalCard({required this.text});

  final TextTheme text;

  @override
  State<_VoiceJournalCard> createState() => _VoiceJournalCardState();
}

class _VoiceJournalCardState extends State<_VoiceJournalCard> {
  bool _playing = false;

  @override
  Widget build(BuildContext context) {
    final text = widget.text;
    return DsCard(
      radius: 20,
      padding: const EdgeInsets.all(14),
      gradient: const LinearGradient(
        colors: [Color(0xFFF1EFFF), Color(0xFFF9F8FF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderColor: AppColors.secondaryFixedDim,
      shadow: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const DsIconBadge(
                icon: Icons.mic_rounded,
                tone: DsTone.secondary,
                size: 34,
                radius: 11,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(t('مذكرة صوتية', 'Voice Journal'),
                    style: text.titleSmall),
              ),
              Text('0:38', style: text.labelSmall),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Material(
                color: AppColors.secondary,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {
                    setState(() => _playing = !_playing);
                    showDsSnack(
                      context,
                      t('تشغيل المذكرة الصوتية (تجريبي)',
                          'Playing the voice note (demo)'),
                    );
                  },
                  child: SizedBox(
                    width: 38,
                    height: 38,
                    child: Icon(
                      _playing
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 30,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: List.generate(26, (index) {
                      final heights = <double>[8, 14, 20, 12, 24, 17, 10, 22, 28, 16, 9, 19, 25, 13, 21, 11, 27, 15, 8, 18, 23, 12, 26, 16, 10, 20];
                      return Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          height: heights[index % heights.length],
                          decoration: BoxDecoration(
                            color: _playing
                                ? AppColors.secondary
                                : AppColors.secondaryFixedDim,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            t('0:14 / 0:38', '0:14 / 0:38'),
            style: text.labelSmall?.copyWith(color: AppColors.secondary),
          ),
          const SizedBox(height: 8),
          Text(
            t(
              '«أشعر برغبة شديدة في السكريات بعد مراجعة الفريق… أحاول أن أتوقف أولًا.»',
              '“Feeling an intense craving for sweets after the sprint review… trying to take a pause first.”',
            ),
            style: text.bodySmall?.copyWith(
              color: AppColors.onSurface,
              fontStyle: FontStyle.italic,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.graphic_eq_rounded,
                  size: 14, color: AppColors.secondary),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  t('نبرة التوتر: متوسطة', 'Stress tone: Moderate'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.labelSmall?.copyWith(color: AppColors.secondary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MicroInterventionCard extends StatefulWidget {
  const _MicroInterventionCard({
    required this.text,
  });

  final TextTheme text;

  @override
  State<_MicroInterventionCard> createState() => _MicroInterventionCardState();
}

class _MicroInterventionCardState extends State<_MicroInterventionCard> {
  final Set<int> _done = {};

  void _complete(int step, int xp) {
    if (_done.contains(step)) return;
    setState(() => _done.add(step));
    showDsSnack(
      context,
      t('تمت المزامنة مع تسجيل اليوم · +$xp XP',
          'Synced to today’s check-in · +$xp XP'),
      success: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.text;
    return DsCard(
      radius: 20,
      padding: const EdgeInsets.all(16),
      gradient: const LinearGradient(
        colors: [Color(0xFFE9EEFF), Color(0xFFF7F9FF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderColor: AppColors.primaryFixedDim,
      shadow: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DsIconBadge(
                icon: Icons.psychology_rounded,
                tone: DsTone.primary,
                size: 36,
                radius: 11,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t('انتصار عصبي', 'Neuro-Victory'),
                        style: text.titleSmall
                            ?.copyWith(color: AppColors.primary)),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        style: text.bodySmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                          height: 1.55,
                        ),
                        children: [
                          TextSpan(
                            text: t(
                              'تلك الوقفة هي انتصار عصبي! لقد عطّلت حلقة المكافأة التلقائية. إليك تدخلًا صغيرًا من خطوتين:',
                              'That pause is a neuro-victory! You disrupted the automatic reward loop. Here is your 2-step micro-intervention:',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _StepRow(
            index: 1,
            icon: Icons.air_rounded,
            title: t('التنفس الصندوقي', 'Box Breathing'),
            subtitle: t('إيقاع 4-4-4-4', '4-4-4-4 rhythm'),
            description: t(
              'شهيق 4 ثوان، حبس 4، زفير 4، حبس 4. يعيد ضبط الجهاز العصبي اللاإرادي.',
              'Inhale 4s, hold 4s, exhale 4s, hold 4s. Resets the autonomic nervous system.',
            ),
            xp: 15,
            done: _done.contains(1),
            onTap: () => _complete(1, 15),
            text: text,
          ),
          const SizedBox(height: 10),
          _StepRow(
            index: 2,
            icon: Icons.water_drop_rounded,
            title: t('تأخير الترطيب', 'Hydration Delay'),
            subtitle: t('نافذة 5 دقائق', '5 min window'),
            description: t(
              'اشرب 250 مل ماء وانتظر 5 دقائق. 68% من الرغبات تخف بعد الترطيب.',
              'Drink 250ml water and wait 5 minutes. 68% of cravings diminish after hydration.',
            ),
            xp: 10,
            done: _done.contains(2),
            onTap: () => _complete(2, 10),
            text: text,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 42,
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(t('إعادة ضبط موجّهة', 'Guided Micro-Reset')),
                  content: Text(t(
                    'ستبدأ جلسة صوتية مدتها دقيقتان: تنفس صندوقي، ثم تأريض بصري 20-20-20، ثم رشفة ماء.',
                    'A two-minute audio session: box breathing, 20-20-20 visual grounding, then a sip of water.',
                  )),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(t('تم', 'Done')),
                    ),
                  ],
                ),
              ),
              icon: const Icon(Icons.headphones_rounded, size: 18),
              label: Text(t('استمع لإعادة ضبط دقيقتين',
                  'Listen to Guided Micro-Reset (2 mins)')),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.index,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.xp,
    required this.done,
    required this.onTap,
    required this.text,
  });

  final int index;
  final IconData icon;
  final String title;
  final String subtitle;
  final String description;
  final int xp;
  final bool done;
  final VoidCallback onTap;
  final TextTheme text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: done
              ? AppColors.success.withValues(alpha: 0.4)
              : AppColors.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: done ? AppColors.success : AppColors.primaryFixed,
              borderRadius: BorderRadius.circular(8),
            ),
            child: done
                ? const Icon(Icons.check_rounded,
                    size: 15, color: Colors.white)
                : Text('$index',
                    style: text.labelSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    )),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 15, color: AppColors.primary),
                    const SizedBox(width: 5),
                    Expanded(child: Text(title, style: text.titleSmall)),
                    Text(
                      subtitle,
                      style: text.labelSmall
                          ?.copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(description, style: text.bodySmall),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: onTap,
                        borderRadius: BorderRadius.circular(8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              done
                                  ? Icons.check_circle_rounded
                                  : Icons.radio_button_unchecked_rounded,
                              size: 15,
                              color:
                                  done ? AppColors.success : AppColors.primary,
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                done
                                    ? t('تمت المزامنة', 'Synced')
                                    : t('مزامنة مع تسجيل اليوم',
                                        'Sync to Today’s Check-In'),
                                style: text.labelSmall?.copyWith(
                                  color: done
                                      ? AppColors.success
                                      : AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    DsPill(
                      label: '+$xp XP',
                      tone: done ? DsTone.success : DsTone.primary,
                      compact: true,
                      bold: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: AppColors.primary),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.onSend,
    required this.onMic,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onMic;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: onMic,
                  icon: const Icon(Icons.mic_none_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.surfaceContainerLowest,
                    side: BorderSide(
                      color: AppColors.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: controller,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => onSend(),
                    decoration: InputDecoration(
                      hintText: t('اسأل مدربك أي شيء…', 'Ask your coach anything…'),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      suffixIcon: IconButton(
                        onPressed: onSend,
                        tooltip: t('إرسال', 'Send'),
                        icon: const Icon(Icons.arrow_upward_rounded,
                            size: 19, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          minimumSize: const Size(34, 34),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline_rounded,
                    size: 11, color: AppColors.outline),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    t('خاص ومشفّر · يعمل على جهازك',
                        'Private & Encrypted · runs on-device'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.labelSmall?.copyWith(fontSize: 10),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
