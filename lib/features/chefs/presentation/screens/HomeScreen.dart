import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
// 👈 استيراد الـ Cubit الجديد
import '../ChefCubit.dart';
import '../widgets/chef_card.dart';
import '../widgets/app_header.dart';
import 'add_chef_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        String userRole = 'chef';
        if (authState is AuthSuccess) {
          userRole = authState.user.role.toLowerCase().trim();
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppHeader(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(
              userRole == 'admin' ? "إدارة الشيفات" : "قائمة الزملاء",
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            actions: const [],
          ),
          // 👈 استخدام BlocBuilder بدلاً من StreamBuilder
          body: BlocBuilder<ChefCubit, ChefState>(
            builder: (context, state) {
              if (state is ChefLoading) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFFFF4D00)));
              }

              if (state is ChefLoaded) {
                if (state.chefs.isEmpty) {
                  return const Center(child: Text("برجاء إضافة بيانات"));
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.chefs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final chefModel = state.chefs[index];
                    Widget chefCard = ChefCard(
                      chef: chefModel,
                      currentUserRole: userRole,
                    );

                    if (userRole == 'admin') {
                      return Dismissible(
                        key: Key(chefModel.id),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) async {
                          await FirebaseFirestore.instance.collection('chefs').doc(chefModel.id).delete();
                        },
                        background: Container(
                          decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(18)),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: chefCard,
                      );
                    }
                    return chefCard;
                  },
                );
              }
              return const SizedBox();
            },
          ),
          floatingActionButton: userRole == 'admin'
              ? FloatingActionButton.extended(
            backgroundColor: const Color(0xFFFF4D00),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddChefScreen())),
            label: Text("add_chef".tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            icon: const Icon(Icons.add, color: Colors.white),
          )
              : null,
        );
      },
    );
  }
}