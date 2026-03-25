import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import 'chat_detail_screen.dart';

class GameDetailScreen extends StatefulWidget {
  final GameItem game;

  const GameDetailScreen({super.key, required this.game});

  @override
  State<GameDetailScreen> createState() => _GameDetailScreenState();
}

class _GameDetailScreenState extends State<GameDetailScreen> {
  bool _joined = false;

  bool get _isFinished => widget.game.status == 'ЗАВЕРШЕН';
  bool get _isConfirmed => widget.game.status == 'ПОДТВЕРЖДЕН';

  Color get _statusColor {
    if (_isFinished) return AppColors.textSecondary;
    if (_isConfirmed) return AppColors.confirmGreen;
    return AppColors.waitGray;
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHero(),
                    const SizedBox(height: 20),
                    _buildDetails(),
                    const SizedBox(height: 20),
                    _buildPlayers(),
                    if (!_isFinished) ...[
                      const SizedBox(height: 28),
                      _buildActions(),
                    ],
                    const SizedBox(height: 20),
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
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
          Text('ДЕТАЛИ ИГРЫ', style: AppTextStyles.headingMD),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: _statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _statusColor.withValues(alpha: 0.5)),
            ),
            child: Text(
              widget.game.status,
              style: AppTextStyles.bodySM.copyWith(
                color: _statusColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Text(widget.game.sportEmoji, style: const TextStyle(fontSize: 60)),
          const SizedBox(height: 14),
          Text(
            widget.game.venueName,
            style: AppTextStyles.headingXL.copyWith(color: AppColors.accent),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(widget.game.sport, style: AppTextStyles.bodySM),
        ],
      ),
    );
  }

  Widget _buildDetails() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          _detailRow(Icons.calendar_today_outlined, 'ДАТА И ВРЕМЯ', widget.game.dateTime),
          _sep(),
          _detailRow(Icons.location_on_outlined, 'АДРЕС', widget.game.location),
          _sep(),
          _detailRow(Icons.people_outline, 'ИГРОКИ', widget.game.players),
          _sep(),
          _detailRow(Icons.sports_outlined, 'ВИД СПОРТА', widget.game.sport),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.accent, size: 18),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.bodySM.copyWith(fontSize: 11)),
              const SizedBox(height: 2),
              Text(value, style: AppTextStyles.labelBold),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sep() => const Divider(color: AppColors.divider, height: 1);

  Widget _buildPlayers() {
    final parts = widget.game.players.split('/');
    final filled = int.tryParse(parts[0]) ?? 0;
    final total = int.tryParse(parts[1]) ?? 10;

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
              Text('СОСТАВ ИГРОКОВ', style: AppTextStyles.headingMD),
              Text(widget.game.players, style: AppTextStyles.accentBold),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(total, (i) {
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  height: 8,
                  decoration: BoxDecoration(
                    color: i < filled ? AppColors.accent : AppColors.surface,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(filled, (i) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🏃', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text('Игрок ${i + 1}', style: AppTextStyles.bodySM),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _joined
                ? null
                : () => setState(() => _joined = true),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: _joined ? AppColors.confirmGreen.withValues(alpha: 0.15) : AppColors.accent,
                borderRadius: BorderRadius.circular(14),
                border: _joined
                    ? Border.all(color: AppColors.confirmGreen, width: 1.5)
                    : null,
              ),
              child: Center(
                child: Text(
                  _joined ? '✓ ВЫ УЧАСТВУЕТЕ' : '⚡ ПРИСОЕДИНИТЬСЯ',
                  style: AppTextStyles.headingMD.copyWith(
                    color: _joined ? AppColors.confirmGreen : AppColors.background,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () => Get.to(() => ChatDetailScreen(
                teamName: widget.game.venueName,
                sportEmoji: widget.game.sportEmoji,
              )),
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.divider),
            ),
            child: const Icon(Icons.chat_bubble_outline,
                color: AppColors.accent, size: 22),
          ),
        ),
      ],
    );
  }
}
