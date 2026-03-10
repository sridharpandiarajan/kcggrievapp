import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
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
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTop = false;

  @override
  void initState() {
    super.initState();

    // Optimized Listener: Threshold set to 80 for near-instant responsiveness
    _scrollController.addListener(() {
      final isScrollingDown = _scrollController.offset > 80;
      if (isScrollingDown != _showBackToTop) {
        setState(() => _showBackToTop = isScrollingDown);
      }
    });

    Future.microtask(() {
      ref.read(grievanceControllerProvider.notifier).fetchMyGrievances();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    HapticFeedback.lightImpact();
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 600), // Quickened duration
      curve: Curves.easeOutCubic, // Responsive, non-linear curve
    );
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

      // SNAPPY & RESPONSIVE BACK TO TOP
      floatingActionButton: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: _showBackToTop ? 1.0 : 0.0,
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 350),
          offset: _showBackToTop ? Offset.zero : const Offset(0, 0.5),
          curve: Curves.easeOutBack,
          child: Container(
            // ChatGPT buttons use a slightly larger shadow spread for that 'floating' look
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF141C46).withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: FloatingActionButton(
              onPressed: _scrollToTop,
              elevation: 0,
              backgroundColor: const Color(0xFF141C46),
              // Circle shape instead of rounded rectangle
              shape: CircleBorder(
                side: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
              ),
              child: Icon(
                Icons.arrow_upward_rounded, // Use upward_rounded for the ChatGPT arrow style
                color: Colors.white,
                size: 24.sp,
              ),
            ),
          ),
        ),
      ),
      // ... inside your build method ...

      body: SafeArea(
        child: Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          trackVisibility: false,
          thickness: 8.w, // Slightly thicker for easier "grabbing"
          radius: Radius.circular(10.r),
          interactive: true, // ✅ THIS ALLOWS THE USER TO HOLD AND DRAG
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
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

              /// 2. REFRESH CONTROL
              CupertinoSliverRefreshControl(
                onRefresh: () async {
                  HapticFeedback.mediumImpact();
                  await ref.read(grievanceControllerProvider.notifier).fetchMyGrievances();
                  HapticFeedback.lightImpact();
                },
              ),

              /// 3. STATS HEADER (Counter Component)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
                  child: state.maybeWhen(
                    data: (grievances) {
                      final filteredCount = grievances.where((g) =>
                      g.id.toLowerCase().contains(searchQuery.toLowerCase()) ||
                          g.title.toLowerCase().contains(searchQuery.toLowerCase())).length;

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            searchQuery.isEmpty ? "All Grievances" : "Search Results",
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFF141C46).withOpacity(0.08),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              "$filteredCount Total",
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF141C46),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                    orElse: () => const SizedBox.shrink(),
                  ),
                ),
              ),

              /// 4. CONTENT LIST
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