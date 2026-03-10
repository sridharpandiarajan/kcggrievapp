import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../models/grievance_model.dart';
import '../../../../../models/timeline_model.dart';

class StatusTimelinePage extends StatelessWidget {
  final List<TimelineModel> timeline;
  final String grievanceId;

  const StatusTimelinePage({
    super.key,
    required this.timeline,
    required this.grievanceId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        centerTitle: true,
        title: Text(
          "Status Timeline",
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Grievance ID: $grievanceId",
              style: TextStyle(fontSize: 13.sp, color: Colors.black54),
            ),
            SizedBox(height: 20.h),

            Expanded(
              child: ListView.builder(
                itemCount: timeline.length,
                itemBuilder: (context, index) {
                  final item = timeline[index];
                  final isLast = index == timeline.length - 1;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Timeline Line
                      Column(
                        children: [
                          Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: isLast
                                  ? const Color(0xFF141C46)
                                  : Colors.white,
                              border: Border.all(
                                color: const Color(0xFF141C46),
                                width: 2,
                              ),
                              shape: BoxShape.circle,
                            ),
                          ),
                          if (!isLast)
                            Container(
                              width: 2,
                              height: 60,
                              color: Colors.grey.shade300,
                            ),
                        ],
                      ),

                      SizedBox(width: 12.w),

                      /// Timeline Content
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 24.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.status,
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    item.actor,
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                item.date,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}