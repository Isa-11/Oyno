import 'package:get/get.dart';
import 'chat_controller.dart';

class NavController extends GetxController {
  final RxInt currentIndex = 0.obs;

  void changePage(int index) {
    currentIndex.value = index;
    if (index == 2) {
      // Обновляем чаты при каждом переходе на таб чатов
      try { Get.find<ChatController>().fetchChats(); } catch (_) {}
    }
  }
}
