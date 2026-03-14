import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Note: Ensure your internal imports match your project structure
// import '../../../../../models/grievance_model.dart';
// import '../../grievance_provider.dart';
// import 'status_timeline_page.dart';
// import 'attachments_page.dart';

class GrievanceDetailsPage extends ConsumerStatefulWidget {
  final dynamic grievance; // Replace with GrievanceModel

  const GrievanceDetailsPage({
    super.key,
    required this.grievance,
  });

  @override
  ConsumerState<GrievanceDetailsPage> createState() =>
      _GrievanceDetailsPageState();
}

class _GrievanceDetailsPageState extends ConsumerState<GrievanceDetailsPage> {
  late Future<dynamic> _future; // Replace with GrievanceModel

  @override
  void initState() {
    super.initState();
    _loadGrievance();
  }

  void _loadGrievance() {
    // Replace with your actual provider logic
    // _future = ref
    //     .read(grievanceControllerProvider.notifier)
    //     .fetchGrievanceById(widget.grievance.id);
  }

  /// Helper to convert string to Sentence Case
  String _toSentenceCase(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  Color getStatusTextColor(String status) {
    // Use .toUpperCase() for consistent matching
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
    // Using widget.grievance for demonstration; replace with snapshot.data in build
    final grievance = widget.grievance;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 24.sp),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          "Grievance Details",
          style: TextStyle(
            fontSize: 18.sp,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Grievance ID: ${grievance.id}",
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              grievance.title,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: Colors.black,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              "Description:",
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 12.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                grievance.description.isNotEmpty
                    ? grievance.description
                    : "No description provided",
                style: TextStyle(
                  fontSize: 15.sp,
                  height: 1.6,
                  color: Colors.black.withOpacity(0.8),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            SizedBox(height: 32.h),
            _buildDetailRow("Channel", grievance.channel),
            _buildDetailRow("Category", grievance.category),
            _buildDetailRow("Submitted Date", grievance.submittedDate),
            _buildDetailRow("Status", grievance.status, isStatus: true),
            SizedBox(height: 32.h),
            _buildActionsSection(grievance),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isStatus = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15.sp,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w400,
            ),
          ),
          if (isStatus)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: getStatusBgColor(value),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                _toSentenceCase(value), // Displays 'Resolved' instead of 'RESOLVED'
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: getStatusTextColor(value),
                ),
              ),
            )
          else
            Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionsSection(dynamic grievance) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Actions",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 20.h),
          InkWell(
            onTap: () {}, // Navigate to Attachments
            child: Row(
              children: [
                Icon(Icons.link, size: 20.sp, color: Colors.black),
                SizedBox(width: 12.w),
                Text(
                  "Attachments (2)",
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: Colors.black.withOpacity(0.8),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const Spacer(),
                Text(
                  "View",
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: Colors.blue.shade400,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(Icons.arrow_forward_ios, size: 14.sp, color: Colors.black),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          _actionButton(
            text: "View Status Timeline",
            isPrimary: true,
            onTap: () {},
          ),
          SizedBox(height: 12.h),
          _actionButton(
            text: "View Final Remarks",
            isPrimary: false,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String text,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 54.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFF0D1435) : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: isPrimary ? null : Border.all(color: Colors.black, width: 1),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: isPrimary ? Colors.white : Colors.black,
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}