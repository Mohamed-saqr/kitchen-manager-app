import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:easy_localization/easy_localization.dart'; // 👈 IMPORT
import '../../presentation/cubit/auth_cubit.dart';
import '../../presentation/cubit/auth_state.dart';

class AuthModals {
  void showPhoneBottomSheet(BuildContext context) {
    final TextEditingController phoneController = TextEditingController();
    String fullPhoneNumber = "";
    final authCubit = context.read<AuthCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => BlocProvider.value(
        value: authCubit,
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthPhoneCodeSent) {
              Navigator.pop(context);
              showOtpDialog(context, state.verificationId, authCubit);
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 25, right: 25, top: 25,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.phonelink_setup_rounded, size: 50, color: Color(0xFFFF4D00)),
                  const SizedBox(height: 15),
                  Text("auth_modals.phone_title".tr(),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 25),
                  IntlPhoneField(
                    controller: phoneController,
                    initialCountryCode: 'EG',
                    languageCode: context.locale.languageCode, // 👈 استخدام لغة التطبيق الحالية
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      labelText: 'auth_modals.phone_label'.tr(),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    onChanged: (phone) {
                      fullPhoneNumber = phone.completeNumber;
                    },
                  ),
                  const SizedBox(height: 25),
                  _buildSubmitButton(context, state, () {
                    if (fullPhoneNumber.isNotEmpty) {
                      authCubit.loginWithPhone(fullPhoneNumber);
                    }
                  }, "auth_modals.send_code".tr()),
                  const SizedBox(height: 25),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void showOtpDialog(BuildContext context, String verId, AuthCubit authCubit) {
    final otpController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BlocProvider.value(
        value: authCubit,
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess) {
              Navigator.pop(context);
              if (state.user.role == 'admin') {
                Navigator.pushReplacementNamed(context, '/adminHome');
              } else {
                Navigator.pushReplacementNamed(context, '/chefHome');
              }
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text("auth_modals.otp_title".tr(), textAlign: TextAlign.center),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 6,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 5),
                    decoration: InputDecoration(
                      counterText: "",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                  if (state is AuthLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 15),
                      child: CircularProgressIndicator(color: Color(0xFFFF4D00)),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("auth_modals.cancel".tr(), style: const TextStyle(color: Colors.grey)),
                ),
                TextButton(
                  onPressed: state is AuthLoading ? null : () => authCubit.verifyOtp(verId, otpController.text.trim()),
                  child: Text("auth_modals.confirm".tr(),
                      style: const TextStyle(color: Color(0xFFFF4D00), fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context, AuthState state, VoidCallback onPressed, String label) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF4D00),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        onPressed: state is AuthLoading ? null : onPressed,
        child: state is AuthLoading
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}