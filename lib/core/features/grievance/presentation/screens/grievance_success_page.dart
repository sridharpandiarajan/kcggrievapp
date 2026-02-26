import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// Replace this with the actual path to your dashboard file
import 'package:kcggriev/core/features/dashboard/presentation/screens/student_dashboard.dart';

class GrievanceSuccessPage extends StatelessWidget {
  const GrievanceSuccessPage({super.key});

  static const Color primaryColor = Color(0xFF141C46);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30.w),
        child: Column(
          children: [
            const Spacer(flex: 3),

            /// Custom Styled Check Icon
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF27AE60), width: 4.r),
              ),
              child: Icon(
                Icons.check_rounded,
                size: 50.sp,
                color: const Color(0xFF27AE60),
              ),
            ),

            SizedBox(height: 32.h),

            Text(
              "Grievance Submitted\nSuccessfully",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: primaryColor,
                height: 1.2,
              ),
            ),

            const Spacer(flex: 4),

            /// View Grievance Button (Placeholder for your logic)
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                onPressed: () {
                  // Typically navigates to a 'My Grievances' list
                },
                child: Text(
                  "View Grievance",
                  style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500),
                ),
              ),
            ),

            SizedBox(height: 12.h),

            /// Back Home Button - UPDATED
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryColor,
                  side: BorderSide(color: Colors.black.withOpacity(0.1)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                onPressed: () {
                  // Navigates to StudentDashboard and clears the stack
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const StudentDashboard()),
                        (route) => false,
                  );
                },
                child: Text(
                  "Back to home",
                  style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500),
                ),
              ),
            ),

            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }
}