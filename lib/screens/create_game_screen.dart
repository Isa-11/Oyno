import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/player_group_controller.dart';
import '../controllers/venue_controller.dart';
import '../models/models.dart';
import '../services/game_service.dart';
import '../services/venue_service.dart';
import '../theme/app_theme.dart';

class CreateGameScreen extends StatefulWidget {
  const CreateGameScreen({super.key});

  @override
  State<CreateGameScreen> createState() => _CreateGameScreenState();
}

class _CreateGameScreenState extends State<CreateGameScreen> {
  int _selectedSport = 0;
  Venue? _selectedVenue;
  String? _selectedSlot;
  int _selectedLevel = 1;
  int _maxPlayers = 10;
  bool _isLoading = false;
  bool _slotsLoading = false;
  String? _error;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  List<VenueSlot> _slots = [];

  final List<Map<String, String>> _sports = [
    {'emoji': '⚽', 'name': 'ФУТБОЛ', 'key': 'football'},
    {'emoji': '🏀', 'name': 'БАСКЕТ', 'key': 'basketball'},
    {'emoji': '🏐', 'name': 'ВОЛЕЙ', 'key': 'volleyball'},
    {'emoji': '🏊', 'name': 'ПЛАВАНИЕ', 'key': 'swimming'},
    {'emoji': '🎾', 'name': 'ТЕННИС', 'key': 'tennis'},
  ];

  final List<Map<String, String>> _levels = [
    {'label': 'НОВИЧОК', 'key': 'beginner'},
    {'label': 'СРЕДНИЙ', 'key': 'medium'},
    {'label': 'ПРОФИ', 'key': 'pro'},
  ];

  String get _dateStr =>
      '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

  Future<void> _loadSlots() async {
    if (_selectedVenue?.id == null) return;
    setState(() { _slotsLoading = true; _selectedSlot = null; _slots = []; });
    final res = await Get.find<VenueService>().getSlots(_selectedVenue!.id!, _dateStr);
    if (!mounted) return;
    setState(() {
      _slotsLoading = false;
      _slots = res.isSuccess ? res.data!.slots : [];
    });
  }

