import '../../domain/models/user_model.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthChecking extends AuthState {} // ✅ NEW: For splash screen

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final UserModel user;
  AuthSuccess(this.user);
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

class AuthPhoneCodeSent extends AuthState {
  final String verificationId;
  AuthPhoneCodeSent(this.verificationId);
}
