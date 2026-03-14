import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../models/grievance_model.dart';
import '../../grievance_provider.dart';
import 'status_timeline_page.dart';

class GrievanceDetailsPage extends ConsumerStatefulWidget {
  final GrievanceModel grievance;

  const GrievanceDetailsPage({
    super.key,
    required this.grievance,
  });

  @override
  ConsumerState<GrievanceDetailsPage> createState() =>
      _GrievanceDetailsPageState();
}

class _GrievanceDetailsPageState extends ConsumerState<GrievanceDetailsPage> {
  late Future<GrievanceModel> _future;

  @override
  void initState() {
    super.initState();
    _loadGrievance();
  }

  void _loadGrievance() {
    _future = ref
        .read(grievanceControllerProvider.notifier)
        .fetchGrievanceById(widget.grievance.id);
  }

  Color getStatusTextColor(String status) {
    switch (status.toUpperCase()) {
      case "RESOLVED": return const Color(0xFF34A853);
      case "REJECTED": return const Color(0xFFD93025);
      case "SUBMITTED": return const Color(0xFFF9AB00);
      default: return const Color(0xFFF9AB00);
    }
  }

  Color getStatusBgColor(String status) {
    switch (status.toUpperCase()) {
      case "RESOLVED": return const Color(0xFFE6F4EA);
      case "REJECTED": return const Color(0xFFFFEBEB);
      case "SUBMITTED": return const Color(0xFFFFF7E6);
      default: return const Color(0xFFFFF7E6);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leadingWidth: 48.w,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          "Grievance Details",
          style: TextStyle(fontSize: 18.sp, color: const Color(0xFF141C46), fontWeight: FontWeight.w700),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.h),
          child: Container(color: Colors.grey.shade100, height: 1.h),
        ),
      ),
      body: FutureBuilder<GrievanceModel>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF141C46)));
          }

          final grievance = snapshot.data ?? widget.grievance;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Grievance ID: ${grievance.id}",
                  style: TextStyle(fontSize: 13.sp, color: Colors.blueGrey.shade400, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 6.h),
                Text(
                  grievance.title,
                  style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w800, color: const Color(0xFF141C46)),
                ),
                SizedBox(height: 25.h),

                _sectionLabel("Description:"),
                SizedBox(height: 12.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Text(
                    grievance.description.isNotEmpty ? grievance.description : "No description provided",
                    style: TextStyle(fontSize: 14.sp, height: 1.4, color: const Color(0xFF4A4A4A)),
                  ),
                ),
                SizedBox(height: 25.h),

                _buildDetailRow("Channel", grievance.channel),
                _buildDetailRow("Category", grievance.category),
                _buildDetailRow("Submitted Date", grievance.submittedDate),
                _buildDetailRow("Status", grievance.status, isStatus: true),

                SizedBox(height: 30.h),
                _buildActionsSection(grievance),
                SizedBox(height: 40.h),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
    text,
    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: Colors.grey.shade600),
  );

  Widget _buildDetailRow(String label, String value, {bool isStatus = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Label
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w400,
            ),
          ),

          // 2. Minimum Gap
          // This ensures the label and value never actually touch
          SizedBox(width: 16.w),

          // 3. Spacer pushes everything else to the right
          const Spacer(),

          // 4. Value Side
          if (isStatus)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: getStatusBgColor(value),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                value.toUpperCase(),
                style: TextStyle(
                  fontSize: 10.sp, // Slightly smaller for status tags
                  fontWeight: FontWeight.w900,
                  color: getStatusTextColor(value),
                ),
              ),
            )
          else
          // Expanded is safer here than Flexible to ensure
          // we use all available space without overlapping
            Expanded(
              flex: 3,
              child: Text(
                value.isNotEmpty ? value : "Yet to Assign",
                textAlign: TextAlign.end,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionsSection(GrievanceModel grievance) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Actions", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Colors.black)),
          SizedBox(height: 14.h),
          InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(8.r),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
              child: Row(
                children: [
                  Icon(Icons.link_rounded, size: 20.sp, color: Colors.grey.shade600),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      "Attachments (${grievance.timeline.isNotEmpty ? 2 : 0})",
                      style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade800, fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text("View", style: TextStyle(fontSize: 13.sp, color: const Color(0xFF141C46), fontWeight: FontWeight.w700)),
                  SizedBox(width: 4.w),
                  Icon(Icons.arrow_forward_rounded, size: 16.sp, color: const Color(0xFF141C46)),
                ],
              ),
            ),
          ),
          SizedBox(height: 18.h),
          _actionButton(
            text: "View Status Timeline",
            isPrimary: true,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => StatusTimelinePage(timeline: grievance.timeline, grievanceId: grievance.id)));
            },
          ),
          SizedBox(height: 10.h),
          _actionButton(
            text: "View Final Remarks",
            isPrimary: false,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _actionButton({required String text, required bool isPrimary, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        height: 48.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFF0D1435) : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: isPrimary ? null : Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            children: [
              SizedBox(width: 22.sp),
              Expanded(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: isPrimary ? Colors.white : const Color(0xFF141C46), fontSize: 13.sp, fontWeight: FontWeight.w600),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: isPrimary ? Colors.white : const Color(0xFF141C46), size: 22.sp),
            ],
          ),
        ),
      ),
    );
  }
}