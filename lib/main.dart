import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'theme/app_theme.dart';
import 'controllers/nav_controller.dart';
import 'controllers/venue_controller.dart';
import 'controllers/auth_controller.dart';
import 'controllers/game_controller.dart';
import 'controllers/player_group_controller.dart';
import 'controllers/chat_controller.dart';
import 'controllers/profile_controller.dart';
import 'controllers/settings_controller.dart';
import 'services/venue_service.dart';
import 'services/auth_service.dart';
import 'services/game_service.dart';
import 'services/player_group_service.dart';
import 'services/chat_service.dart';
import 'services/profile_service.dart';
import 'services/settings_service.dart';
import 'screens/home_screen.dart';
import 'screens/games_screen.dart';
import 'screens/chats_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.cardBackground,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  Get.put<AuthService>(AuthService());
  Get.put<AuthController>(AuthController());
  Get.lazyPut<VenueService>(() => VenueService());
  Get.lazyPut<VenueController>(() => VenueController());
  Get.lazyPut<GameService>(() => GameService());
  Get.lazyPut<GameController>(() => GameController());
  Get.lazyPut<PlayerGroupService>(() => PlayerGroupService());
  Get.lazyPut<PlayerGroupController>(() => PlayerGroupController());
  Get.lazyPut<ChatService>(() => ChatService());
  Get.lazyPut<ChatController>(() => ChatController());
  Get.lazyPut<ProfileService>(() => ProfileService());
  Get.lazyPut<ProfileController>(() => ProfileController());
  Get.put<NavController>(NavController());
  Get.lazyPut<SettingsService>(() => SettingsService());
  Get.lazyPut<SettingsController>(() => SettingsController());
  runApp(const OynoApp());
}

class OynoApp extends StatelessWidget {
  const OynoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Oyno Sports Community',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    return Obx(() => auth.isLoggedIn.value ? const MainShell() : const LoginScreen());
  }
}

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  static const List<Widget> _screens = [
    HomeScreen(),
    GamesScreen(),
    ChatsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final NavController nav = Get.find<NavController>();

    return Obx(() => Scaffold(
          backgroundColor: AppColors.background,
          body: IndexedStack(
            index: nav.currentIndex.value,
            children: _screens,
          ),
          bottomNavigationBar: _buildBottomNav(nav),
        ));
  }

  Widget _buildBottomNav(NavController nav) {
    return Obx(() => Container(
          decoration: const BoxDecoration(
            color: AppColors.cardBackground,
            border: Border(
              top: BorderSide(color: AppColors.divider, width: 1),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 64,
              child: Row(
                children: [
                  _navItem(
                    index: 0,
                    activeIndex: nav.currentIndex.value,
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home,
                    label: 'Главная',
                    onTap: () => nav.changePage(0),
                  ),
                  _navItem(
                    index: 1,
                    activeIndex: nav.currentIndex.value,
                    icon: Icons.calendar_today_outlined,
                    activeIcon: Icons.calendar_today,
                    label: 'Игры',
                    onTap: () => nav.changePage(1),
                  ),
                  _navItem(
                    index: 2,
                    activeIndex: nav.currentIndex.value,
                    icon: Icons.chat_bubble_outline,
                    activeIcon: Icons.chat_bubble,
                    label: 'Чаты',
                    onTap: () => nav.changePage(2),
                    badge: 4,
                  ),
                  _navItem(
                    index: 3,
                    activeIndex: nav.currentIndex.value,
                    icon: Icons.person_outline,
                    activeIcon: Icons.person,
                    label: 'Профиль',
                    onTap: () => nav.changePage(3),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Widget _navItem({
    required int index,
    required int activeIndex,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required VoidCallback onTap,
    int badge = 0,
  }) {
    final isActive = index == activeIndex;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isActive ? activeIcon : icon,
                    key: ValueKey(isActive),
                    color: isActive ? AppColors.accent : AppColors.textSecondary,
                    size: 24,
                  ),
                ),
                if (badge > 0)
                  Positioned(
                    top: -4,
                    right: -6,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          badge.toString(),
                          style: const TextStyle(
                            color: AppColors.background,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppColors.accent : AppColors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
