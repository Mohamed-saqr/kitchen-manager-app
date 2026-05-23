import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart'; // 👈 IMPORT
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../../domain/models/AuthModals.dart';
import 'register_view.dart';
import '../../../chefs/presentation/widgets/login_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            Navigator.pushReplacementNamed(
                context, state.user.role == 'admin' ? '/adminHome' : '/chefHome'
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20), // 👈 تقليل البادينج الرأسي للمحتوى
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 25), // 👈 تقليص المسافة من 40 لـ 25
                    _buildEmailField(),
                    const SizedBox(height: 15), // 👈 تقليص المسافة من 20 لـ 15
                    _buildPasswordField(),
                    const SizedBox(height: 20), // 👈 تقليص المسافة من 30 لـ 20
                    _buildLoginButton(state),
                    const SizedBox(height: 20), // 👈 تقليص المسافة من 25 لـ 20
                    _buildSocialSection(context, state),
                    const SizedBox(height: 20), // 👈 تقليص المسافة من 30 لـ 20
                    _buildRegisterRow(context),
                    const SizedBox(height: 25), // مسافة قبل زر اللغة
                    _buildLanguageButton(context), // 👈 تم نقل زر اللغة هنا في الأسفل بشكل شيك
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Image.asset(
          'assets/images/logo.png',
          width: 400, // 👈 تقليل حجم اللوجو قليلاً ليعطي مساحة أفضل للشاشة (من 200 لـ 160)
          height: 160,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 5), // 👈 تقريب النص من اللوجو
        Text(
          "login_screen.title".tr(),
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFFFF4D00)),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
          labelText: "login_screen.email_label".tr(),
          prefixIcon: const Icon(Icons.email_outlined),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
      validator: (value) => value!.isEmpty ? "login_screen.email_error".tr() : null,
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        labelText: "login_screen.password_label".tr(),
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
          onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      ),
      validator: (value) => value!.length < 6 ? "login_screen.password_error".tr() : null,
    );
  }

  Widget _buildLoginButton(AuthState state) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF4D00),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
        onPressed: state is AuthLoading ? null : () {
          if (_formKey.currentState!.validate()) {
            context.read<AuthCubit>().login(_emailController.text.trim(), _passwordController.text.trim());
          }
        },
        child: state is AuthLoading
            ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
            : Text("login_screen.login_btn".tr(),
            style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSocialSection(BuildContext context, AuthState state) {
    return Column(
      children: [
        // 👈 كلمة "سجل عبر" فوق الأيقونات مباشرة وبمسافة ضيقة
        Text(
          "login_screen.or_social".tr(),
          style: const TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10), // 👈 مسافة صغيرة جداً تفصل النص عن الأزرار

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SocialLoginButton(
              imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/2/2d/Google-favicon-2015.png',
              onTap: state is AuthLoading ? () {} : () => context.read<AuthCubit>().loginWithGoogle(),
            ),
            const SizedBox(width: 15),
            SocialLoginButton(
              imageUrl: 'https://cdn-icons-png.flaticon.com/512/724/724664.png',
              onTap: state is AuthLoading ? () {} : () => AuthModals().showPhoneBottomSheet(context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRegisterRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("login_screen.no_account".tr()),
        TextButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterView())),
          child: Text("login_screen.register_btn".tr(),
              style: const TextStyle(color: Color(0xFFFF4D00), fontSize: 17, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  // 🌍 ويدجت منفصلة لزرار اللغة عشان الكود يفضل نظيف ومقروء
  Widget _buildLanguageButton(BuildContext context) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0xFFFF4D00), width: 1.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      ),
      icon: const Icon(Icons.language, color: Color(0xFFFF4D00), size: 16),
      label: Text(
        context.locale.languageCode == 'ar' ? 'English' : 'عربي',
        style: const TextStyle(color: Color(0xFFFF4D00), fontWeight: FontWeight.bold, fontSize: 13),
      ),
      onPressed: () {
        if (context.locale.languageCode == 'ar') {
          context.setLocale(const Locale('en'));
        } else {
          context.setLocale(const Locale('ar'));
        }
      },
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}