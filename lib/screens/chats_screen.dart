import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chat_controller.dart';
import '../models/models.dart';
import 'chat_detail_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/chat_list_item.dart';
import '../widgets/shimmer_loader.dart';
import '../widgets/error_state.dart';
import '../widgets/empty_state.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

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
                if (ctrl.searchQuery.value.isNotEmpty) {
                  if (ctrl.isSearchingUsers.value) {
                    return const ShimmerLoader(itemCount: 5, itemHeight: 72);
                  }
                  if (ctrl.foundUsers.isEmpty) {
                    return const EmptyState(
                      icon: Icons.person_search_outlined,
                      message: 'Игроки не найдены',
                      subtitle: 'Попробуйте другой логин или имя пользователя',
                    );
                  }
                  return ListView.separated(
                    itemCount: ctrl.foundUsers.length,
                    separatorBuilder: (_, __) => const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Divider(color: AppColors.divider, height: 1, thickness: 1),
                    ),
                    itemBuilder: (_, i) => _buildUserResult(ctrl.foundUsers[i]),
                  );
                }
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
            'ЧАТЫ',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    final ctrl = Get.find<ChatController>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            const Icon(Icons.search, color: AppColors.textSecondary, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                onChanged: ctrl.onSearchChanged,
                style: AppTextStyles.bodySM,
                decoration: InputDecoration(
                  hintText: 'Поиск игроков...',
                  hintStyle: AppTextStyles.bodySM,
                  border: InputBorder.none,
                ),
              ),
            ),
            Obx(() => ctrl.searchQuery.value.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      _searchCtrl.clear();
                      ctrl.onSearchChanged('');
                    },
                    icon: const Icon(Icons.close, color: AppColors.textSecondary, size: 18),
                  )
                : const SizedBox(width: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildUserResult(ChatUserSearch user) {
    final chat = ChatItem(
      id: user.id,
      type: 'direct',
      name: user.username.toUpperCase(),
      sportEmoji: 'DM',
      lastMessage: 'Открыть личный чат',
      time: '',
      otherUserId: user.id,
      otherUsername: user.username,
    );

    return ListTile(
      onTap: () => Get.to(() => ChatDetailScreen(chat: chat)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      leading: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Center(
          child: Text(
            user.username.isNotEmpty ? user.username[0].toUpperCase() : '?',
            style: AppTextStyles.labelBold,
          ),
        ),
      ),
      title: Text(user.username, style: AppTextStyles.labelBold),
      subtitle: Text('Открыть личный чат', style: AppTextStyles.bodySM),
      trailing: const Icon(Icons.arrow_forward_ios, color: AppColors.textSecondary, size: 14),
    );
  }
}
