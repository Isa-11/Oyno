import 'dart:async';
import 'package:get/get.dart';
import '../models/models.dart';
import '../services/venue_service.dart';

class VenueController extends GetxController {
  final VenueService _venueService = Get.find<VenueService>();

  final RxList<Venue> venues = <Venue>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  Timer? _refreshTimer;
  static const _refreshInterval = Duration(seconds: 60);

  @override
  void onInit() {
    super.onInit();
    fetchVenues();
    _startAutoRefresh();
  }

  @override
  void onClose() {
    _refreshTimer?.cancel();
    super.onClose();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(_refreshInterval, (_) => _silentRefresh());
  }

  // Тихое обновление без переключения isLoading (нет мигания UI)
  Future<void> _silentRefresh() async {
    final response = await _venueService.getVenues();
    if (response.isSuccess && response.data != null) {
      venues.assignAll(response.data!);
      error.value = '';
    }
  }

  Future<void> fetchVenues({String? sport}) async {
    isLoading.value = true;
    error.value = '';

    final response = await _venueService.getVenues(sport: sport);

    if (response.isSuccess && response.data != null) {
      venues.assignAll(response.data!);
    } else {
      error.value = response.error ?? 'Не удалось загрузить площадки';
      // Временно оставляем mock-данные при ошибке сети
      if (venues.isEmpty) venues.assignAll(MockData.venues);
    }

    isLoading.value = false;
  }
}
