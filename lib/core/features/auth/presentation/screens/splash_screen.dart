import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

    // Call auth check AFTER widget builds
    Future.microtask(() {
      ref.read(authControllerProvider.notifier).checkAuthStatus();
    });
  }

  @override
  Widget build(BuildContext context) {

    /// Listen for auth state changes
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const StudentDashboard()),
        );
      }

      if (next.status == AuthStatus.unauthenticated) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const StudentLogin()),
        );
      }
    });

    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}