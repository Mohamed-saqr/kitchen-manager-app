import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/AppColors/app_colors.dart';

class AddChefScreen extends StatefulWidget {
  const AddChefScreen({super.key});

  @override
  State<AddChefScreen> createState() => _AddChefScreenState();
}

class _AddChefScreenState extends State<AddChefScreen> {
  // Controllers الأساسية
  final nameController = TextEditingController();
  final positionController = TextEditingController();
  final specialtyController = TextEditingController();

  // Controllers البيانات الشخصية
  final nationalIdController = TextEditingController();
  final addressController = TextEditingController();
  final phoneController = TextEditingController();
  final secondaryPhoneController = TextEditingController();

  bool isLoading = false;
  File? imageFile;
  final picker = ImagePicker();

  Future<void> pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (_) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text("Camera"),
            onTap: () async {
              Navigator.pop(context);
              final img = await picker.pickImage(source: ImageSource.camera);
              if (img != null) setState(() => imageFile = File(img.path));
            },
          ),
          ListTile(
            leading: const Icon(Icons.image),
            title: const Text("Gallery"),
            onTap: () async {
              Navigator.pop(context);
              final img = await picker.pickImage(source: ImageSource.gallery);
              if (img != null) setState(() => imageFile = File(img.path));
            },
          ),
        ],
      ),
    );
  }

  Future<void> saveChef() async {
    if (nameController.text.isEmpty || phoneController.text.isEmpty || nationalIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يرجى ملء البيانات الأساسية (الاسم، الهاتف، الرقم القومي)")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // ✅ تعديل: إضافة قيم افتراضية للتقييم (KPIs) لضمان عمل شاشة التفاصيل بشكل سليم
      final Map<String, dynamic> chefData = {
        'name': nameController.text,
        'position': positionController.text,
        'specialty': specialtyController.text,
        'image': imageFile?.path ?? "",
        'nationalId': nationalIdController.text,
        'address': addressController.text,
        'phone': phoneController.text,
        'secondaryPhone': secondaryPhoneController.text.isEmpty ? null : secondaryPhoneController.text,

        // 📊 تأسيس قيم التقييم الافتراضية
        'attendance': 0.0,
        'food_safety': 0.0,
        'hygiene': 0.0,
        'waste_control': 0.0,
        'rating': 0.0,
      };

      await FirebaseFirestore.instance
          .collection('chefs')
          .add(chefData);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ تمت إضافة الشيف بنجاح")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ حدث خطأ أثناء الحفظ: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    positionController.dispose();
    specialtyController.dispose();
    nationalIdController.dispose();
    addressController.dispose();
    phoneController.dispose();
    secondaryPhoneController.dispose();
    super.dispose();
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.primary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("إضافة شيف جديد", style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            children: [
              _buildImagePicker(),
              const SizedBox(height: 30),

              _buildTextField(nameController, "اسم الشيف", Icons.person),
              _buildTextField(positionController, "الرتبة (Position)", Icons.work),
              _buildTextField(specialtyController, "التخصص (Specialty)", Icons.restaurant_menu),

              const Divider(height: 40),
              const Text("البيانات الشخصية", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 15),

              _buildTextField(nationalIdController, "الرقم القومي (14 رقم)", Icons.badge, type: TextInputType.number),
              _buildTextField(addressController, "عنوان السكن", Icons.location_on),
              _buildTextField(phoneController, "رقم الهاتف الأساسي", Icons.phone, type: TextInputType.phone),
              _buildTextField(secondaryPhoneController, "رقم هاتف إضافي (اختياري)", Icons.phone_android, type: TextInputType.phone),

              const SizedBox(height: 20),
              _saveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: pickImage,
      child: Center(
        child: Stack(
          children: [
            Container(
              width: 130, height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 2),
              ),
              child: ClipOval(
                child: imageFile != null
                    ? Image.file(imageFile!, fit: BoxFit.cover)
                    : Container(color: Colors.grey.shade100, child: const Icon(Icons.person, size: 70, color: Colors.grey)),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: CircleAvatar(
                backgroundColor: AppColors.primary,
                radius: 20,
                child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _saveButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: saveChef,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text("حفظ بيانات الشيف", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}