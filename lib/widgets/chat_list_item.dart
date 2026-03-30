import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../screens/chat_detail_screen.dart';

class ChatListItem extends StatelessWidget {
  final ChatItem chat;

  const ChatListItem({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => ChatDetailScreen(chat: chat)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        color: Colors.transparent,
        child: Row(
          children: [
            _avatar(),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chat.teamName,
                    style: AppTextStyles.labelBold,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    chat.lastMessage,
                    style: AppTextStyles.bodySM,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  chat.time,
                  style: AppTextStyles.bodySM.copyWith(fontSize: 11),
                ),
                const SizedBox(height: 6),
                if (chat.unread > 0)
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        chat.unread.toString(),
                        style: AppTextStyles.bodySM.copyWith(
                          color: AppColors.background,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  )
                else
                  const SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatar() {
    return Stack(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.divider, width: 1.5),
          ),
          child: Center(
            child: Text(
              chat.sportEmoji,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        if (chat.isOnline)
          Positioned(
            bottom: 2,
            right: 2,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.onlineGreen,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.background, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}
