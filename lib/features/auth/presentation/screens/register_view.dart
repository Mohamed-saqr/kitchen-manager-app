import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../data/repositories/widgets/register_form.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../../domain/models/AuthModals.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("register_screen.success".tr()),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home',
                (route) => false,
          );
        }

        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },

      builder: (context, state) {
        return Scaffold(

          /// 🔥 APP BAR + BACK BUTTON
          appBar: AppBar(
            backgroundColor: const Color(0xFFFF4D00),
            elevation: 0,

            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),

            title: const Text(
              "إنشاء حساب",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),

            centerTitle: true,
          ),

          body: SafeArea(
            child: AbsorbPointer(
              absorbing: state is AuthLoading,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    const Icon(
                      Icons.person_add_alt_1,
                      size: 90,
                      color: Color(0xFFFF4D00),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      " برجاء إنشاء حساب",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    const RegisterForm(),

                    const SizedBox(height: 20),

                    if (state is AuthLoading)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 20),
                        child: CircularProgressIndicator(
                          color: Color(0xFFFF4D00),
                        ),
                      ),

                    Row(
                      children: const [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            "أو سجل بواسطة",
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),

                    const SizedBox(height: 15),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _socialButton(
                          imageUrl:
                          'https://upload.wikimedia.org/wikipedia/commons/2/2d/Google-favicon-2015.png',
                          onTap: () {
                            context.read<AuthCubit>().loginWithGoogle();
                          },
                        ),

                        const SizedBox(width: 25),

                        _socialButton(
                          imageUrl:
                          'https://cdn-icons-png.flaticon.com/512/724/724664.png',
                          onTap: () {
                            AuthModals().showPhoneBottomSheet(context);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _socialButton({
    required String imageUrl,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Image.network(
          imageUrl,
          height: 35,
          width: 35,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.error_outline,
              color: Colors.red,
            );
          },
        ),
      ),
    );
  }
}