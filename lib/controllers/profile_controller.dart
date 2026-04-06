import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../services/notification_service.dart';
import '../services/profile_service.dart';
import '../theme/app_theme.dart';

class ProfileController extends GetxController {
  final ProfileService _service = Get.find<ProfileService>();
  final AuthController _auth = Get.find<AuthController>();

  final RxString username = ''.obs;
  final RxString email = ''.obs;
  final RxString city = ''.obs;
  final RxString avatarData = ''.obs;
  final RxDouble rating = 0.0.obs;
  final RxInt gamesTotal = 0.obs;
  final RxInt upcomingGames = 0.obs;
  final RxBool isLoading = false.obs;
  final RxBool isVendor = false.obs;
  final RxString gameLevel = ''.obs;
  final RxString position = ''.obs;
  final RxBool isOwnerMode = false.obs;

  Worker? _authWorker;

  @override
  void onInit() {
    super.onInit();
    if (_auth.token.value.isNotEmpty) {
      fetchProfile();
    } else {
      _clearProfile();
    }

    _authWorker = ever<String>(_auth.token, (token) {
      if (token.isNotEmpty) {
        fetchProfile();
      } else {
        _clearProfile();
      }
    });
  }

  @override
  void onClose() {
    _authWorker?.dispose();
    super.onClose();
  }

  void _clearProfile() {
    username.value = '';
    email.value = '';
    city.value = '';
    avatarData.value = '';
    rating.value = 0.0;
    gamesTotal.value = 0;
    upcomingGames.value = 0;
    isVendor.value = false;
    gameLevel.value = '';
    position.value = '';
    isOwnerMode.value = false;
  }

  Future<void> fetchProfile() async {
    if (_auth.token.value.isEmpty) {
      _clearProfile();
      return;
    }

    isLoading.value = true;
    final res = await _service.getProfile();
    if (res.isSuccess && res.data != null) {
      final p = res.data!;
      username.value = p.username;
      email.value = p.email;
      city.value = p.city;
      avatarData.value = p.avatarData;
      rating.value = p.rating;
      gamesTotal.value = p.gamesTotal;
      upcomingGames.value = p.upcomingGames;
      isVendor.value = p.isVendor;
      gameLevel.value = p.gameLevel;
      position.value = p.position;
    } else {
      _clearProfile();
    }
    isLoading.value = false;
    _refreshUnreadCount();
  }

  void _refreshUnreadCount() {
    try {
      final notifService = Get.find<NotificationService>();
      notifService.getNotifications().then((res) {
        if (res.isSuccess && res.data != null) {
          final unread = res.data!.where((n) => !(n['is_read'] as bool? ?? true)).length;
          notifService.unreadCount.value = unread;
        }
      });
    } catch (_) {}
  }

  Future<String?> saveProfile(
    String newUsername,
    String newEmail,
    String newCity, {
    String? newAvatarData,
    String? newGameLevel,
    String? newPosition,
  }) async {
    final res = await _service.updateProfile(
      username: newUsername.isNotEmpty ? newUsername : null,
      email: newEmail.isNotEmpty ? newEmail : null,
      city: newCity.isNotEmpty ? newCity : null,
      avatarData: newAvatarData,
      gameLevel: newGameLevel,
      position: newPosition,
    );
    if (res.isSuccess && res.data != null) {
      final p = res.data!;
      username.value = p.username;
      email.value = p.email;
      city.value = p.city;
      avatarData.value = p.avatarData;
      rating.value = p.rating;
      gameLevel.value = p.gameLevel;
      position.value = p.position;
      // Синхронизируем с AuthController
      Get.find<AuthController>().username.value = p.username;
      return null;
    }
    return res.error ?? 'Ошибка сохранения';
  }

  Future<void> toggleOwnerMode(bool value) async {
    if (!value) {
      isOwnerMode.value = false;
      return;
    }

    if (!isVendor.value) {
      final res = await _service.updateProfile(isVendor: true);
      if (!res.isSuccess || res.data == null) {
        Get.snackbar(
          'Ошибка',
          res.error ?? 'Не удалось включить режим владельца',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.cardBackground,
          colorText: AppColors.textPrimary,
        );
        return;
      }

      final p = res.data!;
      username.value = p.username;
      email.value = p.email;
      city.value = p.city;
      avatarData.value = p.avatarData;
      rating.value = p.rating;
      gamesTotal.value = p.gamesTotal;
      upcomingGames.value = p.upcomingGames;
      isVendor.value = p.isVendor;
      gameLevel.value = p.gameLevel;
      position.value = p.position;
    }

    isOwnerMode.value = true;
  }
}
