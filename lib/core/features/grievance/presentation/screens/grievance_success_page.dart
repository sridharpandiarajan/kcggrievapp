// grievance_success_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kcggriev/core/features/dashboard/presentation/screens/student_dashboard.dart';
import '../../../../../models/grievance_model.dart'; // Ensure correct path
import 'grievance_details_page.dart';

class GrievanceSuccessPage extends StatelessWidget {
  // 1. Add the grievance model parameter
  final GrievanceModel grievance;

  const GrievanceSuccessPage({
    super.key,
    required this.grievance,
  });

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
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF27AE60), width: 4.r),
              ),
              child: Icon(Icons.check_rounded, size: 50.sp, color: const Color(0xFF27AE60)),
            ),
            SizedBox(height: 32.h),
            Text(
              "Grievance Submitted\nSuccessfully",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w700, color: primaryColor, height: 1.2),
            ),

            // NEW: Show the ID to the user for reference
            SizedBox(height: 12.h),
            Text(
              "ID: #${grievance.id}",
              style: TextStyle(fontSize: 14.sp, color: Colors.black45, fontWeight: FontWeight.bold),
            ),

            const Spacer(flex: 4),

            /// 2. View Grievance Button Logic
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                ),
                onPressed: () {
                  // Navigate directly to the details page for this grievance
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GrievanceDetailsPage(grievance: grievance),
                    ),
                  );
                },
                child: Text("View Grievance", style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500)),
              ),
            ),
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryColor,
                  side: BorderSide(color: Colors.black.withOpacity(0.1)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                ),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const StudentDashboard()),
                        (route) => false,
                  );
                },
                child: Text("Back to home", style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500)),
              ),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }
}