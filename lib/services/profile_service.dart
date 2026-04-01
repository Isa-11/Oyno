import 'api_response.dart';
import 'base_client.dart';

class UserProfile {
  final int id;
  final String username;
  final String email;
  final String city;
  final String avatarData;
  final double rating;
  final int gamesTotal;
  final int upcomingGames;

  UserProfile({
    required this.id,
    required this.username,
    required this.email,
    required this.city,
    required this.avatarData,
    required this.rating,
    required this.gamesTotal,
    required this.upcomingGames,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as int? ?? 0,
        username: json['username'] as String? ?? '',
        email: json['email'] as String? ?? '',
        city: json['city'] as String? ?? '',
        avatarData: json['avatar_data'] as String? ?? '',
        rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
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
    String? city,
    String? avatarData,
  }) =>
      patchRequest<UserProfile>(
        'auth/profile/',
        {
          if (username != null) 'username': username,
          if (email != null) 'email': email,
          if (city != null) 'city': city,
          if (avatarData != null) 'avatar_data': avatarData,
        },
        decoder: (json) => UserProfile.fromJson(json as Map<String, dynamic>),
      );
}
