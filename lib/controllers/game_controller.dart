import 'package:get/get.dart';
import '../models/models.dart';
import '../services/game_service.dart';

class GameController extends GetxController {
  final GameService _gameService = Get.find<GameService>();

  final RxList<GameItem> upcoming = <GameItem>[].obs;
  final RxList<GameItem> history = <GameItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAll();
  }

  Future<void> fetchAll() async {
    isLoading.value = true;
    error.value = '';

    final upRes = await _gameService.getUpcomingGames();
    if (upRes.isSuccess && upRes.data != null) {
      upcoming.assignAll(upRes.data!);
    } else {
      if (upcoming.isEmpty) upcoming.assignAll(MockData.upcomingGames);
    }

    final hiRes = await _gameService.getHistoryGames();
    if (hiRes.isSuccess && hiRes.data != null) {
      history.assignAll(hiRes.data!);
    } else {
      if (history.isEmpty) history.assignAll(MockData.historyGames);
    }

    isLoading.value = false;
  }
}
