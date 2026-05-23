import 'package:flutter/material.dart';

class RoleGuard extends StatelessWidget {
  final String userRole; // الدور الحالي للمستخدم
  final List<String> allowedRoles; // الأدوار المسموح لها
  final Widget child; // الجزء المراد إظهاره

  const RoleGuard({
    super.key,
    required this.userRole,
    required this.allowedRoles,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // 1. تحويل دور المستخدم الحالي إلى حروف صغيرة وحذف أي مسافات
    final String normalizedUserRole = userRole.toLowerCase().trim();

    // 2. تحويل قائمة الأدوار المسموحة إلى حروف صغيرة وحذف المسافات
    final List<String> normalizedAllowedRoles = allowedRoles
        .map((role) => role.toLowerCase().trim())
        .toList();

    // 3. التحقق من وجود الدور الحالي ضمن القائمة المسموحة
    if (normalizedAllowedRoles.contains(normalizedUserRole)) {
      return child;
    }

    // 4. في حالة عدم التطابق، إرجاع عنصر فارغ لا يشغل مساحة
    return const SizedBox.shrink();
  }
}
