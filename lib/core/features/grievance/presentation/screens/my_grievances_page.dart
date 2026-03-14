import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // Ensure intl is in pubspec.yaml
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
    _scrollController.addListener(_scrollListener);
    Future.microtask(() =>
        ref.read(grievanceControllerProvider.notifier).fetchMyGrievances()
    );
  }

  void _scrollListener() {
    final isScrollingDown = _scrollController.offset > 80;
    if (isScrollingDown != _showBackToTop) {
      setState(() => _showBackToTop = isScrollingDown);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  /// RELATIVE TIME LOGIC
  String _getTimeAgo(String dateString) {
    try {
      // Assumes format "dd/MM/yyyy". Adjust if your format differs.
      DateTime submittedDate = DateFormat("dd/MM/yyyy").parse(dateString);
      DateTime now = DateTime.now();
      Duration diff = now.difference(submittedDate);

      if (diff.inDays <= 0) {
        return "Today";
      } else if (diff.inDays < 31) {
        return "${diff.inDays} ${diff.inDays == 1 ? "Day" : "Days"} ago";
      } else if (diff.inDays < 365) {
        int months = (diff.inDays / 30).floor();
        return "$months ${months == 1 ? "Month" : "Months"} ago";
      } else {
        int years = (diff.inDays / 365).floor();
        return "$years ${years == 1 ? "Year" : "Years"} ago";
      }
    } catch (e) {
      return dateString; // Fallback to raw string
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "Resolved": return const Color(0xFF1E8E3E);
      case "Rejected": return const Color(0xFFD93025);
      default: return const Color(0xFFF9AB00);
    }
  }

  void _scrollToTop() {
    HapticFeedback.mediumImpact();
    _scrollController.animateTo(0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(grievanceControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      floatingActionButton: _buildFloatingButton(),
      body: SafeArea(
        child: Scrollbar(
          controller: _scrollController,
          thickness: 6.w,
          radius: Radius.circular(10.r),
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              _buildAppBar(),
              CupertinoSliverRefreshControl(
                onRefresh: () async => await ref.read(grievanceControllerProvider.notifier).fetchMyGrievances(),
              ),
              _buildStatsHeader(state),
              _buildMainContent(state),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text("My Grievances",
          style: TextStyle(color: const Color(0xFF141C46), fontSize: 16.sp, fontWeight: FontWeight.bold)
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(64.h),
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6F8),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: TextField(
              onChanged: (value) => setState(() => searchQuery = value),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey),
                hintText: "Search ID or title...",
                border: InputBorder.none,
                hintStyle: TextStyle(fontSize: 13.sp, color: Colors.grey),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsHeader(AsyncValue state) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(22.w, 15.h, 22.w, 10.h),
        child: state.maybeWhen(
          data: (grievances) {
            final count = grievances.where((g) =>
            g.id.toLowerCase().contains(searchQuery.toLowerCase()) ||
                g.title.toLowerCase().contains(searchQuery.toLowerCase())).length;
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(searchQuery.isEmpty ? "All Grievances" : "Filtered Results",
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.blueGrey)),
                Text("$count items", style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
              ],
            );
          },
          orElse: () => const SizedBox.shrink(),
        ),
      ),
    );
  }

  Widget _buildMainContent(AsyncValue state) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      sliver: state.when(
        loading: () => const SliverFillRemaining(child: Center(child: CupertinoActivityIndicator())),
        error: (e, _) => SliverFillRemaining(child: _buildErrorUI()),
        data: (grievances) {
          final filtered = grievances.where((g) =>
          g.id.toLowerCase().contains(searchQuery.toLowerCase()) ||
              g.title.toLowerCase().contains(searchQuery.toLowerCase())).toList();

          if (filtered.isEmpty) return SliverFillRemaining(child: _buildEmptyUI());

          return SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildGrievanceCard(filtered[index]),
              childCount: filtered.length,
            ),
          );
        },
      ),
    );
  }

  Widget _buildGrievanceCard(dynamic grievance) {
    final statusColor = getStatusColor(grievance.status);
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8))
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => GrievanceDetailsPage(grievance: grievance))),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(grievance.id,
                        style: TextStyle(fontSize: 11.sp, color: Colors.blueGrey.shade300, fontWeight: FontWeight.w700)),
                    SizedBox(height: 4.h),
                    Text(grievance.title,
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: const Color(0xFF141C46))),
                    SizedBox(height: 10.h),
                    // RELATIVE TIME TEXT
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded, size: 12.sp, color: Colors.grey),
                        SizedBox(width: 4.w),
                        Text(_getTimeAgo(grievance.submittedDate),
                            style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade500)),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r)
                    ),
                    child: Text(grievance.status,
                        style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w800, color: statusColor)),
                  ),
                  SizedBox(height: 15.h),
                  Icon(Icons.chevron_right_rounded, size: 20.sp, color: Colors.grey.shade300),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingButton() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: _showBackToTop ? 1.0 : 0.0,
      child: FloatingActionButton(
        onPressed: _scrollToTop,
        backgroundColor: const Color(0xFF141C46),
        child: const Icon(Icons.arrow_upward_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyUI() => _buildFeedback(Icons.search_off_rounded, "No Matches Found", "Try adjusting your search filters.");
  Widget _buildErrorUI() => _buildFeedback(Icons.cloud_off_rounded, "Connection Failed", "Check your internet and try again.");

  Widget _buildFeedback(IconData icon, String title, String msg) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 50.sp, color: Colors.grey.shade300),
        SizedBox(height: 10.h),
        Text(title, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
        Text(msg, style: TextStyle(fontSize: 13.sp, color: Colors.grey)),
      ],
    );
  }
}