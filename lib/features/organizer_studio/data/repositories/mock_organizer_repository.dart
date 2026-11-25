import 'package:bennett_campus/features/organizer_studio/domain/models/organizer_models.dart';
import 'package:bennett_campus/features/organizer_studio/domain/repositories/organizer_repository.dart';
import 'package:bennett_campus/features/student_portal/data/mock/mock_campus_data.dart';
import 'package:bennett_campus/features/student_portal/domain/models/campus_models.dart';
import 'package:bennett_campus/features/student_portal/domain/models/registration_models.dart';

/// Stateful in-memory mock implementation of [OrganizerRepository] for Stage 4.
class MockOrganizerRepository implements OrganizerRepository {
  MockOrganizerRepository()
    : _clubs = List<CampusClub>.from(MockCampusData.clubs),
      _events = _seedOrganizerEvents(),
      _registrations = _seedClubRegistrations(),
      _representatives = _seedRepresentatives();

  final List<CampusClub> _clubs;
  final List<OrganizerEventRecord> _events;
  final List<EventRegistration> _registrations;
  final List<ClubRepresentative> _representatives;

  static List<OrganizerEventRecord> _seedOrganizerEvents() {
    final seeded = MockCampusData.events.map((event) {
      return OrganizerEventRecord(
        id: event.id,
        clubId: event.clubId,
        clubName: event.clubName,
        title: event.title,
        subtitle: event.subtitle,
        description: event.description,
        category: event.category,
        status: event.isCompleted
            ? OrganizerEventStatus.completed
            : OrganizerEventStatus.published,
        startTime: event.startTime,
        endTime: event.endTime,
        registrationDeadline: event.registrationDeadline,
        venue: event.venue,
        bannerUrl: event.bannerUrl,
        capacity: event.capacity,
        registeredCount: event.registeredCount,
        teamSizeLabel: event.teamSizeLabel,
        feeLabel: event.feeLabel,
        registrationMode: event.registrationMode,
        registrationQuestions: event.registrationQuestions,
        mediaUrls: event.mediaGallery.map((m) => m.url).toList(),
        mediaItems: [
          ...event.mediaGallery,
          ...event.promoVideos,
          ...event.recapMedia,
        ],
        updatedAt: event.publishedAt,
      );
    }).toList();

    seeded.addAll([
      OrganizerEventRecord(
        id: 'evt-csi-rust-draft',
        clubId: 'club-csi',
        clubName: 'CSI Bennett Chapter',
        title: 'Systems Programming with Rust — Winter Workshop',
        subtitle:
            'Memory safety, async runtimes, and building CLI tooling from scratch.',
        description:
            'Draft syllabus for CSI Winter Break technical series. Pending speaker confirmation from alumni systems engineers.',
        category: EventCategory.workshops,
        status: OrganizerEventStatus.draft,
        startTime: DateTime(2026, 12, 18, 16, 0),
        endTime: DateTime(2026, 12, 18, 18, 30),
        registrationDeadline: DateTime(2026, 12, 17, 23, 59),
        venue: 'P-Block Seminar Hall 101',
        bannerUrl:
            'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?auto=format&fit=crop&w=1200&q=80',
        capacity: 100,
        registeredCount: 0,
        teamSizeLabel: 'Individual',
        feeLabel: 'Free · Bennett Students',
        registrationMode: RegistrationMode.basic,
        registrationQuestions: const [],
        mediaUrls: const [],
        updatedAt: DateTime(2026, 11, 25, 17, 30),
      ),
      OrganizerEventRecord(
        id: 'evt-csi-completed-spring',
        clubId: 'club-csi',
        clubName: 'CSI Bennett Chapter',
        title: 'Hackaccino 3.0 — Spring Edition',
        subtitle:
            'Annual 36-hour engineering sprint across AI and campus utility tracks.',
        description:
            'Completed flagship hackathon with 95 student teams and 14 alumni mentors.',
        category: EventCategory.hackathons,
        status: OrganizerEventStatus.completed,
        startTime: DateTime(2026, 3, 21, 9, 0),
        endTime: DateTime(2026, 3, 22, 20, 0),
        registrationDeadline: DateTime(2026, 3, 19, 23, 59),
        venue: 'N-Block Innovation Hub',
        bannerUrl:
            'https://images.unsplash.com/photo-1515187029135-18ee286d815b?auto=format&fit=crop&w=1200&q=80',
        capacity: 380,
        registeredCount: 380,
        teamSizeLabel: 'Teams of 2–4',
        feeLabel: 'Free',
        registrationMode: RegistrationMode.advanced,
        registrationQuestions: const [],
        mediaUrls: const [],
        updatedAt: DateTime(2026, 3, 23, 11, 0),
      ),
      OrganizerEventRecord(
        id: 'evt-gdg-firebase-draft',
        clubId: 'club-gdg',
        clubName: 'GDG on Campus · BU',
        title: 'Full-Stack Web with Supabase & Flutter',
        subtitle:
            'Hands-on architecture clinic covering Auth, RLS policies, and real-time feeds.',
        description:
            'Draft workshop outline for GDG December engineering cohort.',
        category: EventCategory.workshops,
        status: OrganizerEventStatus.draft,
        startTime: DateTime(2026, 12, 20, 15, 0),
        endTime: DateTime(2026, 12, 20, 18, 0),
        registrationDeadline: DateTime(2026, 12, 19, 20, 0),
        venue: 'L-Block Lecture Theatre 2',
        bannerUrl:
            'https://images.unsplash.com/photo-1531482615713-2afd69097998?auto=format&fit=crop&w=1200&q=80',
        capacity: 140,
        registeredCount: 0,
        teamSizeLabel: 'Individual',
        feeLabel: 'Free',
        registrationMode: RegistrationMode.basic,
        registrationQuestions: const [],
        mediaUrls: const [],
        updatedAt: DateTime(2026, 11, 25, 19, 0),
      ),
    ]);

    return seeded;
  }

