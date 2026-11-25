import 'package:bennett_campus/features/student_portal/domain/models/registration_models.dart';

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

/// Date window filters for event discovery.
enum EventDateFilter {
  all('Any Date'),
  thisWeek('This Week'),
  thisMonth('This Month'),
  upcomingLater('Later');

  const EventDateFilter(this.label);
  final String label;
}

/// Registration availability filters for event discovery.
enum RegistrationStatusFilter {
  all('All Statuses'),
  open('Open Spots'),
  registered('Registered'),
  fillingFast('Filling Fast');

  const RegistrationStatusFilter(this.label);
  final String label;
}

/// Sort options for event discovery.
enum EventSortOption {
  upcoming('Upcoming Soonest'),
  recentlyPublished('Recently Published');

  const EventSortOption(this.label);
  final String label;
}

/// Structured agenda slot for an event.
class EventAgendaItem {
  const EventAgendaItem({
    required this.timeLabel,
    required this.title,
    required this.description,
  });

  final String timeLabel;
  final String title;
  final String description;
}

/// Speaker or mentor featured at an event.
class EventSpeaker {
  const EventSpeaker({
    required this.name,
    required this.role,
    required this.organization,
    required this.initials,
  });

  final String name;
  final String role;
  final String organization;
  final String initials;
}

/// Type of media asset.
enum MediaKind {
  photo('Photo'),
  video('Video');

  const MediaKind(this.label);
  final String label;
}

/// Editorial placement of media within events and club libraries.
enum MediaSection {
  gallery('Photo Gallery'),
  promo('Promotional'),
  recap('Event Recap');

  const MediaSection(this.label);
  final String label;
}

/// Photo or video media item for events and club profiles.
class MediaItem {
  const MediaItem({
    required this.id,
    required this.url,
    required this.caption,
    this.kind = MediaKind.photo,
    this.section = MediaSection.gallery,
    this.orderIndex = 0,
    this.thumbnailUrl,
    this.durationLabel,
  });

  final String id;
  final String url;
  final String caption;
  final MediaKind kind;
  final MediaSection section;
  final int orderIndex;
  final String? thumbnailUrl;
  final String? durationLabel;

  MediaItem copyWith({
    String? id,
    String? url,
    String? caption,
    MediaKind? kind,
    MediaSection? section,
    int? orderIndex,
    String? thumbnailUrl,
    String? durationLabel,
  }) {
    return MediaItem(
      id: id ?? this.id,
      url: url ?? this.url,
      caption: caption ?? this.caption,
      kind: kind ?? this.kind,
      section: section ?? this.section,
      orderIndex: orderIndex ?? this.orderIndex,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      durationLabel: durationLabel ?? this.durationLabel,
    );
  }
}

/// Social media or external link for a campus club.
class ClubSocialLink {
  const ClubSocialLink({
    required this.platform,
    required this.handle,
    required this.url,
  });

  final String platform;
  final String handle;
  final String url;
}

/// Student leadership member of a campus club.
class ClubLeader {
  const ClubLeader({
    required this.name,
    required this.role,
    required this.program,
    required this.initials,
  });

  final String name;
  final String role;
  final String program;
  final String initials;
}

/// Summary of a previous event hosted by a club.
class PreviousClubEvent {
  const PreviousClubEvent({
    required this.title,
    required this.dateLabel,
    required this.attendeesLabel,
    required this.summary,
    required this.coverUrl,
  });

  final String title;
  final String dateLabel;
  final String attendeesLabel;
  final String summary;
  final String coverUrl;
}

/// Video highlight item for a club profile.
class ClubVideoItem {
  const ClubVideoItem({
    required this.title,
    required this.durationLabel,
    required this.thumbnailUrl,
    required this.videoUrl,
    required this.summary,
  });

  final String title;
  final String durationLabel;
  final String thumbnailUrl;
  final String videoUrl;
  final String summary;
}

