import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  static final List<Map<String, String>> _notifications = [
    {
      'emoji': '⚽',
      'title': 'FC ALPHA приняли вас',
      'body': 'Вы успешно вступили в команду. Игра в 18:00.',
      'time': '5 мин назад',
    },
    {
      'emoji': '⚡',
      'title': 'Игра подтверждена',
      'body': 'СПОРТКОМ АРЕНА • 24 ОКТ 20:00 — ваше место забронировано.',
      'time': '1 час назад',
    },
    {
      'emoji': '🏀',
      'title': 'BASKET KINGS ищут игрока',
      'body': 'Нужен 1 игрок на вечернюю игру. Уровень: ПРОФИ.',
      'time': '3 часа назад',
    },
    {
      'emoji': '🏐',
      'title': 'Новое сообщение в ВОЛНА',
      'body': 'Нужен ещё один игрок, пригласи друга!',
      'time': 'Вчера',
    },
    {
      'emoji': '⭐',
      'title': 'Ваш рейтинг вырос!',
      'body': 'После игры 10 ОКТ ваш рейтинг стал 4.9 ⭐',
      'time': '2 дня назад',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppBar(),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                itemCount: _notifications.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _buildItem(_notifications[i], i < 2),
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
          Text(
            'УВЕДОМЛЕНИЯ',
            style: AppTextStyles.headingLG,
          ),
          const Spacer(),
          GestureDetector(
            onTap: () async {
              final notifyService = Get.find<NotificationService>();
              await notifyService.markAllAsRead();
              notifyService.resetUnread();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
              ),
              child: Text(
                'ВСЕ ПРОЧИТАНО',
                style: AppTextStyles.accentBold.copyWith(fontSize: 11),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(Map<String, String> n, bool isNew) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isNew
            ? AppColors.accent.withValues(alpha: 0.06)
            : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isNew ? AppColors.accent.withValues(alpha: 0.3) : AppColors.divider,
          width: isNew ? 1.5 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(n['emoji']!, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        n['title']!,
                        style: AppTextStyles.labelBold,
                      ),
                    ),
                    if (isNew)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  n['body']!,
                  style: AppTextStyles.bodySM,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  n['time']!,
                  style: AppTextStyles.bodySM.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
