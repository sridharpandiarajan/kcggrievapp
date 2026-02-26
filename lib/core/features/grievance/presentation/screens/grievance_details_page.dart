import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../models/grievance_model.dart';

class GrievanceDetailsPage extends StatelessWidget {
  final GrievanceModel grievance;

  const GrievanceDetailsPage({super.key, required this.grievance});

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
    final statusColor = getStatusColor(grievance.status);

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

            /// DESCRIPTION CARD
            Text("Description:",
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                )),

            SizedBox(height: 10.h),

            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                grievance.description,
                style: TextStyle(
                  fontSize: 13.sp,
                  height: 1.5,
                ),
              ),
            ),

            SizedBox(height: 26.h),

            /// INFO SECTION
            _infoRow("Channel", grievance.channel),
            _infoRow("Category", grievance.category),
            _infoRow("Submitted Date", grievance.submittedDate),

            SizedBox(height: 12.h),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Status",
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.black54,
                    )),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 12.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    grievance.status,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                )
              ],
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

                  Text("Actions",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      )),

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
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.black54,
              )),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
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
            children: [
              Text("View",
                  style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.blue)),
              const Icon(Icons.arrow_forward_ios, size: 14)
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
