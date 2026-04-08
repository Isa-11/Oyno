import 'package:get/get.dart';
import 'dart:async';
import '../controllers/auth_controller.dart';
import '../models/models.dart';
import '../services/chat_service.dart';
import '../services/notification_service.dart';

class ChatController extends GetxController {
  final ChatService _service = Get.find<ChatService>();

  final RxList<ChatItem> chats = <ChatItem>[].obs;
  final RxList<ChatUserSearch> foundUsers = <ChatUserSearch>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSearchingUsers = false.obs;
  final RxString error = ''.obs;
  final RxString searchQuery = ''.obs;

  Timer? _searchDebounce;
  Worker? _authWorker;

  @override
  void onInit() {
    super.onInit();
    final auth = Get.find<AuthController>();
    if (auth.token.value.isNotEmpty) {
      fetchChats();
    }
    _authWorker = ever<String>(auth.token, (token) {
      if (token.isNotEmpty) {
        fetchChats();
      } else {
        chats.clear();
        foundUsers.clear();
        error.value = '';
        try {
          Get.find<NotificationService>().resetUnread();
        } catch (_) {}
      }
    });
  }

  Future<void> fetchChats() async {
    isLoading.value = true;
    error.value = '';
    final res = await _service.getChats();
    if (res.isSuccess && res.data != null) {
      chats.assignAll(res.data!);
    } else {
      error.value = res.error ?? 'Не удалось загрузить чаты';
    }
    isLoading.value = false;
  }

  void onSearchChanged(String value) {
    final query = value.trim();
    searchQuery.value = query;
    _searchDebounce?.cancel();

    if (query.isEmpty) {
      foundUsers.clear();
      isSearchingUsers.value = false;
      return;
    }

    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      searchUsers(query);
    });
  }

  Future<void> searchUsers(String query) async {
    if (query.isEmpty) {
      foundUsers.clear();
      return;
    }

    isSearchingUsers.value = true;
    final res = await _service.searchUsers(query);
    if (searchQuery.value != query) {
      isSearchingUsers.value = false;
      return;
    }

    if (res.isSuccess && res.data != null) {
      foundUsers.assignAll(res.data!);
    } else {
      foundUsers.clear();
    }
    isSearchingUsers.value = false;
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    _authWorker?.dispose();
    super.onClose();
  }
}
