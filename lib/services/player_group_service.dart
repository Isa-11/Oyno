import '../models/models.dart';
import 'api_response.dart';
import 'base_client.dart';

class PlayerGroupService extends BaseClient {
  Future<ApiResponse<List<PlayerGroup>>> getPlayerGroups({String? sport}) =>
      getRequest<List<PlayerGroup>>(
        'groups/',
        query: sport != null ? {'sport': sport} : null,
        decoder: (json) => (json as List)
            .map((e) => PlayerGroup.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
