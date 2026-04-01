import 'package:get/get.dart';
import '../models/models.dart';
import '../services/chat_service.dart';

class ChatController extends GetxController {
  final ChatService _service = Get.find<ChatService>();

  final RxList<ChatItem> chats = <ChatItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

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
}
