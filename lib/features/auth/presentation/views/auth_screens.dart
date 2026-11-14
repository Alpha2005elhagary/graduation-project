import 'package:breakbot/core/di/injection_container.dart';
import 'package:breakbot/core/localisation/app_strings.dart';
import 'package:breakbot/core/theme/app_theme.dart';
import 'package:breakbot/features/auth/presentation/viewmodels/auth_viewmodels.dart';
import 'package:breakbot/shared/widgets/ds_widgets.dart';
import 'package:flutter/material.dart';

/// Authentication follows the Stitch auth screen: a calm lavender surface, a
/// brand header, an account/login segmented switch and a tall primary CTA.
///
/// Local authentication accepts any non-empty credentials (the demo runs fully
/// on-device), so the screen remains faithful to the design without requiring a
/// backend.
class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.onComplete,
    required this.onToggle,
  });

  final VoidCallback onComplete;
  final VoidCallback onToggle;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _viewModel = getIt<LoginViewModel>();
  bool _isLoading = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = t(
            'يرجى إدخال البريد الإلكتروني وكلمة المرور',
            'Please enter your email and password',
          ));
      return;
    }
    if (!email.contains('@')) {
      setState(() => _error = t(
            'يرجى إدخال بريد إلكتروني صحيح',
            'Please enter a valid email address',
          ));
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });
    await _viewModel.login(email, password);
    if (!mounted) return;
    if (_viewModel.error != null) {
      setState(() {
        _isLoading = false;
        _error = _viewModel.error;
      });
      return;
    }
    setState(() => _isLoading = false);
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return _AuthShell(
      activeTab: 1,
      onToggle: widget.onToggle,
      title: t('مرحبًا بعودتك إلى BreakBot', 'Welcome back to BreakBot'),
      subtitle: t(
        'واصل بناء روتينك الصحي مع مدربك الذكي.',
        'Pick up your wellness rhythm with your personal AI guide.',
      ),
      error: _error,
      form: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            textDirection: TextDirection.ltr,
            decoration: InputDecoration(
              hintText: t('البريد الإلكتروني', 'Email Address'),
              prefixIcon: const Icon(Icons.mail_outline_rounded),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _passwordController,
            obscureText: _obscure,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _login(),
            textDirection: TextDirection.ltr,
            decoration: InputDecoration(
              hintText: t('كلمة المرور', 'Password'),
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                tooltip: _obscure
                    ? t('إظهار كلمة المرور', 'Show password')
                    : t('إخفاء كلمة المرور', 'Hide password'),
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(
                  _obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton(
              onPressed: () => showDsSnack(
                context,
                t('سنرسل رابط استعادة عند توفر الخدمة السحابية.',
                    'A recovery link will be sent once cloud sync is enabled.'),
              ),
              child: Text(t('نسيت كلمة المرور؟', 'Forgot password?')),
            ),
          ),
          const SizedBox(height: 6),
          _AuthCta(
            label: t('تسجيل الدخول', 'Log In'),
            loading: _isLoading,
            onPressed: _login,
          ),
        ],
      ),
      footerLink: t('ليس لديك حساب؟ إنشاء حساب جديد',
          'Don’t have an account? Create one'),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    super.key,
    required this.onComplete,
    required this.onToggle,
  });

  final VoidCallback onComplete;
  final VoidCallback onToggle;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _viewModel = getIt<RegisterViewModel>();
  bool _isLoading = false;
  bool _obscure = true;
  bool _acceptedTerms = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() => _error = t(
            'يرجى إدخال جميع الحقول',
            'Please fill in all fields',
          ));
      return;
    }
    if (!email.contains('@')) {
      setState(() => _error = t(
            'يرجى إدخال بريد إلكتروني صحيح',
            'Please enter a valid email address',
          ));
      return;
    }
    if (!_acceptedTerms) {
      setState(() => _error = t(
            'يرجى الموافقة على الشروط وسياسة الخصوصية',
            'Please accept the Terms of Service and Privacy Policy',
          ));
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });
    await _viewModel.register(name: name, email: email, password: password);
    if (!mounted) return;
    if (_viewModel.error != null) {
      setState(() {
        _isLoading = false;
        _error = _viewModel.error;
      });
      return;
    }
    setState(() => _isLoading = false);
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return _AuthShell(
      activeTab: 0,
      onToggle: widget.onToggle,
      title: t('أنشئ حسابك في BreakBot', 'Welcome to BreakBot'),
      subtitle: t(
        'ابنِ روتينك الصحي مع مدربك الذكي — أقل من دقيقة واحدة.',
        'Build unbreakable routines with your personal AI wellness guide.',
      ),
      error: _error,
      form: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _nameController,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              hintText: t('الاسم الكامل', 'Full Name'),
              prefixIcon: const Icon(Icons.person_outline_rounded),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            textDirection: TextDirection.ltr,
            decoration: InputDecoration(
              hintText: t('البريد الإلكتروني', 'Email Address'),
              prefixIcon: const Icon(Icons.mail_outline_rounded),
              suffixIcon: Padding(
                padding: const EdgeInsetsDirectional.only(end: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        size: 16, color: AppColors.success),
                    const SizedBox(width: 4),
                    Text(
                      t('متاح', 'Available'),
                      style: text.labelSmall
                          ?.copyWith(color: AppColors.success),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _passwordController,
            obscureText: _obscure,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _register(),
            textDirection: TextDirection.ltr,
            decoration: InputDecoration(
              hintText: t('كلمة المرور', 'Password'),
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                tooltip: _obscure
                    ? t('إظهار كلمة المرور', 'Show password')
                    : t('إخفاء كلمة المرور', 'Hide password'),
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(
                  _obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: const LinearProgressIndicator(
                    value: 0.86,
                    minHeight: 6,
                    backgroundColor: AppColors.successContainer,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.success),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                t('قوية · جاهزة', 'Strong · Ready'),
                style: text.labelSmall?.copyWith(color: AppColors.success),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DsCard(
            padding: const EdgeInsets.all(14),
            radius: 18,
            color: AppColors.infoContainer,
            borderColor: AppColors.primaryFixedDim,
            shadow: false,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded,
                    size: 18, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: text.bodySmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                        height: 1.5,
                      ),
                      children: [
                        TextSpan(
                          text: t('استعادة ذكية: ', 'Smart Recovery: '),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppColors.onSurface,
                          ),
                        ),
                        TextSpan(
                          text: t(
                            'إذا كان بريدك مسجلًا مسبقًا، سنرسل رابط استعادة بضغطة واحدة.',
                            'if your email already exists, BreakBot can send a 1-tap passwordless recovery link.',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => setState(() => _acceptedTerms = !_acceptedTerms),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _acceptedTerms,
                      onChanged: (value) =>
                          setState(() => _acceptedTerms = value ?? false),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      materialTapTargetSize:
                          MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      t(
                        'أوافق على شروط الخدمة وسياسة الخصوصية لتخصيص عاداتي.',
                        'I agree to BreakBot’s Terms of Service and Privacy Policy to personalize my habits.',
                      ),
                      style: text.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _AuthCta(
            label: t('أنشئ حسابي المجاني', 'Create My Free Account'),
            loading: _isLoading,
            onPressed: _register,
          ),
        ],
      ),
      footerLink: t('لديك حساب بالفعل؟ تسجيل الدخول',
          'Already have an account? Log In'),
    );
  }
}

class _AuthCta extends StatelessWidget {
  const _AuthCta({
    required this.label,
    required this.loading,
    required this.onPressed,
  });

  final String label;
  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        style: FilledButton.styleFrom(shape: const StadiumBorder()),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
      ),
    );
  }
}

