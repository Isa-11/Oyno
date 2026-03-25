import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../screens/join_team_screen.dart';

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

  Widget _joinButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => JoinTeamScreen(group: group)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          'ВОРВАТЬСЯ',
          style: AppTextStyles.labelBold.copyWith(color: AppColors.background),
        ),
      ),
    );
  }
}
