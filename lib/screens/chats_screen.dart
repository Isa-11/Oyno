import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chat_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/chat_list_item.dart';
import '../widgets/shimmer_loader.dart';
import '../widgets/error_state.dart';
import '../widgets/empty_state.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildSearchBar(),
            const SizedBox(height: 8),
            Expanded(
              child: Obx(() {
                final ctrl = Get.find<ChatController>();
                if (ctrl.isLoading.value) {
                  return const ShimmerLoader(itemCount: 5, itemHeight: 72);
                }
                if (ctrl.error.value.isNotEmpty) {
                  return ErrorState(
                    message: ctrl.error.value,
                    onRetry: ctrl.fetchChats,
                  );
                }
                if (ctrl.chats.isEmpty) {
                  return const EmptyState(
                    icon: Icons.chat_bubble_outline,
                    message: 'Нет чатов',
                    subtitle: 'Вступите в игру, чтобы начать общение',
                  );
                }
                return RefreshIndicator(
                  color: AppColors.accent,
                  backgroundColor: AppColors.cardBackground,
                  onRefresh: ctrl.fetchChats,
                  child: ListView.separated(
                    itemCount: ctrl.chats.length,
                    separatorBuilder: (_, __) => const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Divider(color: AppColors.divider, height: 1, thickness: 1),
                    ),
                    itemBuilder: (_, i) => ChatListItem(chat: ctrl.chats[i]),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Row(
        children: [
          Text(
            'ЧАТЫ ',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              letterSpacing: 1.5,
            ),
          ),
          Text(
            '⚡',
            style: TextStyle(fontSize: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: const Row(
          children: [
            SizedBox(width: 14),
            Icon(Icons.search, color: AppColors.textSecondary, size: 20),
            SizedBox(width: 10),
            Text(
              'ПОИСК ИГРОКОВ...',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
