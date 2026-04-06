import '../models/models.dart';
import 'api_response.dart';
import 'base_client.dart';

class VenueSlotsResult {
  final int venueId;
  final String date;
  final String opensAt;
  final String closesAt;
  final List<VenueSlot> slots;
  VenueSlotsResult({
    required this.venueId, required this.date,
    required this.opensAt, required this.closesAt, required this.slots,
  });
  factory VenueSlotsResult.fromJson(Map<String, dynamic> json) => VenueSlotsResult(
    venueId: json['venue_id'] as int,
    date: json['date'] as String,
    opensAt: json['opens_at'] as String,
    closesAt: json['closes_at'] as String,
    slots: (json['slots'] as List).map((e) => VenueSlot.fromJson(e as Map<String, dynamic>)).toList(),
  );
}

class VenueService extends BaseClient {
  Future<ApiResponse<List<Venue>>> getVenues({String? sport}) =>
      getRequest<List<Venue>>(
        'venues/',
        query: sport != null ? {'sport': sport} : null,
        decoder: (json) => (json as List)
            .map((e) => Venue.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Future<ApiResponse<Venue>> getVenueById(int id) =>
      getRequest<Venue>(
        'venues/$id/',
        decoder: (json) => Venue.fromJson(json as Map<String, dynamic>),
      );

  Future<ApiResponse<VenueSlotsResult>> getSlots(int venueId, String date) =>
      getRequest<VenueSlotsResult>(
        'venues/$venueId/slots/',
        query: {'date': date},
        decoder: (json) => VenueSlotsResult.fromJson(json as Map<String, dynamic>),
      );

  Future<ApiResponse<List<Venue>>> getMyVenues() =>
      getRequest<List<Venue>>(
        'venues/my/',
        decoder: (json) => (json as List)
            .map((e) => Venue.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Future<ApiResponse<Venue>> createVenue(Map<String, dynamic> data) =>
      postRequest<Venue>(
        'venues/',
        data,
        decoder: (json) => Venue.fromJson(json as Map<String, dynamic>),
      );

  Future<ApiResponse<Venue>> updateVenue(int id, Map<String, dynamic> data) =>
      patchRequest<Venue>(
        'venues/$id/',
        data,
        decoder: (json) => Venue.fromJson(json as Map<String, dynamic>),
      );
}
