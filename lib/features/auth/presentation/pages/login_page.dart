import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bennett_campus/core/constants/app_constants.dart';
import 'package:bennett_campus/core/theme/app_colors.dart';
import 'package:bennett_campus/core/theme/app_radii.dart';
import 'package:bennett_campus/core/theme/app_spacing.dart';
import 'package:bennett_campus/features/auth/presentation/providers/auth_provider.dart';
import 'package:bennett_campus/shared/widgets/widgets.dart';

/// Responsive dark-mode login screen with Bennett University branding.
class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final screenType = DeviceScreenType.of(context);
    final isDesktop = screenType == DeviceScreenType.desktop;

    return Scaffold(
      body: SafeArea(
        child: isDesktop
            ? Row(
                children: [
                  const Expanded(flex: 11, child: _EditorialShowcasePanel()),
                  Expanded(
                    flex: 9,
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(AppSpacing.xxl),
                        child: _AuthCardSection(isSigningIn: authState.isSigningIn),
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const _CompactBrandHeader(),
                      const SizedBox(height: AppSpacing.xl),
                      _AuthCardSection(isSigningIn: authState.isSigningIn),
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

class _AuthCardSection extends ConsumerWidget {
  const _AuthCardSection({required this.isSigningIn});

  final bool isSigningIn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 440),
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Welcome to BENNETT',
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Sign in to explore campus events, register for workshops, and view your digital passes.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: isSigningIn
                    ? null
                    : () => ref
                          .read(authControllerProvider.notifier)
                          .signInWithMicrosoft(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textPrimary,
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadii.borderMd,
                  ),
                ),
                child: isSigningIn
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.textPrimary,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const _MicrosoftMark(),
                          const SizedBox(width: AppSpacing.sm),
                          Flexible(
                            child: Text(
                              'Continue with Microsoft',
                              style: theme.textTheme.labelLarge,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
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
                          'Restricted to official Bennett University Microsoft accounts (@bennett.edu.in). Mock preview active for Stage 1.',
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
    );
  }
}

class _MicrosoftMark extends StatelessWidget {
  const _MicrosoftMark();

  @override
  Widget build(BuildContext context) {
    const gap = 2.0;
    const tile = 7.0;
    return SizedBox(
      width: tile * 2 + gap,
      height: tile * 2 + gap,
      child: Column(
        children: [
          Row(
            children: [
              Container(width: tile, height: tile, color: const Color(0xFFF25022)),
              const SizedBox(width: gap),
              Container(width: tile, height: tile, color: const Color(0xFF7FBA00)),
            ],
          ),
          const SizedBox(height: gap),
          Row(
            children: [
              Container(width: tile, height: tile, color: const Color(0xFF00A4EF)),
              const SizedBox(width: gap),
              Container(width: tile, height: tile, color: const Color(0xFFFFB900)),
            ],
          ),
        ],
      ),
    );
  }
}
