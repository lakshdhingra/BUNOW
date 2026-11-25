/// Named route paths for the BENNETT application.
abstract final class AppRoutes {
  static const String root = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String explore = '/explore';
  static const String eventDetailPattern = '/events/:eventId';
  static const String eventRegistrationPattern = '/events/:eventId/register';
  static const String ticketDetailPattern = '/tickets/:registrationId';
  static const String calendar = '/calendar';
  static const String myEvents = '/my-events';
  static const String clubs = '/clubs';
  static const String clubProfilePattern = '/clubs/:clubId';
  static const String highlights = '/highlights';
  static const String notifications = '/notifications';
  static const String profile = '/profile';
  static const String studentPortal = home;
  static const String organizerStudio = organizerDashboard;
  static const String organizerRoot = '/organizer';
  static const String organizerDashboard = '/organizer/dashboard';
  static const String organizerEvents = '/organizer/events';
  static const String organizerNewEvent = '/organizer/events/new';
  static const String organizerEditEventPattern = '/organizer/events/:eventId/edit';
  static const String organizerRegistrations = '/organizer/registrations';
  static const String organizerAttendance = '/organizer/attendance';
  static const String organizerClub = '/organizer/club';

  static String eventDetail(String eventId) => '/events/$eventId';
  static String eventRegistration(String eventId) => '/events/$eventId/register';
  static String ticketDetail(String registrationId) => '/tickets/$registrationId';
  static String clubProfile(String clubId) => '/clubs/$clubId';
  static String organizerEditEvent(String eventId) => '/organizer/events/$eventId/edit';
}
