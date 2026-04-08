import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _phoneCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();

  final _step = 1.obs;   // 1=телефон, 2=код, 3=новый пароль
  final _isLoading = false.obs;
  final _errorMsg = ''.obs;
  bool _obscure = true;

  final _authService = Get.find<AuthService>();

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _codeCtrl.dispose();
    _newPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final phone = _phoneCtrl.text.trim();
    if (phone.isEmpty) { _errorMsg.value = 'Введите номер'; return; }
    _isLoading.value = true;
    _errorMsg.value = '';
    final res = await _authService.sendOtp(phone: phone, purpose: 'reset');
    _isLoading.value = false;
    if (res.isSuccess) {
      _step.value = 2;
    } else {
      _errorMsg.value = res.error ?? 'Ошибка';
    }
  }

  void _verifyCode() {
    if (_codeCtrl.text.trim().length != 6) {
      _errorMsg.value = 'Введите 6-значный код';
      return;
    }
    _errorMsg.value = '';
    _isLoading.value = true;
    _authService.verifyOtp(
      phone: _phoneCtrl.text.trim(),
      code: _codeCtrl.text.trim(),
      purpose: 'reset',
    ).then((res) {
      _isLoading.value = false;
      if (res.isSuccess) {
        _step.value = 3;
      } else {
        _errorMsg.value = res.error ?? 'Неверный код';
      }
    });
  }

  Future<void> _resetPassword() async {
    final pass = _newPassCtrl.text;
    if (pass.length < 6) { _errorMsg.value = 'Минимум 6 символов'; return; }
    _isLoading.value = true;
    _errorMsg.value = '';
    final res = await _authService.resetPassword(
      phone: _phoneCtrl.text.trim(),
      code: _codeCtrl.text.trim(),
      newPassword: pass,
    );
    _isLoading.value = false;
    if (res.isSuccess) {
      Get.back();
      Get.snackbar('Готово', 'Пароль успешно изменён',
          backgroundColor: AppColors.accent,
          colorText: Colors.black,
          snackPosition: SnackPosition.BOTTOM);
    } else {
      _errorMsg.value = res.error ?? 'Ошибка';
      if (res.error?.contains('код') == true) _step.value = 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () => _step.value > 1 ? _step.value-- : Get.back(),
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
              const SizedBox(height: 32),
              if (_step.value == 1) ...[
                Text('СБРОС ПАРОЛЯ', style: AppTextStyles.headingXL),
                const SizedBox(height: 8),
                Text('Введите номер телефона привязанный к аккаунту',
                    style: AppTextStyles.bodySM),
                const SizedBox(height: 32),
                _label('НОМЕР ТЕЛЕФОНА'),
                _field(_phoneCtrl,
                  hint: '+996 700 000 000',
                  type: TextInputType.phone,
                  formatters: [FilteringTextInputFormatter.allow(RegExp(r'[+\d]'))],
                ),
              ] else if (_step.value == 2) ...[
                Text('КОД ПОДТВЕРЖДЕНИЯ', style: AppTextStyles.headingXL),
                const SizedBox(height: 8),
                Text('Отправлен на ${_phoneCtrl.text}',
                    style: AppTextStyles.bodySM),
                const SizedBox(height: 32),
                _label('6-ЗНАЧНЫЙ КОД'),
                _field(_codeCtrl,
                  hint: '000000',
                  type: TextInputType.number,
                  formatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: _isLoading.value ? null : _sendOtp,
                  child: Text('Отправить повторно',
                      style: AppTextStyles.bodySM.copyWith(
                          color: AppColors.accent,
                          decoration: TextDecoration.underline)),
                ),
              ] else ...[
                Text('НОВЫЙ ПАРОЛЬ', style: AppTextStyles.headingXL),
                const SizedBox(height: 8),
                Text('Придумайте новый пароль (минимум 6 символов)',
                    style: AppTextStyles.bodySM),
                const SizedBox(height: 32),
                _label('НОВЫЙ ПАРОЛЬ'),
                _field(_newPassCtrl,
                  hint: '••••••',
                  obscure: _obscure,
                  suffix: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.textSecondary, size: 20),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ],
              if (_errorMsg.value.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Text(_errorMsg.value,
                      style: AppTextStyles.bodySM.copyWith(color: Colors.red)),
                ),
              ],
              const SizedBox(height: 24),
              Obx(() {
                final labels = ['ПОЛУЧИТЬ КОД', 'ДАЛЕЕ', 'СМЕНИТЬ ПАРОЛЬ'];
                final actions = [_sendOtp, _verifyCode, _resetPassword];
                return GestureDetector(
                  onTap: _isLoading.value ? null : actions[_step.value - 1],
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: _isLoading.value ? AppColors.surface : AppColors.accent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: _isLoading.value
                          ? const CircularProgressIndicator(
                              color: AppColors.accent, strokeWidth: 2)
                          : Text(labels[_step.value - 1],
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                  letterSpacing: 1)),
                    ),
                  ),
                );
              }),
            ],
          )),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: AppTextStyles.labelBold.copyWith(fontSize: 11)),
  );

  Widget _field(TextEditingController ctrl, {
    String hint = '',
    TextInputType type = TextInputType.text,
    bool obscure = false,
    List<TextInputFormatter>? formatters,
    Widget? suffix,
  }) =>
    Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: TextField(
        controller: ctrl,
        obscureText: obscure,
        keyboardType: type,
        inputFormatters: formatters,
        style: AppTextStyles.bodyMD,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.bodySM,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          suffixIcon: suffix,
        ),
      ),
    );
}
