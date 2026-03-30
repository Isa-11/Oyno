import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';
import '../controllers/game_controller.dart';
import '../models/models.dart' show GameItem;
import '../widgets/game_card.dart';
import 'create_game_screen.dart';

class GamesScreen extends StatefulWidget {
  const GamesScreen({super.key});

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildTabBar(),
            const SizedBox(height: 4),
            Expanded(
              child: Obx(() {
                final ctrl = Get.find<GameController>();
                if (ctrl.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.accent),
                  );
                }
                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildGamesList(ctrl.upcoming),
                    _buildGamesList(ctrl.history),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Row(
        children: [
          Expanded(
            child: Text('МОИ ИГРЫ', style: AppTextStyles.headingXL),
          ),
          GestureDetector(
            onTap: () => Get.to(() => const CreateGameScreen()),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add, color: AppColors.background, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'ИГРА',
                    style: AppTextStyles.labelBold.copyWith(color: AppColors.background),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _tabItem('ПРЕДСТОЯЩИЕ', 0),
          const SizedBox(width: 24),
          _tabItem('ИСТОРИЯ', 1),
        ],
      ),
    );
  }

  Widget _tabItem(String label, int index) {
    final isActive = _tabController.index == index;
    return GestureDetector(
      onTap: () => _tabController.animateTo(index),
      child: Column(
        children: [
          Text(
            label,
            style: AppTextStyles.labelBold.copyWith(
              color: isActive ? AppColors.accent : AppColors.textSecondary,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 6),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 2.5,
            width: isActive ? label.length * 8.0 : 0,
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGamesList(List<GameItem> games) {
    if (games.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🏟️', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              'Нет игр',
              style: AppTextStyles.bodyMD.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      itemCount: games.length,
      itemBuilder: (_, i) => GameCard(game: games[i]),
    );
  }
}
