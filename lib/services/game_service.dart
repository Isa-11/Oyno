import '../models/models.dart';
import 'api_response.dart';
import 'base_client.dart';

class GameService extends BaseClient {
  /// Все открытые игры (главная страница)
  Future<ApiResponse<List<PlayerGroup>>> getOpenGames({String? sport}) =>
      getRequest<List<PlayerGroup>>(
        'games/',
        query: sport != null ? {'sport': sport} : null,
        decoder: (json) => (json as List)
            .map((e) => PlayerGroup.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  /// Мои предстоящие игры
  Future<ApiResponse<List<GameItem>>> getUpcomingGames() =>
      getRequest<List<GameItem>>(
        'games/my/',
        decoder: (json) => (json as List)
            .map((e) => GameItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  /// История игр
  Future<ApiResponse<List<GameItem>>> getHistoryGames() =>
      getRequest<List<GameItem>>(
        'games/history/',
        decoder: (json) => (json as List)
            .map((e) => GameItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  /// Создать игру
  Future<ApiResponse<PlayerGroup>> createGame(Map<String, dynamic> data) =>
      postRequest<PlayerGroup>(
        'games/',
        data,
        decoder: (json) => PlayerGroup.fromJson(json as Map<String, dynamic>),
      );

  /// Вступить в игру
  Future<ApiResponse<PlayerGroup>> joinGame(int gameId) =>
      postRequest<PlayerGroup>(
        'games/$gameId/join/',
        {},
        decoder: (json) => PlayerGroup.fromJson(json as Map<String, dynamic>),
      );

  /// Покинуть игру
  Future<ApiResponse<void>> leaveGame(int gameId) =>
      deleteRequest<void>('games/$gameId/join/');
}
