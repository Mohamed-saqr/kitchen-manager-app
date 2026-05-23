import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/auth_repository.dart'; // تأكد من مسار الـ Repository عندك
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;

  AuthCubit(this._repository) : super(AuthInitial());

  // ✅ FIXED: Changed from void async to Future<void>
  Future<void> checkAuthStatus() async {
    emit(AuthChecking()); // Emit checking state first
    await Future.delayed(
      const Duration(milliseconds: 500),
    ); // Small delay to ensure Firebase is ready
    final result = await _repository.getCurrentUser();
    result.fold(
      (failure) =>
          emit(AuthInitial()), // لو مش مسجل أو حصل خطأ يرجع للحالة الابتدائية
      (user) => emit(
        AuthSuccess(user),
      ), // لو مسجل يبعت الـ user بالـ Role بتاعه (admin/chef)
    );
  }

  void login(String email, String password) async {
    emit(AuthLoading());
    final result = await _repository.login(email, password);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthSuccess(user)),
    );
  }

  void registerUser({
    required String email,
    required String password,
    required String name,
    required String department,
    required String role,
  }) async {
    emit(AuthLoading());
    final result = await _repository.register(
      email: email,
      password: password,
      name: name,
      department: department,
      role: role,
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthSuccess(user)),
    );
  }

  void logout() async {
    await _repository.logout();
    emit(AuthInitial());
  }

  void loginWithGoogle() async {
    emit(AuthLoading());
    final result = await _repository.signInWithGoogle();
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthSuccess(user)),
    );
  }

  void loginWithPhone(String phoneNumber) async {
    emit(AuthLoading());
    await _repository.signInWithPhone(
      phoneNumber: phoneNumber,
      onCodeSent: (verId) => emit(AuthPhoneCodeSent(verId)),
      onError: (msg) => emit(AuthError(msg)),
    );
  }

  void verifyOtp(String verId, String code) async {
    emit(AuthLoading());
    final result = await _repository.verifyOtp(verId, code);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthSuccess(user)),
    );
  }
}