  static List<EventRegistration> _seedClubRegistrations() {
    return [
      ...MockCampusData.initialRegistrations,
      EventRegistration(
        id: 'reg-org-101',
        eventId: 'evt-hackaccino',
        studentId: 'stu-02',
        studentName: 'Diya Mehta',
        studentEmail: 'e23cseu0281@bennett.edu.in',
        studentProgram: 'B.Tech AI · Batch of 2027',
        ticketCode: 'BU-CSI-4822',
        status: RegistrationStatus.confirmed,
        registeredAt: DateTime(2026, 11, 23, 10, 15),
        answers: const {
          'q-team-name': 'TensorFlowed',
          'q-track': 'Applied AI & Agents',
          'q-experience': '3+ hackathons shipped',
          'q-stack': ['Python / FastAPI', 'AI / ML'],
          'q-team-size': '4',
          'q-idea': 'Automated lecture summarizer and lab schedule optimizer.',
          'q-conduct': true,
        },
      ),
      EventRegistration(
        id: 'reg-org-102',
        eventId: 'evt-hackaccino',
        studentId: 'stu-03',
        studentName: 'Kabir Malhotra',
        studentEmail: 'e24cseu0094@bennett.edu.in',
        studentProgram: 'B.Tech CSE · Batch of 2028',
        ticketCode: 'BU-CSI-4829',
        status: RegistrationStatus.confirmed,
        registeredAt: DateTime(2026, 11, 24, 14, 40),
        answers: const {
          'q-team-name': 'CampusOps',
          'q-track': 'Campus Automation',
          'q-experience': 'First campus hackathon',
          'q-stack': ['Flutter / Dart', 'Supabase / SQL'],
          'q-team-size': '2',
          'q-idea': 'Smart hostel laundry & mess queue tracker.',
          'q-conduct': true,
        },
      ),
      EventRegistration(
        id: 'reg-org-103',
        eventId: 'evt-floodlight-cup',
        studentId: 'stu-04',
        studentName: 'Rohan Nair',
        studentEmail: 'e22bba0048@bennett.edu.in',
        studentProgram: 'BBA · Batch of 2026',
        ticketCode: 'BU-CSI-4901',
        status: RegistrationStatus.cancelled,
        registeredAt: DateTime(2026, 11, 19, 18, 0),
        cancelledAt: DateTime(2026, 11, 22, 12, 10),
      ),
      EventRegistration(
        id: 'reg-org-104',
        eventId: 'evt-flutter-web',
        studentId: 'stu-05',
        studentName: 'Niharika Singh',
        studentEmail: 'e23cseu0315@bennett.edu.in',
        studentProgram: 'B.Tech CSE · Batch of 2027',
        ticketCode: 'BU-GDG-5012',
        status: RegistrationStatus.confirmed,
        registeredAt: DateTime(2026, 11, 25, 16, 10),
      ),
      EventRegistration(
        id: 'reg-org-105',
        eventId: 'evt-cloud-bootcamp',
        studentId: 'stu-06',
        studentName: 'Aditya Verma',
        studentEmail: 'e22cseu0198@bennett.edu.in',
        studentProgram: 'B.Tech CSE · Batch of 2026',
        ticketCode: 'BU-GDG-5028',
        status: RegistrationStatus.confirmed,
        registeredAt: DateTime(2026, 11, 24, 21, 5),
      ),
    ];
  }

