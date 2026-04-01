import 'base_client.dart';
import 'api_response.dart';

class UserSettingsData {
  final bool notifications;
  final bool darkTheme;
  final bool geolocation;
  final bool privacy;

  const UserSettingsData({
    required this.notifications,
    required this.darkTheme,
    required this.geolocation,
    required this.privacy,
  });

  factory UserSettingsData.fromJson(Map<String, dynamic> json) =>
      UserSettingsData(
        notifications: json['notifications'] as bool? ?? true,
        darkTheme: json['dark_theme'] as bool? ?? true,
        geolocation: json['geolocation'] as bool? ?? false,
        privacy: json['privacy'] as bool? ?? true,
      );

  static UserSettingsData get defaults => const UserSettingsData(
        notifications: true,
        darkTheme: true,
        geolocation: false,
        privacy: true,
      );
}

class SettingsService extends BaseClient {
  Future<ApiResponse<UserSettingsData>> getSettings() => getRequest(
        'auth/settings/',
        decoder: (json) =>
            UserSettingsData.fromJson(json as Map<String, dynamic>),
      );

  Future<ApiResponse<UserSettingsData>> patchSettings(
          Map<String, dynamic> data) =>
      patchRequest(
        'auth/settings/',
        data,
        decoder: (json) =>
            UserSettingsData.fromJson(json as Map<String, dynamic>),
      );
}
