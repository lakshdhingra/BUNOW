import 'package:bennett_campus/features/auth/domain/models/student_user.dart';
import 'package:bennett_campus/features/student_portal/domain/models/campus_models.dart';
import 'package:bennett_campus/features/student_portal/domain/models/registration_models.dart';

/// Realistic mock campus dataset for Bennett University (Stage 2).
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
      description:
          'Hackaccino 4.0 returns to Bennett University as our flagship 36-hour engineering sprint. Teams collaborate overnight in the N-Block Innovation Hub to design, build, and pitch working software or hardware prototypes across four tracks: Applied AI, FinTech & Web3, Campus Automation, and Open Innovation.\n\nParticipants get round-the-clock mentor check-ins, API credits, midnight snacks, and direct evaluation from product engineers and Bennett Hatchery advisors.',
      clubId: 'club-csi',
      clubName: 'CSI Bennett Chapter',
      category: EventCategory.hackathons,
      startTime: DateTime(2026, 11, 28, 9, 30),
      endTime: DateTime(2026, 11, 29, 21, 30),
      publishedAt: DateTime(2026, 11, 20, 12, 0),
      registrationDeadline: DateTime(2026, 11, 27, 23, 59),
      venue: 'N-Block Innovation Hub & Main Auditorium',
      bannerUrl:
          'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?auto=format&fit=crop&w=1400&q=80',
      registeredCount: 342,
      capacity: 400,
      teamSizeLabel: 'Teams of 2–4',
      feeLabel: 'Free · Bennett ID Required',
      registrationMode: RegistrationMode.advanced,
      registrationQuestions: const [
        RegistrationQuestion(
          id: 'q-team-name',
          label: 'Team Name',
          type: QuestionFieldType.shortText,
          isRequired: true,
          hintText: 'e.g. NullPointers BU',
        ),
        RegistrationQuestion(
          id: 'q-track',
          label: 'Primary Problem Track',
          type: QuestionFieldType.dropdown,
          isRequired: true,
          options: [
            'Applied AI & Agents',
            'FinTech & Web3',
            'Campus Automation',
            'Open Innovation',
          ],
        ),
        RegistrationQuestion(
          id: 'q-experience',
          label: 'Hackathon Experience Level',
          type: QuestionFieldType.singleChoice,
          isRequired: true,
          options: [
            'First campus hackathon',
            '1–2 previous hackathons',
            '3+ hackathons shipped',
          ],
        ),
        RegistrationQuestion(
          id: 'q-stack',
          label: 'Primary Tech Stack',
          type: QuestionFieldType.multipleChoice,
          isRequired: true,
          options: ['Flutter / Dart', 'React / Next.js', 'Python / FastAPI', 'Supabase / SQL', 'AI / ML'],
        ),
        RegistrationQuestion(
          id: 'q-team-size',
          label: 'Total Team Members (2–4)',
          type: QuestionFieldType.number,
          isRequired: true,
          hintText: 'Enter a number between 2 and 4',
        ),
        RegistrationQuestion(
          id: 'q-idea',
          label: 'Brief Project Pitch',
          type: QuestionFieldType.longText,
          isRequired: true,
          hintText: 'Summarize the problem you plan to tackle in 2–4 sentences...',
        ),
        RegistrationQuestion(
          id: 'q-deck',
          label: 'Resume or Idea One-Pager (PDF)',
          type: QuestionFieldType.fileUpload,
          isRequired: false,
          helperText: 'Optional PDF or slide deck for early mentor matching.',
        ),
        RegistrationQuestion(
          id: 'q-conduct',
          label: 'I confirm all code will be built during the 36-hour sprint and agree to the Bennett Hackathon Code of Conduct.',
          type: QuestionFieldType.checkbox,
          isRequired: true,
        ),
      ],
      isFeatured: true,
      isRegistered: true,
      tags: ['36 Hours', 'Team of 2-4', 'Prizes ₹1.5L'],
      agenda: const [
        EventAgendaItem(
          timeLabel: 'Day 1 · 09:30 AM',
          title: 'Check-in & Problem Track Reveal',
          description: 'Badge verification at N-Block Atrium and opening keynote.',
        ),
        EventAgendaItem(
          timeLabel: 'Day 1 · 11:30 AM',
          title: 'Hacking Begins & Mentor Pairing',
          description: 'Architecture reviews with alumni engineers and club leads.',
        ),
        EventAgendaItem(
          timeLabel: 'Day 2 · 02:00 PM',
          title: 'Prototype Freeze & Live Demos',
          description: 'Top 12 teams pitch on stage at the Main Auditorium.',
        ),
      ],
      speakers: const [
        EventSpeaker(
          name: 'Rohan Malhotra',
          role: 'Staff Software Engineer',
          organization: 'Razorpay · Bennett Alumni',
          initials: 'RM',
        ),
        EventSpeaker(
          name: 'Dr. Kavita Iyer',
          role: 'Faculty Advisor',
          organization: 'School of CSET, Bennett University',
          initials: 'KI',
        ),
      ],
      mediaGallery: const [
        MediaItem(
          id: 'm-hack-1',
          url: 'https://images.unsplash.com/photo-1515187029135-18ee286d815b?auto=format&fit=crop&w=1000&q=80',
          caption: 'Hackaccino 3.0 midnight mentoring session at N-Block',
        ),
        MediaItem(
          id: 'm-hack-2',
          url: 'https://images.unsplash.com/photo-1531482615713-2afd69097998?auto=format&fit=crop&w=1000&q=80',
          caption: 'Finalist teams preparing pitch decks before demo hour',
        ),
      ],
    ),
    CampusEvent(
      id: 'evt-genai-studio',
      title: 'Applied GenAI & Agentic Systems Lab',
      subtitle:
          'Hands-on engineering workshop covering tool-calling architectures, RAG pipelines, and evaluation harnesses.',
      description:
          'Move beyond basic prompt demos into reliable production AI workflows. In this guided lab hosted by the Alan Turing Club, you will implement a retrieval-augmented campus assistant, structure deterministic tool calls, and measure output quality using automated eval datasets.',
      clubId: 'club-turing',
      clubName: 'Alan Turing Club',
      category: EventCategory.techAi,
      startTime: DateTime(2026, 11, 29, 16, 0),
      endTime: DateTime(2026, 11, 29, 19, 0),
      publishedAt: DateTime(2026, 11, 24, 15, 30),
      registrationDeadline: DateTime(2026, 11, 29, 12, 0),
      venue: 'P-Block Seminar Hall 204',
      bannerUrl:
          'https://images.unsplash.com/photo-1518770660439-4636190af475?auto=format&fit=crop&w=1200&q=80',
      registeredCount: 118,
      capacity: 150,
      teamSizeLabel: 'Individual',
      feeLabel: 'Free · Open to All Branches',
      isRegistered: true,
      tags: ['Hands-on', 'Bring Laptop'],
      agenda: const [
        EventAgendaItem(
          timeLabel: '04:00 PM',
          title: 'Structured Outputs & Tool Calling',
          description: 'Designing reliable schemas and failure recovery.',
        ),
        EventAgendaItem(
          timeLabel: '05:15 PM',
          title: 'Live Lab: Campus Knowledge RAG',
          description: 'Building hybrid search and citation grounding.',
        ),
      ],
      speakers: const [
        EventSpeaker(
          name: 'Ananya Verma',
          role: 'ML Research Lead',
          organization: 'Alan Turing Club · B.Tech AI',
          initials: 'AV',
        ),
      ],
      mediaGallery: const [
        MediaItem(
          id: 'm-genai-1',
          url: 'https://images.unsplash.com/photo-1555949963-aa79dcee981c?auto=format&fit=crop&w=1000&q=80',
          caption: 'Previous Neural Systems Bootcamp in P-Block',
        ),
      ],
    ),
    CampusEvent(
      id: 'evt-uphaar-night',
      title: 'Uphaar Acoustic & Indie Live Night',
      subtitle:
          'An evening of student bands, unplugged sets, and stage lighting under the open campus amphitheatre.',
      description:
          'Advaita Music Society presents Uphaar, an intimate open-air showcase celebrating original student compositions, indie covers, and collaborative acoustic ensembles. Food stalls and community seating open at 6:00 PM.',
      clubId: 'club-advaita',
      clubName: 'Advaita Music Society',
      category: EventCategory.cultural,
      startTime: DateTime(2026, 12, 1, 18, 30),
      endTime: DateTime(2026, 12, 1, 22, 0),
      publishedAt: DateTime(2026, 11, 22, 18, 0),
      registrationDeadline: DateTime(2026, 12, 1, 17, 0),
      venue: 'Central Amphitheatre',
      bannerUrl:
          'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?auto=format&fit=crop&w=1200&q=80',
      registeredCount: 410,
      capacity: 500,
      teamSizeLabel: 'Individual Pass',
      feeLabel: 'Free · Bennett Students',
      tags: ['Open Air', 'All Years'],
      agenda: const [
        EventAgendaItem(
          timeLabel: '06:30 PM',
          title: 'Acoustic Duets & Freshman Debuts',
          description: 'Opening unplugged sets by first-year vocalists.',
        ),
        EventAgendaItem(
          timeLabel: '08:00 PM',
          title: 'Advaita Collective Headliner Set',
          description: 'Full live band performance under amphitheatre lights.',
        ),
      ],
      speakers: const [
        EventSpeaker(
          name: 'Kabir Khanna',
          role: 'Music Director',
          organization: 'Advaita Music Society',
          initials: 'KK',
        ),
      ],
      mediaGallery: const [
        MediaItem(
          id: 'm-uphaar-1',
          url: 'https://images.unsplash.com/photo-1501386761578-eac5c94b800a?auto=format&fit=crop&w=1000&q=80',
          caption: 'Autumn Jam crowd at the Central Amphitheatre',
        ),
      ],
    ),
    CampusEvent(
      id: 'evt-design-sprint',
      title: 'Figma Systems & Motion Design Sprint',
      subtitle:
          'Craft high-contrast dark interfaces, design tokens, and interactive prototypes in a guided 3-hour sprint.',
      description:
          'Learn how modern SaaS product teams structure color tokens, typography scales, auto-layout components, and micro-interactions in Figma. Participants leave with a reusable component kit ready for hackathons and portfolios.',
      clubId: 'club-pixelate',
      clubName: 'Pixelate Design Guild',
      category: EventCategory.design,
      startTime: DateTime(2026, 12, 3, 15, 30),
      endTime: DateTime(2026, 12, 3, 18, 30),
      publishedAt: DateTime(2026, 11, 25, 11, 0),
      registrationDeadline: DateTime(2026, 12, 3, 12, 0),
      venue: 'M-Block Media Studio 102',
      bannerUrl:
          'https://images.unsplash.com/photo-1558655146-9f40138edfeb?auto=format&fit=crop&w=1200&q=80',
      registeredCount: 64,
      capacity: 80,
      teamSizeLabel: 'Individual',
      feeLabel: 'Free · Certificate Included',
      registrationMode: RegistrationMode.advanced,
      registrationQuestions: const [
        RegistrationQuestion(
          id: 'q-portfolio',
          label: 'Figma or Portfolio URL / Handle',
          type: QuestionFieldType.shortText,
          isRequired: true,
          hintText: 'e.g. @aarav.design or figma.com/@aarav',
        ),
        RegistrationQuestion(
          id: 'q-skill',
          label: 'Design Experience',
          type: QuestionFieldType.singleChoice,
          isRequired: true,
          options: ['Beginner', 'Intermediate', 'Advanced'],
        ),
        RegistrationQuestion(
          id: 'q-tools',
          label: 'Tools You Use',
          type: QuestionFieldType.multipleChoice,
          isRequired: false,
          options: ['Figma', 'Framer', 'After Effects', 'Rive'],
        ),
        RegistrationQuestion(
          id: 'q-goal',
          label: 'What do you want to learn in this sprint?',
          type: QuestionFieldType.longText,
          isRequired: true,
          hintText: 'Share what you hope to build during the 3-hour session...',
        ),
        RegistrationQuestion(
          id: 'q-sample',
          label: 'Upload Sample Screen or Wireframe',
          type: QuestionFieldType.fileUpload,
          isRequired: true,
          helperText: 'Required: PNG, JPG, or PDF showcase.',
        ),
        RegistrationQuestion(
          id: 'q-laptop',
          label: 'I will bring my laptop with Figma installed.',
          type: QuestionFieldType.checkbox,
          isRequired: true,
        ),
      ],
      tags: ['UI/UX', 'Portfolio'],
      agenda: const [
        EventAgendaItem(
          timeLabel: '03:30 PM',
          title: 'Dark-Mode Token Architecture',
          description: 'Surface elevation, contrast ratios, and spacing rhythm.',
        ),
        EventAgendaItem(
          timeLabel: '04:45 PM',
          title: 'Interactive Prototype Critique',
          description: 'Live peer review and feedback from guild leads.',
        ),
      ],
      speakers: const [
        EventSpeaker(
          name: 'Meera Nair',
          role: 'Product Design Lead',
          organization: 'Pixelate Design Guild',
          initials: 'MN',
        ),
      ],
      mediaGallery: const [
        MediaItem(
          id: 'm-design-1',
          url: 'https://images.unsplash.com/photo-1542744094-3a31f272c490?auto=format&fit=crop&w=1000&q=80',
          caption: 'Design critique table at M-Block Studio',
        ),
      ],
    ),
    CampusEvent(
      id: 'evt-founders-table',
      title: 'Bennett Hatchery Founders Roundtable',
      subtitle:
          'Early-stage student founders pitch live to seed mentors and unpack GTM strategies from zero to first 1,000 users.',
      description:
          'Hosted inside the Bennett Hatchery incubator, this roundtable connects student builders with alumni founders and early-stage operators. Expect candid teardown sessions on pricing, campus distribution, and MVP validation.',
      clubId: 'club-ecell',
      clubName: 'Bennett E-Cell',
      category: EventCategory.entrepreneurship,
      startTime: DateTime(2026, 12, 5, 14, 0),
      endTime: DateTime(2026, 12, 5, 17, 0),
      publishedAt: DateTime(2026, 11, 21, 10, 0),
      registrationDeadline: DateTime(2026, 12, 4, 22, 0),
      venue: 'Bennett Hatchery, A-Block',
      bannerUrl:
          'https://images.unsplash.com/photo-1552664730-d307ca884978?auto=format&fit=crop&w=1200&q=80',
      registeredCount: 88,
      capacity: 110,
      teamSizeLabel: 'Individual or Co-founders',
      feeLabel: 'Free · E-Cell Verified',
      registrationMode: RegistrationMode.advanced,
      registrationQuestions: const [
        RegistrationQuestion(
          id: 'q-startup',
          label: 'Startup or Idea Name',
          type: QuestionFieldType.shortText,
          isRequired: true,
          hintText: 'e.g. CampusCart',
        ),
        RegistrationQuestion(
          id: 'q-stage',
          label: 'Current Venture Stage',
          type: QuestionFieldType.dropdown,
          isRequired: true,
          options: ['Idea Stage', 'MVP Built', 'Early Campus Revenue'],
        ),
        RegistrationQuestion(
          id: 'q-deck-upload',
          label: 'Pitch Deck (Optional)',
          type: QuestionFieldType.fileUpload,
          isRequired: false,
        ),
      ],
      isRegistered: false,
      tags: ['Startups', 'Pitch Deck'],
      agenda: const [
        EventAgendaItem(
          timeLabel: '02:00 PM',
          title: 'Fireside Chat: First 1,000 Campus Users',
          description: 'How Bennett startups cracked initial organic growth.',
        ),
        EventAgendaItem(
          timeLabel: '03:30 PM',
          title: 'Rapid Pitch Clinic',
          description: '5 student ventures receive live deck feedback.',
        ),
      ],
      speakers: const [
        EventSpeaker(
          name: 'Siddharth Rao',
          role: 'Co-Founder',
          organization: 'StackPulse · Hatchery Cohort 2024',
          initials: 'SR',
        ),
      ],
      mediaGallery: const [
        MediaItem(
          id: 'm-ecell-1',
          url: 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?auto=format&fit=crop&w=1000&q=80',
          caption: 'Bennovate pitch stage at Bennett Hatchery',
        ),
      ],
    ),
    CampusEvent(
      id: 'evt-flutter-web',
      title: 'Production Flutter Web & State Craft',
      subtitle:
          'Deep dive into responsive Flutter layouts, Riverpod architecture, and shipping fast web apps.',
      description:
          'Google Developer Groups on Campus · BU brings a practical engineering session on scaling Flutter Web applications cleanly. We cover feature-first layering, GoRouter guards, Riverpod notifiers, and responsive breakpoints across desktop and mobile browsers.',
      clubId: 'club-gdg',
      clubName: 'GDG on Campus · BU',
      category: EventCategory.workshops,
      startTime: DateTime(2026, 12, 12, 17, 0),
      endTime: DateTime(2026, 12, 12, 19, 30),
      publishedAt: DateTime(2026, 11, 25, 19, 0),
      registrationDeadline: DateTime(2026, 12, 12, 14, 0),
      venue: 'L-Block Lecture Theatre 3',
      bannerUrl:
          'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?auto=format&fit=crop&w=1200&q=80',
      registeredCount: 95,
      capacity: 120,
      teamSizeLabel: 'Individual',
      feeLabel: 'Free · GDG Badge Eligible',
      tags: ['Flutter', 'Certificate'],
      agenda: const [
        EventAgendaItem(
          timeLabel: '05:00 PM',
          title: 'Feature-First Architecture & GoRouter',
          description: 'Keeping navigation, state, and widgets decoupled.',
        ),
        EventAgendaItem(
          timeLabel: '06:15 PM',
          title: 'Responsive Web Polish & Performance',
          description: 'Avoiding layout overflows and optimizing web assets.',
        ),
      ],
      speakers: const [
        EventSpeaker(
          name: 'Devansh Kulkarni',
          role: 'GDG On-Campus Organizer',
          organization: 'GDG on Campus · BU',
          initials: 'DK',
        ),
      ],
      mediaGallery: const [
        MediaItem(
          id: 'm-gdg-1',
          url: 'https://images.unsplash.com/photo-1522071820081-009f0129c71c?auto=format&fit=crop&w=1000&q=80',
          caption: 'GDG Study Jam cohort collaborating in L-Block',
        ),
      ],
    ),
    CampusEvent(
      id: 'evt-floodlight-cup',
      title: 'Inter-Hostel Floodlight Futsal Cup',
      subtitle:
          'Knockout night matches across hostel squads competing for the Autumn Championship trophy.',
      description:
          'High-intensity 5v5 floodlight futsal matches held across three evenings on the Bennett Synthetic Turf Arena. Squads represent their hostel blocks with live commentary, standings boards, and spectator zones.',
      clubId: 'club-csi',
      clubName: 'CSI Bennett Chapter',
      category: EventCategory.sports,
      startTime: DateTime(2027, 1, 14, 19, 0),
      endTime: DateTime(2027, 1, 14, 22, 0),
      publishedAt: DateTime(2026, 11, 18, 9, 0),
      registrationDeadline: DateTime(2027, 1, 10, 23, 59),
      venue: 'Synthetic Turf Arena',
      bannerUrl:
          'https://images.unsplash.com/photo-1574629810360-7efbbe195018?auto=format&fit=crop&w=1200&q=80',
      registeredCount: 160,
      capacity: 180,
      teamSizeLabel: 'Squad of 7 (5v5)',
      feeLabel: 'Free · Hostel Teams',
      tags: ['Night League', '5v5'],
      agenda: const [
        EventAgendaItem(
          timeLabel: '07:00 PM',
          title: 'Quarterfinal Kickoffs',
          description: '20-minute halves under arena floodlights.',
        ),
        EventAgendaItem(
          timeLabel: '09:00 PM',
          title: 'Championship Semifinals',
          description: 'Knockout bracket deciders.',
        ),
      ],
      speakers: const [],
      mediaGallery: const [],
    ),
    CampusEvent(
      id: 'evt-cloud-bootcamp',
      title: 'Cloud & Kubernetes Reliability Bootcamp',
      subtitle:
          'Hands-on production observability, autoscaling, and zero-downtime rollouts in GDG Cloud Lab.',
      description:
          'Intensive Saturday bootcamp covering container orchestration, health probes, and incident simulation on live clusters.',
      clubId: 'club-gdg',
      clubName: 'GDG on Campus · BU',
      category: EventCategory.techAi,
      startTime: DateTime(2026, 12, 13, 10, 0),
      endTime: DateTime(2026, 12, 13, 16, 0),
      publishedAt: DateTime(2026, 11, 23, 11, 0),
      registrationDeadline: DateTime(2026, 12, 12, 20, 0),
      venue: 'N-Block Cloud Lab 301',
      bannerUrl:
          'https://images.unsplash.com/photo-1451187580459-43490279c0fa?auto=format&fit=crop&w=1200&q=80',
      registeredCount: 120,
      capacity: 120,
      teamSizeLabel: 'Individual',
      feeLabel: 'Free · Seats Full',
      tags: ['Cloud', 'Sold Out'],
    ),
    CampusEvent(
      id: 'evt-robotics-closed',
      title: 'Autonomous Rover Track Trials',
      subtitle:
          'Closed qualifier briefing and sensor calibration run for registered robotics teams.',
      description:
          'Track testing and safety inspection for shortlisted robotics teams ahead of the inter-university rover showcase.',
      clubId: 'club-turing',
      clubName: 'Alan Turing Club',
      category: EventCategory.workshops,
      startTime: DateTime(2026, 11, 30, 15, 0),
      endTime: DateTime(2026, 11, 30, 18, 0),
      publishedAt: DateTime(2026, 11, 15, 9, 0),
      registrationDeadline: DateTime(2026, 11, 25, 18, 0),
      venue: 'N-Block Robotics Courtyard',
      bannerUrl:
          'https://images.unsplash.com/photo-1581091226825-a6a2a5aee158?auto=format&fit=crop&w=1200&q=80',
      registeredCount: 42,
      capacity: 60,
      teamSizeLabel: 'Teams of 3–5',
      feeLabel: 'Closed · Shortlist Only',
      isRegistrationClosed: true,
      tags: ['Robotics', 'Closed'],
    ),
    CampusEvent(
      id: 'evt-bennovate-past',
      title: 'Bennovate Startup Expo 2026',
      subtitle:
          'Annual Bennett Hatchery flagship demo day featuring 28 student startups and alumni panels.',
      description:
          'Completed autumn startup showcase where student teams demonstrated hardware, SaaS, and climate prototypes to industry judges.',
      clubId: 'club-ecell',
      clubName: 'Bennett E-Cell',
      category: EventCategory.entrepreneurship,
      startTime: DateTime(2026, 10, 18, 10, 0),
      endTime: DateTime(2026, 10, 18, 18, 0),
      publishedAt: DateTime(2026, 10, 1, 10, 0),
      registrationDeadline: DateTime(2026, 10, 17, 20, 0),
      venue: 'Main Auditorium & Hatchery Lawn',
      bannerUrl:
          'https://images.unsplash.com/photo-1540575467063-178a50c2df87?auto=format&fit=crop&w=1200&q=80',
      registeredCount: 520,
      capacity: 520,
      teamSizeLabel: 'Individual Pass',
      feeLabel: 'Completed Event',
      isRegistrationClosed: true,
      isCompleted: true,
      tags: ['Completed', 'Expo'],
    ),
  ];

  static final List<EventRegistration> initialRegistrations = [
    EventRegistration(
      id: 'reg-hackaccino-01',
      eventId: 'evt-hackaccino',
      studentId: currentStudent.id,
      studentName: currentStudent.fullName,
      studentEmail: currentStudent.email,
      studentProgram: '${currentStudent.program} · ${currentStudent.batchYear}',
      ticketCode: 'BU-CSI-4821',
      status: RegistrationStatus.confirmed,
      registeredAt: DateTime(2026, 11, 22, 14, 20),
      answers: const {
        'q-team-name': 'NullPointers BU',
        'q-track': 'Applied AI & Agents',
        'q-experience': '1–2 previous hackathons',
        'q-stack': ['Flutter / Dart', 'Supabase / SQL'],
        'q-team-size': '3',
        'q-idea': 'Unified campus events and club companion built for Bennett students.',
        'q-conduct': true,
      },
    ),
    EventRegistration(
      id: 'reg-genai-02',
      eventId: 'evt-genai-studio',
      studentId: currentStudent.id,
      studentName: currentStudent.fullName,
      studentEmail: currentStudent.email,
      studentProgram: '${currentStudent.program} · ${currentStudent.batchYear}',
      ticketCode: 'BU-ALA-3910',
      status: RegistrationStatus.confirmed,
      registeredAt: DateTime(2026, 11, 24, 19, 45),
    ),
    EventRegistration(
      id: 'reg-bennovate-03',
      eventId: 'evt-bennovate-past',
      studentId: currentStudent.id,
      studentName: currentStudent.fullName,
      studentEmail: currentStudent.email,
      studentProgram: '${currentStudent.program} · ${currentStudent.batchYear}',
      ticketCode: 'BU-BEN-1094',
      status: RegistrationStatus.completed,
      registeredAt: DateTime(2026, 10, 12, 11, 15),
    ),
    EventRegistration(
      id: 'reg-founders-04',
      eventId: 'evt-founders-table',
      studentId: currentStudent.id,
      studentName: currentStudent.fullName,
      studentEmail: currentStudent.email,
      studentProgram: '${currentStudent.program} · ${currentStudent.batchYear}',
      ticketCode: 'BU-BEN-2740',
      status: RegistrationStatus.cancelled,
      registeredAt: DateTime(2026, 11, 21, 16, 0),
      cancelledAt: DateTime(2026, 11, 23, 9, 30),
    ),
  ];

  static const List<CampusClub> clubs = [
    CampusClub(
      id: 'club-csi',
      name: 'CSI Bennett Chapter',
      shortCode: 'CSI',
      category: 'Computer Science',
      tagline: 'Flagship hackathons, systems engineering, and peer coding circles.',
      about:
          'The Computer Society of India (CSI) Bennett University Student Chapter is one of the largest technical communities on campus. We host Hackaccino, weekly algorithmic problem-solving circles, open-source sprints, and industry engineering talks throughout the academic year.',
      memberCount: 420,
      upcomingEventCount: 2,
      coverUrl:
          'https://images.unsplash.com/photo-1522071820081-009f0129c71c?auto=format&fit=crop&w=900&q=80',
      socialLinks: [
        ClubSocialLink(
          platform: 'Instagram',
          handle: '@csi.bennett',
          url: 'https://instagram.com',
        ),
        ClubSocialLink(
          platform: 'LinkedIn',
          handle: 'csi-bennett',
          url: 'https://linkedin.com',
        ),
        ClubSocialLink(
          platform: 'GitHub',
          handle: 'csi-bu',
          url: 'https://github.com',
        ),
      ],
      leadership: [
        ClubLeader(
          name: 'Pranav Joshi',
          role: 'President',
          program: 'B.Tech CSE · Year 4',
          initials: 'PJ',
        ),
        ClubLeader(
          name: 'Ishita Sen',
          role: 'Vice President · Tech',
          program: 'B.Tech CSE · Year 3',
          initials: 'IS',
        ),
        ClubLeader(
          name: 'Raghav Bansal',
          role: 'General Secretary',
          program: 'B.Tech CSE · Year 3',
          initials: 'RB',
        ),
      ],
      previousEvents: [
        PreviousClubEvent(
          title: 'Hackaccino 3.0 — Spring Edition',
          dateLabel: 'Mar 2026',
          attendeesLabel: '380 participants',
          summary: '95 teams shipped prototypes across AI and campus utility tracks.',
          coverUrl:
              'https://images.unsplash.com/photo-1515187029135-18ee286d815b?auto=format&fit=crop&w=900&q=80',
        ),
        PreviousClubEvent(
          title: 'Linux & Docker Internals Night',
          dateLabel: 'Jan 2026',
          attendeesLabel: '145 attendees',
          summary: 'Hands-on container networking and CI deployment lab.',
          coverUrl:
              'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?auto=format&fit=crop&w=900&q=80',
        ),
      ],
      photos: [
        MediaItem(
          id: 'csi-p1',
          url: 'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?auto=format&fit=crop&w=1000&q=80',
          caption: 'Midnight coding floor at N-Block Innovation Hub',
        ),
        MediaItem(
          id: 'csi-p2',
          url: 'https://images.unsplash.com/photo-1522071820081-009f0129c71c?auto=format&fit=crop&w=1000&q=80',
          caption: 'Core organizing team debrief after demo day',
        ),
      ],
      videos: [
        ClubVideoItem(
          title: 'Hackaccino 3.0 Official Aftermovie',
          durationLabel: '02:45',
          thumbnailUrl:
              'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?auto=format&fit=crop&w=1000&q=80',
          videoUrl: 'https://youtube.com',
          summary: '36 hours of building, mentoring, and finale pitches in under 3 minutes.',
        ),
      ],
    ),
    CampusClub(
      id: 'club-gdg',
      name: 'GDG on Campus · BU',
      shortCode: 'GDG',
      category: 'Developer Community',
      tagline: 'Workshops on Flutter, Cloud, Web, and open-source engineering.',
      about:
          'Google Developer Groups on Campus at Bennett University empowers student developers through peer-led study jams, Solution Challenge cohorts, and production engineering bootcamps across mobile, web, and cloud infrastructure.',
      memberCount: 510,
      upcomingEventCount: 1,
      coverUrl:
          'https://images.unsplash.com/photo-1531482615713-2afd69097998?auto=format&fit=crop&w=900&q=80',
      socialLinks: [
        ClubSocialLink(
          platform: 'Instagram',
          handle: '@gdg.bennett',
          url: 'https://instagram.com',
        ),
        ClubSocialLink(
          platform: 'LinkedIn',
          handle: 'gdg-bu',
          url: 'https://linkedin.com',
        ),
        ClubSocialLink(
          platform: 'Website',
          handle: 'gdg.community.dev',
          url: 'https://gdg.community.dev',
        ),
      ],
      leadership: [
        ClubLeader(
          name: 'Devansh Kulkarni',
          role: 'Lead Organizer',
          program: 'B.Tech CSE · Year 4',
          initials: 'DK',
        ),
        ClubLeader(
          name: 'Niharika Singh',
          role: 'Flutter & Mobile Lead',
          program: 'B.Tech CSE · Year 3',
          initials: 'NS',
        ),
      ],
      previousEvents: [
        PreviousClubEvent(
          title: 'Cloud Study Jam & Kubernetes Lab',
          dateLabel: 'Oct 2026',
          attendeesLabel: '210 attendees',
          summary: 'Deployed containerized microservices during a 4-hour campus lab.',
          coverUrl:
              'https://images.unsplash.com/photo-1531482615713-2afd69097998?auto=format&fit=crop&w=900&q=80',
        ),
      ],
      photos: [
        MediaItem(
          id: 'gdg-p1',
          url: 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?auto=format&fit=crop&w=1000&q=80',
          caption: 'Flutter Web architecture walkthrough in L-Block',
        ),
      ],
      videos: [
        ClubVideoItem(
          title: 'Solution Challenge Orientation Recap',
          durationLabel: '01:58',
          thumbnailUrl:
              'https://images.unsplash.com/photo-1531482615713-2afd69097998?auto=format&fit=crop&w=1000&q=80',
          videoUrl: 'https://youtube.com',
          summary: 'Highlights from our campus Solution Challenge kickoff.',
        ),
      ],
    ),
    CampusClub(
      id: 'club-turing',
      name: 'Alan Turing Club',
      shortCode: 'ATC',
      category: 'AI & Research',
      tagline: 'Applied machine learning labs, paper reading groups, and Kaggle sprints.',
      about:
          'Alan Turing Club bridges undergraduate research and practical AI engineering at Bennett University. Members participate in weekly paper clubs, fine-tuning workshops, and competitive ML sprints.',
      memberCount: 315,
      upcomingEventCount: 1,
      coverUrl:
          'https://images.unsplash.com/photo-1485827404703-89b55fcc595e?auto=format&fit=crop&w=900&q=80',
      socialLinks: [
        ClubSocialLink(
          platform: 'GitHub',
          handle: 'alan-turing-bu',
          url: 'https://github.com',
        ),
        ClubSocialLink(
          platform: 'LinkedIn',
          handle: 'alan-turing-bennett',
          url: 'https://linkedin.com',
        ),
      ],
      leadership: [
        ClubLeader(
          name: 'Ananya Verma',
          role: 'President',
          program: 'B.Tech AI · Year 4',
          initials: 'AV',
        ),
        ClubLeader(
          name: 'Yashwardhan Tiwari',
          role: 'Research Lead',
          program: 'B.Tech CSE · Year 3',
          initials: 'YT',
        ),
      ],
      previousEvents: [
        PreviousClubEvent(
          title: 'Vision Transformers Paper Circle',
          dateLabel: 'Sep 2026',
          attendeesLabel: '90 attendees',
          summary: 'Interactive code walkthrough of attention maps and ViT training.',
          coverUrl:
              'https://images.unsplash.com/photo-1555949963-aa79dcee981c?auto=format&fit=crop&w=900&q=80',
        ),
      ],
      photos: [
        MediaItem(
          id: 'atc-p1',
          url: 'https://images.unsplash.com/photo-1485827404703-89b55fcc595e?auto=format&fit=crop&w=1000&q=80',
          caption: 'Applied ML demo showcase in P-Block',
        ),
      ],
      videos: [],
    ),
    CampusClub(
      id: 'club-advaita',
      name: 'Advaita Music Society',
      shortCode: 'AMS',
      category: 'Performing Arts',
      tagline: 'Live campus concerts, jam rooms, and acoustic showcases.',
      about:
          'Advaita is Bennett University’s official music collective uniting vocalists, instrumentalists, producers, and sound engineers. From acoustic open-mic nights to mainstage Uphoria performances, Advaita keeps campus nights alive.',
      memberCount: 245,
      upcomingEventCount: 1,
      coverUrl:
          'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?auto=format&fit=crop&w=900&q=80',
      socialLinks: [
        ClubSocialLink(
          platform: 'Instagram',
          handle: '@advaita.bu',
          url: 'https://instagram.com',
        ),
        ClubSocialLink(
          platform: 'YouTube',
          handle: 'Advaita Bennett',
          url: 'https://youtube.com',
        ),
      ],
      leadership: [
        ClubLeader(
          name: 'Kabir Khanna',
          role: 'Society President',
          program: 'BBA · Year 3',
          initials: 'KK',
        ),
        ClubLeader(
          name: 'Sana Mir',
          role: 'Vocal & Stage Coordinator',
          program: 'BAJMC · Year 3',
          initials: 'SM',
        ),
      ],
      previousEvents: [
        PreviousClubEvent(
          title: 'Uphoria Mainstage Battle of Bands',
          dateLabel: 'Oct 2026',
          attendeesLabel: '900+ audience',
          summary: '12 university bands competed across rock, fusion, and indie genres.',
          coverUrl:
              'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?auto=format&fit=crop&w=900&q=80',
        ),
      ],
      photos: [
        MediaItem(
          id: 'ams-p1',
          url: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?auto=format&fit=crop&w=1000&q=80',
          caption: 'Evening amphitheatre soundcheck',
        ),
      ],
      videos: [
        ClubVideoItem(
          title: 'Advaita Live Sessions — Ep. 4',
          durationLabel: '04:12',
          thumbnailUrl:
              'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?auto=format&fit=crop&w=1000&q=80',
          videoUrl: 'https://youtube.com',
          summary: 'Unplugged studio session recorded on campus.',
        ),
      ],
    ),
    CampusClub(
      id: 'club-ecell',
      name: 'Bennett E-Cell',
      shortCode: 'EC',
      category: 'Entrepreneurship',
      tagline: 'Founder roundtables, Hatchery demo days, and venture challenges.',
      about:
          'Bennett Entrepreneurship Cell collaborates closely with the Bennett Hatchery to nurture student startups from ideation to seed readiness through pitch clinics, founder fireside chats, and annual startup expos.',
      memberCount: 380,
      upcomingEventCount: 1,
      coverUrl:
          'https://images.unsplash.com/photo-1556761175-5973dc0f32e7?auto=format&fit=crop&w=900&q=80',
      socialLinks: [
        ClubSocialLink(
          platform: 'LinkedIn',
          handle: 'ecell-bennett',
          url: 'https://linkedin.com',
        ),
        ClubSocialLink(
          platform: 'Instagram',
          handle: '@ecell.bennett',
          url: 'https://instagram.com',
        ),
      ],
      leadership: [
        ClubLeader(
          name: 'Vivaan Kapoor',
          role: 'Student Head',
          program: 'B.Tech CSE · Year 4',
          initials: 'VK',
        ),
      ],
      previousEvents: [
        PreviousClubEvent(
          title: 'Bennovate Startup Expo',
          dateLabel: 'Sep 2026',
          attendeesLabel: '520 attendees',
          summary: '28 student startups pitched to angel investors and mentors.',
          coverUrl:
              'https://images.unsplash.com/photo-1540575467063-178a50c2df87?auto=format&fit=crop&w=900&q=80',
        ),
      ],
      photos: [],
      videos: [],
    ),
    CampusClub(
      id: 'club-pixelate',
      name: 'Pixelate Design Guild',
      shortCode: 'PDG',
      category: 'Design & Media',
      tagline: 'Product design critiques, brand systems, and visual storytelling.',
      about:
          'Pixelate Design Guild is Bennett’s hub for UI/UX designers, motion artists, and brand thinkers. We partner with campus chapters to elevate event visual identities and mentor students building product design portfolios.',
      memberCount: 190,
      upcomingEventCount: 1,
      coverUrl:
          'https://images.unsplash.com/photo-1542744094-3a31f272c490?auto=format&fit=crop&w=900&q=80',
      socialLinks: [
        ClubSocialLink(
          platform: 'Instagram',
          handle: '@pixelate.bu',
          url: 'https://instagram.com',
        ),
        ClubSocialLink(
          platform: 'Website',
          handle: 'pixelate-bu.design',
          url: 'https://figma.com',
        ),
      ],
      leadership: [
        ClubLeader(
          name: 'Meera Nair',
          role: 'Design Director',
          program: 'B.Des · Year 3',
          initials: 'MN',
        ),
      ],
      previousEvents: [
        PreviousClubEvent(
          title: 'Campus Brand Jam 2026',
          dateLabel: 'Aug 2026',
          attendeesLabel: '75 designers',
          summary: '4-hour rapid identity redesign challenge for campus societies.',
          coverUrl:
              'https://images.unsplash.com/photo-1558655146-9f40138edfeb?auto=format&fit=crop&w=900&q=80',
        ),
      ],
      photos: [],
      videos: [],
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
