import '../models/models.dart';
import 'api_response.dart';
import 'base_client.dart';

class ChatService extends BaseClient {
  Future<ApiResponse<List<ChatItem>>> getChats() =>
      getRequest<List<ChatItem>>(
        'chats/',
        decoder: (json) => (json as List)
            .map((e) => ChatItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Future<ApiResponse<List<ChatUserSearch>>> searchUsers(String query) =>
      getRequest<List<ChatUserSearch>>(
        'chats/users/',
        query: {'q': query},
        decoder: (json) => (json as List)
            .map((e) => ChatUserSearch.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Future<ApiResponse<List<ChatMessage>>> getGameMessages(int gameId) =>
      getRequest<List<ChatMessage>>(
        'chats/game/$gameId/',
        decoder: (json) => (json as List)
            .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Future<ApiResponse<ChatMessage>> sendGameMessage(int gameId, String text) =>
      postRequest<ChatMessage>(
        'chats/game/$gameId/',
        {'text': text},
        decoder: (json) => ChatMessage.fromJson(json as Map<String, dynamic>),
      );

  Future<ApiResponse<List<ChatMessage>>> getDirectMessages(int userId) =>
      getRequest<List<ChatMessage>>(
        'chats/direct/$userId/',
        decoder: (json) => (json as List)
            .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Future<ApiResponse<ChatMessage>> sendDirectMessage(int userId, String text) =>
      postRequest<ChatMessage>(
        'chats/direct/$userId/',
        {'text': text},
        decoder: (json) => ChatMessage.fromJson(json as Map<String, dynamic>),
      );
}
