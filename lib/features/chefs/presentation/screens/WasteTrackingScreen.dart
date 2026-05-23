import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:easy_localization/easy_localization.dart'; // 👈 لا تنسَ هذا الـ Import
import '../../data/models/waste_model.dart';
import '../widgets/WasteItemCard.dart';

class WasteTrackingScreen extends StatefulWidget {
  const WasteTrackingScreen({super.key});

  @override
  State<WasteTrackingScreen> createState() => _WasteTrackingScreenState();
}

class _WasteTrackingScreenState extends State<WasteTrackingScreen> {
  late final Box wasteBox;
  late final Box chefsBox;

  final nameController = TextEditingController();
  final chefNameController = TextEditingController();
  final limitController = TextEditingController();
  final reasonController = TextEditingController();
  final beforeController = TextEditingController();
  final afterController = TextEditingController();

  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    wasteBox = Hive.box('wasteBox');
    chefsBox = Hive.box('chefsBox');
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _addWasteEntry() {
    final String name = nameController.text;
    final String chefName = chefNameController.text;
    final double? before = double.tryParse(beforeController.text);
    final double? after = double.tryParse(afterController.text);
    final double? limit = double.tryParse(limitController.text) ?? 10.0;

    if (name.isEmpty || before == null || after == null || before <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("waste_screen.error".tr(), style: const TextStyle(fontWeight: FontWeight.bold))));
      return;
    }

    final double lossWeight = (before - after).clamp(0, before);
    // ... باقي منطق الحسابات كما هو

    final newEntry = {
      "name": name,
      "chef": chefName,
      "reason": reasonController.text,
      "limit": limit,
      "totalWeight": before,
      "wasteWeight": lossWeight,
      "date": selectedDate.toIso8601String(),
    };

    wasteBox.add(newEntry);
    _clearControllers();
    setState(() { selectedDate = DateTime.now(); });
  }

  void _clearControllers() {
    nameController.clear();
    chefNameController.clear();
    limitController.clear();
    reasonController.clear();
    beforeController.clear();
    afterController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text("waste_screen.title".tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        toolbarHeight: 50,
      ),
      body: Column(
        children: [
          SingleChildScrollView(child: _buildInputSection()),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text("waste_screen.recent".tr(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: wasteBox.listenable(),
              builder: (context, Box box, _) {
                if (box.isEmpty) return Center(child: Text("waste_screen.no_entries".tr(), style: const TextStyle(fontWeight: FontWeight.bold)));
                final keys = box.keys.toList().reversed.toList();
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  itemCount: keys.length,
                  itemBuilder: (context, index) {
                    final key = keys[index];
                    final rawData = box.get(key);
                    final entry = WasteEntry.fromMap(Map<String, dynamic>.from(rawData), key.toString());
                    return WasteItemCard(entry: entry, onDelete: () => box.delete(key));
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 8)]),
        child: Column(
          children: [
            _buildField(nameController, "waste_screen.name".tr()),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _buildField(chefNameController, "waste_screen.chef".tr())),
              const SizedBox(width: 10),
              Expanded(child: _buildField(limitController, "waste_screen.limit".tr(), isNum: true)),
            ]),
            const SizedBox(height: 10),
            _buildField(reasonController, "waste_screen.reason".tr()),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _buildField(beforeController, "waste_screen.before".tr(), isNum: true)),
              const SizedBox(width: 10),
              Expanded(child: _buildField(afterController, "waste_screen.after".tr(), isNum: true)),
            ]),
            const SizedBox(height: 10),
            InkWell(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                child: Row(children: [
                  const Icon(Icons.calendar_today, color: Color(0xFFB12C05), size: 16),
                  const SizedBox(width: 8),
                  Text("${"waste_screen.date".tr()}: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  const Icon(Icons.edit, size: 14, color: Colors.blue),
                ]),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB12C05), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                onPressed: _addWasteEntry,
                child: Text("waste_screen.btn".tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, {bool isNum = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNum ? TextInputType.number : TextInputType.text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        border: const OutlineInputBorder(),
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}