import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import '../widgets/shimmer_loader.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationService _service = Get.find<NotificationService>();

  List<Map<String, dynamic>> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    final res = await _service.getNotifications();
    if (!mounted) return;
    if (res.isSuccess && res.data != null) {
      setState(() { _items = res.data!; _loading = false; });
    } else {
      setState(() { _error = res.error ?? 'Не удалось загрузить'; _loading = false; });
    }
  }

  Future<void> _markAllRead() async {
    await _service.markAllAsRead();
    _service.resetUnread();
    // Обновляем список — помечаем все как прочитанные локально
    setState(() {
      _items = _items.map((n) => {...n, 'is_read': true}).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppBar(),
            Expanded(child: _buildBody()),
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
              width: 44, height: 44,
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
          Text('УВЕДОМЛЕНИЯ', style: AppTextStyles.headingLG),
          const Spacer(),
          GestureDetector(
            onTap: _markAllRead,
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

  Widget _buildBody() {
    if (_loading) {
      return const ShimmerLoader(itemCount: 5, itemHeight: 80);
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: AppTextStyles.bodySM, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _load,
              child: Text('Повторить',
                  style: AppTextStyles.bodySM.copyWith(color: AppColors.accent)),
            ),
          ],
        ),
      );
    }
    if (_items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_none_outlined,
                size: 64, color: AppColors.textSecondary.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text('Уведомлений нет', style: AppTextStyles.bodyMD.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      color: AppColors.accent,
      backgroundColor: AppColors.cardBackground,
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _buildItem(_items[i]),
      ),
    );
  }

  Widget _buildItem(Map<String, dynamic> n) {
    final isNew = !(n['is_read'] as bool? ?? true);
    final title = n['title'] as String? ?? '';
    final body = n['body'] as String? ?? '';
    final time = n['created_at'] as String? ?? '';
    final emoji = n['emoji'] as String? ?? '🔔';

    return GestureDetector(
      onTap: () async {
        if (isNew && n['id'] != null) {
          await _service.markAsRead(n['id'] as int);
          setState(() {
            _items = _items.map((item) =>
              item['id'] == n['id'] ? {...item, 'is_read': true} : item
            ).toList();
          });
          _service.decrementUnread();
        }
      },
      child: Container(
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
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 24)),
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
                        child: Text(title, style: AppTextStyles.labelBold),
                      ),
                      if (isNew)
                        Container(
                          width: 8, height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  if (body.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(body,
                        style: AppTextStyles.bodySM,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ],
                  if (time.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(time,
                        style: AppTextStyles.bodySM.copyWith(fontSize: 11)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
