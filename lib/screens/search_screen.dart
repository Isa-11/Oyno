import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/venue_service.dart';
import '../services/game_service.dart';
import '../widgets/venue_card.dart';
import '../widgets/game_card.dart';
import '../widgets/shimmer_loader.dart';
import '../widgets/empty_state.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final RxList<Venue> _venueResults = <Venue>[].obs;
  final RxList<GameItem> _gameResults = <GameItem>[].obs;
  final RxBool _isSearching = false.obs;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.isEmpty) {
      _venueResults.clear();
      _gameResults.clear();
      return;
    }
    _isSearching.value = true;
    _searchQuery = query.toLowerCase();

    try {
      final venueRes = await Get.find<VenueService>().getVenues();
      final gameRes = await Get.find<GameService>().getUpcomingGames();

      if (venueRes.isSuccess && venueRes.data != null) {
        final filtered = venueRes.data!
            .where((v) =>
                v.name.toLowerCase().contains(_searchQuery) ||
                v.address.toLowerCase().contains(_searchQuery) ||
                v.sport.toLowerCase().contains(_searchQuery))
            .toList();
        _venueResults.assignAll(filtered);
      }

      if (gameRes.isSuccess && gameRes.data != null) {
        final filtered = gameRes.data!
            .where((g) =>
                g.venueName.toLowerCase().contains(_searchQuery) ||
                g.location.toLowerCase().contains(_searchQuery) ||
                g.sport.toLowerCase().contains(_searchQuery))
            .toList();
        _gameResults.assignAll(filtered);
      }
    } finally {
      _isSearching.value = false;
    }
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
            Expanded(
              child: _searchQuery.isEmpty
                  ? _buildInitialState()
                  : _buildSearchResults(),
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
          Text('ПОИСК', style: AppTextStyles.headingMD),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            const Icon(Icons.search, color: AppColors.textSecondary, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                onChanged: _search,
                style: AppTextStyles.bodySM,
                decoration: InputDecoration(
                  hintText: 'Поиск площадки или игры...',
                  hintStyle: AppTextStyles.bodySM,
                  border: InputBorder.none,
                ),
              ),
            ),
            if (_searchQuery.isNotEmpty)
              IconButton(
                onPressed: () {
                  _searchCtrl.clear();
                  _search('');
                  setState(() {});
                },
                icon: const Icon(Icons.close, color: AppColors.textSecondary, size: 18),
              )
            else
              const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialState() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_rounded, size: 64, color: AppColors.textSecondary.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text('Начните поиск', style: AppTextStyles.bodyMD.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Text('Ищите площадки и игры по названию, спорту или месторасположению',
              style: AppTextStyles.bodySM.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return Obx(() {
      if (_isSearching.value) {
        return const ShimmerLoader(itemCount: 3, itemHeight: 100);
      }

      final hasVenues = _venueResults.isNotEmpty;
      final hasGames = _gameResults.isNotEmpty;

      if (!hasVenues && !hasGames) {
        return const EmptyState(
          icon: Icons.search_off_rounded,
          message: 'Ничего не найдено',
          subtitle: 'Попробуйте другой запрос',
        );
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasVenues) ...[
              Text('ПЛОЩАДКИ (${_venueResults.length})', style: AppTextStyles.headingMD),
              const SizedBox(height: 12),
              ..._venueResults.map((v) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: VenueCard(venue: v),
              )),
              const SizedBox(height: 20),
            ],
            if (hasGames) ...[
              Text('ИГРЫ (${_gameResults.length})', style: AppTextStyles.headingMD),
              const SizedBox(height: 12),
              ..._gameResults.map((g) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GameCard(game: g),
              )),
            ],
          ],
        ),
      );
    });
  }
}
