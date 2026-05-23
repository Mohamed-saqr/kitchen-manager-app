import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:easy_localization/easy_localization.dart';
// 👈 استيراد الـ Cubit الجديد الذي أنشأناه
import 'features/auth/data/auth_repository.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/chefs/presentation/ChefCubit.dart';
import 'features/chefs/presentation/screens/main_screen.dart';
import 'features/splash/presentation/splash_screen.dart';
import 'features/training/models/TrainingModel.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await EasyLocalization.ensureInitialized();

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Firebase App Check is only supported on Android
    if (defaultTargetPlatform == TargetPlatform.android) {
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.playIntegrity,
      );
    }

    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TrainingModelAdapter());
    }

    await Hive.openBox('chefsBox');
    await Hive.openBox('deletedChefsBox');
    await Hive.openBox('wasteBox');
    await Hive.openBox<TrainingModel>('trainingBox');

    runApp(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ar')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        child: MultiRepositoryProvider(
          providers: [
            RepositoryProvider<AuthRepository>(
              create: (context) => AuthRepositoryImpl(),
            ),
          ],
          child: MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => AuthCubit(context.read<AuthRepository>()),
              ),
              // 👈 إضافة ChefCubit هنا وجلب البيانات فوراً
              BlocProvider(create: (context) => ChefCubit()..getChefs(10)),
            ],
            child: const MyApp(),
          ),
        ),
      ),
    );
  } catch (e) {
    debugPrint("❌ FATAL ERROR IN MAIN: $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kitchen Manager',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFF4D00)),
        useMaterial3: true,
        fontFamily: 'Cairo',
      ),
      home: const SplashScreen(),
      routes: {
        '/adminHome': (context) => const MainScreen(),
        '/chefHome': (context) => const MainScreen(),
      },
    );
  }
}
