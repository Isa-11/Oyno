import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../screens/game_detail_screen.dart';
import '../screens/chat_detail_screen.dart';

class GameCard extends StatelessWidget {
  final GameItem game;

  const GameCard({super.key, required this.game});

  IconData _sportIcon(String sport) {
    switch (sport.toLowerCase()) {
      case 'футбол': return Icons.sports_soccer;
      case 'баскетбол': return Icons.sports_basketball;
      case 'волейбол': return Icons.sports_volleyball;
      case 'теннис': return Icons.sports_tennis;
      case 'плавание': return Icons.pool;
      case 'хоккей': return Icons.sports_hockey;
      default: return Icons.sports;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isConfirmed = game.status == 'ПОДТВЕРЖДЕН';
    final isFinished = game.status == 'ЗАВЕРШЕН';

    return GestureDetector(
      onTap: () => Get.to(() => GameDetailScreen(game: game)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider, width: 0.8),
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
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined,
                              color: AppColors.textSecondary, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            game.dateTime,
                            style: AppTextStyles.bodySM.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
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
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider, width: 0.8),
                  ),
                  child: Center(
                    child: Icon(
                      _sportIcon(game.sport),
                      color: AppColors.accent,
                      size: 26,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    color: AppColors.textSecondary, size: 13),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    game.location,
                    style: AppTextStyles.bodySM.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.people_outline,
                    color: AppColors.textSecondary, size: 13),
                const SizedBox(width: 4),
                Text(
                  game.players,
                  style: AppTextStyles.bodySM.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            if (!isFinished) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Get.to(() => GameDetailScreen(game: game)),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.divider, width: 0.8),
                        ),
                        child: Center(
                          child: Text(
                            'ПОДРОБНЕЕ',
                            style: AppTextStyles.labelBold.copyWith(fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => Get.to(() => ChatDetailScreen(
                          chat: ChatItem(
                            id: 0,
                            type: 'game',
                            name: game.venueName,
                            sportEmoji: game.sportEmoji,
                            lastMessage: '',
                            time: '',
                          ),
                        )),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.chat_bubble_outline,
                        color: AppColors.background,
                        size: 18,
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