  static List<ClubRepresentative> _seedRepresentatives() {
    return [
      ClubRepresentative(
        id: 'rep-1',
        clubId: 'club-csi',
        name: 'Pranav Joshi',
        email: 'e22cseu0019@bennett.edu.in',
        program: 'B.Tech CSE · Year 4',
        role: OrganizerRole.owner,
        addedAt: DateTime(2026, 8, 12),
      ),
      ClubRepresentative(
        id: 'rep-2',
        clubId: 'club-csi',
        name: 'Aarav Sharma',
        email: 'e23cseu0142@bennett.edu.in',
        program: 'B.Tech CSE · Year 3',
        role: OrganizerRole.admin,
        addedAt: DateTime(2026, 8, 20),
      ),
      ClubRepresentative(
        id: 'rep-3',
        clubId: 'club-csi',
        name: 'Ishita Sen',
        email: 'e23cseu0211@bennett.edu.in',
        program: 'B.Tech CSE · Year 3',
        role: OrganizerRole.eventManager,
        addedAt: DateTime(2026, 9, 4),
      ),
      ClubRepresentative(
        id: 'rep-4',
        clubId: 'club-gdg',
        name: 'Devansh Kulkarni',
        email: 'e22cseu0110@bennett.edu.in',
        program: 'B.Tech CSE · Year 4',
        role: OrganizerRole.owner,
        addedAt: DateTime(2026, 8, 15),
      ),
      ClubRepresentative(
        id: 'rep-5',
        clubId: 'club-gdg',
        name: 'Aarav Sharma',
        email: 'e23cseu0142@bennett.edu.in',
        program: 'B.Tech CSE · Year 3',
        role: OrganizerRole.eventManager,
        addedAt: DateTime(2026, 9, 10),
      ),
    ];
  }

