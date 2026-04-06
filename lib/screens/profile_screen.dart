import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/auth_controller.dart';
import '../controllers/nav_controller.dart';
import '../controllers/profile_controller.dart';
import '../controllers/settings_controller.dart';
import '../theme/app_theme.dart';
import 'games_history_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  ProfileController get _ctrl => Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Obx(() {
          if (_ctrl.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
            child: Column(
              children: [
                _buildHeader(context),
                const SizedBox(height: 20),
                _buildAvatarSection(context),
                const SizedBox(height: 20),
                _buildStatsRow(),
                const SizedBox(height: 28),
                _buildMenuSection(context),
                const SizedBox(height: 20),
                _buildLogoutButton(context),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text('ПРОФИЛЬ', style: AppTextStyles.headingXL)),
        GestureDetector(
          onTap: () => _showEditSheet(context),
          child: Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: const Icon(Icons.edit_outlined,
                color: AppColors.accent, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarSection(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.accent, width: 3),
                color: AppColors.cardBackground,
              ),
              child: ClipOval(
                child: Center(
                  child: Obx(() {
                    final name = _ctrl.username.value;
                    final avatar = _ctrl.avatarData.value;
                    if (avatar.isNotEmpty && avatar.contains(',')) {
                      final raw = avatar.split(',').last;
                      try {
                        return Image.memory(base64Decode(raw), fit: BoxFit.cover);
                      } catch (_) {}
                    }
                    return Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: AppTextStyles.headingXL.copyWith(fontSize: 40));
                  }),
                ),
              ),
            ),
            Positioned(
              bottom: 0, right: 0,
              child: Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.background, width: 2),
                ),
                child: const Icon(Icons.photo_camera, size: 14, color: AppColors.background),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Obx(() => Text(
              _ctrl.username.value.toUpperCase(),
              style: AppTextStyles.headingXL,
            )),
        const SizedBox(height: 4),
        Obx(() => _ctrl.email.value.isNotEmpty
            ? Text(_ctrl.email.value, style: AppTextStyles.bodySM)
            : const SizedBox.shrink()),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_on, color: AppColors.textSecondary, size: 14),
            const SizedBox(width: 4),
            Obx(() => Text(
                  _ctrl.city.value.isNotEmpty ? _ctrl.city.value : 'Бишкек',
                  style: AppTextStyles.bodySM,
                )),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.accent, width: 1.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Obx(() => Text(
                'РЕЙТИНГ ${_ctrl.rating.value.toStringAsFixed(1)}',
                style: AppTextStyles.accentBold,
              )),
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
          Obx(() => _statItem(
                _ctrl.gamesTotal.value.toString(),
                'МАТЧИ', Icons.sports_soccer)),
          _verticalDivider(),
          Obx(() => _statItem(
                _ctrl.upcomingGames.value.toString(),
                'БЛИЖАЙШИЕ', Icons.event)),
          _verticalDivider(),
          Obx(() => _statItem(
                _ctrl.rating.value.toStringAsFixed(1),
                'РЕЙТИНГ', Icons.star_half,
              )),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 18),
          const SizedBox(height: 6),
          Text(value,
              style: AppTextStyles.headingLG.copyWith(color: AppColors.accent)),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.bodySM.copyWith(fontSize: 10)),
        ],
      ),
    );
  }

  Widget _verticalDivider() =>
      Container(width: 1, height: 52, color: AppColors.divider);

  Widget _buildMenuSection(BuildContext context) {
    return Column(
      children: [
        _menuItem(
          icon: Icons.person_outline,
          label: 'РЕДАКТИРОВАТЬ ПРОФИЛЬ',
          onTap: () => _showEditSheet(context),
        ),
        _menuItem(
          icon: Icons.history,
          label: 'ИСТОРИЯ ИГР',
          onTap: () => Get.to(() => const GamesHistoryScreen()),
        ),
        _menuItem(
          icon: Icons.chat_bubble_outline,
          label: 'МОИ ЧАТЫ',
          onTap: () {
            Get.find<NavController>().changePage(2);
          },
        ),
        _menuItem(
          icon: Icons.settings_outlined,
          label: 'НАСТРОЙКИ',
          onTap: () => _showSettingsSheet(context),
        ),
        _buildOwnerModeSwitch(),
      ],
    );
  }

  Widget _buildOwnerModeSwitch() {
    return Obx(() {
      final ctrl = _ctrl;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
          border: Border(
            left: Border.all(color: AppColors.divider).left,
            right: Border.all(color: AppColors.divider).right,
            bottom: Border.all(color: AppColors.divider).bottom,
          ),
        ),
        child: SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Row(
            children: [
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.store_outlined,
                  color: ctrl.isVendor.value
                      ? AppColors.accent
                      : AppColors.textSecondary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('РЕЖИМ ВЛАДЕЛЬЦА', style: AppTextStyles.labelBold),
                  Text(
                    ctrl.isVendor.value
                        ? 'Управляйте своими площадками'
                        : 'Недоступно для вашего аккаунта',
                    style: AppTextStyles.bodySM.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          value: ctrl.isOwnerMode.value,
          onChanged: ctrl.isVendor.value ? ctrl.toggleOwnerMode : null,
          activeThumbColor: AppColors.accent,
          activeTrackColor: AppColors.accent.withValues(alpha: 0.3),
          inactiveThumbColor: AppColors.textSecondary,
          inactiveTrackColor: AppColors.surface,
        ),
      );
    });
  }

  void _showEditSheet(BuildContext context) {
    final ctrl = Get.find<ProfileController>();
    final nameCtrl = TextEditingController(text: ctrl.username.value);
    final emailCtrl = TextEditingController(text: ctrl.email.value);
    final cityCtrl = TextEditingController(text: ctrl.city.value);
    final saving = false.obs;
    final error = ''.obs;
    final avatarData = ''.obs;
    final selectedLevel = ctrl.gameLevel.value.obs;
    final selectedPosition = ctrl.position.value.obs;

    const levels = ['Новичок', 'Любитель', 'Профи'];
    const positions = ['Вратарь', 'Защитник', 'Полузащитник', 'Нападающий'];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('РЕДАКТИРОВАТЬ', style: AppTextStyles.headingMD),
            const SizedBox(height: 20),
            _inputField('ИМЯ ПОЛЬЗОВАТЕЛЯ', nameCtrl,
                hint: 'Введите имя...'),
            const SizedBox(height: 12),
            _inputField('EMAIL', emailCtrl,
                hint: 'Введите email...', keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 12),
            _inputField('ГОРОД', cityCtrl,
                hint: 'Введите город...'),
            const SizedBox(height: 16),
            _chipSectionLabel('УРОВЕНЬ ИГРЫ'),
            const SizedBox(height: 8),
            Obx(() => Wrap(
              spacing: 8,
              children: levels.map((lvl) {
                final isSelected = selectedLevel.value == lvl;
                return ChoiceChip(
                  label: Text(lvl),
                  selected: isSelected,
                  onSelected: (_) => selectedLevel.value = lvl,
                  selectedColor: AppColors.accent,
                  backgroundColor: AppColors.surface,
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.background : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  side: BorderSide(
                    color: isSelected ? AppColors.accent : AppColors.divider,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              }).toList(),
            )),
            const SizedBox(height: 16),
            _chipSectionLabel('ПОЗИЦИЯ (ФУТБОЛ)'),
            const SizedBox(height: 8),
            Obx(() => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: positions.map((pos) {
                final isSelected = selectedPosition.value == pos;
                return ChoiceChip(
                  label: Text(pos),
                  selected: isSelected,
                  onSelected: (_) => selectedPosition.value = pos,
                  selectedColor: AppColors.accent,
                  backgroundColor: AppColors.surface,
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.background : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  side: BorderSide(
                    color: isSelected ? AppColors.accent : AppColors.divider,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              }).toList(),
            )),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () async {
                final picker = ImagePicker();
                final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                if (file == null) return;
                final bytes = await file.readAsBytes();
                avatarData.value = 'data:image/jpeg;base64,${base64Encode(bytes)}';
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.photo_library_outlined, color: AppColors.textSecondary, size: 18),
                    const SizedBox(width: 10),
                    Obx(() => Text(
                          avatarData.value.isNotEmpty ? 'Фото выбрано' : 'Загрузить фото',
                          style: AppTextStyles.bodySM,
                        )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Obx(() => error.value.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(error.value,
                        style: AppTextStyles.bodySM
                            .copyWith(color: AppColors.dangerRed)),
                  )
                : const SizedBox.shrink()),
            const SizedBox(height: 8),
            Obx(() => GestureDetector(
                  onTap: saving.value
                      ? null
                      : () async {
                          saving.value = true;
                          error.value = '';
                          final err = await ctrl.saveProfile(
                            nameCtrl.text.trim(),
                            emailCtrl.text.trim(),
                            cityCtrl.text.trim(),
                            newAvatarData: avatarData.value.isNotEmpty ? avatarData.value : null,
                            newGameLevel: selectedLevel.value.isNotEmpty ? selectedLevel.value : null,
                            newPosition: selectedPosition.value.isNotEmpty ? selectedPosition.value : null,
                          );
                          if (err == null) {
                            Get.back();
                          } else {
                            error.value = err;
                          }
                          saving.value = false;
                        },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: saving.value
                          ? AppColors.surface
                          : AppColors.accent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: saving.value
                          ? const SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.background),
                            )
                          : Text('СОХРАНИТЬ',
                              style: AppTextStyles.labelBold
                                  .copyWith(color: AppColors.background)),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _chipSectionLabel(String label) => Text(
        label,
        style: AppTextStyles.bodySM.copyWith(
          fontSize: 11,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w700,
        ),
      );

  Widget _inputField(String label, TextEditingController ctrl,
      {String? hint, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.bodySM.copyWith(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: TextField(
            controller: ctrl,
            keyboardType: keyboardType,
            style: AppTextStyles.bodyMD,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.bodySM,
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  void _showSettingsSheet(BuildContext context) {
    final s = Get.find<SettingsController>();
    final items = [
      (Icons.notifications_outlined, 'Уведомления', 'notifications', s.notifications),
      (Icons.dark_mode_outlined, 'Тёмная тема', 'dark_theme', s.darkTheme),
      (Icons.my_location_outlined, 'Геолокация', 'geolocation', s.geolocation),
      (Icons.lock_outline, 'Приватность', 'privacy', s.privacy),
    ];

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
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text('НАСТРОЙКИ', style: AppTextStyles.headingMD),
            const SizedBox(height: 20),
            ...items.map((item) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      Icon(item.$1, color: AppColors.textSecondary, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(item.$2, style: AppTextStyles.labelBold),
                      ),
                      Obx(() => Switch(
                            value: item.$4.value,
                            onChanged: (v) => s.toggle(item.$3, v),
                            activeThumbColor: AppColors.accent,
                            activeTrackColor:
                                AppColors.accent.withValues(alpha: 0.3),
                          )),
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
    final isFirst = label == 'РЕДАКТИРОВАТЬ ПРОФИЛЬ';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.vertical(
            top: isFirst ? const Radius.circular(16) : Radius.zero,
            bottom: isLast ? const Radius.circular(16) : Radius.zero,
          ),
          border: Border(
            top: Border.all(color: AppColors.divider).top,
            left: Border.all(color: AppColors.divider).left,
            right: Border.all(color: AppColors.divider).right,
            bottom: isLast
                ? Border.all(color: AppColors.divider).bottom
                : BorderSide.none,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38, height: 38,
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
              onPressed: () async {
                Get.back();
                await Get.find<AuthController>().logout();
              },
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
          child: Text('ВЫЙТИ ИЗ ПРОФИЛЯ',
              style: AppTextStyles.labelBold
                  .copyWith(color: AppColors.dangerRed)),
        ),
      ),
    );
  }
}
