// lib/core/error/failures.dart
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

// الخطأ اللي بنرجعه لما يحصل مشكلة في الـ Firebase أو الـ Server
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

// الخطأ اللي بنرجعه لو فيه مشكلة في الـ Cache أو البيانات المحلية
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}