import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../services/auth_storage.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  final RxBool isLoggedIn = false.obs;
  final RxString username = ''.obs;
  final RxString token = ''.obs;

  int _sessionRevision = 0;

  @override
  void onInit() {
    super.onInit();
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    final rev = _sessionRevision;
    final savedToken = await AuthStorage.readAccessToken();
    final savedUsername = await AuthStorage.readUsername();

    // Ignore stale load result if auth state changed while reading storage.
    if (rev != _sessionRevision) return;

    if (savedToken.isNotEmpty) {
      token.value = savedToken;
      username.value = savedUsername;
      isLoggedIn.value = true;
    }
  }

  Future<String?> login(String usernameInput, String password) async {
    // Always start a fresh auth attempt to prevent stale account state.
    await _clearSession();

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
    _sessionRevision++;
    token.value = result.access;
    username.value = result.user.username;
    isLoggedIn.value = true;
    await AuthStorage.writeSession(
      access: result.access,
      refresh: result.refresh,
      username: result.user.username,
    );
  }

  Future<void> loginWithResult(AuthResult result) => _saveSession(result);

  Future<void> logout() async {
    await _clearSession();
  }

  Future<void> _clearSession() async {
    _sessionRevision++;
    token.value = '';
    username.value = '';
    isLoggedIn.value = false;
    await AuthStorage.clearSession();
  }
}
