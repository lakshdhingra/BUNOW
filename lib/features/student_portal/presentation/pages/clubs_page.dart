import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bennett_campus/core/theme/app_spacing.dart';
import 'package:bennett_campus/features/student_portal/data/mock/mock_campus_data.dart';
import 'package:bennett_campus/features/student_portal/presentation/providers/student_portal_providers.dart';
import 'package:bennett_campus/features/student_portal/presentation/widgets/club_card.dart';
import 'package:bennett_campus/shared/widgets/widgets.dart';

/// Directory of onboarded Bennett University clubs and chapters (mock data).
class ClubsPage extends ConsumerWidget {
  const ClubsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final query = ref.watch(searchQueryProvider).trim().toLowerCase();
    final clubs = MockCampusData.clubs.where((club) {
      if (query.isEmpty) return true;
      return club.name.toLowerCase().contains(query) ||
          club.category.toLowerCase().contains(query) ||
          club.tagline.toLowerCase().contains(query);
    }).toList();

    return SingleChildScrollView(
      child: ResponsiveContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Clubs & Chapters', style: theme.textTheme.headlineLarge),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              'Explore verified student-led technical, cultural, design, and entrepreneurship communities at Bennett.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xl),
            ResponsiveCardGrid(
              children: clubs.map((club) {
                return ClubCard(
                  club: club,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${club.name} profile view will connect in a later stage.',
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
