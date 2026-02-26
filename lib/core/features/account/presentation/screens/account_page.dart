import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kcggriev/core/info/support_content.dart'; // Ensure this path matches your project structure
import 'package:kcggriev/core/features/auth/presentation/screens/student_login.dart';
import  '../../../../storage/secure_storage_services.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  static const Color primaryColor = Color(0xFF141C46);
  static const Color backgroundColor = Color(0xFFF5F6F8);
  static const Color accentColor = Color(0xFF1E8E3E);

  // Controllers are now based on the length of the external data
  late final List<ExpansionTileController> _controllers;

  @override
  void initState() {
    super.initState();
    // Dynamically generate controllers based on the data provided in SupportContent
    _controllers = List.generate(
      SupportContent.data.length,
          (_) => ExpansionTileController(),
    );
  }

Future<void> _handleLogout() async {
  try {
    await SecureStorageService().clearTokens();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const StudentLogin(),
      ),
      (route) => false,
    );
  } catch (e) {
    debugPrint("Logout error: $e");
  }
}

  void _handleExpansion(int index) {
    for (int i = 0; i < _controllers.length; i++) {
      if (i != index) {
        _controllers[i].collapse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final supportItems = SupportContent.data; // Retrieve external text from your model

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Account",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 10.h),
        child: Column(
          children: [
            _buildProfileHeader(),
            SizedBox(height: 30.h),
            _buildSectionHeader("Personal Details"),
            SizedBox(height: 12.h),
            _buildInfoCard(),
            SizedBox(height: 30.h),
            _buildSectionHeader("Information & Support"),
            SizedBox(height: 12.h),

            /// BUILD ACCORDION FROM SEPARATED TEXT DATA
            Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: List.generate(supportItems.length, (index) {
                  return Column(
                    children: [
                      _buildExpansionTile(
                        index: index,
                        icon: supportItems[index]['icon'],
                        title: supportItems[index]['title'],
                        content: supportItems[index]['content'],
                      ),
                      if (index != supportItems.length - 1) _divider(),
                    ],
                  );
                }),
              ),
            ),

            SizedBox(height: 40.h),
            _buildLogoutButton(),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildExpansionTile({
    required int index,
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        controller: _controllers[index],
        onExpansionChanged: (isExpanded) {
          if (isExpanded) _handleExpansion(index);
        },
        leading: Icon(icon, size: 22.sp, color: primaryColor.withOpacity(0.7)),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        children: [
          Padding(
            padding: EdgeInsets.only(left: 55.w, right: 20.w, bottom: 15.h),
            child: Text(
              content,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.black54,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= PROFILE & INFO WIDGETS =================

  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 50.r,
                backgroundColor: primaryColor,
                child: Text("S", style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: CircleAvatar(
                  radius: 16.r,
                  backgroundColor: accentColor,
                  child: Icon(Icons.edit, color: Colors.white, size: 16.sp),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text("Sridhar P", style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700, color: primaryColor)),
          Text("ID: 9123205104", style: TextStyle(fontSize: 14.sp, color: Colors.black45, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          _infoRow(Icons.business_center_outlined, "Department", "Information Technology"),
          _divider(),
          _infoRow(Icons.calendar_today_outlined, "Current Year", "III Year"),
          _divider(),
          _infoRow(Icons.email_outlined, "Email ID", "sridhar.p@institution.edu"),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Text(title, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: primaryColor.withOpacity(0.8))),
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        children: [
          Icon(icon, size: 20.sp, color: Colors.black38),
          SizedBox(width: 15.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12.sp, color: Colors.black45)),
              Text(value, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: primaryColor)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return InkWell(
      borderRadius: BorderRadius.circular(16.r),
      onTap: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.r), // Softer, more modern corners
              ),
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// ICON HEADER
                    CircleAvatar(
                      radius: 30.r,
                      backgroundColor: Colors.red.withOpacity(0.1),
                      child: Icon(Icons.logout_rounded,
                          color: Colors.redAccent, size: 30.sp),
                    ),
                    SizedBox(height: 20.h),

                    /// TITLE
                    Text(
                      "Confirm Logout",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: primaryColor, // Using your Dark Navy
                      ),
                    ),
                    SizedBox(height: 10.h),

                    /// DESCRIPTION
                    Text(
                      "Are you sure you want to sign out? You will need to login again to access your grievances.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.black54,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 28.h),

                    /// ACTIONS
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              backgroundColor: Colors.grey.withOpacity(0.1),
                            ),
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              backgroundColor: Colors.redAccent,
                            ),
                            onPressed: _handleLogout,
                            child: Text(
                              "Logout",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );

        if (confirm == true) {
          /// 🔥 REMOVE ALL PREVIOUS SCREENS
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => const StudentLogin(),
            ),
                (route) => false,
          );
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.red.withOpacity(0.1)),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded,
                  color: Colors.redAccent, size: 20.sp),
              SizedBox(width: 10.w),
              Text(
                "Logout Account",
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w700,
                  fontSize: 15.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider() {
    return Divider(thickness: 1, color: backgroundColor, height: 1.h, indent: 50.w);
  }
}