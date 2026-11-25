import 'package:bennett_campus/features/auth/domain/models/student_user.dart';
import 'package:bennett_campus/features/student_portal/domain/models/campus_models.dart';

/// Realistic mock campus dataset for Bennett University (Stage 1).
abstract final class MockCampusData {
  static const StudentUser currentStudent = StudentUser(
    id: 'mock-student-01',
    fullName: 'Aarav Sharma',
    email: 'e23cseu0142@bennett.edu.in',
    program: 'B.Tech Computer Science',
    batchYear: 'Batch of 2027',
    initials: 'AS',
  );

  static final List<CampusEvent> events = [
    CampusEvent(
      id: 'evt-hackaccino',
      title: 'Hackaccino 4.0 — 36-Hour Campus Hackathon',
      subtitle:
          'Build AI, FinTech, and Campus Utility prototypes with mentorship from industry engineers and Bennett alumni.',
      clubName: 'CSI Bennett Chapter',
      category: EventCategory.hackathons,
      startTime: DateTime(2026, 11, 28, 9, 30),
      venue: 'N-Block Innovation Hub & Main Auditorium',
      bannerUrl:
          'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?auto=format&fit=crop&w=1400&q=80',
      registeredCount: 342,
      capacity: 400,
      isFeatured: true,
      isRegistered: true,
      tags: ['36 Hours', 'Team of 2-4', 'Prizes ₹1.5L'],
    ),
    CampusEvent(
      id: 'evt-genai-studio',
      title: 'Applied GenAI & Agentic Systems Lab',
      subtitle:
          'Hands-on engineering workshop covering tool-calling architectures, RAG pipelines, and evaluation harnesses.',
      clubName: 'Alan Turing Club',
      category: EventCategory.techAi,
      startTime: DateTime(2026, 11, 29, 16, 0),
      venue: 'P-Block Seminar Hall 204',
      bannerUrl:
          'https://images.unsplash.com/photo-1518770660439-4636190af475?auto=format&fit=crop&w=1200&q=80',
      registeredCount: 118,
      capacity: 150,
      isRegistered: true,
      tags: ['Hands-on', 'Bring Laptop'],
    ),
    CampusEvent(
      id: 'evt-uphaar-night',
      title: 'Uphaar Acoustic & Indie Live Night',
      subtitle:
          'An evening of student bands, unplugged sets, and stage lighting under the open campus amphitheatre.',
      clubName: 'Advaita Music Society',
      category: EventCategory.cultural,
      startTime: DateTime(2026, 12, 1, 18, 30),
      venue: 'Central Amphitheatre',
      bannerUrl:
          'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?auto=format&fit=crop&w=1200&q=80',
      registeredCount: 410,
      capacity: 500,
      tags: ['Open Air', 'All Years'],
    ),
    CampusEvent(
      id: 'evt-design-sprint',
      title: 'Figma Systems & Motion Design Sprint',
      subtitle:
          'Craft high-contrast dark interfaces, design tokens, and interactive prototypes in a guided 3-hour sprint.',
      clubName: 'Pixelate Design Guild',
      category: EventCategory.design,
      startTime: DateTime(2026, 12, 3, 15, 30),
      venue: 'M-Block Media Studio 102',
      bannerUrl:
          'https://images.unsplash.com/photo-1558655146-9f40138edfeb?auto=format&fit=crop&w=1200&q=80',
      registeredCount: 64,
      capacity: 80,
      tags: ['UI/UX', 'Portfolio'],
    ),
    CampusEvent(
      id: 'evt-founders-table',
      title: 'Bennett Hatchery Founders Roundtable',
      subtitle:
          'Early-stage student founders pitch live to seed mentors and unpack GTM strategies from zero to first 1,000 users.',
      clubName: 'Bennett Entrepreneurship Cell',
      category: EventCategory.entrepreneurship,
      startTime: DateTime(2026, 12, 5, 14, 0),
      venue: 'Bennett Hatchery, A-Block',
      bannerUrl:
          'https://images.unsplash.com/photo-1552664730-d307ca884978?auto=format&fit=crop&w=1200&q=80',
      registeredCount: 88,
      capacity: 110,
      isRegistered: true,
      tags: ['Startups', 'Pitch Deck'],
    ),
    CampusEvent(
      id: 'evt-flutter-web',
      title: 'Production Flutter Web & State Craft',
      subtitle:
          'Deep dive into responsive Flutter layouts, Riverpod architecture, and shipping fast web apps.',
      clubName: 'Google Developer Groups on Campus · BU',
      category: EventCategory.workshops,
      startTime: DateTime(2026, 12, 7, 17, 0),
      venue: 'L-Block Lecture Theatre 3',
      bannerUrl:
          'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?auto=format&fit=crop&w=1200&q=80',
      registeredCount: 95,
      capacity: 120,
      tags: ['Flutter', 'Certificate'],
    ),
    CampusEvent(
      id: 'evt-floodlight-cup',
      title: 'Inter-Hostel Floodlight Futsal Cup',
      subtitle:
          'Knockout night matches across hostel squads competing for the Autumn Championship trophy.',
      clubName: 'Bennett Sports Council',
      category: EventCategory.sports,
      startTime: DateTime(2026, 12, 9, 19, 0),
      venue: 'Synthetic Turf Arena',
      bannerUrl:
          'https://images.unsplash.com/photo-1574629810360-7efbbe195018?auto=format&fit=crop&w=1200&q=80',
      registeredCount: 160,
      capacity: 180,
      tags: ['Night League', '5v5'],
    ),
  ];

