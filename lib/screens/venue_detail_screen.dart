import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';

class VenueDetailScreen extends StatefulWidget {
  final Venue venue;

  const VenueDetailScreen({super.key, required this.venue});

  @override
  State<VenueDetailScreen> createState() => _VenueDetailScreenState();
}

class _VenueDetailScreenState extends State<VenueDetailScreen> {
  int? _selectedSlot;
  bool _booked = false;

  final List<String> _timeSlots = [
    '08:00', '09:00', '10:00', '12:00',
    '14:00', '16:00', '18:00', '20:00',
  ];

  final List<bool> _available = [
    false, true, true, false,
    true, true, false, true,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildImageHeader()),
                  SliverToBoxAdapter(child: _buildInfo()),
                  SliverToBoxAdapter(child: _buildDescription()),
                  SliverToBoxAdapter(child: _buildTimeSlots()),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageHeader() {
    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: 260,
          child: Image.network(
            widget.venue.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: AppColors.surface,
              child: const Icon(Icons.sports, color: AppColors.textSecondary, size: 64),
            ),
          ),
        ),
        Container(
          height: 260,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.background.withValues(alpha: 0.6),
                Colors.transparent,
                AppColors.background.withValues(alpha: 0.8),
              ],
            ),
          ),
        ),
        Positioned(
          top: 16,
          left: 20,
          child: GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.background.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  color: AppColors.textPrimary, size: 18),
            ),
          ),
        ),
        Positioned(
          top: 16,
          right: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.background.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.accent.withValues(alpha: 0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('⭐', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 5),
                Text(
                  widget.venue.rating.toString(),
                  style: AppTextStyles.labelBold,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 16,
          left: 20,
          right: 20,
          child: Text(
            widget.venue.name,
            style: AppTextStyles.headingXL.copyWith(color: AppColors.accent),
          ),
        ),
      ],
    );
  }

  Widget _buildInfo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        children: [
          Row(
            children: [
              _infoChip(Icons.location_on_outlined, widget.venue.address),
              const SizedBox(width: 12),
              _infoChip(Icons.sports_soccer, widget.venue.sport),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statChip('💰', widget.venue.price, 'ЦЕНА'),
                _divider(),
                _statChip('⭐', '${widget.venue.rating}', 'РЕЙТИНГ'),
                _divider(),
                _statChip('🏟️', '1000 М²', 'ПЛОЩАДЬ'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 15),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                text,
                style: AppTextStyles.bodySM,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statChip(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 6),
        Text(value, style: AppTextStyles.labelBold),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.bodySM.copyWith(fontSize: 10)),
      ],
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 44, color: AppColors.divider);
  }

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('О ПЛОЩАДКЕ', style: AppTextStyles.headingMD),
            const SizedBox(height: 10),
            Text(
              'Профессиональная площадка с современным покрытием. '
              'Раздевалки, душевые, парковка. Аренда инвентаря доступна на месте. '
              'Трибуны для зрителей, освещение для вечерних игр.',
              style: AppTextStyles.bodySM.copyWith(height: 1.6),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['🚿 Душевые', '🅿️ Парковка', '💡 Освещение', '👕 Аренда формы']
                  .map((tag) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Text(tag, style: AppTextStyles.bodySM),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlots() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ВЫБРАТЬ ВРЕМЯ', style: AppTextStyles.headingMD),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.2,
            ),
            itemCount: _timeSlots.length,
            itemBuilder: (_, i) {
              final isSelected = _selectedSlot == i;
              final isAvail = _available[i];
              return GestureDetector(
                onTap: isAvail ? () => setState(() => _selectedSlot = i) : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.accent
                        : isAvail
                            ? AppColors.cardBackground
                            : AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.accent
                          : isAvail
                              ? AppColors.divider
                              : Colors.transparent,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _timeSlots[i],
                      style: AppTextStyles.labelBold.copyWith(
                        color: isSelected
                            ? AppColors.background
                            : isAvail
                                ? AppColors.textPrimary
                                : AppColors.textSecondary.withValues(alpha: 0.4),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _legend(AppColors.cardBackground, AppColors.divider, 'Свободно'),
              const SizedBox(width: 16),
              _legend(AppColors.surface, Colors.transparent, 'Занято'),
              const SizedBox(width: 16),
              _legend(AppColors.accent, AppColors.accent, 'Выбрано'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legend(Color fill, Color border, String label) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: border, width: 1),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppTextStyles.bodySM.copyWith(fontSize: 11)),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.venue.price,
                style: AppTextStyles.headingAccent,
              ),
              Text(
                _selectedSlot != null
                    ? 'Время: ${_timeSlots[_selectedSlot!]}'
                    : 'Выберите время',
                style: AppTextStyles.bodySM,
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: _selectedSlot == null
                  ? null
                  : () {
                      setState(() => _booked = true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.confirmGreen,
                          content: Text(
                            '✓ Забронировано на ${_timeSlots[_selectedSlot!]}!',
                            style: AppTextStyles.labelBold
                                .copyWith(color: Colors.white),
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                      Future.delayed(const Duration(seconds: 2), () => Get.back());
                    },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: _selectedSlot != null ? AppColors.accent : AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    _booked ? '✓ ЗАБРОНИРОВАНО' : 'ЗАБРОНИРОВАТЬ',
                    style: AppTextStyles.headingMD.copyWith(
                      color: _selectedSlot != null
                          ? AppColors.background
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
