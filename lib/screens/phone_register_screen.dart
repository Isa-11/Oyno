import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class PhoneRegisterScreen extends StatefulWidget {
  const PhoneRegisterScreen({super.key});

  @override
  State<PhoneRegisterScreen> createState() => _PhoneRegisterScreenState();
}

class _PhoneRegisterScreenState extends State<PhoneRegisterScreen> {
  // Шаг 1 — телефон
  final _phoneCtrl = TextEditingController();
  // Шаг 2 — код
  final _codeCtrl = TextEditingController();
  // Шаг 3 — имя и пароль
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  final _step = 1.obs;        // 1=телефон, 2=код, 3=данные
  final _isLoading = false.obs;
  final _errorMsg = ''.obs;
  bool _obscure = true;

  final _authService = Get.find<AuthService>();

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _codeCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final phone = _phoneCtrl.text.trim();
    if (phone.isEmpty) {
      _errorMsg.value = 'Введите номер телефона';
      return;
    }
    _isLoading.value = true;
    _errorMsg.value = '';
    final res = await _authService.sendOtp(phone: phone, purpose: 'register');
    _isLoading.value = false;
    if (res.isSuccess) {
      _step.value = 2;
    } else {
      _errorMsg.value = res.error ?? 'Ошибка отправки';
    }
  }

  Future<void> _verifyCode() async {
    final code = _codeCtrl.text.trim();
    if (code.length != 6) {
      _errorMsg.value = 'Введите 6-значный код';
      return;
    }
    _isLoading.value = true;
    _errorMsg.value = '';
    final res = await _authService.verifyOtp(
      phone: _phoneCtrl.text.trim(),
      code: code,
      purpose: 'register',
    );
    _isLoading.value = false;
    if (res.isSuccess) {
      _step.value = 3;
    } else {
      _errorMsg.value = res.error ?? 'Неверный код';
    }
  }

  Future<void> _register() async {
    final username = _usernameCtrl.text.trim();
    final password = _passwordCtrl.text;
    if (username.isEmpty || password.isEmpty) {
      _errorMsg.value = 'Заполните все поля';
      return;
    }
    if (password.length < 6) {
      _errorMsg.value = 'Пароль минимум 6 символов';
      return;
    }
    _isLoading.value = true;
    _errorMsg.value = '';
    final res = await _authService.registerPhone(
      phone: _phoneCtrl.text.trim(),
      code: _codeCtrl.text.trim(),
      username: username,
      password: password,
    );
    _isLoading.value = false;
    if (res.isSuccess && res.data != null) {
      await Get.find<AuthController>().loginWithResult(res.data!);
      if (mounted && Navigator.of(context).canPop()) {
        Get.back(result: true);
      }
    } else {
      _errorMsg.value = res.error ?? 'Ошибка регистрации';
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
              _buildStepIndicator(),
              const SizedBox(height: 32),
              if (_step.value == 1) _buildPhoneStep(),
              if (_step.value == 2) _buildCodeStep(),
              if (_step.value == 3) _buildDetailsStep(),
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
              _buildActionButton(),
            ],
          )),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    final steps = ['Телефон', 'Код', 'Данные'];
    return Row(
      children: List.generate(3, (i) {
        final active = _step.value == i + 1;
        final done = _step.value > i + 1;
        return Expanded(
          child: Row(children: [
            if (i > 0)
              Expanded(child: Container(height: 2,
                  color: done ? AppColors.accent : AppColors.divider)),
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: active || done ? AppColors.accent : AppColors.cardBackground,
                shape: BoxShape.circle,
                border: Border.all(color: active || done ? AppColors.accent : AppColors.divider),
              ),
              child: Center(child: done
                  ? const Icon(Icons.check, color: Colors.black, size: 16)
                  : Text('${i + 1}',
                    style: TextStyle(
                      color: active ? Colors.black : AppColors.textSecondary,
                      fontWeight: FontWeight.bold, fontSize: 13))),
            ),
            if (i < 2)
              Expanded(child: Container(height: 2,
                  color: _step.value > i + 1 ? AppColors.accent : AppColors.divider)),
          ]),
        );
      }),
    );
  }

  Widget _buildPhoneStep() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('РЕГИСТРАЦИЯ', style: AppTextStyles.headingXL),
      const SizedBox(height: 8),
      Text('Введите номер телефона — мы отправим код подтверждения',
          style: AppTextStyles.bodySM),
      const SizedBox(height: 32),
      _label('НОМЕР ТЕЛЕФОНА'),
      _field(_phoneCtrl,
        hint: '+996 700 000 000',
        type: TextInputType.phone,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[+\d]'))],
      ),
    ]);
  }

  Widget _buildCodeStep() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('КОД ПОДТВЕРЖДЕНИЯ', style: AppTextStyles.headingXL),
      const SizedBox(height: 8),
      Text('Код отправлен на ${_phoneCtrl.text}',
          style: AppTextStyles.bodySM),
      const SizedBox(height: 32),
      _label('6-ЗНАЧНЫЙ КОД'),
      _field(_codeCtrl,
        hint: '000000',
        type: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(6),
        ],
      ),
      const SizedBox(height: 12),
      GestureDetector(
        onTap: _isLoading.value ? null : _sendOtp,
        child: Text('Отправить код повторно',
            style: AppTextStyles.bodySM.copyWith(
                color: AppColors.accent, decoration: TextDecoration.underline)),
      ),
    ]);
  }

  Widget _buildDetailsStep() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('СОЗДАЙТЕ ПРОФИЛЬ', style: AppTextStyles.headingXL),
      const SizedBox(height: 8),
      Text('Придумайте имя и пароль для входа',
          style: AppTextStyles.bodySM),
      const SizedBox(height: 32),
      _label('ИМЯ ПОЛЬЗОВАТЕЛЯ'),
      _field(_usernameCtrl, hint: 'sportsman_96'),
      const SizedBox(height: 16),
      _label('ПАРОЛЬ'),
      _field(_passwordCtrl,
        hint: '••••••',
        obscure: _obscure,
        suffix: IconButton(
          icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility,
              color: AppColors.textSecondary, size: 20),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
    ]);
  }

  Widget _buildActionButton() {
    final labels = ['ПОЛУЧИТЬ КОД', 'ДАЛЕЕ', 'ЗАРЕГИСТРИРОВАТЬСЯ'];
    final actions = [_sendOtp, _verifyCode, _register];
    return Obx(() => GestureDetector(
      onTap: _isLoading.value ? null : actions[_step.value - 1],
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: _isLoading.value ? AppColors.surface : AppColors.accent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: _isLoading.value
              ? const CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2)
              : Text(labels[_step.value - 1],
                  style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.w900,
                    fontSize: 15, letterSpacing: 1)),
        ),
      ),
    ));
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: AppTextStyles.labelBold.copyWith(fontSize: 11)),
  );

  Widget _field(TextEditingController ctrl, {
    String hint = '',
    TextInputType type = TextInputType.text,
    bool obscure = false,
    List<TextInputFormatter>? inputFormatters,
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
        inputFormatters: inputFormatters,
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
