import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';
import '../controllers/venue_controller.dart';
import '../controllers/player_group_controller.dart';
import '../widgets/sport_filter_chips.dart';
import '../widgets/player_card.dart';
import '../widgets/venue_card.dart';
import 'notification_screen.dart';
import 'create_game_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildSearchBar()),
            SliverToBoxAdapter(child: _buildCreateGameButton()),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Column(
                  children: [SportFilterChips()],
                ),
              ),
            ),
            SliverToBoxAdapter(child: _buildSectionTitle('👥 НАБОР ИГРОКОВ')),
            SliverToBoxAdapter(child: _buildPlayersList()),
            SliverToBoxAdapter(child: _buildSectionTitle('⚡ ПЛОЩАДКИ')),
            SliverToBoxAdapter(child: _buildVenuesList()),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
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
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'BISHKEK ',
                    style: AppTextStyles.headingXL,
                  ),
                  TextSpan(
                    text: 'SPORT',
                    style: AppTextStyles.headingXL.copyWith(color: AppColors.accent),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () => Get.to(() => const NotificationScreen()),
            child: Stack(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: const Icon(
                    Icons.notifications_outlined,
                    color: AppColors.textPrimary,
                    size: 22,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            const Icon(Icons.search, color: AppColors.textSecondary, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Поиск игры или площадки...',
                style: AppTextStyles.bodySM,
              ),
            ),
            Container(
              margin: const EdgeInsets.all(6),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.tune, color: AppColors.background, size: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateGameButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: GestureDetector(
        onTap: () => Get.to(() => const CreateGameScreen()),
        child: Container(
          height: 62,
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.accent,
              width: 2,
            ),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: AppColors.background, size: 18),
                ),
                const SizedBox(width: 12),
                Text(
                  'СОЗДАТЬ СВОЮ ИГРУ',
                  style: AppTextStyles.headingMD.copyWith(color: AppColors.accent),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
      child: Text(
        title,
        style: AppTextStyles.headingMD,
      ),
    );
  }

  Widget _buildPlayersList() {
    final controller = Get.find<PlayerGroupController>();
    return Obx(() {
      if (controller.isLoading.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(child: CircularProgressIndicator(color: AppColors.accent)),
        );
      }
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: controller.groups.map((g) => PlayerCard(group: g)).toList(),
        ),
      );
    });
  }

  Widget _buildVenuesList() {
    final controller = Get.find<VenueController>();
    return Obx(() {
      if (controller.isLoading.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          ),
        );
      }
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: controller.venues.map((v) => VenueCard(venue: v)).toList(),
        ),
      );
    });
  }
}
