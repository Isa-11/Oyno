import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/game_service.dart';
import 'chat_detail_screen.dart';
import 'other_user_profile_screen.dart';

class GameDetailScreen extends StatefulWidget {
  final GameItem game;

  const GameDetailScreen({super.key, required this.game});

  @override
  State<GameDetailScreen> createState() => _GameDetailScreenState();
}

class _GameDetailScreenState extends State<GameDetailScreen> {
  bool _joined = false;
  Map<String, dynamic>? _gameDetails;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadGameDetails();
  }

  Future<void> _loadGameDetails() async {
    if (widget.game.id == null) {
      setState(() => _isLoading = false);
      return;
    }
    try {
      final res = await Get.find<GameService>().getGameDetails(widget.game.id!);
      if (res.isSuccess && res.data != null) {
        setState(() {
          _gameDetails = res.data;
          _joined = res.data?['is_joined'] as bool? ?? false;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = res.error ?? 'Ошибка загрузки игры';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Ошибка: $e';
        _isLoading = false;
      });
    }
  }

  bool get _isFinished => widget.game.status == 'ЗАВЕРШЕН';
  bool get _isConfirmed => widget.game.status == 'ПОДТВЕРЖДЕН';

  Color get _statusColor {
    if (_isFinished) return AppColors.textSecondary;
    if (_isConfirmed) return AppColors.confirmGreen;
    return AppColors.waitGray;
  }

  Future<void> _joinGame() async {
    if (widget.game.id == null) return;
    try {
      final res = await Get.find<GameService>().joinGame(widget.game.id!);
      if (res.isSuccess) {
        setState(() => _joined = true);
        Get.snackbar('Успешно', 'Вы присоединились к игре', snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar('Ошибка', res.error ?? 'Не удалось присоединиться', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Ошибка', 'Ошибка: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.accent)),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Text(_error!, style: AppTextStyles.bodySM),
        ),
      );
    }

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
    
    // Get real participants from game details if available
    final participants = _gameDetails?['participants'] as List? ?? [];

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
            children: participants.isNotEmpty
                ? participants.map((p) {
                    final username = p['username'] as String? ?? 'Unknown';
                    return GestureDetector(
                      onTap: () {
                        if (p['id'] != null) {
                          Get.to(() => OtherUserProfileScreen(
                            userId: p['id'] as int,
                            username: username,
                          ));
                        }
                      },
                      child: Container(
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
                            Text(username, style: AppTextStyles.bodySM),
                          ],
                        ),
                      ),
                    );
                  }).toList()
                : List.generate(filled, (i) {
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
                : _joinGame,
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
                chat: ChatItem(
                  id: widget.game.id ?? 0,
                  type: 'game',
                  name: widget.game.venueName,
                  sportEmoji: widget.game.sportEmoji,
                  lastMessage: '',
                  time: '',
                  gameId: widget.game.id,
                ),
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
