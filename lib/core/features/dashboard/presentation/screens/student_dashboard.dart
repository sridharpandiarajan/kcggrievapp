import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // Added for Cupertino Refresh
import 'package:flutter/services.dart';  // Added for Haptics
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:kcggriev/core/features/grievance/presentation/screens/register_grievance_page.dart';
import '../../../grievance/grievance_provider.dart';
import '../../../grievance/presentation/screens/grievance_details_page.dart';
import '../../../../../models/grievance_model.dart';
import '../../../account/presentation/screens/account_page.dart';
import '../../../grievance/presentation/screens/my_grievances_page.dart';

class StudentDashboard extends ConsumerStatefulWidget {
  const StudentDashboard({super.key});

  static const Color primaryColor = Color(0xFF141C46);
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color overviewBg = Color(0xFFF0F4F9);

  @override
  ConsumerState<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends ConsumerState<StudentDashboard> {
  Color getStatusColor(String status) {
    switch (status) {
      case "Resolved": return const Color(0xFF1E8E3E);
      case "Rejected": return const Color(0xFFD93025);
      default: return const Color(0xFFF9AB00);
    }
  }

  // ... inside your _StudentDashboardState ...

  @override
  Widget build(BuildContext context) {
    final grievanceState = ref.watch(grievanceControllerProvider);
    bool _hapticTriggered = false;
    return Scaffold(
      backgroundColor: StudentDashboard.backgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            CupertinoSliverRefreshControl(
              refreshTriggerPullDistance: 100.0,
              refreshIndicatorExtent: 60.0,
              // This is the secret: Trigger a haptic the moment the user pulls far enough
              onRefresh: () async {
                // 1. Try heavy impact for better visibility on all devices
                HapticFeedback.mediumImpact();

                await ref
                    .read(grievanceControllerProvider.notifier)
                    .fetchMyGrievances();

                // 2. Light "success" tap when finished
                await HapticFeedback.lightImpact();
              },
            ),
            // 2. MAIN CONTENT WRAPPER
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 18.h),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildHeader(context),
                  SizedBox(height: 28.h),
                  _buildRegisterCard(context),
                  SizedBox(height: 32.h),
                  _sectionTitle("Grievances Overview"),
                  SizedBox(height: 18.h),

                  // Overview Data
                  grievanceState.when(
                    loading: () => _buildOverviewShimmer(),
                    error: (_, __) => _buildErrorState(),
                    data: (grievances) {
                      final total = grievances.length;
                      final pending = grievances.where((g) => g.status == "Pending").length;
                      final resolved = grievances.where((g) => g.status == "Resolved").length;
                      return _buildOverviewSection(total, pending, resolved);
                    },
                  ),

                  SizedBox(height: 36.h),
                  _buildMyGrievancesLink(context),
                  SizedBox(height: 16.h),

                  // Grievance List Items
                  grievanceState.when(
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (grievances) {
                      if (grievances.isEmpty) {
                        return _buildEmptyState();
                      }
                      return Column(
                        children: grievances
                            .take(3)
                            .map((g) => _grievanceCard(context, g))
                            .toList(),
                      );
                    },
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= SUB-COMPONENTS (PRESERVED) =================

  Widget _buildOverviewShimmer() => Opacity(opacity: 0.6, child: _buildOverviewSection(0, 0, 0));

  Widget _buildErrorState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12.r)),
      child: Text("Unable to load overview. Pull to try again.",
          style: TextStyle(color: Colors.red.shade800, fontSize: 13.sp), textAlign: TextAlign.center),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 40.h),
      alignment: Alignment.center,
      child: Text("No grievances submitted yet.", style: TextStyle(fontSize: 14.sp, color: Colors.grey)),
    );
  }

  Widget _buildMyGrievancesLink(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8.r),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyGrievancesPage())),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("My Grievances", style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w600)),
            Icon(Icons.chevron_right_rounded, size: 22.sp, color: Colors.grey.shade600),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 180.w,
          height: 40.h,
          child: Image.asset("assets/kcgnamelogo1.png", fit: BoxFit.contain),
        ),
        InkWell(
          borderRadius: BorderRadius.circular(50.r),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountPage())),
          child: CircleAvatar(
            radius: 22.r,
            backgroundColor: StudentDashboard.primaryColor,
            child: Icon(Icons.person, color: Colors.white, size: 22.sp),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterCard(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18.r),
      onTap: () async {
        await Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterGrievancePage()));
        ref.read(grievanceControllerProvider.notifier).fetchMyGrievances();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 22.h),
        decoration: BoxDecoration(
          color: StudentDashboard.primaryColor,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [BoxShadow(color: StudentDashboard.primaryColor.withOpacity(0.25), blurRadius: 12, offset: const Offset(0, 6))],
        ),
        child: Row(
          children: [
            Expanded(child: Text("Register your grievance", style: TextStyle(color: Colors.white, fontSize: 17.sp, fontWeight: FontWeight.w600))),
            Container(
              height: 42.h, width: 42.w,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.r)),
              child: Icon(Icons.arrow_forward_ios_rounded, size: 18.sp, color: StudentDashboard.primaryColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(title, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600));

  Widget _buildOverviewSection(int total, int pending, int resolved) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 5,
            child: Container(
              padding: EdgeInsets.all(22.w),
              decoration: BoxDecoration(color: StudentDashboard.overviewBg, borderRadius: BorderRadius.circular(20.r)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Total number\nof grievances", style: TextStyle(fontSize: 15.sp, color: Colors.black54, fontWeight: FontWeight.w500, height: 1.2)),
                  SizedBox(height: 30.h),
                  Text(total.toString().padLeft(2, '0'), style: TextStyle(fontSize: 52.sp, fontWeight: FontWeight.w900, color: StudentDashboard.primaryColor)),
                ],
              ),
            ),
          ),
          SizedBox(width: 12.w),
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
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
        decoration: BoxDecoration(color: StudentDashboard.overviewBg, borderRadius: BorderRadius.circular(18.r)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: TextStyle(fontSize: 14.sp, color: Colors.black54, fontWeight: FontWeight.w500)),
            const Spacer(),
            Text(value.toString(), style: TextStyle(fontSize: 34.sp, fontWeight: FontWeight.w900, color: StudentDashboard.primaryColor, height: 1.0)),
          ],
        ),
      ),
    );
  }

  /// RELATIVE TIME LOGIC (Consistent with MyGrievancesPage)
  String _getTimeAgo(String dateString) {
    try {
      // Assumes format "dd/MM/yyyy". Adjust if your format differs.
      DateTime submittedDate = DateFormat("dd/MM/yyyy").parse(dateString);
      DateTime now = DateTime.now();

      // Normalize to date-only for "Today" calculation
      DateTime today = DateTime(now.year, now.month, now.day);
      DateTime submittedDay = DateTime(submittedDate.year, submittedDate.month, submittedDate.day);

      final diffInDays = today.difference(submittedDay).inDays;

      if (diffInDays <= 0) return "Today";

      if (diffInDays < 31) {
        return "$diffInDays ${diffInDays == 1 ? "day" : "days"} ago";
      }

      if (diffInDays < 365) {
        int months = (diffInDays / 30).floor();
        return "$months ${months == 1 ? "month" : "months"} ago";
      }

      int years = (diffInDays / 365).floor();
      return "$years ${years == 1 ? "year" : "years"} ago";
    } catch (e) {
      return dateString; // Fallback
    }
  }

  Widget _grievanceCard(BuildContext context, GrievanceModel grievance) {
    final statusColor = getStatusColor(grievance.status);
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: () {
          HapticFeedback.lightImpact(); // Snappy feedback on tap
          Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => GrievanceDetailsPage(grievance: grievance))
          );
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F3F6),
            borderRadius: BorderRadius.circular(16.r),
            // Optional: slight border to match premium look
            border: Border.all(color: Colors.black.withOpacity(0.03)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        grievance.id,
                        style: TextStyle(fontSize: 11.sp, color: Colors.blueGrey.shade300, fontWeight: FontWeight.w600)
                    ),
                    SizedBox(height: 6.h),
                    Text(
                        grievance.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: const Color(0xFF141C46))
                    ),
                    SizedBox(height: 8.h),
                    // UPDATED TIME DISPLAY
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded, size: 12.sp, color: Colors.grey),
                        SizedBox(width: 4.w),
                        Text(
                            _getTimeAgo(grievance.submittedDate),
                            style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600, fontWeight: FontWeight.w500)
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8.r)
                    ),
                    child: Text(
                        grievance.status,
                        style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w800, color: statusColor)
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Icon(Icons.arrow_forward_ios_rounded, size: 16.sp, color: Colors.grey.shade400),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}