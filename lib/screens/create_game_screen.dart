import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';

class CreateGameScreen extends StatefulWidget {
  const CreateGameScreen({super.key});

  @override
  State<CreateGameScreen> createState() => _CreateGameScreenState();
}

class _CreateGameScreenState extends State<CreateGameScreen> {
  int _selectedSport = 0;
  int _selectedVenue = 0;
  int _selectedLevel = 1;
  int _maxPlayers = 10;
  bool _created = false;

  final List<Map<String, String>> _sports = [
    {'emoji': '⚽', 'name': 'ФУТБОЛ'},
    {'emoji': '🏀', 'name': 'БАСКЕТ'},
    {'emoji': '🏐', 'name': 'ВОЛЕЙ'},
    {'emoji': '🏊', 'name': 'ПЛАВАНИЕ'},
    {'emoji': '🎾', 'name': 'ТЕННИС'},
  ];

  final List<String> _venues = [
    'СПОРТКОМ АРЕНА',
    'БАСКЕТ ХОЛЛ',
    'AQUA SPORT',
    'СТАДИОН СПАРТАК',
    'ВОЛЕЙ ЦЕНТР',
  ];

  final List<String> _levels = ['НОВИЧОК', 'СРЕДНИЙ', 'ПРОФИ'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection('ВИД СПОРТА', _buildSportPicker()),
                    const SizedBox(height: 24),
                    _buildSection('ПЛОЩАДКА', _buildVenuePicker()),
                    const SizedBox(height: 24),
                    _buildSection('ДАТА И ВРЕМЯ', _buildDateTime()),
                    const SizedBox(height: 24),
                    _buildSection('УРОВЕНЬ', _buildLevelPicker()),
                    const SizedBox(height: 24),
                    _buildSection('ИГРОКОВ МАКСИМУМ', _buildPlayerCount()),
                    const SizedBox(height: 36),
                    _buildCreateButton(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
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
          const SizedBox(width: 16),
          Text('СОЗДАТЬ ИГРУ', style: AppTextStyles.headingLG),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.bodySM.copyWith(
          color: AppColors.textSecondary,
          letterSpacing: 1.5,
        )),
        const SizedBox(height: 12),
        content,
      ],
    );
  }

  Widget _buildSportPicker() {
    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _sports.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final isSelected = _selectedSport == i;
          return GestureDetector(
            onTap: () => setState(() => _selectedSport = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 76,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.accent.withValues(alpha: 0.1)
                    : AppColors.cardBackground,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? AppColors.accent : AppColors.divider,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_sports[i]['emoji']!,
                      style: const TextStyle(fontSize: 28)),
                  const SizedBox(height: 6),
                  Text(
                    _sports[i]['name']!,
                    style: AppTextStyles.bodySM.copyWith(
                      color: isSelected ? AppColors.accent : AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVenuePicker() {
    return Column(
      children: List.generate(_venues.length, (i) {
        final isSelected = _selectedVenue == i;
        return GestureDetector(
          onTap: () => setState(() => _selectedVenue = i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.accent.withValues(alpha: 0.08)
                  : AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.accent : AppColors.divider,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.stadium_outlined,
                  color: isSelected ? AppColors.accent : AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _venues[i],
                    style: AppTextStyles.labelBold.copyWith(
                      color: isSelected ? AppColors.accent : AppColors.textPrimary,
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle, color: AppColors.accent, size: 20),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildDateTime() {
    return Row(
      children: [
        Expanded(
          child: _dateField(Icons.calendar_today_outlined, 'ДАТА', '24 ОКТ 2025'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _dateField(Icons.access_time, 'ВРЕМЯ', '20:00'),
        ),
      ],
    );
  }

  Widget _dateField(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accent, size: 18),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: AppTextStyles.bodySM.copyWith(fontSize: 10)),
              const SizedBox(height: 2),
              Text(value, style: AppTextStyles.labelBold),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLevelPicker() {
    return Row(
      children: List.generate(_levels.length, (i) {
        final isSelected = _selectedLevel == i;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedLevel = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: EdgeInsets.only(right: i < _levels.length - 1 ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.accent
                    : AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.accent : AppColors.divider,
                ),
              ),
              child: Center(
                child: Text(
                  _levels[i],
                  style: AppTextStyles.bodySM.copyWith(
                    color: isSelected ? AppColors.background : AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPlayerCount() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (_maxPlayers > 2) setState(() => _maxPlayers--);
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.divider),
              ),
              child: const Icon(Icons.remove, color: AppColors.textPrimary, size: 20),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                '$_maxPlayers',
                style: AppTextStyles.headingXL.copyWith(color: AppColors.accent),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              if (_maxPlayers < 22) setState(() => _maxPlayers++);
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.divider),
              ),
              child: const Icon(Icons.add, color: AppColors.textPrimary, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton() {
    return GestureDetector(
      onTap: _created
          ? null
          : () {
              setState(() => _created = true);
              Future.delayed(const Duration(seconds: 2), () => Get.back());
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: _created
              ? AppColors.confirmGreen.withValues(alpha: 0.15)
              : AppColors.accent,
          borderRadius: BorderRadius.circular(16),
          border: _created
              ? Border.all(color: AppColors.confirmGreen, width: 1.5)
              : null,
        ),
        child: Center(
          child: Text(
            _created ? '✓ ИГРА СОЗДАНА!' : '⚡ СОЗДАТЬ ИГРУ',
            style: AppTextStyles.headingMD.copyWith(
              color: _created ? AppColors.confirmGreen : AppColors.background,
            ),
          ),
        ),
      ),
    );
  }
}
