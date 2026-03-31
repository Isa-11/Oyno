import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import '../controllers/auth_controller.dart';
import '../models/models.dart';
import '../services/chat_service.dart';
import '../theme/app_theme.dart';

class ChatDetailScreen extends StatefulWidget {
  final ChatItem chat;

  const ChatDetailScreen({super.key, required this.chat});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final ChatService _service = Get.find<ChatService>();

  final RxList<ChatMessage> _messages = <ChatMessage>[].obs;
  final RxBool _loading = true.obs;
  final RxBool _sending = false.obs;

  WebSocketChannel? _channel;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _connectWebSocket();
  }

  void _connectWebSocket() {
    final token = Get.find<AuthController>().token.value;
    final chat = widget.chat;
    final chatType = chat.type;
    final chatId = chatType == 'game' ? chat.gameId : chat.otherUserId;
    if (chatId == null) return;

    final wsUrl = Uri.parse(
      'ws://127.0.0.1:8000/ws/chat/$chatType/$chatId/?token=$token',
    );
    _channel = WebSocketChannel.connect(wsUrl);
    _channel!.stream.listen(
      (data) {
        final msg = jsonDecode(data as String);
        _messages.add(ChatMessage(
          id: msg['id'] as int,
          senderUsername: msg['sender_username'] as String,
          isMine: msg['is_mine'] as bool,
          text: msg['text'] as String,
          time: msg['time'] as String,
        ));
        _scrollToBottom();
      },
      onError: (_) {},
      onDone: () {},
    );
  }

  Future<void> _loadMessages() async {
    _loading.value = true;
    final chat = widget.chat;
    if (chat.type == 'game' && chat.gameId != null) {
      final res = await _service.getGameMessages(chat.gameId!);
      if (res.isSuccess && res.data != null) {
        _messages.assignAll(res.data!);
      }
    } else if (chat.type == 'direct' && chat.otherUserId != null) {
      final res = await _service.getDirectMessages(chat.otherUserId!);
      if (res.isSuccess && res.data != null) {
        _messages.assignAll(res.data!);
      }
    }
    _loading.value = false;
    _scrollToBottom();
  }

  void _send() {
    final text = _input.text.trim();
    if (text.isEmpty || _sending.value) return;
    _input.clear();

    if (_channel != null) {
      _channel!.sink.add(jsonEncode({'text': text}));
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _channel?.sink.close();
    _input.dispose();
    _scroll.dispose();
    super.dispose();
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
              child: Obx(() {
                if (_loading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.accent),
                  );
                }
                if (_messages.isEmpty) {
                  return Center(
                    child: Text('Напишите первое сообщение',
                        style: AppTextStyles.bodySM),
                  );
                }
                return ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  itemCount: _messages.length,
                  itemBuilder: (_, i) => _buildMessage(_messages[i]),
                );
              }),
            ),
            _buildInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    final chat = widget.chat;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  color: AppColors.textPrimary, size: 18),
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: Center(
              child: Text(chat.sportEmoji,
                  style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(chat.name, style: AppTextStyles.labelBold,
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(
                  chat.type == 'game' ? 'ГРУППОВОЙ ЧАТ' : 'ЛИЧНЫЙ ЧАТ',
                  style: AppTextStyles.bodySM
                      .copyWith(fontSize: 11, color: AppColors.accent),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage msg) {
    final isMine = msg.isMine;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment:
            isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMine) ...[
            Container(
              width: 32, height: 32,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  msg.senderUsername.isNotEmpty
                      ? msg.senderUsername[0].toUpperCase()
                      : '?',
                  style: AppTextStyles.labelBold.copyWith(fontSize: 14),
                ),
              ),
            ),
          ],
          Column(
            crossAxisAlignment:
                isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (!isMine)
                Padding(
                  padding: const EdgeInsets.only(bottom: 3, left: 2),
                  child: Text(msg.senderUsername,
                      style: AppTextStyles.bodySM.copyWith(
                          fontSize: 10, color: AppColors.accent)),
                ),
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.65,
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color:
                      isMine ? AppColors.accent : AppColors.cardBackground,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isMine ? 16 : 4),
                    bottomRight: Radius.circular(isMine ? 4 : 16),
                  ),
                  border:
                      isMine ? null : Border.all(color: AppColors.divider),
                ),
                child: Text(
                  msg.text,
                  style: AppTextStyles.bodyMD.copyWith(
                    color: isMine
                        ? AppColors.background
                        : AppColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Text(msg.time,
                  style: AppTextStyles.bodySM.copyWith(fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.divider),
              ),
              child: TextField(
                controller: _input,
                style: AppTextStyles.bodyMD,
                decoration: InputDecoration(
                  hintText: 'Написать сообщение...',
                  hintStyle: AppTextStyles.bodySM,
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 12),
                ),
                onSubmitted: (_) => _send(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _send,
            child: Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.send_rounded,
                  color: AppColors.background, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}
