/// Represents a single dashboard module card returned by the backend.
///
/// The backend sends `key`, `title`, `subtitle`, and `route`.
/// Icon and color are resolved client-side using [key].
class DashboardModuleModel {
  /// Unique identifier used to map icon + color on the client side.
  /// Example: `"patient_registration"`, `"doctor_panel"`
  final String key;

  /// Display title shown on the card.
  final String title;

  /// Short description shown below the title.
  final String subtitle;

  /// GoRouter route path to navigate to on tap.
  /// Null means the card is not tappable (e.g. "Settings" placeholder).
  final String? route;

  const DashboardModuleModel({
    required this.key,
    required this.title,
    required this.subtitle,
    this.route,
  });

  /// Deserialise from a JSON map returned by the API.
  factory DashboardModuleModel.fromJson(Map<String, dynamic> json) {
    return DashboardModuleModel(
      key: json['key'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      route: json['route'] as String?,
    );
  }

  @override
  String toString() =>
      'DashboardModuleModel(key: $key, title: $title, route: $route)';
}
