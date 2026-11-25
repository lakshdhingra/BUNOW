import 'package:bennett_campus/features/student_portal/domain/models/campus_models.dart';
import 'package:bennett_campus/features/student_portal/domain/models/registration_models.dart';

/// Lifecycle states for organizer-managed events.
enum OrganizerEventStatus {
  draft('Draft'),
  published('Published'),
  completed('Completed'),
  cancelled('Cancelled');

  const OrganizerEventStatus(this.label);
  final String label;
}

/// Representative permission levels within a club (UI demonstration; RLS enforced server-side).
enum OrganizerRole {
  owner('Owner', 'Full control over events, forms, exports, and team access'),
  admin('Admin', 'Create/publish events, manage registrations, and edit club profile'),
  eventManager('Event Manager', 'Create drafts, edit assigned events, and view participants'),
  viewer('Viewer', 'Read-only access to event analytics and participant lists');

  const OrganizerRole(this.label, this.summary);
  final String label;
  final String summary;

  bool get canEditEvents =>
      this == owner || this == admin || this == eventManager;

  bool get canPublishEvents => this == owner || this == admin;

  bool get canManageTeam => this == owner || this == admin;

  bool get canExportCsv => this != viewer;
}

/// Authorized student representative for a Bennett University club.
class ClubRepresentative {
  const ClubRepresentative({
    required this.id,
    required this.clubId,
    required this.name,
    required this.email,
    required this.program,
    required this.role,
    required this.addedAt,
  });

  final String id;
  final String clubId;
  final String name;
  final String email;
  final String program;
  final OrganizerRole role;
  final DateTime addedAt;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'BU';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  ClubRepresentative copyWith({OrganizerRole? role}) {
    return ClubRepresentative(
      id: id,
      clubId: clubId,
      name: name,
      email: email,
      program: program,
      role: role ?? this.role,
      addedAt: addedAt,
    );
  }
}

/// Organizer-facing event model supporting drafts, wizard authoring, and publishing.
class OrganizerEventRecord {
  const OrganizerEventRecord({
    required this.id,
    required this.clubId,
    required this.clubName,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.category,
    required this.status,
    required this.startTime,
    required this.endTime,
    required this.registrationDeadline,
    required this.venue,
    required this.bannerUrl,
    required this.capacity,
    required this.registeredCount,
    required this.teamSizeLabel,
    required this.feeLabel,
    required this.registrationMode,
    required this.registrationQuestions,
    required this.mediaUrls,
    this.mediaItems = const [],
    required this.updatedAt,
  });

  final String id;
  final String clubId;
  final String clubName;
  final String title;
  final String subtitle;
  final String description;
  final EventCategory category;
  final OrganizerEventStatus status;
  final DateTime startTime;
  final DateTime endTime;
  final DateTime registrationDeadline;
  final String venue;
  final String bannerUrl;
  final int capacity;
  final int registeredCount;
  final String teamSizeLabel;
  final String feeLabel;
  final RegistrationMode registrationMode;
  final List<RegistrationQuestion> registrationQuestions;
  final List<String> mediaUrls;
  final List<MediaItem> mediaItems;
  final DateTime updatedAt;

  double get fillRatio =>
      capacity == 0 ? 0 : (registeredCount / capacity).clamp(0, 1);

  OrganizerEventRecord copyWith({
    String? id,
    String? clubId,
    String? clubName,
    String? title,
    String? subtitle,
    String? description,
    EventCategory? category,
    OrganizerEventStatus? status,
    DateTime? startTime,
    DateTime? endTime,
    DateTime? registrationDeadline,
    String? venue,
    String? bannerUrl,
    int? capacity,
    int? registeredCount,
    String? teamSizeLabel,
    String? feeLabel,
    RegistrationMode? registrationMode,
    List<RegistrationQuestion>? registrationQuestions,
    List<String>? mediaUrls,
    List<MediaItem>? mediaItems,
    DateTime? updatedAt,
  }) {
    return OrganizerEventRecord(
      id: id ?? this.id,
      clubId: clubId ?? this.clubId,
      clubName: clubName ?? this.clubName,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      category: category ?? this.category,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      registrationDeadline: registrationDeadline ?? this.registrationDeadline,
      venue: venue ?? this.venue,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      capacity: capacity ?? this.capacity,
      registeredCount: registeredCount ?? this.registeredCount,
      teamSizeLabel: teamSizeLabel ?? this.teamSizeLabel,
      feeLabel: feeLabel ?? this.feeLabel,
      registrationMode: registrationMode ?? this.registrationMode,
      registrationQuestions:
          registrationQuestions ?? this.registrationQuestions,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      mediaItems: mediaItems ?? this.mediaItems,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Recent organizer studio activity feed item.
class OrganizerActivityItem {
  const OrganizerActivityItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.timeAgo,
  });

  final String id;
  final String title;
  final String subtitle;
  final String timeAgo;
}
