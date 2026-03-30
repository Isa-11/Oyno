import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../services/profile_service.dart';

class ProfileController extends GetxController {
  final ProfileService _service = Get.find<ProfileService>();

  final RxString username = ''.obs;
  final RxString email = ''.obs;
  final RxInt gamesTotal = 0.obs;
  final RxInt upcomingGames = 0.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    isLoading.value = true;
    final res = await _service.getProfile();
    if (res.isSuccess && res.data != null) {
      final p = res.data!;
      username.value = p.username;
      email.value = p.email;
      gamesTotal.value = p.gamesTotal;
      upcomingGames.value = p.upcomingGames;
    }
    isLoading.value = false;
  }

  Future<String?> saveProfile(String newUsername, String newEmail) async {
    final res = await _service.updateProfile(
      username: newUsername.isNotEmpty ? newUsername : null,
      email: newEmail.isNotEmpty ? newEmail : null,
    );
    if (res.isSuccess && res.data != null) {
      final p = res.data!;
      username.value = p.username;
      email.value = p.email;
      // Синхронизируем с AuthController
      Get.find<AuthController>().username.value = p.username;
      return null;
    }
    return res.error ?? 'Ошибка сохранения';
  }
}
