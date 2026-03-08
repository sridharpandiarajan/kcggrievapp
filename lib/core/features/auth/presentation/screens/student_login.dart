import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../dashboard/presentation/screens/student_dashboard.dart';
import '../controllers/auth_state.dart';
import '../../auth_provider.dart';

class StudentLogin extends ConsumerStatefulWidget {
  const StudentLogin({super.key});

  @override
  ConsumerState<StudentLogin> createState() => _StudentLoginState();
}

class _StudentLoginState extends ConsumerState<StudentLogin> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController regController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  bool _isObscure = true;

  void login() {
    if (!_formKey.currentState!.validate()) return;

    ref.read(authControllerProvider.notifier).login(
      registerNumber: regController.text.trim(),
      password: passController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const StudentDashboard()),
        );
      }

      if (next.status == AuthStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.redAccent,
            content: Text(next.errorMessage ?? "Login failed"),
          ),
        );
      }
    });

    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.status == AuthStatus.loading;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFDFDFD), Color(0xFFE9EDF5)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              /// 🏛️ HEADER LOGO (Fixed at top)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    width: 180.w,
                    height: 40.h,
                    child: Image.asset(
                      "assets/kcgnamelogo1.png",
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              /// 📑 CENTERED FORM
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(28.r),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 24,
                                  offset: const Offset(0, 12),
                                )
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Student Login",
                                  style: TextStyle(
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF0D1B4C),
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                SizedBox(height: 6.h),
                                Text(
                                  "Track your grievances by signing in",
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                                SizedBox(height: 32.h),

                                _buildInputField(
                                  label: "Register Number",
                                  controller: regController,
                                  hint: "e.g. 9123205104",
                                  icon: Icons.badge_outlined,
                                  obscure: false,
                                  maxLength: 10,
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) return "Field required";
                                    if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) return "10 digits required";
                                    return null;
                                  },
                                ),

                                SizedBox(height: 20.h),

                                _buildInputField(
                                  label: "Password",
                                  controller: passController,
                                  hint: "DDMMYYYY",
                                  icon: Icons.lock_outline_rounded,
                                  obscure: _isObscure,
                                  maxLength: 20,
                                  isPassword: true,
                                  keyboardType: TextInputType.number,
                                  onToggleVisibility: () => setState(() => _isObscure = !_isObscure),
                                  validator: (value) => (value == null || value.isEmpty) ? "Field required" : null,
                                ),

                                SizedBox(height: 32.h),

                                SizedBox(
                                  width: double.infinity,
                                  height: 56.h,
                                  child: ElevatedButton(
                                    onPressed: isLoading ? null : login,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF111A44),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14.r),
                                      ),
                                    ),
                                    child: isLoading
                                        ? SizedBox(
                                      height: 24.h, width: 24.w,
                                      child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                        : Text(
                                      "Login",
                                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              /// 🏛️ FOOTER
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: Text(
                  "© 2026 KCG College of Technology",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool obscure,
    required int maxLength,
    required TextInputType keyboardType,
    bool isPassword = false,
    VoidCallback? onToggleVisibility,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
          child: Text(
            label,
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: const Color(0xFF0D1B4C)),
          ),
        ),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          maxLength: maxLength,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14.sp),
            counterText: "",
            filled: true,
            fillColor: const Color(0xFFF8F9FB),
            prefixIcon: Icon(icon, size: 20.sp, color: const Color(0xFF111A44)),
            suffixIcon: isPassword
                ? IconButton(
              icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: Colors.grey.shade600, size: 20.sp),
              onPressed: onToggleVisibility,
            )
                : null,
            contentPadding: EdgeInsets.symmetric(vertical: 18.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey.shade100),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Color(0xFF111A44), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}