/// UI model for a campus event (backed by mock data in Stage 2).
class CampusEvent {
  const CampusEvent({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.clubId,
    required this.clubName,
    required this.category,
    required this.startTime,
    required this.endTime,
    required this.publishedAt,
    required this.registrationDeadline,
    required this.venue,
    required this.bannerUrl,
    required this.registeredCount,
    required this.capacity,
    required this.teamSizeLabel,
    required this.feeLabel,
    this.registrationMode = RegistrationMode.basic,
    this.registrationQuestions = const [],
    this.isRegistrationClosed = false,
    this.isCompleted = false,
    this.isFeatured = false,
    this.isRegistered = false,
    this.tags = const [],
    this.agenda = const [],
    this.speakers = const [],
    this.mediaGallery = const [],
    this.promoVideos = const [],
    this.recapMedia = const [],
  });

  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String clubId;
  final String clubName;
  final EventCategory category;
  final DateTime startTime;
  final DateTime endTime;
  final DateTime publishedAt;
  final DateTime registrationDeadline;
  final String venue;
  final String bannerUrl;
  final int registeredCount;
  final int capacity;
  final String teamSizeLabel;
  final String feeLabel;
  final RegistrationMode registrationMode;
  final List<RegistrationQuestion> registrationQuestions;
  final bool isRegistrationClosed;
  final bool isCompleted;
  final bool isFeatured;
  final bool isRegistered;
  final List<String> tags;
  final List<EventAgendaItem> agenda;
  final List<EventSpeaker> speakers;
  final List<MediaItem> mediaGallery;
  final List<MediaItem> promoVideos;
  final List<MediaItem> recapMedia;

  int get spotsRemaining => (capacity - registeredCount).clamp(0, capacity);

  bool get isFull => spotsRemaining <= 0;

  double get fillRatio => capacity == 0 ? 0 : (registeredCount / capacity).clamp(0, 1);

  bool get isFillingFast => fillRatio >= 0.78 && spotsRemaining > 0;
}

/// UI model for an onboarded Bennett University club or chapter.
class CampusClub {
  const CampusClub({
    required this.id,
    required this.name,
    required this.shortCode,
    required this.category,
    required this.tagline,
    required this.about,
    required this.memberCount,
    required this.upcomingEventCount,
    required this.coverUrl,
    this.logoUrl,
    this.isVerified = true,
    this.socialLinks = const [],
    this.leadership = const [],
    this.previousEvents = const [],
    this.photos = const [],
    this.videos = const [],
  });

  final String id;
  final String name;
  final String shortCode;
  final String category;
  final String tagline;
  final String about;
  final int memberCount;
  final int upcomingEventCount;
  final String coverUrl;
  final String? logoUrl;
  final bool isVerified;
  final List<ClubSocialLink> socialLinks;
  final List<ClubLeader> leadership;
  final List<PreviousClubEvent> previousEvents;
  final List<MediaItem> photos;
  final List<ClubVideoItem> videos;
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

/// Categories for campus notification center filtering.
enum NotificationType {
  newEventPublished('New Event'),
  registrationConfirmation('Confirmation'),
  eventReminder('Event Reminder'),
  eventChanges('Event Update'),
  deadlineReminder('Deadline'),
  clubAnnouncement('Announcement');

  const NotificationType(this.label);
  final String label;
}

/// UI model for campus notifications.
class CampusNotification {
  const CampusNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timeAgo,
    required this.type,
    this.isUnread = false,
    this.eventId,
    this.clubId,
    this.registrationId,
  });

  final String id;
  final String title;
  final String body;
  final String timeAgo;
  final NotificationType type;
  final bool isUnread;
  final String? eventId;
  final String? clubId;
  final String? registrationId;

  CampusNotification copyWith({bool? isUnread}) {
    return CampusNotification(
      id: id,
      title: title,
      body: body,
      timeAgo: timeAgo,
      type: type,
      isUnread: isUnread ?? this.isUnread,
      eventId: eventId,
      clubId: clubId,
      registrationId: registrationId,
    );
  }
}
