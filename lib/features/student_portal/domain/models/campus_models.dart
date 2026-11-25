/// Event categories across Bennett University clubs and chapters.
enum EventCategory {
  all('All'),
  techAi('Tech & AI'),
  hackathons('Hackathons'),
  cultural('Cultural'),
  workshops('Workshops'),
  sports('Sports'),
  entrepreneurship('Entrepreneurship'),
  design('Design');

  const EventCategory(this.label);
  final String label;
}

/// UI model for a campus event (backed by mock data in Stage 1).
class CampusEvent {
  const CampusEvent({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.clubName,
    required this.category,
    required this.startTime,
    required this.venue,
    required this.bannerUrl,
    required this.registeredCount,
    required this.capacity,
    this.isFeatured = false,
    this.isRegistered = false,
    this.tags = const [],
  });

  final String id;
  final String title;
  final String subtitle;
  final String clubName;
  final EventCategory category;
  final DateTime startTime;
  final String venue;
  final String bannerUrl;
  final int registeredCount;
  final int capacity;
  final bool isFeatured;
  final bool isRegistered;
  final List<String> tags;

  int get spotsRemaining => (capacity - registeredCount).clamp(0, capacity);
}

/// UI model for an onboarded Bennett University club or chapter.
class CampusClub {
  const CampusClub({
    required this.id,
    required this.name,
    required this.shortCode,
    required this.category,
    required this.tagline,
    required this.memberCount,
    required this.upcomingEventCount,
    required this.coverUrl,
    this.isVerified = true,
  });

  final String id;
  final String name;
  final String shortCode;
  final String category;
  final String tagline;
  final int memberCount;
  final int upcomingEventCount;
  final String coverUrl;
  final bool isVerified;
}

/// UI model for past campus activity highlights and media galleries.
class CampusHighlight {
  const CampusHighlight({
    required this.id,
    required this.title,
    required this.clubName,
    required this.dateLabel,
    required this.photoCount,
    required this.imageUrl,
    required this.summary,
  });

  final String id;
  final String title;
  final String clubName;
  final String dateLabel;
  final int photoCount;
  final String imageUrl;
  final String summary;
}

/// UI model for campus notifications.
class CampusNotification {
  const CampusNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timeAgo,
    this.isUnread = false,
  });

  final String id;
  final String title;
  final String body;
  final String timeAgo;
  final bool isUnread;
}
