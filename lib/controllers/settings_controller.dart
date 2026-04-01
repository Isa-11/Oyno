import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/settings_service.dart';

class SettingsController extends GetxController {
  final RxBool notifications = true.obs;
  final RxBool darkTheme = true.obs;
  final RxBool geolocation = false.obs;
  final RxBool privacy = true.obs;

  SettingsService get _svc => Get.find<SettingsService>();

  @override
  void onInit() {
    super.onInit();
    _loadFromPrefs();
    fetchSettings();
  }

  Future<void> fetchSettings() async {
    final res = await _svc.getSettings();
    if (!res.isSuccess || res.data == null) return;
    final d = res.data!;
    notifications.value = d.notifications;
    darkTheme.value = d.darkTheme;
    geolocation.value = d.geolocation;
    privacy.value = d.privacy;
    _saveToPrefs();
  }

  Future<void> toggle(String field, bool value) async {
    // Обновляем UI сразу
    switch (field) {
      case 'notifications':
        notifications.value = value;
      case 'dark_theme':
        darkTheme.value = value;
      case 'geolocation':
        geolocation.value = value;
      case 'privacy':
        privacy.value = value;
    }
    _saveToPrefs();
    // Отправляем на сервер (не откатываем при ошибке — настройки сохранены локально)
    await _svc.patchSettings({field: value});
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    notifications.value = prefs.getBool('setting_notifications') ?? true;
    darkTheme.value = prefs.getBool('setting_dark_theme') ?? true;
    geolocation.value = prefs.getBool('setting_geolocation') ?? false;
    privacy.value = prefs.getBool('setting_privacy') ?? true;
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('setting_notifications', notifications.value);
    await prefs.setBool('setting_dark_theme', darkTheme.value);
    await prefs.setBool('setting_geolocation', geolocation.value);
    await prefs.setBool('setting_privacy', privacy.value);
  }
}
