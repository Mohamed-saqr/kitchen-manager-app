import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../training/presentation/screens/training_screen.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import 'HomeScreen.dart';
import 'WasteTrackingScreen.dart';
import 'chat_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final user = (state is AuthSuccess) ? state.user : null;
        String userRole = user?.role.toLowerCase().trim() ?? 'chef';

        // الحصول على الـ ID الخاص بالمستخدم الحالي للـ Chat
        String currentUid = FirebaseAuth.instance.currentUser?.uid ?? 'general_chat';

        if (state is AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Color(0xFFFF4D00))),
          );
        }

        final List<Widget> pages = [
          const HomeScreen(),
          ChatScreen(chatId: currentUid), // 👈 تمرير الـ ID الحقيقي
          TrainingScreen(userRole: userRole),
          const WasteTrackingScreen(),
        ];

        return Scaffold(
          body: IndexedStack(
            index: currentIndex,
            children: pages,
          ),
          bottomNavigationBar: CustomBottomNavBar(
            currentIndex: currentIndex,
            userRole: userRole,
            onTap: (index) {
              setState(() => currentIndex = index);
            },
          ),
        );
      },
    );
  }
}