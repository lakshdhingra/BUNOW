# BU NOW

A campus events and student engagement platform for Bennett University.

BU NOW brings university events, clubs, registrations, and campus activities into one place. Students can discover upcoming events, explore clubs, register for activities, and manage their event participation. Authorized club representatives will be able to manage their events and registrations through a dedicated organizer interface.

## Overview

University events are often distributed across emails, messaging groups, and separate registration forms. This makes it difficult for students to discover activities and keep track of their registrations.

BU NOW aims to provide a centralized platform for campus engagement, making event discovery and participation simpler for students while giving clubs a structured way to manage their activities.

## Features

### Student Portal

- Student authentication using Supabase Email/Password.
- Student profile management.
- Home page with event discovery.
- Browse and search published events.
- Explore clubs and their profiles.
- View event details, schedules, venues, and descriptions.
- Register for basic-registration events.
- View personal event registrations.
- Registration tickets with QR tokens.
- Campus calendar and notifications.

### Organizer Studio

The application includes an initial Organizer Studio interface.

The planned organizer functionality includes:

- Event creation and management.
- Club-specific event administration.
- Registration management.
- Custom registration forms.
- Participant tracking and attendance.
- Event media management.

Organizer functionality is not yet fully integrated with the Supabase backend.

## Technology Stack

| Layer | Technology |
|---|---|
| Frontend | Flutter |
| Language | Dart |
| State management | Riverpod |
| Navigation | GoRouter |
| Backend and database | Supabase |
| Database | PostgreSQL |
| Authentication | Supabase Auth |
| File storage | Supabase Storage |
| Image loading | Cached Network Image |
| Date formatting | intl |

## Project Structure

The application follows a feature-first architecture.

```text
lib/
├── core/
│   ├── config/
│   ├── router/
│   ├── services/
│   ├── theme/
│   └── utils/
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── student_portal/
│   │   ├── data/
│   │   │   ├── mock/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   └── presentation/
│   │       ├── pages/
│   │       ├── providers/
│   │       └── widgets/
│   │
│   └── organizer_studio/
│
├── shared/
│   └── widgets/
│
├── app.dart
└── main.dart

test/
```

The structure separates application infrastructure, business logic, data access, and presentation.

## Database Design

BU NOW uses Supabase PostgreSQL with the following tables:

| Table | Purpose |
|---|---|
| `profiles` | Student profile information |
| `clubs` | University clubs and their details |
| `club_members` | Club membership and representative roles |
| `events` | Event information and publishing status |
| `event_media` | Event images and media references |
| `registrations` | Student event registrations |
| `form_questions` | Custom registration form questions |
| `form_responses` | Submitted registration answers |
| `attendance` | Event attendance records |
| `notifications` | Student notifications |
| `notification_preferences` | Notification settings |

### Registration

Basic event registration is handled through a PostgreSQL function:

```sql
public.register_for_event(target_event UUID)
```

The function checks authentication, event publishing status, registration mode, deadline, duplicate registrations, and available capacity before creating a registration.

The function returns the newly created registration UUID.

## Getting Started

### Prerequisites

Install the following:

- Flutter SDK
- Dart SDK
- Google Chrome
- Git
- A Supabase project

Verify your Flutter installation:

```bash
flutter doctor
```

### 1. Clone the repository

```bash
git clone <YOUR_REPOSITORY_URL>
```

Navigate into the project:

```bash
cd BU-NOW
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Configure Supabase

Create a file named `env.local.json` in the project root:

```json
{
  "SUPABASE_URL": "YOUR_SUPABASE_PROJECT_URL",
  "SUPABASE_PUBLISHABLE_KEY": "YOUR_SUPABASE_PUBLISHABLE_KEY"
}
```

Replace the placeholders with your own Supabase project URL and publishable key.

The configuration file is excluded from Git through `.gitignore`.

Never put a Supabase service-role key in the Flutter application.

### 4. Run the application

For Flutter Web:

```bash
flutter run -d chrome --dart-define-from-file=env.local.json
```

For a web production build:

```bash
flutter build web --dart-define-from-file=env.local.json
```

## Development Commands

Fetch dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run -d chrome --dart-define-from-file=env.local.json
```

Analyze the project:

```bash
flutter analyze
```

Run tests:

```bash
flutter test
```

Build for web:

```bash
flutter build web --dart-define-from-file=env.local.json
```

## Current Implementation Status

The initial Supabase integration stage has been completed.

| Component | Status |
|---|---|
| Flutter application foundation | Implemented |
| Supabase initialization | Implemented |
| Email/Password authentication | Implemented |
| Student profile integration | Implemented |
| Event repository | Implemented |
| Club repository | Implemented |
| Registration repository | Implemented |
| Notification repository | Implemented |
| Student portal data integration | Implemented |
| Basic registration RPC integration | Implemented |
| Microsoft OAuth | Pending |
| Advanced registration form submission | Pending |
| Organizer Studio backend integration | Pending |
| Production database security | Pending |

### Verification

The latest reported development checks:

- `flutter pub get` completed successfully.
- `flutter analyze` reported no issues.
- All 14 Flutter tests passed.
- Flutter Web production build completed successfully.
- Supabase REST schema queries returned HTTP 200.

Live end-to-end authentication and registration with populated event data still require manual browser testing.

## Security Considerations

**Current database configuration is for development only.**

Row Level Security (RLS) is currently disabled on the application tables. This means authenticated users may be able to access or modify records belonging to other users, depending on the granted database permissions.

Before production deployment:

- Enable RLS on application tables.
- Implement policies for student-owned records.
- Restrict club management to authorized club representatives.
- Secure registration and attendance operations.
- Configure Microsoft OAuth and university account restrictions.
- Validate all user input.
- Review Supabase Storage access policies.
- Never expose service-role credentials in the client application.

Do not use real student information with the current development security configuration.

## Roadmap

- [x] Flutter application foundation
- [x] Student portal interface
- [x] Supabase database integration
- [x] Email/Password authentication
- [x] Student, event, and club repositories
- [x] Basic registration RPC integration
- [ ] Populate the platform with initial club and event data
- [ ] Complete live end-to-end testing
- [ ] Microsoft university authentication
- [ ] Advanced registration forms
- [ ] Organizer Studio backend integration
- [ ] Attendance management
- [ ] Notification delivery
- [ ] Database security and RLS policies
- [ ] Production deployment

## Project Goal

BU NOW is intended to become a centralized digital platform for campus events and student activities at Bennett University, connecting students and university clubs through a single, accessible application.
