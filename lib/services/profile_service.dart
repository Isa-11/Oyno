import 'api_response.dart';
import 'base_client.dart';

class UserProfile {
  final int id;
  final String username;
  final String email;
  final int gamesTotal;
  final int upcomingGames;

  UserProfile({
    required this.id,
    required this.username,
    required this.email,
    required this.gamesTotal,
    required this.upcomingGames,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as int? ?? 0,
        username: json['username'] as String? ?? '',
        email: json['email'] as String? ?? '',
        gamesTotal: json['games_total'] as int? ?? 0,
        upcomingGames: json['upcoming_games'] as int? ?? 0,
      );
}

class ProfileService extends BaseClient {
  Future<ApiResponse<UserProfile>> getProfile() =>
      getRequest<UserProfile>(
        'auth/profile/',
        decoder: (json) => UserProfile.fromJson(json as Map<String, dynamic>),
      );

  Future<ApiResponse<UserProfile>> updateProfile({
    String? username,
    String? email,
  }) =>
      patchRequest<UserProfile>(
        'auth/profile/',
        {
          if (username != null) 'username': username,
          if (email != null) 'email': email,
        },
        decoder: (json) => UserProfile.fromJson(json as Map<String, dynamic>),
      );
}
