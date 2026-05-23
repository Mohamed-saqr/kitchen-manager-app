import 'package:dartz/dartz.dart';
import '../models/user_model.dart';
import '../../../../core/error/failures.dart';
import '../../data/auth_repository.dart';


class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  // دالة تسجيل الشيف (Chef)
  Future<Either<Failure, UserModel>> callChef({
    required String email,
    required String password,
    required String name,
    required String department,
    required String role,
  }) async {
    return await repository.register(
      email: email,
      password: password,
      name: name,
      department: department,
      role: role,
    );
  }

  // دالة تسجيل المدير (Admin)
  Future<Either<Failure, UserModel>> callAdmin({
    required String email,
    required String password,
    required String name,
  }) async {
    return await repository.register(
      email: email,
      password: password,
      name: name, department: '', role: '',
    );
  }
}