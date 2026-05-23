import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../domain/models/user_model.dart'; // تأكد أن المسار مطابق للموديل عندك

abstract class AuthRepository {
  // ✅ الدالة الجديدة لفحص حالة المستخدم الحالي وسحب صلاحياته (Admin / Chef)
  Future<Either<Failure, UserModel>> getCurrentUser();

  Future<Either<Failure, UserModel>> login(String email, String password);

  Future<Either<Failure, UserModel>> register({
    required String email,
    required String password,
    required String name,
    required String department,
    required String role,
  });

  Future<void> signInWithPhone({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String errorMessage) onError,
  });

  Future<Either<Failure, UserModel>> verifyOtp(String verificationId, String smsCode);

  Future<Either<Failure, UserModel>> signInWithGoogle();

  Future<void> logout();
}