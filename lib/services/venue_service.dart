import '../models/models.dart';
import 'api_response.dart';
import 'base_client.dart';

class VenueService extends BaseClient {
  Future<ApiResponse<List<Venue>>> getVenues({String? sport}) =>
      getRequest<List<Venue>>(
        'venues',
        query: sport != null ? {'sport': sport} : null,
        decoder: (json) => (json as List)
            .map((e) => Venue.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Future<ApiResponse<Venue>> getVenueById(String id) =>
      getRequest<Venue>(
        'venues/$id',
        decoder: (json) => Venue.fromJson(json as Map<String, dynamic>),
      );
}
