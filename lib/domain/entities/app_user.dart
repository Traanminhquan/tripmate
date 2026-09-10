class AppUser {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String? bio;
  final List<String> travelPreferences;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.bio,
    this.travelPreferences = const [],
  });
}