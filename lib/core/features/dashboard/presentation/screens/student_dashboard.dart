import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kcggriev/core/features/grievance/presentation/screens/register_grievance_page.dart';
import '../../../grievance/presentation/screens/grievance_details_page.dart';
import '../../../../../models/grievance_model.dart';
import '../../../../../services/mock_student_service.dart';
import '../../../account/presentation/screens/account_page.dart';
import '../../../grievance/presentation/screens/my_grievances_page.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  static const Color primaryColor = Color(0xFF141C46);
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color overviewBg = Color(0xFFF0F4F9);

  Color getStatusColor(String status) {
    switch (status) {
      case "Resolved":
        return const Color(0xFF1E8E3E);
      case "Rejected":
        return const Color(0xFFD93025);
      default:
        return const Color(0xFFF9AB00);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: FutureBuilder<List<GrievanceModel>>(
          future: MockStudentService().getGrievances(),
          builder: (context, snapshot) {

            /// 🔄 Loading
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            /// ❌ Error
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Something went wrong",
                  style: TextStyle(fontSize: 14.sp),
                ),
              );
            }

            final grievances = snapshot.data ?? [];

            final total = grievances.length;
            final pending =
                grievances.where((g) => g.status == "Pending").length;
            final resolved =
                grievances.where((g) => g.status == "Resolved").length;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 18.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// HEADER
                  _buildHeader(context),

                  SizedBox(height: 28.h),

                  /// REGISTER CARD
                  _buildRegisterCard(context),

                  SizedBox(height: 32.h),

                  /// OVERVIEW TITLE
                  _sectionTitle("Grievances Overview"),

                  SizedBox(height: 18.h),

                  /// OVERVIEW SECTION
                  _buildOverviewSection(total, pending, resolved),

                  SizedBox(height: 36.h),

                  /// MY GRIEVANCES HEADER (Clickable)
                  InkWell(
                    borderRadius: BorderRadius.circular(8.r),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MyGrievancesPage(),
                        ),
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 6.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "My Grievances",
                            style: TextStyle(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 22.sp,
                            color: Colors.grey.shade600,
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  /// EMPTY STATE
                  if (grievances.isEmpty)
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 40.h),
                      alignment: Alignment.center,
                      child: Text(
                        "No grievances submitted yet.",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  else
                    ...grievances
                        .take(3)
                        .map((g) => _grievanceCard(context, g))
                        .toList(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ================= HEADER =================

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 22.r,
          backgroundColor: Colors.white,
          child: Icon(Icons.account_balance,
              color: primaryColor, size: 22.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            "KCG Grievance Portal",
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        /// 👇 CLICKABLE PROFILE
        InkWell(
          borderRadius: BorderRadius.circular(50.r),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AccountPage(),
              ),
            );
          },
          child: CircleAvatar(
            radius: 22.r,
            backgroundColor: primaryColor,
            child: Icon(Icons.person,
                color: Colors.white, size: 22.sp),
          ),
        ),
      ],
    );
  }


  // ================= REGISTER CARD =================

  Widget _buildRegisterCard(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18.r),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const RegisterGrievancePage(),
            ),
          );
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 22.w,
            vertical: 22.h,
          ),
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(18.r),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.25),
                blurRadius: 12,
                offset: const Offset(0, 6),
              )
            ],
          ),
          child: Row(
            children: [
              /// TEXT
              Expanded(
                child: Text(
                  "Register your grievance",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ),

              /// ARROW CONTAINER
              Container(
                height: 42.h,
                width: 42.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 18.sp,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= SECTION TITLE =================

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // ================= BIGGER OVERVIEW SECTION =================

  Widget _buildOverviewSection(int total, int pending, int resolved) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          /// LEFT LARGE CARD - BIGGER PADDING & TEXT
          Expanded(
            flex: 5,
            child: Container(
              padding: EdgeInsets.all(22.w), // Increased padding
              decoration: BoxDecoration(
                color: overviewBg,
                borderRadius: BorderRadius.circular(20.r), // Softer corners
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Total number\nof grievances",
                    style: TextStyle(
                      fontSize: 15.sp, // Slightly bigger label
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 30.h), // More vertical space
                  Text(
                    total.toString().padLeft(2, '0'),
                    style: TextStyle(
                      fontSize: 52.sp, // Significantly bigger number
                      fontWeight: FontWeight.w900,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(width: 12.w),

          /// RIGHT SMALL CARDS
          Expanded(
            flex: 5,
            child: Column(
              children: [
                _smallOverviewCard("Pending", pending),
                SizedBox(height: 12.h),
                _smallOverviewCard("Resolved", resolved),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallOverviewCard(String title, int value) {
    return Expanded(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h), // Increased padding
        decoration: BoxDecoration(
          color: overviewBg,
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp, // Slightly bigger label
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 34.sp, // Bigger number
                fontWeight: FontWeight.w900,
                color: primaryColor,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= GRIEVANCE CARD =================

  Widget _grievanceCard(BuildContext context, GrievanceModel grievance) {
    final statusColor = getStatusColor(grievance.status);

    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => GrievanceDetailsPage(grievance: grievance),
              ),
            );
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F3F6),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: Colors.grey.withOpacity(0.08),
              ),
            ),
            child: Row(
              children: [

                /// LEFT CONTENT
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// ID
                      Text(
                        grievance.id,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      SizedBox(height: 6.h),

                      /// TITLE
                      Text(
                        grievance.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),

                      SizedBox(height: 6.h),

                      /// DATE
                      Text(
                        "2 days ago",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 12.w),

                /// RIGHT SIDE
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [

                    /// STATUS BADGE
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        grievance.status,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ),

                    SizedBox(height: 12.h),

                    /// ARROW ICON
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16.sp,
                      color: Colors.grey.shade500,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
