import 'package:get/get.dart';
import 'dart:async';
import '../models/models.dart';
import '../services/chat_service.dart';

class ChatController extends GetxController {
  final ChatService _service = Get.find<ChatService>();

  final RxList<ChatItem> chats = <ChatItem>[].obs;
  final RxList<ChatUserSearch> foundUsers = <ChatUserSearch>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSearchingUsers = false.obs;
  final RxString error = ''.obs;
  final RxString searchQuery = ''.obs;

  Timer? _searchDebounce;

  @override
  void onInit() {
    super.onInit();
    fetchChats();
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
    super.onClose();
  }
}
