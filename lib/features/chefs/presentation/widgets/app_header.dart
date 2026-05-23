import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

// ✅ تأكد من صحة هذه المسارات في مشروعك
import '../../../../core/theme/AppColors/app_colors.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../auth/presentation/screens/login_screen.dart';

class AppHeader extends StatefulWidget implements PreferredSizeWidget {
  // ✅ تم تبسيط الـ Constructor ليعمل في أي مكان بدون تمرير باراميترات يدوية
  const AppHeader({super.key, required bool centerTitle, required List<dynamic> actions, required Color backgroundColor, required int elevation, required Text title});

  @override
  State<AppHeader> createState() => _AppHeaderState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 10); // زيادة بسيطة للارتفاع عشان الـ Role
}

class _AppHeaderState extends State<AppHeader> {
  File? imageFile;
  final ImagePicker picker = ImagePicker();

  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

  void showPickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Camera"),
              onTap: () {
                Navigator.pop(context);
                pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Gallery"),
              onTap: () {
                Navigator.pop(context);
                pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("تسجيل الخروج", textAlign: TextAlign.right),
        content: const Text("هل أنت متأكد أنك تريد تسجيل الخروج؟", textAlign: TextAlign.right),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("إلغاء", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              context.read<AuthCubit>().logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
              );
            },
            child: const Text("خروج", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        String userName = "مستخدم";
        String userRole = "جاري التحميل...";
        String? googlePhotoUrl;

        if (state is AuthSuccess) {
          userName = state.user.name;
          userRole = state.user.role; // سحب الـ role من الموديل
          googlePhotoUrl = state.user.image;
        }

        // قفل الـ Role للتأكد من الحالة
        final bool isAdmin = userRole.toLowerCase().trim() == 'admin';

        return AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: GestureDetector(
            onTap: showPickerOptions,
            child: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                backgroundImage: imageFile != null
                    ? FileImage(imageFile!)
                    : (googlePhotoUrl != null
                    ? NetworkImage(googlePhotoUrl)
                    : null) as ImageProvider?,
                child: (imageFile == null && googlePhotoUrl == null)
                    ? Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : "M",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                )
                    : null,
              ),
            ),
          ),
          // ✅ تعديل العنوان ليظهر الـ Role بوضوح للتأكد
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Welcome $userName",
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "Role: $userRole",
                style: TextStyle(
                  color: isAdmin ? Colors.green : Colors.redAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_rounded),
              iconSize: 28,
              color: Colors.redAccent,
              onPressed: () => _showLogoutDialog(context),
            ),
          ],
        );
      },
    );
  }
}