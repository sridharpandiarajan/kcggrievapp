import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../models/grievance_model.dart';
import '../../grievance_provider.dart';
import 'status_timeline_page.dart'; // Ensure this import exists

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
    switch (status) {
      case "Resolved": return const Color(0xFF1E8E3E);
      case "Rejected": return const Color(0xFFD93025);
      default: return const Color(0xFFF9AB00);
    }
  }

  Color getStatusBgColor(String status) {
    switch (status) {
      case "Resolved": return const Color(0xFFE8F5E9);
      case "Rejected": return const Color(0xFFFFEBEB);
      default: return const Color(0xFFFFF7E6);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: const BackButton(color: Colors.black),
        centerTitle: true,
        title: Text(
          "Grievance Details",
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: FutureBuilder<GrievanceModel>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF141C46)));
          }

          if (snapshot.hasError) {
            return _buildErrorState();
          }

          final grievance = snapshot.data!;

          return SingleChildScrollView(
            padding: EdgeInsets.all(18.w),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ID & Copy Action
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Grievance ID: ${grievance.id}",
                      style: TextStyle(fontSize: 12.sp, color: Colors.black54, fontWeight: FontWeight.w500),
                    ),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: grievance.id));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("ID copied to clipboard"), behavior: SnackBarBehavior.floating),
                        );
                      },
                      child: Icon(Icons.copy_rounded, size: 16.sp, color: Colors.blue),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),

                Text(
                  grievance.title,
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: const Color(0xFF141C46)),
                ),
                SizedBox(height: 20.h),

                _sectionLabel("Description"),
                SizedBox(height: 10.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Text(
                    grievance.description.isNotEmpty ? grievance.description : "No description provided",
                    style: TextStyle(fontSize: 13.sp, height: 1.6, color: Colors.black87),
                  ),
                ),
                SizedBox(height: 24.h),

                _sectionLabel("Details"),
                SizedBox(height: 10.h),
                _buildInfoCard(grievance),
                SizedBox(height: 24.h),

                _sectionLabel("Actions"),
                SizedBox(height: 10.h),
                _buildActionsCard(grievance),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- UI Helper Components ---

  Widget _sectionLabel(String text) => Text(
    text,
    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Colors.black54),
  );

  Widget _buildInfoCard(GrievanceModel grievance) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14.r)),
      child: Column(
        children: [
          _infoRow("Channel", grievance.channel),
          _infoRow("Category", grievance.category),
          _infoRow("Submitted Date", grievance.submittedDate),
          _infoRow(
            "Status",
            grievance.status,
            isStatus: true,
            statusTextColor: getStatusTextColor(grievance.status),
            statusBgColor: getStatusBgColor(grievance.status),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsCard(GrievanceModel grievance) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r)
      ),
      child: Column(
        children: [
          // Safety check: if timeline is empty, show 0 attachments
          _actionTile(
              "Attachments (${grievance.timeline.isNotEmpty ? 2 : 0})",
              isLink: true
          ),
          SizedBox(height: 16.h),
          _primaryButton("View Status Timeline", () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StatusTimelinePage(
                  timeline: grievance.timeline, // Now this works!
                  grievanceId: grievance.id,
                ),
              ),
            );
          }),
          SizedBox(height: 12.h),
          _outlineButton("View Final Remarks", () {
            // Your remarks logic
          }),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool isStatus = false, Color? statusTextColor, Color? statusBgColor}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13.sp, color: Colors.black54)),
          if (isStatus)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(color: statusBgColor, borderRadius: BorderRadius.circular(20.r)),
              child: Text(value, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w800, color: statusTextColor)),
            )
          else
            Text(value.isNotEmpty ? value : "N/A", style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _actionTile(String text, {bool isLink = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.attachment_rounded, size: 18.sp, color: const Color(0xFF141C46)),
            SizedBox(width: 8.w),
            Text(text, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500)),
          ],
        ),
        if (isLink) Icon(Icons.arrow_forward_ios_rounded, size: 12.sp, color: Colors.grey),
      ],
    );
  }

  Widget _primaryButton(String text, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF141C46),
        minimumSize: Size(double.infinity, 48.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        elevation: 0,
      ),
      child: Text(text, style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold)),
    );
  }

  Widget _outlineButton(String text, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: Size(double.infinity, 48.h),
        side: const BorderSide(color: Color(0xFF141C46)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      ),
      child: Text(text, style: TextStyle(color: const Color(0xFF141C46), fontSize: 14.sp, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Could not load latest details"),
          TextButton(onPressed: () => setState(() => _loadGrievance()), child: const Text("Retry")),
        ],
      ),
    );
  }
}