import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';
import '../controllers/auth_controller.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _isLoading = false.obs;
  final _errorMsg = ''.obs;
  bool _obscure = true;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final username = _usernameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (username.isEmpty || password.isEmpty) {
      _errorMsg.value = 'Заполните обязательные поля';
      return;
    }

    _isLoading.value = true;
    _errorMsg.value = '';

    final error =
        await Get.find<AuthController>().register(username, email, password);

    if (error == null) {
      // Возвращаемся к корневому маршруту (AuthGate) — он уже покажет MainShell
      Get.until((route) => route.isFirst);
    } else {
      _isLoading.value = false;
      _errorMsg.value = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
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
              const SizedBox(height: 40),
              RichText(
                text: TextSpan(children: [
                  TextSpan(text: 'СОЗДАТЬ\n', style: AppTextStyles.headingXL),
                  TextSpan(
                      text: 'АККАУНТ',
                      style: AppTextStyles.headingXL
                          .copyWith(color: AppColors.accent)),
                ]),
              ),
              const SizedBox(height: 8),
              Text('Регистрация займёт 30 секунд',
                  style: AppTextStyles.bodySM),
              const SizedBox(height: 40),
              _field(
                controller: _usernameCtrl,
                hint: 'Имя пользователя',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              _field(
                controller: _emailCtrl,
                hint: 'Email (необязательно)',
                icon: Icons.email_outlined,
                keyboard: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _field(
                controller: _passwordCtrl,
                hint: 'Пароль (мин. 6 символов)',
                icon: Icons.lock_outline,
                obscure: _obscure,
                suffix: IconButton(
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              const SizedBox(height: 12),
              Obx(() => _errorMsg.value.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(_errorMsg.value,
                          style: AppTextStyles.bodySM
                              .copyWith(color: AppColors.dangerRed)),
                    )
                  : const SizedBox.shrink()),
              Obx(() => GestureDetector(
                    onTap: _isLoading.value ? null : _submit,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: _isLoading.value
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.background),
                              )
                            : Text('ЗАРЕГИСТРИРОВАТЬСЯ',
                                style: AppTextStyles.headingMD
                                    .copyWith(color: AppColors.background)),
                      ),
                    ),
                  )),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Уже есть аккаунт?', style: AppTextStyles.bodySM),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => Get.off(() => const LoginScreen()),
                    child: Text('Войти',
                        style: AppTextStyles.bodySM
                            .copyWith(color: AppColors.accent)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    TextInputType keyboard = TextInputType.text,
    Widget? suffix,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboard,
        style: AppTextStyles.bodyMD,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.bodySM,
          prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        ),
      ),
    );
  }
}
