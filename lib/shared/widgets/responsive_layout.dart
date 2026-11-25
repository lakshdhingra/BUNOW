import 'package:flutter/material.dart';
import 'package:bennett_campus/core/theme/app_spacing.dart';

enum DeviceScreenType {
  mobile,
  tablet,
  desktop;

  static DeviceScreenType fromWidth(double width) {
    if (width >= AppSpacing.desktopBreakpoint) return DeviceScreenType.desktop;
    if (width >= AppSpacing.tabletBreakpoint) return DeviceScreenType.tablet;
    return DeviceScreenType.mobile;
  }

  static DeviceScreenType of(BuildContext context) {
    return fromWidth(MediaQuery.sizeOf(context).width);
  }
}

/// Switches widgets cleanly across mobile, tablet, and desktop breakpoints.
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  @override
  Widget build(BuildContext context) {
    return switch (DeviceScreenType.of(context)) {
      DeviceScreenType.desktop => desktop,
      DeviceScreenType.tablet => tablet ?? mobile,
      DeviceScreenType.mobile => mobile,
    };
  }
}

/// Centers content within [AppSpacing.maxContentWidth] with responsive padding.
class ResponsiveContainer extends StatelessWidget {
  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth = AppSpacing.maxContentWidth,
    this.verticalPadding = AppSpacing.lg,
  });

  final Widget child;
  final double maxWidth;
  final double verticalPadding;

  @override
  Widget build(BuildContext context) {
    final screenType = DeviceScreenType.of(context);
    final horizontalPadding = switch (screenType) {
      DeviceScreenType.desktop => AppSpacing.xl,
      DeviceScreenType.tablet => AppSpacing.lg,
      DeviceScreenType.mobile => AppSpacing.md,
    };

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Responsive multi-column card grid (1 col mobile, 2 cols tablet, 3 cols desktop).
class ResponsiveCardGrid extends StatelessWidget {
  const ResponsiveCardGrid({
    super.key,
    required this.children,
    this.spacing = AppSpacing.md,
    this.desktopColumns = 3,
    this.tabletColumns = 2,
    this.mobileColumns = 1,
  });

  final List<Widget> children;
  final double spacing;
  final int desktopColumns;
  final int tabletColumns;
  final int mobileColumns;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 880
            ? desktopColumns
            : (width >= 540 ? tabletColumns : mobileColumns);
        final itemWidth = (width - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: children
              .map((child) => SizedBox(width: itemWidth, child: child))
              .toList(),
        );
      },
    );
  }
}
