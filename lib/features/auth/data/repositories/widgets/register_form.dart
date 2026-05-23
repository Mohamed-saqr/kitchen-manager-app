import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../presentation/cubit/auth_cubit.dart';
import '../../../presentation/cubit/auth_state.dart';
import 'auth_widgets.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        return Column(
          children: [

            /// 🔙 Back Button

            const SizedBox(height: 10),

            Form(
              key: _formKey,
              child: Column(
                children: [

                  const SizedBox(height: 10),

                  /// Name
                  AuthTextField(
                    controller: _nameController,
                    label: "الاسم",
                    icon: Icons.person,
                    keyboardType: TextInputType.name,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "الاسم مطلوب";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 15),

                  /// Email
                  AuthTextField(
                    controller: _emailController,
                    label: "البريد الإلكتروني",
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "البريد الإلكتروني مطلوب";
                      }
                      if (!value.contains('@')) {
                        return "بريد إلكتروني غير صحيح";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 15),

                  /// Password
                  AuthTextField(
                    controller: _passwordController,
                    label: "كلمة المرور",
                    icon: Icons.lock_outline,
                    isPassword: true,
                    keyboardType: TextInputType.visiblePassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "كلمة المرور مطلوبة";
                      }
                      if (value.length < 6) {
                        return "كلمة المرور ضعيفة";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 15),

                  /// Confirm Password
                  AuthTextField(
                    controller: _confirmPasswordController,
                    label: "تأكيد كلمة المرور",
                    icon: Icons.lock_reset_outlined,
                    isPassword: true,
                    keyboardType: TextInputType.visiblePassword,
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return "كلمة المرور غير متطابقة";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 30),

                  /// Register Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF4D00),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),

                      onPressed: state is AuthLoading
                          ? null
                          : () {
                        if (_formKey.currentState!.validate()) {
                          context.read<AuthCubit>().registerUser(
                            email: _emailController.text.trim(),
                            password: _passwordController.text.trim(),
                            name: _nameController.text.trim(),
                            role: 'user',
                            department: 'Kitchen',
                          );
                        }
                      },

                      child: state is AuthLoading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : const Text(
                        "إنشاء حساب",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}