  static const List<CampusClub> clubs = [
    CampusClub(
      id: 'club-csi',
      name: 'CSI Bennett Chapter',
      shortCode: 'CSI',
      category: 'Computer Science',
      tagline: 'Flagship hackathons, systems engineering, and peer coding circles.',
      memberCount: 420,
      upcomingEventCount: 3,
      coverUrl:
          'https://images.unsplash.com/photo-1522071820081-009f0129c71c?auto=format&fit=crop&w=900&q=80',
    ),
    CampusClub(
      id: 'club-gdg',
      name: 'GDG on Campus · BU',
      shortCode: 'GDG',
      category: 'Developer Community',
      tagline: 'Workshops on Flutter, Cloud, Web, and open-source engineering.',
      memberCount: 510,
      upcomingEventCount: 4,
      coverUrl:
          'https://images.unsplash.com/photo-1531482615713-2afd69097998?auto=format&fit=crop&w=900&q=80',
    ),
    CampusClub(
      id: 'club-turing',
      name: 'Alan Turing Club',
      shortCode: 'ATC',
      category: 'AI & Research',
      tagline: 'Applied machine learning labs, paper reading groups, and Kaggle sprints.',
      memberCount: 315,
      upcomingEventCount: 2,
      coverUrl:
          'https://images.unsplash.com/photo-1485827404703-89b55fcc595e?auto=format&fit=crop&w=900&q=80',
    ),
    CampusClub(
      id: 'club-advaita',
      name: 'Advaita Music Society',
      shortCode: 'AMS',
      category: 'Performing Arts',
      tagline: 'Live campus concerts, jam rooms, and acoustic showcases.',
      memberCount: 245,
      upcomingEventCount: 2,
      coverUrl:
          'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?auto=format&fit=crop&w=900&q=80',
    ),
    CampusClub(
      id: 'club-ecell',
      name: 'Bennett E-Cell',
      shortCode: 'EC',
      category: 'Entrepreneurship',
      tagline: 'Founder roundtables, Hatchery demo days, and venture challenges.',
      memberCount: 380,
      upcomingEventCount: 2,
      coverUrl:
          'https://images.unsplash.com/photo-1556761175-5973dc0f32e7?auto=format&fit=crop&w=900&q=80',
    ),
    CampusClub(
      id: 'club-pixelate',
      name: 'Pixelate Design Guild',
      shortCode: 'PDG',
      category: 'Design & Media',
      tagline: 'Product design critiques, brand systems, and visual storytelling.',
      memberCount: 190,
      upcomingEventCount: 1,
      coverUrl:
          'https://images.unsplash.com/photo-1542744094-3a31f272c490?auto=format&fit=crop&w=900&q=80',
    ),
  ];

  static const List<CampusHighlight> highlights = [
    CampusHighlight(
      id: 'hl-uphonics',
      title: 'Uphoria Cultural Fest — Mainstage Finale',
      clubName: 'Cultural Committee',
      dateLabel: 'Oct 2026',
      photoCount: 64,
      imageUrl:
          'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?auto=format&fit=crop&w=1100&q=80',
      summary:
          'Three days of music, dance battles, and student-led stage production across the main quad.',
    ),
    CampusHighlight(
      id: 'hl-bennovate',
      title: 'Bennovate Startup Expo & Demo Day',
      clubName: 'Bennett Hatchery',
      dateLabel: 'Sep 2026',
      photoCount: 38,
      imageUrl:
          'https://images.unsplash.com/photo-1540575467063-178a50c2df87?auto=format&fit=crop&w=1100&q=80',
      summary:
          '28 student teams showcased hardware and SaaS prototypes to alumni founders and angel investors.',
    ),
    CampusHighlight(
      id: 'hl-robotics',
      title: 'Autonomous Rover Trials — Tech Week',
      clubName: 'Robotics & IoT Society',
      dateLabel: 'Aug 2026',
      photoCount: 45,
      imageUrl:
          'https://images.unsplash.com/photo-1581091226825-a6a2a5aee158?auto=format&fit=crop&w=1100&q=80',
      summary:
          'Custom-built ROS2 rovers navigated the obstacle track outside N-Block.',
    ),
  ];

  static const List<CampusNotification> notifications = [
    CampusNotification(
      id: 'notif-1',
      title: 'Hackaccino 4.0 check-in opens Friday',
      body: 'Bring your Bennett ID card to N-Block Hub at 9:00 AM.',
      timeAgo: '18m ago',
      isUnread: true,
    ),
    CampusNotification(
      id: 'notif-2',
      title: 'Registration confirmed: Applied GenAI Lab',
      body: 'Your seat in P-Block Seminar Hall 204 is reserved.',
      timeAgo: '3h ago',
      isUnread: true,
    ),
    CampusNotification(
      id: 'notif-3',
      title: 'New photos from Uphoria Finale',
      body: '64 event photographs added to Campus Highlights.',
      timeAgo: '2d ago',
    ),
  ];
}
