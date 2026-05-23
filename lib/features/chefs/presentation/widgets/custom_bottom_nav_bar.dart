import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final String userRole;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.userRole,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 📊 تحديد العناصر بناءً على دور المستخدم (Role-Based Navigation)
    final List<Map<String, dynamic>> navItems = [
      {
        'index': 0,
        'icon': Icons.home_rounded,
        'label': "nav_bar.home".tr(),
        'show': true,
      },
      {
        'index': 1,
        'icon': Icons.chat_rounded,
        'label': "nav_bar.chat".tr(),
        'show': true,
      },
      {
        'index': 2,
        'icon': Icons.menu_book_rounded,
        'label': "nav_bar.training".tr(),
        'show': true,
      },
      {
        'index': 3,
        'icon': Icons.delete_sweep_rounded,
        'label': "nav_bar.waste".tr(),
        'show': true,
      },
    ];

    final visibleItems = navItems.where((item) => item['show'] == true).toList();

    // 🌍 تغليف الـ Container بـ Padding عشان نرفعه ونبعده عن الحواف
    return Padding(
      padding: const EdgeInsets.only(
        left: 16,   // مسافة من الشمال
        right: 16,  // مسافة من اليمين
        bottom: 16, // رفعه لفوق عن قاع الشاشة (سنة بسيطة)
      ),
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          color: Colors.white,
          // 🔄 جعل الـ NavBar دائري بالكامل لأنه أصبح عائماً
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06), // زيادة التظليل خفيف جداً عشان يبرز العوم
              blurRadius: 12,
              offset: const Offset(0, 4), // الظل يتجه لأسفل الكارت عشان يبان مرفوع
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: visibleItems.map((item) {
            return _buildNavItem(
              index: item['index'] as int,
              icon: item['icon'] as IconData,
              label: item['label'] as String,
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildNavItem({required int index, required IconData icon, required String label}) {
    final isSelected = currentIndex == index;

    return InkWell(
      onTap: () => onTap(index),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF4D00).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFFFF4D00) : Colors.grey,
              size: 22,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFFFF4D00) : Colors.grey,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}