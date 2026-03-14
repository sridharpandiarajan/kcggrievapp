                                                            import 'package:flutter/material.dart';
                                                            import 'package:flutter_riverpod/flutter_riverpod.dart';
                                                            import 'package:flutter_screenutil/flutter_screenutil.dart';

                                                            import '../../auth_provider.dart';
                                                            import '../controllers/auth_state.dart';
                                                            import 'student_login.dart';
                                                            import '../../../dashboard/presentation/screens/student_dashboard.dart';

                                                            class SplashScreen extends ConsumerStatefulWidget {
                                                              const SplashScreen({super.key});

                                                              @override
                                                              ConsumerState<SplashScreen> createState() => _SplashScreenState();
                                                            }

                                                            class _SplashScreenState extends ConsumerState<SplashScreen> {

                                                              @override
                                                              void initState() {
                                                                super.initState();

                                                                // Run auth check after splash delay
                                                                Future.delayed(const Duration(seconds: 3), () {
                                                                  ref.read(authControllerProvider.notifier).checkAuthStatus();
                                                                });
                                                              }

                                                              @override
                                                              Widget build(BuildContext context) {

                                                                // Your SplashScreen ref.listen logic is already correct:
                                                                ref.listen<AuthState>(authControllerProvider, (previous, next) {
                                                                  if (!mounted) return;

                                                                  if (next.status == AuthStatus.authenticated) {
                                                                    // User data is now present in next.user
                                                                    Navigator.pushReplacement(
                                                                      context,
                                                                      MaterialPageRoute(builder: (_) => const StudentDashboard()),
                                                                    );
                                                                  }

                                                                  if (next.status == AuthStatus.unauthenticated ||
                                                                      next.status == AuthStatus.error) {
                                                                    Navigator.pushReplacement(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                        builder: (_) => const StudentLogin(),
                                                                      ),
                                                                    );
                                                                  }
                                                                });

                                                                return Scaffold(
                                                                  backgroundColor: Colors.white,
                                                                  body: SizedBox(
                                                                    width: double.infinity,
                                                                    child: Column(
                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                      children: [

                                                                        /// Logo
                                                                        Image.asset(
                                                                          "assets/kcglogo.png",
                                                                          width: 120.w,
                                                                          height: 120.h,
                                                                          fit: BoxFit.contain,
                                                                        ),

                                                                        SizedBox(height: 20.h),

                                                                        /// Title
                                                                        Text(
                                                                          "Grievance Portal",
                                                                          style: TextStyle(
                                                                            fontSize: 24.sp,
                                                                            fontWeight: FontWeight.bold,
                                                                            color: const Color(0xFF1A1A1A),
                                                                            letterSpacing: 0.5,
                                                                          ),
                                                                        ),

                                                                        SizedBox(height: 40.h),

                                                                        const CircularProgressIndicator(
                                                                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0D1B4C)),
                                                                          strokeWidth: 3,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                );
                                                              }
                                                            }