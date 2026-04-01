import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Экран ошибки с кнопкой Retry.
///
/// Использование:
///   ErrorState(message: ctrl.error.value, onRetry: ctrl.fetchAll)
class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.divider),
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                color: AppColors.textSecondary,
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Что-то пошло не так',
              style: AppTextStyles.headingMD,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message.isNotEmpty ? message : 'Проверьте подключение к интернету',
              style: AppTextStyles.bodySM,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'ПОВТОРИТЬ',
                  style: AppTextStyles.labelBold.copyWith(color: AppColors.background),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
