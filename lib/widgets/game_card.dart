import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../screens/game_detail_screen.dart';
import '../screens/chat_detail_screen.dart';

class GameCard extends StatelessWidget {
  final GameItem game;

  const GameCard({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final isConfirmed = game.status == 'ПОДТВЕРЖДЕН';
    final isFinished = game.status == 'ЗАВЕРШЕН';

    return GestureDetector(
      onTap: () => Get.to(() => GameDetailScreen(game: game)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _statusBadge(isConfirmed, isFinished),
                      const SizedBox(height: 8),
                      Text(
                        game.dateTime,
                        style: AppTextStyles.bodySM,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        game.venueName,
                        style: AppTextStyles.headingMD,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Center(
                    child: Text(
                      game.sportEmoji,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    color: AppColors.textSecondary, size: 13),
                const SizedBox(width: 4),
                Text(game.location, style: AppTextStyles.bodySM),
                const SizedBox(width: 16),
                const Icon(Icons.people_outline,
                    color: AppColors.textSecondary, size: 13),
                const SizedBox(width: 4),
                Text(game.players, style: AppTextStyles.bodySM),
              ],
            ),
            if (!isFinished) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Get.to(() => GameDetailScreen(game: game)),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Center(
                          child: Text(
                            'ПОДРОБНЕЕ',
                            style: AppTextStyles.labelBold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => Get.to(() => ChatDetailScreen(
                          teamName: game.venueName,
                          sportEmoji: game.sportEmoji,
                        )),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.chat_bubble_outline,
                        color: AppColors.background,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(bool isConfirmed, bool isFinished) {
    Color bgColor;
    Color textColor;
    String text;

    if (isFinished) {
      bgColor = AppColors.divider;
      textColor = AppColors.textSecondary;
      text = 'ЗАВЕРШЕН';
    } else if (isConfirmed) {
      bgColor = AppColors.confirmGreen.withValues(alpha: 0.15);
      textColor = AppColors.confirmGreen;
      text = 'ПОДТВЕРЖДЕН';
    } else {
      bgColor = AppColors.waitGray.withValues(alpha: 0.3);
      textColor = AppColors.textSecondary;
      text = 'ОЖИДАНИЕ';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: AppTextStyles.bodySM.copyWith(
          color: textColor,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}
