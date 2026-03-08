import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // For modern refresh
import 'package:flutter/services.dart';  // For haptics
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../grievance_provider.dart';
import 'grievance_details_page.dart';

class MyGrievancesPage extends ConsumerStatefulWidget {
  const MyGrievancesPage({super.key});

  @override
  ConsumerState<MyGrievancesPage> createState() => _MyGrievancesPageState();
}

class _MyGrievancesPageState extends ConsumerState<MyGrievancesPage> {
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(grievanceControllerProvider.notifier).fetchMyGrievances();
    });
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "Resolved": return const Color(0xFF1E8E3E);
      case "Rejected": return const Color(0xFFD93025);
      default: return const Color(0xFFF9AB00);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(grievanceControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            /// 1. APP BAR
            SliverAppBar(
              floating: true,
              pinned: true,
              elevation: 0,
              backgroundColor: Colors.white,
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                "My grievances",
                style: TextStyle(color: Colors.black, fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(70.h),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 12.h),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F6F8),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: TextField(
                      onChanged: (value) => setState(() => searchQuery = value),
                      decoration: InputDecoration(
                        icon: const Icon(Icons.search, size: 20),
                        hintText: "Search by ID or title",
                        border: InputBorder.none,
                        hintStyle: TextStyle(fontSize: 13.sp),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            /// 2. MODERN REFRESH
            CupertinoSliverRefreshControl(
              onRefresh: () async {
                HapticFeedback.mediumImpact();
                await ref.read(grievanceControllerProvider.notifier).fetchMyGrievances();
                HapticFeedback.lightImpact();
              },
            ),

            /// 3. CONTENT SECTION
            SliverPadding(
              padding: EdgeInsets.all(18.w),
              sliver: state.when(
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: Color(0xFF1E8E3E))),
                ),
                error: (e, _) => SliverFillRemaining(
                  child: _buildStateFeedback(
                    icon: Icons.cloud_off_rounded,
                    title: "Connection Error",
                    message: "We couldn't fetch your grievances.",
                    onRetry: () => ref.read(grievanceControllerProvider.notifier).fetchMyGrievances(),
                  ),
                ),
                data: (grievances) {
                  final filtered = grievances.where((g) {
                    return g.id.toLowerCase().contains(searchQuery.toLowerCase()) ||
                        g.title.toLowerCase().contains(searchQuery.toLowerCase());
                  }).toList();

                  if (filtered.isEmpty) {
                    return SliverFillRemaining(
                      child: _buildStateFeedback(
                        icon: Icons.assignment_late_outlined,
                        title: "No Results",
                        message: "We couldn't find any matches.",
                        onRetry: () => ref.read(grievanceControllerProvider.notifier).fetchMyGrievances(),
                      ),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final grievance = filtered[index];
                        return _buildGrievanceCard(grievance);
                      },
                      childCount: filtered.length,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrievanceCard(dynamic grievance) {
    final statusColor = getStatusColor(grievance.status);
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: () {
          HapticFeedback.selectionClick();
          Navigator.push(context, MaterialPageRoute(builder: (_) => GrievanceDetailsPage(grievance: grievance)));
        },
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(grievance.id, style: TextStyle(fontSize: 12.sp, color: Colors.black54)),
                    SizedBox(height: 6.h),
                    Text(grievance.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                    decoration: BoxDecoration(color: statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(20.r)),
                    child: Text(grievance.status, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: statusColor)),
                  ),
                  SizedBox(height: 10.h),
                  Icon(Icons.arrow_forward_ios_rounded, size: 14.sp, color: Colors.grey),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStateFeedback({required IconData icon, required String title, required String message, required VoidCallback onRetry}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 60.sp, color: Colors.grey.shade400),
        SizedBox(height: 16.h),
        Text(title, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 8.h),
        Text(message, textAlign: TextAlign.center, style: TextStyle(fontSize: 14.sp, color: Colors.black54)),
        SizedBox(height: 24.h),
        TextButton(onPressed: onRetry, child: const Text("Try Again", style: TextStyle(color: Color(0xFF1E8E3E)))),
      ],
    );
  }
}