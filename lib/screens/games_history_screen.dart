import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/game_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import '../widgets/game_card.dart';
import '../widgets/shimmer_loader.dart';

class GamesHistoryScreen extends StatefulWidget {
  const GamesHistoryScreen({super.key});

  @override
  State<GamesHistoryScreen> createState() => _GamesHistoryScreenState();
}

class _GamesHistoryScreenState extends State<GamesHistoryScreen> {
  @override
  void initState() {
    super.initState();
    Get.find<GameController>().fetchAll();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<GameController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('История игр', style: AppTextStyles.headingMD),
      ),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const ShimmerLoader(itemCount: 4, itemHeight: 96);
        }
        if (ctrl.error.value.isNotEmpty) {
          return ErrorState(
            message: ctrl.error.value,
            onRetry: ctrl.fetchAll,
          );
        }
        if (ctrl.history.isEmpty) {
          return const EmptyState(
            icon: Icons.history,
            message: 'История пуста',
            subtitle: 'Сыграйте матч, чтобы увидеть историю',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          itemCount: ctrl.history.length,
          itemBuilder: (_, i) => GameCard(game: ctrl.history[i]),
        );
      }),
    );
  }
}
