import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';
import '../services/booking_service.dart';
import '../widgets/shimmer_loader.dart';
import '../widgets/empty_state.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  final RxList<Map<String, dynamic>> _bookings = <Map<String, dynamic>>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    _isLoading.value = true;
    _error.value = '';
    try {
      final res = await Get.find<BookingService>().getMyBookings();
      if (res.isSuccess && res.data != null) {
        _bookings.assignAll(
          res.data!.map((b) => {
            'id': b.id,
            'venue_name': b.venueName,
            'date': b.date,
            'time_slot': b.timeSlot,
            'status': b.status,
          }).toList(),
        );
      } else {
        _error.value = res.error ?? 'Не удалось загрузить бронирования';
      }
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Expanded(
              child: Obx(() {
                if (_isLoading.value) {
                  return const ShimmerLoader(itemCount: 3, itemHeight: 120);
                }
                if (_error.value.isNotEmpty) {
                  return ErrorStateWidget(
                    message: _error.value,
                    onRetry: _loadBookings,
                  );
                }
                if (_bookings.isEmpty) {
                  return const EmptyState(
                    icon: Icons.event_note_outlined,
                    message: 'Бронирований нет',
                    subtitle: 'Забронируйте площадку, чтобы она появилась здесь',
                  );
                }
                return RefreshIndicator(
                  color: AppColors.accent,
                  backgroundColor: AppColors.cardBackground,
                  onRefresh: _loadBookings,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    itemCount: _bookings.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _buildBookingItem(_bookings[i]),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  color: AppColors.textPrimary, size: 18),
            ),
          ),
          const SizedBox(width: 16),
          Text('МОИ БРОНИРОВАНИЯ', style: AppTextStyles.headingMD),
        ],
      ),
    );
  }

  Widget _buildBookingItem(Map<String, dynamic> booking) {
    final status = booking['status'] as String? ?? '';
    final statusColor = status == 'confirmed'
        ? AppColors.confirmGreen
        : status == 'pending'
            ? AppColors.waitGray
            : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  booking['venue_name'] as String? ?? '',
                  style: AppTextStyles.labelBold,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  (booking['status'] as String? ?? '').toUpperCase(),
                  style: AppTextStyles.bodySM.copyWith(color: statusColor, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, color: AppColors.textSecondary, size: 16),
              const SizedBox(width: 8),
              Text('${booking['date']} • ${booking['time_slot']}', style: AppTextStyles.bodySM),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              GestureDetector(
                onTap: () async {
                  final res = await Get.find<BookingService>().cancelBooking(booking['id']);
                  if (res.isSuccess) {
                    Get.snackbar('Успех', 'Бронирование отменено', snackPosition: SnackPosition.BOTTOM);
                    _loadBookings();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Text('ОТМЕНИТЬ', style: AppTextStyles.bodySM),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorStateWidget({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.textSecondary.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(message, style: AppTextStyles.bodySM, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('ПОВТОРИТЬ', style: AppTextStyles.labelBold.copyWith(color: AppColors.background)),
            ),
          ),
        ],
      ),
    );
  }
}