  Future<void> _submit() async {
    if (_selectedVenue == null) {
      setState(() => _error = 'Выберите площадку');
      return;
    }
    if (_selectedSlot == null) {
      setState(() => _error = 'Выберите время');
      return;
    }
    setState(() { _isLoading = true; _error = null; });

    final res = await Get.find<GameService>().createGame({
      'sport': _sports[_selectedSport]['key'],
      'venue': _selectedVenue!.id,
      'venue_name': _selectedVenue!.name,
      'location': _selectedVenue!.address,
      'date': _dateStr,
      'time': _selectedSlot,
      'level': _levels[_selectedLevel]['key'],
      'max_players': _maxPlayers,
    });

    if (!mounted) return;

    if (res.isSuccess) {
      try { Get.find<PlayerGroupController>().fetchGroups(); } catch (_) {}
      Get.back();
      Get.snackbar('', '⚡ Игра создана!',
        backgroundColor: AppColors.confirmGreen,
        colorText: AppColors.background,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    } else {
      setState(() { _isLoading = false; _error = res.error ?? 'Ошибка создания'; });
    }
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection('ВИД СПОРТА', _buildSportPicker()),
                    const SizedBox(height: 24),
                    _buildSection('ПЛОЩАДКА', _buildVenuePicker()),
                    const SizedBox(height: 24),
                    _buildSection('ДАТА', _buildDatePicker()),
                    const SizedBox(height: 24),
                    if (_selectedVenue != null)
                      _buildSection('ВРЕМЯ', _buildSlotsPicker()),
                    if (_selectedVenue != null) const SizedBox(height: 24),
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
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 18),
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
          color: AppColors.textSecondary, letterSpacing: 1.5,
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
                color: isSelected ? AppColors.accent.withValues(alpha: 0.1) : AppColors.cardBackground,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? AppColors.accent : AppColors.divider,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_sports[i]['emoji']!, style: const TextStyle(fontSize: 28)),
                  const SizedBox(height: 6),
                  Text(_sports[i]['name']!, style: AppTextStyles.bodySM.copyWith(
                    color: isSelected ? AppColors.accent : AppColors.textSecondary,
                    fontSize: 10,
                  )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVenuePicker() {
    final venueCtrl = Get.find<VenueController>();
    return Obx(() {
      if (venueCtrl.isLoading.value) {
        return const Center(child: CircularProgressIndicator(color: AppColors.accent));
      }
      final venues = venueCtrl.venues;
      if (venues.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: Text('Площадок пока нет. Добавьте через admin-панель.',
              style: AppTextStyles.bodySM),
        );
      }
      return Column(
        children: venues.map((venue) {
          final isSelected = _selectedVenue?.id == venue.id;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedVenue = venue);
              _loadSlots();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accent.withValues(alpha: 0.08) : AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.accent : AppColors.divider,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.stadium_outlined,
                      color: isSelected ? AppColors.accent : AppColors.textSecondary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(venue.name, style: AppTextStyles.labelBold.copyWith(
                          color: isSelected ? AppColors.accent : AppColors.textPrimary,
                        )),
                        Text(venue.address, style: AppTextStyles.bodySM.copyWith(fontSize: 11)),
                      ],
                    ),
                  ),
                  Text(venue.price, style: AppTextStyles.accentBold.copyWith(fontSize: 11)),
                  if (isSelected) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.check_circle, color: AppColors.accent, size: 20),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _buildDatePicker() {
    final dateDisp =
        '${_selectedDate.day.toString().padLeft(2, '0')}.${_selectedDate.month.toString().padLeft(2, '0')}.${_selectedDate.year}';
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          builder: (ctx, child) => Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: const ColorScheme.dark(
                primary: AppColors.accent, surface: AppColors.cardBackground),
            ),
            child: child!,
          ),
        );
        if (picked != null) {
          setState(() { _selectedDate = picked; _selectedSlot = null; });
          if (_selectedVenue != null) _loadSlots();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, color: AppColors.accent, size: 18),
            const SizedBox(width: 10),
            Text(dateDisp, style: AppTextStyles.labelBold),
            const Spacer(),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildSlotsPicker() {
    if (_slotsLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.accent));
    }
    if (_slots.isEmpty) {
      return Text('Нет доступных слотов', style: AppTextStyles.bodySM);
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _slots.map((slot) {
        final isSelected = _selectedSlot == slot.time;
        return GestureDetector(
          onTap: slot.available ? () => setState(() => _selectedSlot = slot.time) : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: !slot.available
                  ? AppColors.surface
                  : isSelected
                      ? AppColors.accent
                      : AppColors.cardBackground,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: !slot.available
                    ? AppColors.divider
                    : isSelected
                        ? AppColors.accent
                        : AppColors.divider,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  slot.time,
                  style: AppTextStyles.labelBold.copyWith(
                    color: !slot.available
                        ? AppColors.textSecondary
                        : isSelected
                            ? AppColors.background
                            : AppColors.textPrimary,
                  ),
                ),
                if (!slot.available)
                  Text('занято', style: AppTextStyles.bodySM.copyWith(
                    fontSize: 9, color: AppColors.dangerRed,
                  )),
              ],
            ),
          ),
        );
      }).toList(),
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
                color: isSelected ? AppColors.accent : AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isSelected ? AppColors.accent : AppColors.divider),
              ),
              child: Center(
                child: Text(_levels[i]['label']!, style: AppTextStyles.bodySM.copyWith(
                  color: isSelected ? AppColors.background : AppColors.textSecondary,
                  fontWeight: FontWeight.w700, fontSize: 12,
                )),
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
            onTap: () { if (_maxPlayers > 2) setState(() => _maxPlayers--); },
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.divider),
              ),
              child: const Icon(Icons.remove, color: AppColors.textPrimary, size: 20),
            ),
          ),
          Expanded(
            child: Center(child: Text('$_maxPlayers',
                style: AppTextStyles.headingXL.copyWith(color: AppColors.accent))),
          ),
          GestureDetector(
            onTap: () { if (_maxPlayers < 22) setState(() => _maxPlayers++); },
            child: Container(
              width: 40, height: 40,
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
    return Column(
      children: [
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(_error!,
                style: AppTextStyles.bodySM.copyWith(color: AppColors.dangerRed),
                textAlign: TextAlign.center),
          ),
        GestureDetector(
          onTap: _isLoading ? null : _submit,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: _isLoading
                  ? const SizedBox(width: 22, height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.background))
                  : Text('⚡ СОЗДАТЬ ИГРУ',
                      style: AppTextStyles.headingMD.copyWith(color: AppColors.background)),
            ),
          ),
        ),
      ],
    );
  }
}
