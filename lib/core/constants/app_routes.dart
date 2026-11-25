/// Typed route paths for all 16 screens in Career Guidance Community.
abstract final class AppRoutes {
  static const String home = '/';
  static const String quiz = '/quiz';
  static const String results = '/results';
  static const String recommendations = '/recommendations';
  static const String colleges = '/colleges';
  static const String collegeDetailsPattern = '/college/:collegeId';
  static const String compare = '/compare';
  static const String scholarships = '/scholarships';
  static const String saved = '/saved';
  static const String aiMentor = '/ai-mentor';
  static const String applicationTracker = '/application-tracker';
  static const String community = '/community';
  static const String dashboard = '/dashboard';
  static const String parental = '/parental';
  static const String profile = '/profile';
  static const String settings = '/settings';

  static String collegeDetails(String collegeId) => '/college/$collegeId';

  static String compareWithIds(List<String> ids) {
    final cleanIds = ids.where((id) => id.trim().isNotEmpty).take(3).toList();
    if (cleanIds.isEmpty) return compare;
    return '$compare?ids=${Uri.encodeQueryComponent(cleanIds.join(','))}';
  }
}
