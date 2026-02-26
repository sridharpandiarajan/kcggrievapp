import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'grievance_details_page.dart';
import '../../../../../models/grievance_model.dart';
import '../../../../../services/mock_student_service.dart';

class MyGrievancesPage extends StatefulWidget {
  const MyGrievancesPage({super.key});

  @override
  State<MyGrievancesPage> createState() => _MyGrievancesPageState();
}

class _MyGrievancesPageState extends State<MyGrievancesPage> {
  List<GrievanceModel> allGrievances = [];
  List<GrievanceModel> filteredGrievances = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await MockStudentService().getGrievances();
    setState(() {
      allGrievances = data;
      filteredGrievances = data;
    });
  }

  void _search(String query) {
    setState(() {
      filteredGrievances = allGrievances.where((g) {
        return g.id.toLowerCase().contains(query.toLowerCase()) ||
            g.title.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

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
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "My grievances",
          style: TextStyle(
            color: Colors.black,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(18.w),
        child: Column(
          children: [
            /// SEARCH BAR
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: TextField(
                onChanged: _search,
                decoration: InputDecoration(
                  icon: const Icon(Icons.search),
                  hintText: "Search by Grievance ID or title",
                  border: InputBorder.none,
                  hintStyle: TextStyle(fontSize: 13.sp),
                ),
              ),
            ),

            SizedBox(height: 18.h),

            /// LIST
            Expanded(
              child: ListView.builder(
                itemCount: filteredGrievances.length,
                itemBuilder: (context, index) {
                  final grievance = filteredGrievances[index];
                  final statusColor = getStatusColor(grievance.status);

                  return InkWell(
                    borderRadius: BorderRadius.circular(16.r),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              GrievanceDetailsPage(grievance: grievance),
                        ),
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: 14.h),
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  grievance.id,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.black54,
                                  ),
                                ),
                                SizedBox(height: 6.h),
                                Text(
                                  grievance.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 6.h),
                                Text(
                                  "2 days ago",
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12.w, vertical: 5.h),
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
                              SizedBox(height: 10.h),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 14.sp,
                                color: Colors.grey,
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
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
