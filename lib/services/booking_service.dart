import 'base_client.dart';
import 'api_response.dart';

class BookingResult {
  final int id;
  final String venueName;
  final String date;
  final String timeSlot;
  final String status;

  const BookingResult({
    required this.id,
    required this.venueName,
    required this.date,
    required this.timeSlot,
    required this.status,
  });

  factory BookingResult.fromJson(Map<String, dynamic> json) => BookingResult(
        id: json['id'] as int? ?? 0,
        venueName: (json['venue'] is Map ? json['venue']['name'] : json['venue']?.toString()) ?? '',
        date: json['date'] as String? ?? '',
        timeSlot: json['time_slot'] as String? ?? '',
        status: json['status'] as String? ?? '',
      );
}

class BookingService extends BaseClient {
  Future<ApiResponse<BookingResult>> createBooking({
    required int venueId,
    required String date,
    required String timeSlot,
  }) =>
      postRequest<BookingResult>(
        'bookings/',
        {'venue': venueId, 'date': date, 'time_slot': timeSlot},
        decoder: (json) => BookingResult.fromJson(json as Map<String, dynamic>),
      );

  Future<ApiResponse<List<BookingResult>>> getMyBookings() =>
      getRequest<List<BookingResult>>(
        'bookings/',
        decoder: (json) => (json as List)
            .map((e) => BookingResult.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Future<ApiResponse<void>> cancelBooking(int id) =>
      deleteRequest<void>('bookings/$id/');
}
