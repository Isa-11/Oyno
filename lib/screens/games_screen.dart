import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';
import '../controllers/player_group_controller.dart';
import '../models/models.dart' show PlayerGroup;
import '../widgets/player_card.dart';
import '../widgets/shimmer_loader.dart';
import '../widgets/error_state.dart';
import '../widgets/empty_state.dart';
import 'create_game_screen.dart';

class GamesScreen extends StatefulWidget {
  const GamesScreen({super.key});

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen>
    {
  final TextEditingController _searchCtrl = TextEditingController();

  String _selectedSport = 'all';
  String _selectedDateMode = 'all';
  String _selectedDistrict = 'all';
  DateTime? _customDate;
  String _searchQuery = '';

  static const Map<String, String?> _sportMap = {
    'all': null,
    'football': 'football',
    'basketball': 'basketball',
    'tennis': 'tennis',
  };

  static const List<Map<String, String>> _districtFilters = [
    {'key': 'all', 'label': 'Все районы'},
    {'key': 'center', 'label': 'Центр'},
    {'key': 'south', 'label': 'Южные магистрали'},
    {'key': 'east5', 'label': 'Восток-5'},
  ];

  @override
  void initState() {
    super.initState();
    Get.find<PlayerGroupController>().fetchGroups(
      sport: _sportMap[_selectedSport],
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildCompactFilters(),
            Expanded(
              child: Obx(() {
                final ctrl = Get.find<PlayerGroupController>();
                if (ctrl.isLoading.value) {
                  return const ShimmerLoader(itemCount: 5, itemHeight: 94);
                }
                if (ctrl.error.value.isNotEmpty) {
                  return ErrorState(
                    message: ctrl.error.value,
                    onRetry: () => ctrl.fetchGroups(sport: _sportMap[_selectedSport]),
                  );
                }
                return _buildGamesList(_applyFilters(ctrl.groups));
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Row(
        children: [
          Expanded(
            child: Text('ИГРЫ', style: AppTextStyles.headingXL),
          ),
          GestureDetector(
            onTap: () => Get.to(() => const CreateGameScreen()),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add, color: AppColors.background, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'ИГРА',
                    style: AppTextStyles.labelBold.copyWith(color: AppColors.background),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            const Icon(Icons.search, color: AppColors.textSecondary, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _searchQuery = v.trim().toLowerCase()),
                style: AppTextStyles.bodySM,
                decoration: InputDecoration(
                  hintText: 'Поиск по площадке или району',
                  hintStyle: AppTextStyles.bodySM,
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
            if (_searchQuery.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _searchCtrl.clear();
                  setState(() => _searchQuery = '');
                },
                child: const Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: Icon(Icons.close, color: AppColors.textSecondary, size: 18),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactFilters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterChip('Все', _selectedSport == 'all', () => _onSportChanged('all')),
                const SizedBox(width: 8),
                _filterChip('Футбол', _selectedSport == 'football', () => _onSportChanged('football')),
                const SizedBox(width: 8),
                _filterChip('Баскетбол', _selectedSport == 'basketball', () => _onSportChanged('basketball')),
                const SizedBox(width: 8),
                _filterChip('Теннис', _selectedSport == 'tennis', () => _onSportChanged('tennis')),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _filterChip('Все даты', _selectedDateMode == 'all', () {
                        setState(() {
                          _selectedDateMode = 'all';
                          _customDate = null;
                        });
                      }),
                      const SizedBox(width: 8),
                      _filterChip('Сегодня', _selectedDateMode == 'today', () {
                        setState(() {
                          _selectedDateMode = 'today';
                          _customDate = null;
                        });
                      }),
                      const SizedBox(width: 8),
                      _filterChip('Завтра', _selectedDateMode == 'tomorrow', () {
                        setState(() {
                          _selectedDateMode = 'tomorrow';
                          _customDate = null;
                        });
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _openAdvancedFilters,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: const Icon(Icons.tune, color: AppColors.textPrimary, size: 18),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.accent : AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isActive ? AppColors.accent : AppColors.divider,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySM.copyWith(
            color: isActive ? AppColors.background : AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Future<void> _openAdvancedFilters() async {
    var localDistrict = _selectedDistrict;
    var localDateMode = _selectedDateMode;
    var localCustomDate = _customDate;

    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Фильтры', style: AppTextStyles.headingMD),
                  const SizedBox(height: 16),
                  Text('Дата', style: AppTextStyles.bodySM.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _filterChip('Все даты', localDateMode == 'all', () => setSheetState(() {
                        localDateMode = 'all';
                        localCustomDate = null;
                      })),
                      _filterChip('Сегодня', localDateMode == 'today', () => setSheetState(() {
                        localDateMode = 'today';
                        localCustomDate = null;
                      })),
                      _filterChip('Завтра', localDateMode == 'tomorrow', () => setSheetState(() {
                        localDateMode = 'tomorrow';
                        localCustomDate = null;
                      })),
                      _filterChip('Выбрать дату', localDateMode == 'custom', () async {
                        final now = DateTime.now();
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: localCustomDate ?? now,
                          firstDate: DateTime(now.year, now.month, now.day),
                          lastDate: now.add(const Duration(days: 120)),
                        );
                        if (picked == null) return;
                        setSheetState(() {
                          localDateMode = 'custom';
                          localCustomDate = DateTime(picked.year, picked.month, picked.day);
                        });
                      }),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('Район', style: AppTextStyles.bodySM.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _districtFilters.map((item) {
                      return _filterChip(
                        item['label']!,
                        localDistrict == item['key'],
                        () => setSheetState(() => localDistrict = item['key']!),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _selectedDistrict = 'all';
                              _selectedDateMode = 'all';
                              _customDate = null;
                            });
                            Get.back();
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.divider),
                            foregroundColor: AppColors.textPrimary,
                          ),
                          child: const Text('Сбросить'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedDistrict = localDistrict;
                              _selectedDateMode = localDateMode;
                              _customDate = localCustomDate;
                            });
                            Get.back();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: AppColors.background,
                          ),
                          child: const Text('Применить'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _onSportChanged(String sportKey) async {
    setState(() => _selectedSport = sportKey);
    await Get.find<PlayerGroupController>().fetchGroups(
      sport: _sportMap[sportKey],
    );
  }

  List<PlayerGroup> _applyFilters(List<PlayerGroup> groups) {
    final targetDate = _resolveTargetDate();
    return groups.where((g) {
      if (!_matchDate(g, targetDate)) return false;
      if (!_matchDistrict(g.location)) return false;
      if (!_matchSearch(g)) return false;
      return true;
    }).toList();
  }

  DateTime? _resolveTargetDate() {
    final now = DateTime.now();
    if (_selectedDateMode == 'all') return null;
    if (_selectedDateMode == 'tomorrow') {
      return DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    }
    if (_selectedDateMode == 'custom' && _customDate != null) {
      return _customDate!;
    }
    return DateTime(now.year, now.month, now.day);
  }

  bool _matchDate(PlayerGroup group, DateTime? target) {
    if (target == null) return true;
    final parts = group.time.split('•');
    if (parts.isEmpty) return true;
    final rawDate = parts.first.trim();
    final parsed = DateTime.tryParse(rawDate);
    if (parsed == null) return true;
    return parsed.year == target.year && parsed.month == target.month && parsed.day == target.day;
  }

  bool _matchDistrict(String location) {
    if (_selectedDistrict == 'all') return true;
    final lc = location.toLowerCase();

    switch (_selectedDistrict) {
      case 'center':
        return lc.contains('центр') || lc.contains('moskov') || lc.contains('москов');
      case 'south':
        return lc.contains('юж') || lc.contains('магистрал');
      case 'east5':
        return lc.contains('восток') || lc.contains('east');
      default:
        return true;
    }
  }

  bool _matchSearch(PlayerGroup group) {
    if (_searchQuery.isEmpty) return true;
    final value = '${group.teamName} ${group.location} ${group.sport}'.toLowerCase();
    return value.contains(_searchQuery);
  }

  Widget _buildGamesList(List<PlayerGroup> games) {
    if (games.isEmpty) {
      return EmptyState(
        icon: Icons.sports_outlined,
        message: 'Игр пока нет',
        subtitle: 'Попробуйте изменить фильтры или создайте новую игру',
        actionLabel: 'СОЗДАТЬ ИГРУ',
        onAction: () => Get.to(() => const CreateGameScreen()),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      itemCount: games.length,
      itemBuilder: (_, i) => PlayerCard(group: games[i], compact: true),
    );
  }
}
