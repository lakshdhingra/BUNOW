import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bennett_campus/core/constants/app_constants.dart';
import 'package:bennett_campus/core/theme/app_colors.dart';
import 'package:bennett_campus/core/theme/app_radii.dart';
import 'package:bennett_campus/core/theme/app_spacing.dart';
import 'package:bennett_campus/features/auth/presentation/providers/auth_provider.dart';
import 'package:bennett_campus/shared/widgets/widgets.dart';

/// Responsive dark-mode login screen with Email/Password Supabase Auth.
class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenType = DeviceScreenType.of(context);
    final isDesktop = screenType == DeviceScreenType.desktop;

    return Scaffold(
      body: SafeArea(
        child: isDesktop
            ? const Row(
                children: [
                  Expanded(flex: 11, child: _EditorialShowcasePanel()),
                  Expanded(
                    flex: 9,
                    child: Center(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(AppSpacing.xxl),
                        child: _AuthCardSection(),
                      ),
                    ),
                  ),
                ],
              )
            : Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenType == DeviceScreenType.tablet
                        ? AppSpacing.xl
                        : AppSpacing.md,
                    vertical: AppSpacing.lg,
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _CompactBrandHeader(),
                      SizedBox(height: AppSpacing.xl),
                      _AuthCardSection(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _EditorialShowcasePanel extends StatelessWidget {
  const _EditorialShowcasePanel();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const Opacity(
            opacity: 0.24,
            child: CampusNetworkImage(
              imageUrl:
                  'https://images.unsplash.com/photo-1523580494863-6f3031224c94?auto=format&fit=crop&w=1400&q=80',
              fallbackIcon: Icons.school_outlined,
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.background.withValues(alpha: 0.92),
                  AppColors.surface.withValues(alpha: 0.85),
                  AppColors.primary.withValues(alpha: 0.18),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xxxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _BrandWordmark(),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xxs + 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryMuted,
                    borderRadius: AppRadii.borderPill,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.45),
                    ),
                  ),
                  child: Text(
                    'BENNETT UNIVERSITY CAMPUS PLATFORM',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.primaryHover,
                      letterSpacing: 0.9,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Text(
                    'Every campus hackathon, club showcase, and registration pass in one place.',
                    style: theme.textTheme.displaySmall?.copyWith(height: 1.18),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Text(
                    'Discover curated technical workshops, cultural nights, and verified student chapters across Bennett University.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                const Wrap(
                  spacing: AppSpacing.lg,
                  runSpacing: AppSpacing.md,
                  children: [
                    _StatPill(value: '35+', label: 'Active Clubs'),
                    _StatPill(value: '120+', label: 'Annual Events'),
                    _StatPill(value: '@bennett.edu.in', label: 'Verified Access'),
                  ],
                ),
                const Spacer(),
                Text(
                  'Bennett University · Greater Noida',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
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

class _StatPill extends StatelessWidget {
  const _StatPill({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.7),
        borderRadius: AppRadii.borderMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: theme.textTheme.titleMedium),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactBrandHeader extends StatelessWidget {
  const _CompactBrandHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _BrandWordmark(centered: true),
        const SizedBox(height: AppSpacing.xs),
        Text(
          AppConstants.appTagline,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _BrandWordmark extends StatelessWidget {
  const _BrandWordmark({this.centered = false});

  final bool centered;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment:
          centered ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: AppRadii.borderMd,
            border: Border.all(
              color: AppColors.secondary.withValues(alpha: 0.45),
            ),
          ),
          child: Text(
            'B',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppConstants.appName,
              style: theme.textTheme.titleMedium?.copyWith(letterSpacing: 1.1),
            ),
            Text(
              AppConstants.universityName,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AuthCardSection extends ConsumerStatefulWidget {
  const _AuthCardSection();

  @override
  ConsumerState<_AuthCardSection> createState() => _AuthCardSectionState();
}

class _AuthCardSectionState extends ConsumerState<_AuthCardSection> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isSignUp = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final notifier = ref.read(authControllerProvider.notifier);
    if (_isSignUp) {
      await notifier.signUpWithEmail(
        fullName: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );
    } else {
      await notifier.signInWithEmail(
        email: _emailController.text,
        password: _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authControllerProvider);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 440),
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _isSignUp ? 'Create BENNETT Account' : 'Welcome to BENNETT',
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                _isSignUp
                    ? 'Register with your campus email and password to access events and passes.'
                    : 'Sign in with your Bennett account to explore campus events and manage registrations.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              if (authState.errorMessage != null) ...[
                _AuthNoticeBanner(
                  message: authState.errorMessage!,
                  color: AppColors.error,
                  icon: Icons.error_outline_rounded,
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              if (authState.infoMessage != null) ...[
                _AuthNoticeBanner(
                  message: authState.infoMessage!,
                  color: AppColors.success,
                  icon: Icons.check_circle_outline_rounded,
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              if (_isSignUp) ...[
                AppTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  hintText: 'Aarav Sharma',
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(
                    Icons.person_outline_rounded,
                    size: 18,
                    color: AppColors.textMuted,
                  ),
                  validator: (value) {
                    if (_isSignUp && (value == null || value.trim().isEmpty)) {
                      return 'Please enter your full name.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              AppTextField(
                controller: _emailController,
                label: 'Email',
                hintText: 'student@bennett.edu.in',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                prefixIcon: const Icon(
                  Icons.mail_outline_rounded,
                  size: 18,
                  color: AppColors.textMuted,
                ),
                validator: (value) {
                  final trimmed = value?.trim() ?? '';
                  if (trimmed.isEmpty || !trimmed.contains('@')) {
                    return 'Enter a valid email address.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _passwordController,
                label: 'Password',
                hintText: 'Enter your password',
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                prefixIcon: const Icon(
                  Icons.lock_outline_rounded,
                  size: 18,
                  color: AppColors.textMuted,
                ),
                suffixIcon: IconButton(
                  tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 18,
                    color: AppColors.textMuted,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'Password must be at least 6 characters.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: _isSignUp ? 'Create Account' : 'Sign In',
                isLoading: authState.isSubmitting,
                fullWidth: true,
                size: AppButtonSize.lg,
                onPressed: _submit,
              ),
              const SizedBox(height: AppSpacing.sm),
              Center(
                child: TextButton(
                  onPressed: authState.isSubmitting
                      ? null
                      : () => setState(() => _isSignUp = !_isSignUp),
                  child: Text(
                    _isSignUp
                        ? 'Already have an account? Sign in'
                        : 'New here? Create an account',
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: AppRadii.borderMd,
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.verified_user_outlined,
                      size: 18,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'University-only access',
                            style: theme.textTheme.titleSmall,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Email/password Supabase Auth is active. Bennett Microsoft SSO will be connected in a future stage.',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthNoticeBanner extends StatelessWidget {
  const _AuthNoticeBanner({
    required this.message,
    required this.color,
    required this.icon,
  });

  final String message;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm + 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: AppRadii.borderMd,
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
