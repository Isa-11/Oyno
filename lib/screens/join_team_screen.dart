import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../controllers/player_group_controller.dart';

class JoinTeamScreen extends StatefulWidget {
  final PlayerGroup group;

  const JoinTeamScreen({super.key, required this.group});

  @override
  State<JoinTeamScreen> createState() => _JoinTeamScreenState();
}

class _JoinTeamScreenState extends State<JoinTeamScreen> {
  bool _joined = false;
  bool _loading = false;

  String get _sportEmoji {
    switch (widget.group.sport) {
      case 'Баскетбол':
        return '🏀';
      case 'Волейбол':
        return '🏐';
      case 'Плавание':
        return '🏊';
      default:
        return '⚽';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildTeamHero(),
                    const SizedBox(height: 24),
                    _buildInfoCards(),
                    const SizedBox(height: 24),
                    _buildPlayersSlots(),
                    const SizedBox(height: 32),
                    if (!_joined) _buildJoinButton() else _buildJoinedState(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  color: AppColors.textPrimary, size: 18),
            ),
          ),
          const SizedBox(width: 16),
          Text('ВСТУПЛЕНИЕ В КОМАНДУ', style: AppTextStyles.headingMD),
        ],
      ),
    );
  }

  Widget _buildTeamHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Column(
        children: [
          Text(_sportEmoji, style: const TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text(
            widget.group.teamName,
            style: AppTextStyles.headingXL.copyWith(color: AppColors.accent),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.divider),
            ),
            child: Text(
              widget.group.level,
              style: AppTextStyles.labelBold.copyWith(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCards() {
    return Row(
      children: [
        _infoCard('🕐', 'ВРЕМЯ', widget.group.time),
        const SizedBox(width: 12),
        _infoCard('📍', 'МЕСТО', widget.group.location),
        const SizedBox(width: 12),
        _infoCard('⚡', 'МЕСТ', '${widget.group.slotsNeeded} СВОБ.'),
      ],
    );
  }

  Widget _infoCard(String emoji, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTextStyles.labelBold.copyWith(fontSize: 12),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(label, style: AppTextStyles.bodySM.copyWith(fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayersSlots() {
    const totalSlots = 10;
    final filledSlots = totalSlots - widget.group.slotsNeeded;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('ИГРОКИ', style: AppTextStyles.labelBold),
              Text(
                '$filledSlots/$totalSlots',
                style: AppTextStyles.accentBold,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: List.generate(totalSlots, (i) {
              final isFilled = i < filledSlots;
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  height: 8,
                  decoration: BoxDecoration(
                    color: isFilled ? AppColors.accent : AppColors.surface,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Text(
            'Свободных мест: ${widget.group.slotsNeeded}',
            style: AppTextStyles.bodySM,
          ),
        ],
      ),
    );
  }

  Widget _buildJoinButton() {
    return GestureDetector(
      onTap: _loading ? null : () async {
        if (widget.group.id == null) return;
        setState(() => _loading = true);
        final ok = await Get.find<PlayerGroupController>().joinGame(widget.group.id!);
        if (!mounted) return;
        if (ok) {
          setState(() { _joined = true; _loading = false; });
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) Get.back();
          });
        } else {
          setState(() => _loading = false);
          Get.snackbar(
            'Ошибка',
            'Не удалось вступить в команду',
            backgroundColor: AppColors.dangerRed,
            colorText: AppColors.textPrimary,
            snackPosition: SnackPosition.TOP,
          );
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: _loading ? AppColors.surface : AppColors.accent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: _loading
              ? const SizedBox(
                  width: 22, height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.background),
                )
              : Text(
                  '⚡  ВОРВАТЬСЯ В КОМАНДУ',
                  style: AppTextStyles.headingMD.copyWith(color: AppColors.background),
                ),
        ),
      ),
    );
  }

  Widget _buildJoinedState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.confirmGreen.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.confirmGreen, width: 1.5),
      ),
      child: Center(
        child: Text(
          '✓  ВЫ ВСТУПИЛИ В КОМАНДУ!',
          style: AppTextStyles.headingMD.copyWith(color: AppColors.confirmGreen),
        ),
      ),
    );
  }
}
