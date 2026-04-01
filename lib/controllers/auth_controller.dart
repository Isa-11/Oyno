import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  final RxBool isLoggedIn = false.obs;
  final RxString username = ''.obs;
  final RxString token = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('access_token') ?? '';
    final savedUsername = prefs.getString('username') ?? '';
    if (savedToken.isNotEmpty) {
      token.value = savedToken;
      username.value = savedUsername;
      isLoggedIn.value = true;
    }
  }

  Future<String?> login(String usernameInput, String password) async {
    final response = await _authService.login(
      username: usernameInput,
      password: password,
    );
    if (response.isSuccess && response.data != null) {
      await _saveSession(response.data!);
      return null;
    }
    return response.error ?? 'Ошибка входа';
  }

  Future<String?> register(String usernameInput, String email, String password) async {
    final response = await _authService.register(
      username: usernameInput,
      email: email,
      password: password,
    );
    if (response.isSuccess && response.data != null) {
      await _saveSession(response.data!);
      return null;
    }
    return response.error ?? 'Ошибка регистрации';
  }

  Future<void> _saveSession(AuthResult result) async {
    token.value = result.access;
    username.value = result.user.username;
    isLoggedIn.value = true;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', result.access);
    await prefs.setString('refresh_token', result.refresh);
    await prefs.setString('username', result.user.username);
  }

  Future<void> loginWithResult(AuthResult result) => _saveSession(result);

  Future<void> logout() async {
    token.value = '';
    username.value = '';
    isLoggedIn.value = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('username');
  }
}
