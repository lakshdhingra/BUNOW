/// Named route paths for the BENNETT application.
abstract final class AppRoutes {
  static const String root = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String explore = '/explore';
  static const String eventDetailPattern = '/events/:eventId';
  static const String calendar = '/calendar';
  static const String myEvents = '/my-events';
  static const String clubs = '/clubs';
  static const String clubProfilePattern = '/clubs/:clubId';
  static const String highlights = '/highlights';
  static const String profile = '/profile';
  static const String studentPortal = home;
  static const String organizerStudio = '/organizer';

  static String eventDetail(String eventId) => '/events/$eventId';
  static String clubProfile(String clubId) => '/clubs/$clubId';
}
