import 'package:flutter/material.dart';
import 'package:bennett_campus/core/theme/app_spacing.dart';
import 'package:bennett_campus/features/student_portal/data/mock/mock_campus_data.dart';
import 'package:bennett_campus/features/student_portal/presentation/widgets/highlight_card.dart';
import 'package:bennett_campus/shared/widgets/widgets.dart';

/// Campus highlights gallery placeholder page (Stage 1 mock data).
class HighlightsPage extends StatelessWidget {
  const HighlightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: ResponsiveContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Campus Highlights', style: theme.textTheme.headlineLarge),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              'Photography and recap reels from recent Bennett University campus activities.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xl),
            ResponsiveCardGrid(
              children: MockCampusData.highlights.map((highlight) {
                return HighlightCard(
                  highlight: highlight,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${highlight.title} gallery (${highlight.photoCount} photos) will open in a later stage.',
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
