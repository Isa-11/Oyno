import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/venue_service.dart';

class OwnerVenuesScreen extends StatefulWidget {
  const OwnerVenuesScreen({super.key});

  @override
  State<OwnerVenuesScreen> createState() => _OwnerVenuesScreenState();
}

class _OwnerVenuesScreenState extends State<OwnerVenuesScreen> {
  final VenueService _venueService = Get.find<VenueService>();
  List<Venue> _myVenues = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVenues();
  }

  Future<void> _loadVenues() async {
    setState(() => _isLoading = true);
    final res = await _venueService.getMyVenues();
    if (res.isSuccess && res.data != null) {
      if (mounted) setState(() => _myVenues = res.data!);
    } else {
      if (mounted) setState(() => _myVenues = []);
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: _isLoading 
                  ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
                  : _myVenues.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          itemCount: _myVenues.length,
                          itemBuilder: (ctx, i) => _buildVenueTile(ctx, _myVenues[i]),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        children: [
          Expanded(child: Text('МОИ ПЛОЩАДКИ', style: AppTextStyles.headingXL)),
          GestureDetector(
            onTap: () => _showAddVenueSheet(context),
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.add, color: AppColors.background, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.divider),
              ),
              child: const Icon(Icons.store_outlined,
                  color: AppColors.textSecondary, size: 36),
            ),
            const SizedBox(height: 20),
            Text(
              'У вас нет площадок',
              style: AppTextStyles.headingMD,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Добавьте свою первую площадку, чтобы начать принимать бронирования',
              style: AppTextStyles.bodySM,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            Builder(builder: (context) => GestureDetector(
              onTap: () => _showAddVenueSheet(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'ДОБАВИТЬ ПЛОЩАДКУ',
                  style: AppTextStyles.labelBold.copyWith(color: AppColors.background),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildVenueTile(BuildContext context, Venue venue) {
    return GestureDetector(
      onTap: () => _showEditVenueSheet(context, venue),
      child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider, width: 0.8),
      ),
      child: Row(
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider, width: 0.8),
            ),
            child: const Icon(Icons.sports_soccer,
                color: AppColors.accent, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(venue.name, style: AppTextStyles.labelBold),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        color: AppColors.textSecondary, size: 12),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        venue.address,
                        style: AppTextStyles.bodySM.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.attach_money,
                        color: AppColors.accent, size: 12),
                    const SizedBox(width: 2),
                    Text(
                      venue.price,
                      style: AppTextStyles.bodySM.copyWith(
                        fontSize: 12,
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios,
              color: AppColors.textSecondary, size: 14),
        ],
      ),
    ),
    );
  }

  void _showEditVenueSheet(BuildContext context, Venue venue) {
    final nameCtrl = TextEditingController(text: venue.name);
    final addressCtrl = TextEditingController(text: venue.address);
    final descCtrl = TextEditingController(text: venue.description);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('РЕДАКТИРОВАТЬ ПЛОЩАДКУ', style: AppTextStyles.headingMD),
            const SizedBox(height: 20),
            _sheetField('НАЗВАНИЕ', nameCtrl, hint: venue.name),
            const SizedBox(height: 12),
            _sheetField('АДРЕС', addressCtrl, hint: venue.address),
            const SizedBox(height: 12),
            _sheetField('ОПИСАНИЕ', descCtrl, hint: 'Краткое описание площадки...', maxLines: 3),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () async {
                final name = nameCtrl.text.trim();
                final address = addressCtrl.text.trim();
                final desc = descCtrl.text.trim();

                if (name.isEmpty || address.isEmpty) {
                  Get.snackbar('Ошибка', 'Название и адрес обязательны');
                  return;
                }

                final data = {
                  'name': name,
                  'address': address,
                  'description': desc,
                  'sport': venue.sport,
                  'price_per_hour': venue.price.replaceAll(RegExp(r'[^0-9]'), ''),
                };

                // PATCH через обновление площадки — используем PUT на venues/{id}/
                final res = await _venueService.updateVenue(venue.id!, data);

                if (res.isSuccess) {
                  Get.back();
                  Get.snackbar(
                    'Готово',
                    'Площадка обновлена',
                    backgroundColor: AppColors.cardBackground,
                    colorText: AppColors.textPrimary,
                    snackPosition: SnackPosition.BOTTOM,
                  );
                  _loadVenues();
                } else {
                  Get.snackbar('Ошибка', res.error ?? 'Не удалось сохранить');
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'СОХРАНИТЬ',
                    style: AppTextStyles.labelBold.copyWith(color: AppColors.background),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddVenueSheet(BuildContext context) {
    final nameCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final priceCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('НОВАЯ ПЛОЩАДКА', style: AppTextStyles.headingMD),
            const SizedBox(height: 20),
            _sheetField('НАЗВАНИЕ', nameCtrl, hint: 'Например: Спортком Арена'),
            const SizedBox(height: 12),
            _sheetField('АДРЕС', addressCtrl, hint: 'ул. Московская 45'),
            const SizedBox(height: 12),
            _sheetField('ЦЕНА ЗА ЧАС', priceCtrl,
                hint: '800 сом/час',
                keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () async {
                final name = nameCtrl.text.trim();
                final address = addressCtrl.text.trim();
                final price = priceCtrl.text.trim();
                
                if (name.isEmpty || address.isEmpty || price.isEmpty) {
                  Get.snackbar('Ошибка', 'Заполните все поля');
                  return;
                }

                final data = {
                  'name': name,
                  'address': address,
                  'price_per_hour': price.replaceAll(RegExp(r'[^0-9]'), ''),
                  'sport': 'football', // Default
                  'description': '',
                };

                final res = await _venueService.createVenue(data);

                if (res.isSuccess) {
                  Get.back();
                  Get.snackbar(
                    'Готово',
                    'Площадка "$name" добавлена',
                    backgroundColor: AppColors.cardBackground,
                    colorText: AppColors.textPrimary,
                    snackPosition: SnackPosition.BOTTOM,
                  );
                  _loadVenues();
                } else {
                  Get.snackbar('Ошибка', res.error ?? 'Произошла ошибка при добавлении');
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'ДОБАВИТЬ',
                    style: AppTextStyles.labelBold
                        .copyWith(color: AppColors.background),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sheetField(String label, TextEditingController ctrl,
      {String? hint, TextInputType? keyboardType, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySM.copyWith(
            fontSize: 11,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: TextField(
            controller: ctrl,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: AppTextStyles.bodyMD,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.bodySM,
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}
