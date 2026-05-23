import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../data/models/chef_model.dart';
import '../widgets/chef_kpi_section.dart';

class ChefDetailsScreen extends StatefulWidget {
  final ChefModel chef;
  final String docId;
  final String userRole;

  const ChefDetailsScreen({
    super.key,
    required this.chef,
    required this.docId,
    required this.userRole,
  });

  @override
  State<ChefDetailsScreen> createState() => _ChefDetailsScreenState();
}

class _ChefDetailsScreenState extends State<ChefDetailsScreen> {
  late Map<String, dynamic> updatedData;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    updatedData = widget.chef.toMap();
  }

  void _updateValuesLocally(String category, dynamic value) {
    setState(() {
      updatedData[category] = value;
      // إعادة حساب التقييم العام فوراً عند تحريك أي سلايدر
      if ([
        'attendance',
        'hygiene',
        'food_safety',
        'waste_control',
      ].contains(category)) {
        double attendance = (updatedData['attendance'] ?? 0.0).toDouble();
        double hygiene = (updatedData['hygiene'] ?? 0.0).toDouble();
        double foodSafety = (updatedData['food_safety'] ?? 0.0).toDouble();
        double wasteControl = (updatedData['waste_control'] ?? 0.0).toDouble();

        double totalAvg =
            (attendance + hygiene + foodSafety + wasteControl) / 4;
        updatedData['rating'] = double.parse(totalAvg.toStringAsFixed(1));
      }
    });
  }

  Future<void> _confirmAndSave() async {
    setState(() => isSaving = true);
    try {
      await FirebaseFirestore.instance
          .collection('chefs')
          .doc(widget.docId)
          .update(updatedData);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("chef_details.save_success".tr())),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${"chef_details.save_error".tr()}$e")),
        );
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = widget.userRole.toLowerCase().trim() == 'admin';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          "chef_details.title".tr(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(
              child: Text(
                isAdmin
                    ? "chef_details.admin".tr()
                    : "chef_details.view_only".tr(),
                style: TextStyle(
                  color: isAdmin ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: isSaving
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF4D00)),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildImageHeader(),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildDataCard(
                          "chef_details.fields.name".tr(),
                          "name",
                          Icons.person,
                          isAdmin,
                        ),
                        _buildDataCard(
                          "chef_details.fields.position".tr(),
                          "position",
                          Icons.work,
                          isAdmin,
                        ),
                        _buildDataCard(
                          "chef_details.fields.specialty".tr(),
                          "specialty",
                          Icons.restaurant_menu,
                          isAdmin,
                        ),
                        const Divider(height: 40),
                        _buildDataCard(
                          "chef_details.fields.national_id".tr(),
                          "nationalId",
                          Icons.badge,
                          isAdmin,
                        ),
                        _buildDataCard(
                          "chef_details.fields.address".tr(),
                          "address",
                          Icons.location_on,
                          isAdmin,
                        ),
                        _buildDataCard(
                          "chef_details.fields.phone".tr(),
                          "phone",
                          Icons.phone,
                          isAdmin,
                        ),
                        const SizedBox(height: 25),

                        // تمرير الـ updatedData والـ setState لضمان عمل السلايدر
                        ChefKPISection(
                          data: updatedData,
                          isAdmin: isAdmin,
                          onUpdate: (key, val) =>
                              _updateValuesLocally(key, val),
                        ),

                        const SizedBox(height: 30),
                        if (isAdmin) _saveButton(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDataCard(String label, String key, IconData icon, bool isAdmin) {
    final dynamic val = updatedData[key];
    String value = (val is Map) ? "..." : (val?.toString() ?? "غير مسجل");

    return InkWell(
      onTap: isAdmin ? () => _showEditDialog(label, key, val) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFFF4D00), size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            if (isAdmin) const Icon(Icons.edit_note, color: Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildImageHeader() {
    final imagePath = updatedData["image"]?.toString();
    final bool hasImage = imagePath != null && imagePath.isNotEmpty;

    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        image: hasImage
            ? DecorationImage(
                image: imagePath.startsWith('http')
                    ? NetworkImage(imagePath) as ImageProvider
                    : FileImage(File(imagePath)),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: !hasImage
          ? const Icon(Icons.person, size: 80, color: Colors.grey)
          : null,
    );
  }

  Widget _saveButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF4D00),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: _confirmAndSave,
        child: Text(
          "chef_details.save_btn".tr(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showEditDialog(String title, String key, dynamic initialValue) {
    final TextEditingController controller = TextEditingController(
      text: initialValue?.toString() ?? "",
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("${"chef_details.edit".tr()} $title"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: title,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("chef_details.cancel".tr()),
          ),
          ElevatedButton(
            onPressed: () {
              _updateValuesLocally(
                key,
                double.tryParse(controller.text) ?? controller.text,
              );
              Navigator.pop(context);
            },
            child: Text("chef_details.update".tr()),
          ),
        ],
      ),
    );
  }
}
