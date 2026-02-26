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
          email: regController.text.trim(),
          password: passController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    /// ✅ Listen MUST be inside build
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
            content: Text(next.errorMessage ?? "Login failed"),
          ),
        );
      }
    });

    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18.r,
                      backgroundColor: Colors.white,
                      child: const Icon(
                        Icons.account_balance,
                        color: Color(0xFF0D1B4C),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      "KCG Grievance Portal",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16.sp,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    Text(
                      "Student Login",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 30.h),

                    _buildInputField(
                      controller: regController,
                      hint: "Register Number",
                      obscure: false,
                      maxLength: 10,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Enter Register Number";
                        }

                      },
                    ),

                    SizedBox(height: 18.h),

                    _buildInputField(
                      controller: passController,
                      hint: "Password (DDMMYYYY)",
                      obscure: _isObscure,
                      isPassword: true,
                      maxLength: 8,
                      onToggleVisibility: () {
                        setState(() {
                          _isObscure = !_isObscure;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Enter Password";
                        }
                       
                      },
                    ),

                    SizedBox(height: 28.h),

                    SizedBox(
                      width: double.infinity,
                      height: 50.h,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF111A44),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        child: isLoading
                            ? SizedBox(
                                height: 20.h,
                                width: 20.w,
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                "Login",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: Text(
                  "© 2026 KCG College of Technology",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey,
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
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required int maxLength,
    bool isPassword = false,
    VoidCallback? onToggleVisibility,
    required String? Function(String?) validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,

        keyboardType: TextInputType.emailAddress,
        validator: validator,
        style: TextStyle(fontSize: 14.sp),
        decoration: InputDecoration(
          hintText: hint,
          counterText: "",
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscure ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                    size: 20.sp,
                  ),
                  onPressed: onToggleVisibility,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
          errorStyle: TextStyle(fontSize: 11.sp, height: 0.8),
        ),
      ),
    );
  }
}