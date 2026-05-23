import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';
import '../../auth/presentation/cubit/auth_state.dart';
import '../../auth/presentation/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // الأنميشنز الخاصة بتأثير النبض والوميض
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;

  @override
  void initState() {
    super.initState();

    // 1. فحص حالة الـ Auth من الـ Cubit الخاص بك
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthCubit>().checkAuthStatus();
    });

    // 2. إعداد الـ Controller مع وقت كافٍ لتأثير الـ Pulse
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // أنميشن اللوجو: يتلاشى للظهور في أول 30% من الوقت
    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    // أنميشن النبض (Pulse): اللوجو يكبر، ثم ينبض مرتين باستخدام كيرف Curves.elasticOut
    _logoScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.5,
          end: 1.1,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 40, // 40% من الوقت للوصول للحجم الأكبر
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.1,
          end: 0.95,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 30, // ارتداد مطاطي لداخل
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.95,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 30, // الاستقرار على الحجم الطبيعي 100%
      ),
    ]).animate(_controller);

    // أنميشن النصوص: تبدأ الظهور بعد استقرار نبضة اللوجو (عند الـ 60% من الوقت)
    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
      ),
    );

    // حركة النصوص: صعود ناعم جداً من أسفل لتستقر تحت اللوجو مباشرة
    _textSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.35), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    // تشغيل الأنميشن فوراً
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (!mounted) return;

        if (state is AuthSuccess) {
          Navigator.pushReplacementNamed(
            context,
            state.user.role == 'admin' ? '/adminHome' : '/chefHome',
          );
        } else if (state is AuthInitial) {
          // Navigate to login after animation completes
          Future.delayed(const Duration(milliseconds: 2000), () {
            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          });
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // الدوائر الديكورية الخلفية باللون البرتقالي الخاص بالبراند
            Positioned(
              top: -50,
              right: -50,
              child: CircleAvatar(
                radius: 100,
                backgroundColor: Colors.deepOrange.withOpacity(0.05),
              ),
            ),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 🖼️ اللوجو المدمج مع أنميشن النبض المرن والـ Fade
                  FadeTransition(
                    opacity: _logoFadeAnimation,
                    child: ScaleTransition(
                      scale: _logoScaleAnimation,
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 260,
                        height: 260,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // ✍️ النصوص والسلوجن تظهر بتأثير الصعود الانسيابي المتأخر
                  FadeTransition(
                    opacity: _textFadeAnimation,
                    child: SlideTransition(
                      position: _textSlideAnimation,
                      child: const Column(
                        children: [
                          Text(
                            "KITCHEN MANAGER",
                            style: TextStyle(
                              color: Colors.deepOrange,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Manage Your Culinary Team Professionally",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // مؤشر التحميل هادئ في الأسفل
            const Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.deepOrange,
                  strokeWidth: 3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
