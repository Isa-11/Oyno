import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildAvatarSection(),
              const SizedBox(height: 20),
              _buildStatsRow(),
              const SizedBox(height: 28),
              _buildMenuSection(context),
              const SizedBox(height: 20),
              _buildLogoutButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Text('ПРОФИЛЬ', style: AppTextStyles.headingXL),
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: const Icon(Icons.share_outlined,
              color: AppColors.textPrimary, size: 20),
        ),
      ],
    );
  }

  Widget _buildAvatarSection() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.accent, width: 3),
                color: AppColors.cardBackground,
              ),
              child: const ClipOval(
                child: Center(
                  child: Text('🏃', style: TextStyle(fontSize: 44)),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.background, width: 2),
                ),
                child: const Center(
                  child: Text('⚡', style: TextStyle(fontSize: 14)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text('ИСХАК', style: AppTextStyles.headingXL),
        const SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_on, color: AppColors.textSecondary, size: 14),
            const SizedBox(width: 4),
            Text('БИШКЕК, КР', style: AppTextStyles.bodySM),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.accent, width: 1.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'ПРОДВИНУТЫЙ ИГРОК',
            style: AppTextStyles.accentBold,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          _statItem('42', 'МАТЧИ', '🏆'),
          _verticalDivider(),
          _statItem('4.9', 'РЕЙТИНГ', '⭐'),
          _verticalDivider(),
          _statItem('98%', 'НАДЁЖНОСТЬ', '🎯'),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label, String emoji) {
    return Expanded(
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 6),
          Text(value, style: AppTextStyles.headingLG.copyWith(color: AppColors.accent)),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.bodySM.copyWith(fontSize: 10)),
        ],
      ),
    );
  }

  Widget _verticalDivider() {
    return Container(width: 1, height: 52, color: AppColors.divider);
  }

  Widget _buildMenuSection(BuildContext context) {
    return Column(
      children: [
        _menuItem(
          icon: Icons.person_outline,
          label: 'РЕДАКТИРОВАТЬ ПРОФИЛЬ',
          onTap: () => _showSimpleSheet(context, 'РЕДАКТИРОВАТЬ ПРОФИЛЬ', '✏️',
              'Изменение данных профиля будет доступно в следующей версии.'),
        ),
        _menuItem(
          icon: Icons.credit_card,
          label: 'VISA .... 4242',
          sublabel: 'Основная карта',
          onTap: () => _showSimpleSheet(context, 'ПЛАТЁЖНАЯ КАРТА', '💳',
              'Управление картами доступно в следующей версии.'),
        ),
        _menuItem(
          icon: Icons.stadium_outlined,
          label: 'МОИ ПЛОЩАДКИ',
          onTap: () => _showSimpleSheet(context, 'МОИ ПЛОЩАДКИ', '🏟️',
              'У вас пока нет своих площадок. Добавьте площадку для аренды.'),
        ),
        _menuItem(
          icon: Icons.settings_outlined,
          label: 'НАСТРОЙКИ',
          onTap: () => _showSettingsSheet(context),
          isLast: true,
        ),
      ],
    );
  }

  void _showSimpleSheet(
      BuildContext context, String title, String emoji, String body) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(title, style: AppTextStyles.headingMD),
            const SizedBox(height: 12),
            Text(body,
                style: AppTextStyles.bodySM, textAlign: TextAlign.center),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Center(
                  child: Text('ЗАКРЫТЬ', style: AppTextStyles.labelBold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettingsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text('НАСТРОЙКИ', style: AppTextStyles.headingMD),
            const SizedBox(height: 20),
            ...[
              ('🔔', 'Уведомления', true),
              ('🌙', 'Тёмная тема', true),
              ('📍', 'Геолокация', false),
              ('🔒', 'Приватность', true),
            ].map((item) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      Text(item.$1, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(item.$2, style: AppTextStyles.labelBold),
                      ),
                      Switch(
                        value: item.$3,
                        onChanged: (_) {},
                        activeThumbColor: AppColors.accent,
                        activeTrackColor:
                            AppColors.accent.withValues(alpha: 0.3),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String label,
    String? sublabel,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.vertical(
            top: label == 'РЕДАКТИРОВАТЬ ПРОФИЛЬ'
                ? const Radius.circular(16)
                : Radius.zero,
            bottom: isLast ? const Radius.circular(16) : Radius.zero,
          ),
          border: Border(
            top: Border.all(color: AppColors.divider, width: 1).top,
            left: Border.all(color: AppColors.divider, width: 1).left,
            right: Border.all(color: AppColors.divider, width: 1).right,
            bottom: isLast
                ? Border.all(color: AppColors.divider, width: 1).bottom
                : BorderSide.none,
          ),
        ),
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTextStyles.labelBold),
                  if (sublabel != null) ...[
                    const SizedBox(height: 2),
                    Text(sublabel, style: AppTextStyles.bodySM),
                  ],
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                color: AppColors.textSecondary, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () => showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: AppColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.divider),
          ),
          title: Text('ВЫЙТИ?', style: AppTextStyles.headingMD),
          content: Text(
            'Вы уверены, что хотите выйти из профиля?',
            style: AppTextStyles.bodySM,
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('ОТМЕНА',
                  style: AppTextStyles.labelBold
                      .copyWith(color: AppColors.textSecondary)),
            ),
            TextButton(
              onPressed: () => Get.back(),
              child: Text('ВЫЙТИ',
                  style: AppTextStyles.labelBold
                      .copyWith(color: AppColors.dangerRed)),
            ),
          ],
        ),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.dangerRed, width: 1.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Text(
            'ВЫЙТИ ИЗ ПРОФИЛЯ',
            style: AppTextStyles.labelBold.copyWith(color: AppColors.dangerRed),
          ),
        ),
      ),
    );
  }
}
