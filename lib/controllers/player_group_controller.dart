import 'package:get/get.dart';
import '../models/models.dart';
import '../services/game_service.dart';

class PlayerGroupController extends GetxController {
  final GameService _service = Get.find<GameService>();

  final RxList<PlayerGroup> groups = <PlayerGroup>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchGroups();
  }

  Future<void> fetchGroups({String? sport}) async {
    isLoading.value = true;
    error.value = '';
    final res = await _service.getOpenGames(sport: sport);
    if (res.isSuccess && res.data != null) {
      groups.assignAll(res.data!);
    } else {
      error.value = res.error ?? 'Не удалось загрузить игроков';
    }
    isLoading.value = false;
  }

  Future<bool> joinGame(int gameId) async {
    final res = await _service.joinGame(gameId);
    if (res.isSuccess) {
      await fetchGroups();
      return true;
    }
    return false;
  }

  Future<bool> leaveGame(int gameId) async {
    final res = await _service.leaveGame(gameId);
    if (res.isSuccess) {
      await fetchGroups();
      return true;
    }
    return false;
  }
}
