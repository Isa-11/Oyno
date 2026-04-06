import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../controllers/auth_controller.dart';
import '../services/venue_service.dart';
import '../services/booking_service.dart';
import '../widgets/venue_image.dart';
import 'login_screen.dart';

class VenueDetailScreen extends StatefulWidget {
  final Venue venue;
  const VenueDetailScreen({super.key, required this.venue});

  @override
  State<VenueDetailScreen> createState() => _VenueDetailScreenState();
}

class _VenueDetailScreenState extends State<VenueDetailScreen> {
  int? _selectedSlotIndex;
  bool _booking = false;

  // Слоты с бэкенда
  List<VenueSlot> _slots = [];
  bool _loadingSlots = false;
  String? _slotsError;

  // Выбранная дата (сегодня по умолчанию)
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadSlots();
  }

  Future<void> _loadSlots() async {
    setState(() { _loadingSlots = true; _slotsError = null; _selectedSlotIndex = null; });
    final dateStr = _formatDate(_selectedDate);
    final res = await Get.find<VenueService>().getSlots(widget.venue.id ?? 0, dateStr);
    if (!mounted) return;
    if (res.isSuccess && res.data != null) {
      setState(() { _slots = res.data!.slots; _loadingSlots = false; });
    } else {
      setState(() { _slotsError = res.error ?? 'Ошибка загрузки'; _loadingSlots = false; });
    }
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _weekDay(DateTime d) {
    const days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    return days[d.weekday - 1];
  }

  Future<void> _book() async {
    if (_selectedSlotIndex == null || _booking) return;

    final auth = Get.find<AuthController>();
    if (!auth.isLoggedIn.value) {
      final result = await Get.to(() => const LoginScreen());
      if (result != true) return;
    }

    setState(() => _booking = true);

    final slot = _slots[_selectedSlotIndex!];
    final res = await Get.find<BookingService>().createBooking(
      venueId: widget.venue.id ?? 0,
      date: _formatDate(_selectedDate),
      timeSlot: slot.time,
    );

    if (!mounted) return;
    setState(() => _booking = false);

    if (res.isSuccess) {
      _showConfirmDialog(slot.time);
    } else {
      Get.snackbar(
        'Ошибка',
        res.error ?? 'Не удалось забронировать',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.dangerRed,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  void _showConfirmDialog(String time) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('✓', style: TextStyle(fontSize: 36, color: AppColors.accent)),
                ),
              ),
              const SizedBox(height: 20),
              Text('ЗАБРОНИРОВАНО!', style: AppTextStyles.headingMD),
              const SizedBox(height: 10),
              Text(
                widget.venue.name,
                style: AppTextStyles.bodyMD.copyWith(color: AppColors.accent),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                '${_weekDay(_selectedDate)}, ${_selectedDate.day}.${_selectedDate.month.toString().padLeft(2, '0')} · $time',
                style: AppTextStyles.bodySM,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () { Get.back(); Get.back(); },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text('ОТЛИЧНО',
                        style: AppTextStyles.labelBold
                            .copyWith(color: AppColors.background)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
                  SliverToBoxAdapter(child: _buildDatePicker()),
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
        VenueImage(
          imageUrl: widget.venue.imageUrl,
          sport: widget.venue.sport,
          height: 260,
          iconSize: 64,
        ),
        Container(
          height: 260,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [
                AppColors.background.withValues(alpha: 0.6),
                Colors.transparent,
                AppColors.background.withValues(alpha: 0.8),
              ],
            ),
          ),
        ),
        Positioned(
          top: 16, left: 20,
          child: GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 44, height: 44,
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
          top: 16, right: 20,
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
                Text(widget.venue.rating.toString(), style: AppTextStyles.labelBold),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 16, left: 20, right: 20,
          child: Text(widget.venue.name,
              style: AppTextStyles.headingXL.copyWith(color: AppColors.accent)),
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
                _statChip('🕐', '${widget.venue.opensAt}–${widget.venue.closesAt}', 'ЧАСЫ'),
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
              child: Text(text, style: AppTextStyles.bodySM,
                  overflow: TextOverflow.ellipsis),
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

  Widget _divider() => Container(width: 1, height: 44, color: AppColors.divider);

  Widget _buildDescription() {
    final desc = widget.venue.description.trim();
    if (desc.isEmpty) return const SizedBox.shrink();
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
            Text(desc, style: AppTextStyles.bodySM.copyWith(height: 1.6)),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    final today = DateTime.now();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ВЫБРАТЬ ДАТУ', style: AppTextStyles.headingMD),
          const SizedBox(height: 12),
          SizedBox(
            height: 66,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 7,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final date = today.add(Duration(days: i));
                final isSelected = _formatDate(date) == _formatDate(_selectedDate);
                return GestureDetector(
                  onTap: () {
                    setState(() { _selectedDate = date; _selectedSlotIndex = null; });
                    _loadSlots();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 52,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.accent : AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.accent : AppColors.divider,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _weekDay(date),
                          style: AppTextStyles.bodySM.copyWith(
                            fontSize: 11,
                            color: isSelected ? AppColors.background : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${date.day}',
                          style: AppTextStyles.labelBold.copyWith(
                            color: isSelected ? AppColors.background : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
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
          if (_loadingSlots)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: CircularProgressIndicator(color: AppColors.accent),
              ),
            )
          else if (_slotsError != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Text(_slotsError!, style: AppTextStyles.bodySM,
                        textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _loadSlots,
                      child: Text('Повторить',
                          style: AppTextStyles.bodySM
                              .copyWith(color: AppColors.accent)),
                    ),
                  ],
                ),
              ),
            )
          else if (_slots.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text('Нет доступных слотов', style: AppTextStyles.bodySM),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2.2,
              ),
              itemCount: _slots.length,
              itemBuilder: (_, i) {
                final slot = _slots[i];
                final isSelected = _selectedSlotIndex == i;
                final isAvail = slot.available;
                return GestureDetector(
                  onTap: isAvail ? () => setState(() => _selectedSlotIndex = i) : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.accent
                          : isAvail ? AppColors.cardBackground : AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.accent
                            : isAvail ? AppColors.divider : Colors.transparent,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        slot.time,
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
          if (_slots.isNotEmpty && !_loadingSlots) ...[
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
        ],
      ),
    );
  }

  Widget _legend(Color fill, Color border, String label) {
    return Row(
      children: [
        Container(
          width: 14, height: 14,
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
    final selectedTime = _selectedSlotIndex != null
        ? _slots[_selectedSlotIndex!].time
        : null;

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
              Text(widget.venue.price, style: AppTextStyles.headingAccent),
              Text(
                selectedTime != null ? 'Время: $selectedTime' : 'Выберите время',
                style: AppTextStyles.bodySM,
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: selectedTime == null ? null : _book,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: selectedTime != null ? AppColors.accent : AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: _booking
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.background,
                          ),
                        )
                      : Text(
                          'ЗАБРОНИРОВАТЬ',
                          style: AppTextStyles.headingMD.copyWith(
                            color: selectedTime != null
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
