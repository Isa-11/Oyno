import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SportFilterChips extends StatefulWidget {
  const SportFilterChips({super.key});

  @override
  State<SportFilterChips> createState() => _SportFilterChipsState();
}

class _SportFilterChipsState extends State<SportFilterChips> {
  int _selectedIndex = 0;

  final List<Map<String, String>> _filters = [
    {'label': 'ВСЕ', 'emoji': '⭐'},
    {'label': 'ФУТБОЛ', 'emoji': '⚽'},
    {'label': 'БАСКЕТ', 'emoji': '🏀'},
    {'label': 'ПЛАВАНИЕ', 'emoji': '🏊'},
    {'label': 'ВОЛЕЙ', 'emoji': '🏐'},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final isActive = _selectedIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isActive ? AppColors.accent : AppColors.cardBackground,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isActive ? AppColors.accent : AppColors.divider,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _filters[index]['emoji']!,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _filters[index]['label']!,
                    style: TextStyle(
                      color: isActive ? AppColors.background : AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
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
}