class _AuthShell extends StatelessWidget {
  const _AuthShell({
    required this.activeTab,
    required this.onToggle,
    required this.title,
    required this.subtitle,
    required this.form,
    required this.footerLink,
    this.error,
  });

  final int activeTab;
  final VoidCallback onToggle;
  final String title;
  final String subtitle;
  final Widget form;
  final String footerLink;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
          physics: const BouncingScrollPhysics(),
          children: [
            Row(
              children: [
                if (Navigator.of(context).canPop())
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                  )
                else
                  const SizedBox(width: 6),
                const DsBrandLockup(size: 32),
                const Spacer(),
                IconButton(
                  onPressed: () => showDsSnack(
                    context,
                    t(
                      'BreakBot يعمل محليًا على جهازك. لا تُرسل بياناتك لأي خادم.',
                      'BreakBot runs locally on your device. Your data is never uploaded.',
                    ),
                  ),
                  icon: const Icon(Icons.help_outline_rounded),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const DsPill(
              label: 'Better Habits · Brighter You',
              icon: Icons.auto_awesome_rounded,
              tone: DsTone.secondary,
              compact: true,
            ),
            const SizedBox(height: 16),
            Text(title, style: text.headlineLarge),
            const SizedBox(height: 6),
            Text(subtitle, style: text.bodyLarge),
            const SizedBox(height: 22),
            _AuthTabs(activeTab: activeTab, onToggle: onToggle),
            const SizedBox(height: 20),
            if (error != null) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.errorContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        size: 20, color: AppColors.error),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        error!,
                        style: text.bodySmall
                            ?.copyWith(color: AppColors.onErrorContainer),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],
            form,
            const SizedBox(height: 20),
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(t('أو تابع باستخدام', 'or sign in with'),
                      style: text.labelSmall),
                ),
                const Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () => showDsSnack(
                        context,
                        t('تسجيل الدخول عبر Google غير متاح في النسخة التجريبية.',
                            'Google sign-in is not available in the demo build.'),
                      ),
                      icon: const Icon(Icons.g_mobiledata_rounded, size: 26),
                      label: const Text('Google'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.onSurface,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () => showDsSnack(
                        context,
                        t('تسجيل الدخول عبر Apple غير متاح في النسخة التجريبية.',
                            'Apple sign-in is not available in the demo build.'),
                      ),
                      icon: const Icon(Icons.apple_rounded, size: 24),
                      label: const Text('Apple'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.onSurface,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            DsCard(
              radius: 22,
              padding: const EdgeInsets.all(16),
              gradient: const LinearGradient(
                colors: [Color(0xFFEFF3FF), Color(0xFFF8F9FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shadow: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const DsIconBadge(
                        icon: Icons.smart_toy_rounded,
                        tone: DsTone.primary,
                        size: 36,
                        radius: 12,
                      ),
                      const SizedBox(width: 10),
                      Text(t('رسالة من مدربك', 'A note from your coach'),
                          style: text.labelMedium),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    t(
                      '«جاهز لتحقيق أهداف صغيرة؟ تحتاج 45 ثانية فقط لضبط إيقاع راحتك.»',
                      '“Ready to crush micro-goals? It only takes 45 seconds to tune your break pacing.”',
                    ),
                    style: text.bodyMedium?.copyWith(
                      color: AppColors.onSurface,
                      height: 1.55,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _MiniFeature(
                    icon: Icons.timer_outlined,
                    label: t('عادات دقيقتين', '2-Min Micro Habits'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MiniFeature(
                    icon: Icons.shield_outlined,
                    label: t('خاص ومشفّر', 'Private & Encrypted'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Center(
              child: TextButton(
                onPressed: onToggle,
                child: Text(footerLink),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                t('BreakBot • مدعوم بالذكاء السلوكي',
                    'BreakBot • Powered by Behavioral AI'),
                style: text.labelSmall?.copyWith(color: AppColors.outline),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthTabs extends StatelessWidget {
  const _AuthTabs({required this.activeTab, required this.onToggle});

  final int activeTab;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Expanded(
            child: _Tab(
              label: t('إنشاء حساب', 'Create Account'),
              icon: Icons.person_add_alt_1_rounded,
              active: activeTab == 0,
              onTap: activeTab == 0 ? null : onToggle,
              text: text,
            ),
          ),
          Expanded(
            child: _Tab(
              label: t('دخول', 'Log In'),
              icon: Icons.login_rounded,
              active: activeTab == 1,
              onTap: activeTab == 1 ? null : onToggle,
              text: text,
            ),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
    required this.text,
  });

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback? onTap;
  final TextTheme text;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? AppColors.surfaceContainerLowest : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: AppColors.onSurface.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: active ? AppColors.primary : AppColors.onSurfaceVariant,
            ),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: text.labelMedium?.copyWith(
                  color: active ? AppColors.primary : AppColors.onSurfaceVariant,
                  fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniFeature extends StatelessWidget {
  const _MiniFeature({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: text.labelSmall?.copyWith(color: AppColors.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}
