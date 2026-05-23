import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';

class ChefKPISection extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isAdmin;
  final Function(String key, double value) onUpdate;

  const ChefKPISection({
    super.key,
    required this.data,
    required this.isAdmin,
    required this.onUpdate,
  });

  double _toDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString()) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.analytics_outlined, color: Color(0xFFFF4D00)),
            const SizedBox(width: 8),
            Text("chef_details.kpi.title".tr(),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 15),

        _buildRatingSlider("chef_details.kpi.attendance".tr(), "attendance", Colors.orange),
        _buildRatingSlider("chef_details.kpi.food_safety".tr(), "food_safety", Colors.green),
        _buildRatingSlider("chef_details.kpi.hygiene".tr(), "hygiene", Colors.blue),
        _buildRatingSlider("chef_details.kpi.waste_control".tr(), "waste_control", Colors.red),

        const SizedBox(height: 25),
        _buildOverallRatingCard(),
      ],
    );
  }

  Widget _buildRatingSlider(String title, String key, Color color) {
    double currentValue = _toDouble(data[key]);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200), // تحسين الحدود
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${currentValue.toStringAsFixed(1)} / 5.0", // دقة أكثر في العرض
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          Slider(
            value: currentValue.clamp(0.0, 5.0),
            min: 0,
            max: 5,
            // تقسيم الـ Slider إلى 10 أجزاء يعطي دقة 0.5 بدلاً من 1.0 (اختياري)
            divisions: 10,
            label: currentValue.toStringAsFixed(1), // يظهر الرقم فوق الـ Slider أثناء السحب
            activeColor: isAdmin ? color : Colors.grey,
            onChanged: isAdmin
                ? (val) {
              HapticFeedback.selectionClick(); // رد فعل لمسي أكثر دقة
              onUpdate(key, double.parse(val.toStringAsFixed(1)));
            }
                : null,
          ),
        ],
      ),
    );
  }  Widget _buildOverallRatingCard() {
    double rating = _toDouble(data['rating']);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF4511E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text("chef_details.kpi.overall".tr(), style: const TextStyle(color: Colors.white)),
          Text(rating.toStringAsFixed(1), style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}