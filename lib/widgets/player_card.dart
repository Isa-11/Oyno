import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/player_group_controller.dart';
import '../screens/chat_detail_screen.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';

class PlayerCard extends StatelessWidget {
  final PlayerGroup group;

  const PlayerCard({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
            children: [
              Expanded(
                child: Text(
                  group.teamName,
                  style: AppTextStyles.headingMD,
                ),
              ),
              _levelBadge(group.level),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.access_time, color: AppColors.textSecondary, size: 14),
              const SizedBox(width: 4),
              Text(group.time, style: AppTextStyles.bodySM),
              const SizedBox(width: 12),
              const Icon(Icons.location_on_outlined, color: AppColors.textSecondary, size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  group.location,
                  style: AppTextStyles.bodySM,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _neededChip(group.slotsNeeded),
              const Spacer(),
              if ((group.isJoined || group.isCreator) && group.id != null) ...[
                _chatButton(),
                const SizedBox(width: 8),
              ],
              _joinButton(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _levelBadge(String level) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.darkChip,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Text(
        level,
        style: AppTextStyles.bodySM.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _neededChip(int slots) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.4), width: 1),
      ),
      child: Text(
        'НУЖНО: $slots',
        style: AppTextStyles.accentBold.copyWith(fontSize: 12),
      ),
    );
  }

  Widget _chatButton() {
    return GestureDetector(
      onTap: () {
        final chatItem = ChatItem(
          id: group.id!,
          type: 'game',
          name: group.teamName,
          sportEmoji: group.sportEmoji,
          lastMessage: '',
          time: '',
          gameId: group.id,
        );
        Get.to(() => ChatDetailScreen(chat: chatItem));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.divider),
        ),
        child: const Icon(Icons.chat_bubble_outline,
            color: AppColors.accent, size: 18),
      ),
    );
  }

  Widget _joinButton(BuildContext context) {
    if (group.isCreator) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.divider),
        ),
        child: Text('МОЯ ИГРА', style: AppTextStyles.bodySM.copyWith(color: AppColors.textSecondary)),
      );
    }
    if (group.isJoined) {
      return GestureDetector(
        onTap: () async {
          if (group.id == null) { return; }
          final ok = await Get.find<PlayerGroupController>().leaveGame(group.id!);
          if (!ok) {
            Get.snackbar('Ошибка', 'Не удалось покинуть игру',
                backgroundColor: AppColors.dangerRed, colorText: AppColors.textPrimary,
                snackPosition: SnackPosition.TOP);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.dangerRed),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text('ВЫЙТИ', style: AppTextStyles.labelBold.copyWith(color: AppColors.dangerRed)),
        ),
      );
    }
    return GestureDetector(
      onTap: () async {
        if (group.id == null) { return; }
        final ok = await Get.find<PlayerGroupController>().joinGame(group.id!);
        if (!ok) {
          Get.snackbar('Ошибка', 'Не удалось вступить в игру',
              backgroundColor: AppColors.dangerRed, colorText: AppColors.textPrimary,
              snackPosition: SnackPosition.TOP);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text('ВОРВАТЬСЯ', style: AppTextStyles.labelBold.copyWith(color: AppColors.background)),
      ),
    );
  }
}
