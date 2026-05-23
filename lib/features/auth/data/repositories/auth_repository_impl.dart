import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dartz/dartz.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/error/failures.dart';
import '../../domain/models/user_model.dart';
import '../auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 👈 التعديل هنا: أضفنا هذي الخيارات لإجبار جوجل على إظهار شاشة اختيار الحساب
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
    signInOption: SignInOption.standard,
  );

  // ✅ إضافة الدالة الجديدة لفحص حالة المستخدم الحالي وسحب بيانات الـ Role من Firestore
  @override
  Future<Either<Failure, UserModel>> getCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        final userData = await _firestore.collection('users').doc(user.uid).get();
        if (userData.exists && userData.data() != null) {
          return Right(UserModel.fromMap(userData.data()!));
        }
      }
      return Left(ServerFailure("لا يوجد مستخدم مسجل حالياً"));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserModel>> login(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      final userData = await _firestore.collection('users').doc(credential.user!.uid).get();

      if (userData.exists && userData.data() != null) {
        return Right(UserModel.fromMap(userData.data()!));
      } else {
        return Left(ServerFailure("بيانات المستخدم غير موجودة"));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserModel>> register({
    required String email,
    required String password,
    required String name,
    required String department,
    required String role,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);

      final user = UserModel(
        uid: credential.user!.uid,
        name: name,
        email: email,
        role: role,
        department: department,
        image: null,
      );

      await _firestore.collection('users').doc(user.uid).set(user.toMap());
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<void> signInWithPhone({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String errorMessage) onError,
  }) async {
    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _firebaseAuth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          onError(e.message ?? "فشل التحقق");
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      onError(e.toString());
    }
  }

  @override
  Future<Either<Failure, UserModel>> verifyOtp(String verificationId, String smsCode) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        var doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          return Right(UserModel.fromMap(doc.data()!));
        } else {
          final newUser = UserModel(
            uid: user.uid,
            name: "Chef ${user.phoneNumber?.substring(user.phoneNumber!.length - 4) ?? 'New'}",
            email: "",
            phone: user.phoneNumber,
            role: "chef",
            image: user.photoURL,
          );
          await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
          return Right(newUser);
        }
      }
      return Left(ServerFailure("فشل التحقق من المستخدم"));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserModel>> signInWithGoogle() async {
    try {
      // 👈 تم إضافة السطر ده للتأكد من مسح أي جلسة قديمة قبل البدء
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return Left(ServerFailure("تم إلغاء العملية"));

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user!;

      var doc = await _firestore.collection('users').doc(user.uid).get();

      if (doc.exists) {
        UserModel existingUser = UserModel.fromMap(doc.data()!);
        if (existingUser.image == null && user.photoURL != null) {
          await _firestore.collection('users').doc(user.uid).update({'image': user.photoURL});
          existingUser = UserModel.fromMap({...doc.data()!, 'image': user.photoURL});
        }
        return Right(existingUser);
      } else {
        final newUser = UserModel(
          uid: user.uid,
          name: user.displayName ?? "مستخدم جوجل",
          email: user.email ?? "",
          role: "chef",
          image: user.photoURL,
        );
        await _firestore.collection('users').doc(user.uid).set(newUser.toMap(), SetOptions(merge: true));
        return Right(newUser);
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<void> logout() async {
    // 👈 السطر ده بيفصل الحساب تماماً عشان يسألك المرة الجاية تختار مين
    await _googleSignIn.disconnect();
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }
}