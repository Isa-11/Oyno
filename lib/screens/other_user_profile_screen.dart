import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';
import '../services/profile_service.dart';

class OtherUserProfileScreen extends StatefulWidget {
  final int userId;
  final String? username;

  const OtherUserProfileScreen({
    super.key,
    required this.userId,
    this.username,
  });

  @override
  State<OtherUserProfileScreen> createState() => _OtherUserProfileScreenState();
}

class _OtherUserProfileScreenState extends State<OtherUserProfileScreen> {
  final RxMap<String, dynamic> _userData = <String, dynamic>{}.obs;
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    _isLoading.value = true;
    _error.value = '';
    try {
      final res = await Get.find<ProfileService>().getUserProfile(widget.userId);
      if (res.isSuccess && res.data != null) {
        _userData.assignAll(res.data as Map<String, dynamic>);
      } else {
        _error.value = res.error ?? 'Не удалось загрузить профиль';
      }
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Obx(() {
          if (_isLoading.value) {
            return const Center(child: CircularProgressIndicator(color: AppColors.accent));
          }

          if (_error.value.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_error.value, style: AppTextStyles.bodySM),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _loadProfile,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('RETRY', style: AppTextStyles.labelBold.copyWith(color: AppColors.background)),
                    ),
                  ),
                ],
              ),
            );
          }

          final username = _userData['username'] as String? ?? widget.username ?? 'User';
          final rating = (_userData['rating'] as num?)?.toDouble() ?? 0.0;
          final gamesCount = _userData['games_count'] as int? ?? 0;
          final bio = _userData['bio'] as String? ?? 'Спортсмен';

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildAvatar(username),
                const SizedBox(height: 16),
                Text(username, style: AppTextStyles.headingXL),
                const SizedBox(height: 8),
                Text(bio, style: AppTextStyles.bodySM.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 24),
                _buildStatsRow(rating, gamesCount),
                const SizedBox(height: 24),
                _buildActionButtons(username),
                const SizedBox(height: 24),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
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
          const Spacer(),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: const Icon(Icons.more_vert, color: AppColors.textPrimary, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String username) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.accent, width: 2),
      ),
      child: Center(
        child: Text(
          username.isNotEmpty ? username[0].toUpperCase() : '?',
          style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }

  Widget _buildStatsRow(double rating, int gamesCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStat('⭐', '$rating', 'РЕЙТИНГ'),
          Container(width: 1, height: 50, color: AppColors.divider),
          _buildStat('⚽', '$gamesCount', 'ИГР'),
          Container(width: 1, height: 50, color: AppColors.divider),
          _buildStat('📊', '${(rating * 20).toInt()}%', 'УСПЕХ'),
        ],
      ),
    );
  }

  Widget _buildStat(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.labelBold),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.bodySM.copyWith(fontSize: 10)),
      ],
    );
  }

  Widget _buildActionButtons(String username) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              // Open chat with this user
              Get.snackbar('Чат', 'Открыть чат с $username', snackPosition: SnackPosition.BOTTOM);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text('НАПИСАТЬ СООБЩЕНИЕ', style: AppTextStyles.labelBold.copyWith(color: AppColors.background)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              Get.snackbar('Добавлено', '$username добавлен в друзья', snackPosition: SnackPosition.BOTTOM);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.divider),
              ),
              child: Center(
                child: Text('ДОБАВИТЬ В ДРУЗЬЯ', style: AppTextStyles.labelBold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