  @override
  Future<List<CampusClub>> fetchAuthorizedClubs(List<String> clubIds) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    return _clubs.where((club) => clubIds.contains(club.id)).toList();
  }

  @override
  Future<List<OrganizerEventRecord>> fetchClubEvents(String clubId) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    final list = _events.where((e) => e.clubId == clubId).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return List<OrganizerEventRecord>.unmodifiable(list);
  }

  @override
  Future<OrganizerEventRecord> saveEvent(OrganizerEventRecord event) async {
    await Future<void>.delayed(const Duration(milliseconds: 160));
    final updated = event.copyWith(updatedAt: DateTime.now());
    final index = _events.indexWhere((e) => e.id == updated.id);
    if (index >= 0) {
      _events[index] = updated;
    } else {
      _events.insert(0, updated);
    }
    return updated;
  }

  @override
  Future<OrganizerEventRecord> duplicateEvent(String eventId) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    final source = _events.firstWhere((e) => e.id == eventId);
    final copy = source.copyWith(
      id: 'evt-${DateTime.now().microsecondsSinceEpoch}',
      title: '${source.title} (Copy)',
      status: OrganizerEventStatus.draft,
      registeredCount: 0,
      updatedAt: DateTime.now(),
    );
    _events.insert(0, copy);
    return copy;
  }

  @override
  Future<OrganizerEventRecord> cancelEvent(String eventId) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    final index = _events.indexWhere((e) => e.id == eventId);
    final updated = _events[index].copyWith(
      status: OrganizerEventStatus.cancelled,
      updatedAt: DateTime.now(),
    );
    _events[index] = updated;
    return updated;
  }

  @override
  Future<List<EventRegistration>> fetchClubRegistrations(String clubId) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    final clubEventIds = _events
        .where((e) => e.clubId == clubId)
        .map((e) => e.id)
        .toSet();
    final list = _registrations
        .where((r) => clubEventIds.contains(r.eventId))
        .toList()
      ..sort((a, b) => b.registeredAt.compareTo(a.registeredAt));
    return List<EventRegistration>.unmodifiable(list);
  }

  @override
  Future<List<OrganizerActivityItem>> fetchRecentActivity(String clubId) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    final clubEvents = _events.where((e) => e.clubId == clubId).toList();
    final latestEvent = clubEvents.isNotEmpty ? clubEvents.first.title : 'Club event';
    return [
      OrganizerActivityItem(
        id: 'act-1',
        title: 'New registration received',
        subtitle: 'Student registered for $latestEvent',
        timeAgo: '14m ago',
      ),
      const OrganizerActivityItem(
        id: 'act-2',
        title: 'Custom registration form updated',
        subtitle: 'Added required track & tech stack fields',
        timeAgo: '2h ago',
      ),
      const OrganizerActivityItem(
        id: 'act-3',
        title: 'Draft saved in Event Wizard',
        subtitle: 'Winter workshop syllabus staged for review',
        timeAgo: '1d ago',
      ),
    ];
  }

  @override
  Future<CampusClub> updateClubProfile(CampusClub club) async {
    await Future<void>.delayed(const Duration(milliseconds: 140));
    final index = _clubs.indexWhere((c) => c.id == club.id);
    if (index >= 0) {
      _clubs[index] = club;
    }
    return club;
  }

  @override
  Future<List<ClubRepresentative>> fetchRepresentatives(String clubId) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    return _representatives.where((r) => r.clubId == clubId).toList();
  }

  @override
  Future<ClubRepresentative> addRepresentative({
    required String clubId,
    required String name,
    required String email,
    required String program,
    required OrganizerRole role,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    final rep = ClubRepresentative(
      id: 'rep-${DateTime.now().microsecondsSinceEpoch}',
      clubId: clubId,
      name: name,
      email: email,
      program: program,
      role: role,
      addedAt: DateTime.now(),
    );
    _representatives.add(rep);
    return rep;
  }

  @override
  Future<ClubRepresentative> updateRepresentativeRole({
    required String representativeId,
    required OrganizerRole role,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    final index = _representatives.indexWhere((r) => r.id == representativeId);
    final updated = _representatives[index].copyWith(role: role);
    _representatives[index] = updated;
    return updated;
  }

  @override
  Future<void> removeRepresentative(String representativeId) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    _representatives.removeWhere((r) => r.id == representativeId);
  }
}
