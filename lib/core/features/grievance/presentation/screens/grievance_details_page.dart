import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../models/grievance_model.dart';
import '../../grievance_provider.dart';

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
    _future = ref
        .read(grievanceControllerProvider.notifier)
        .fetchGrievanceById(widget.grievance.id);
  }

  // Text color for the badge
  Color getStatusTextColor(String status) {
    switch (status) {
      case "Resolved":
        return const Color(0xFF1E8E3E);
      case "Rejected":
        return const Color(0xFFD93025);
      default:
        return const Color(0xFFF9AB00);
    }
  }

  // Soft background color for the badge chip
  Color getStatusBgColor(String status) {
    switch (status) {
      case "Resolved":
        return const Color(0xFFE8F5E9);
      case "Rejected":
        return const Color(0xFFFFEBEB);
      default:
        return const Color(0xFFFFF7E6);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<GrievanceModel>(
      future: _future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final grievance = snapshot.data!;

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
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(18.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ID
                Text(
                  "Grievance ID: ${grievance.id}",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: 8.h),

                /// TITLE
                Text(
                  grievance.title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 20.h),

                /// DESCRIPTION
                Text(
                  "Description",
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 10.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    grievance.description.isNotEmpty
                        ? grievance.description
                        : "No description provided",
                    style: TextStyle(
                      fontSize: 13.sp,
                      height: 1.5,
                    ),
                  ),
                ),
                SizedBox(height: 26.h),

                /// INFORMATION CARD
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Column(
                    children: [
                      _infoRow("Channel", grievance.channel),
                      _infoRow("Category", grievance.category),
                      _infoRow("Submitted Date", grievance.submittedDate),
                      // Pass status details to render the chip
                      _infoRow(
                        "Status",
                        grievance.status,
                        isStatus: true,
                        statusTextColor: getStatusTextColor(grievance.status),
                        statusBgColor: getStatusBgColor(grievance.status),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 26.h),

                /// ACTIONS CARD
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Actions",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      _actionTile("Attachments (2)", isLink: true),
                      SizedBox(height: 14.h),
                      _primaryButton("View Status Timeline"),
                      SizedBox(height: 12.h),
                      _outlineButton("View Final Remarks"),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _infoRow(
      String label,
      String value, {
        bool isStatus = false,
        Color? statusTextColor,
        Color? statusBgColor,
      }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.black54,
            ),
          ),
          if (isStatus)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: statusBgColor,
                borderRadius: BorderRadius.circular(20.r), // Rounded pill style
              ),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: statusTextColor,
                ),
              ),
            )
          else
            Flexible(
              child: Text(
                value.isNotEmpty ? value : "N/A",
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
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
            const Icon(Icons.attachment, size: 18),
            SizedBox(width: 8.w),
            Text(text, style: TextStyle(fontSize: 13.sp)),
          ],
        ),
        if (isLink)
          Row(
            children: const [
              Text(
                "View",
                style: TextStyle(color: Colors.blue),
              ),
              Icon(Icons.arrow_forward_ios, size: 14)
            ],
          )
      ],
    );
  }

  Widget _primaryButton(String text) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 14.h),
      decoration: BoxDecoration(
        color: const Color(0xFF141C46),
        borderRadius: BorderRadius.circular(12.r),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _outlineButton(String text) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 14.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFF141C46)),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          color: const Color(0xFF141C46),
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}