import 'package:get/get.dart';
import '../models/models.dart';
import '../services/chat_service.dart';

class ChatController extends GetxController {
  final ChatService _service = Get.find<ChatService>();

  final RxList<ChatItem> chats = <ChatItem>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchChats();
  }

  Future<void> fetchChats() async {
    isLoading.value = true;
    final res = await _service.getChats();
    if (res.isSuccess && res.data != null) {
      chats.assignAll(res.data!);
    } else {
      if (chats.isEmpty) chats.assignAll(MockData.chats);
    }
    isLoading.value = false;
  }
}
