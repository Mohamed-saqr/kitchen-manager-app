import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/waste_model.dart';
import 'package:easy_localization/easy_localization.dart'; // 👈 IMPORT

class WasteItemCard extends StatelessWidget {
  final WasteEntry entry;
  final VoidCallback onDelete;

  const WasteItemCard({super.key, required this.entry, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final double percent = entry.calculatedPercent;
    final bool isOverLimit = percent > entry.limit;

    // النص التوضيحي واللون
    final Color statusColor = isOverLimit ? Colors.red : Colors.green;
    final String statusText = isOverLimit ? "النسبة كبيرة" : "تمام ✅";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: statusColor.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(DateFormat('dd').format(entry.date),
                    style: TextStyle(fontWeight: FontWeight.bold, color: statusColor, fontSize: 16)),
                Text(DateFormat('MMM').format(entry.date),
                    style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text("الشيف: ${entry.chef}", style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
                const SizedBox(height: 4),
                Text("إجمالي: ${entry.totalWeight} | هالك: ${entry.wasteWeight}",
                    style: TextStyle(fontSize: 15, color: Colors.grey[600])),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("${percent.toStringAsFixed(1)}%",
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 17)),
              Text(statusText, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
              IconButton(
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 22),
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}