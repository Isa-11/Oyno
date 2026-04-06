import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';
import '../controllers/venue_controller.dart';
import '../services/notification_service.dart';
import '../widgets/venue_card.dart';
import '../widgets/shimmer_loader.dart';
import '../widgets/empty_state.dart';
import 'notification_screen.dart';
import 'search_screen.dart';
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
            SliverToBoxAdapter(child: _buildCreateGameButton()),
            SliverToBoxAdapter(child: _buildSectionTitle('РЕКОМЕНДУЕМ СЕГОДНЯ')),
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
            onTap: () => Get.to(() => const SearchScreen()),
            child: Container(
              width: 44,
              height: 44,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: const Icon(Icons.search, color: AppColors.textPrimary, size: 22),
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
                Obx(() {
                  final notifyService = Get.find<NotificationService>();
                  if (notifyService.unreadCount.value > 0) {
                    return Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${notifyService.unreadCount.value}',
                            style: const TextStyle(
                              color: AppColors.background,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  return Positioned(
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
                  );
                }),
              ],
            ),
          ),
        ],
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

  Widget _buildVenuesList() {
    final controller = Get.find<VenueController>();
    return Obx(() {
      if (controller.isLoading.value) {
        return const ShimmerLoader(itemCount: 2, itemHeight: 120);
      }
      if (controller.venues.isEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: EmptyState(
            icon: Icons.sports_outlined,
            message: 'Площадки не найдены',
          ),
        );
      }
      final featured = controller.venues.take(2).toList();
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: featured.map((v) => VenueCard(venue: v)).toList(),
        ),
      );
    });
  }
}
