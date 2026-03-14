import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class AttachmentsPage extends StatelessWidget {
  final String grievanceId;

  const AttachmentsPage({super.key, required this.grievanceId});

  /// Opens the PDF inside the app using the Syncfusion widget
  void _viewInternalPdf(BuildContext context, String assetPath, String fileName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InternalPdfScreen(
          assetPath: assetPath,
          fileName: fileName,
        ),
      ),
    );
  }

  /// Downloads the file from assets to the device storage
  Future<void> _downloadFile(
      BuildContext context, String assetPath, String fileName) async {
    try {
      // 1. Load the bytes from your assets
      final byteData = await rootBundle.load(assetPath);

      Directory? directory;

      if (Platform.isAndroid) {
        // Direct path to the system Downloads folder
        final downloadsDir = Directory('/storage/emulated/0/Download');
        directory = Directory('${downloadsDir.path}/KCGGrievance');

        // Create the KCGGrievance folder if it doesn't exist
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }
      } else {
        // On iOS, we save to the app's Documents folder as iOS doesn't have a public 'Downloads' folder
        final docDir = await getApplicationDocumentsDirectory();
        directory = Directory('${docDir.path}/KCGGrievance');

        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }
      }

      // 2. Define the final path using the exact fileName passed
      final String finalPath = '${directory.path}/$fileName';
      final File file = File(finalPath);

      // 3. Write the data to the file
      // Using buffer.asUint8List ensures we only write the actual file data
      await file.writeAsBytes(byteData.buffer.asUint8List(
          byteData.offsetInBytes,
          byteData.lengthInBytes
      ));

      _showSnackBar(
        context,
        "File saved to Download/KCGGrievance",
        isSuccess: true,
      );
    } catch (e) {
      String errorMsg = e.toString().contains("Permission denied")
          ? "Please enable storage permissions in settings"
          : "Download failed: $e";

      _showSnackBar(context, errorMsg, isSuccess: false);
    }
  }

  void _showSnackBar(BuildContext context, String message, {required bool isSuccess}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic list pointing to your assets
    final List<Map<String, String>> attachments = [
      {"name": "test_pdf.PDF", "path": "assets/test_pdf.PDF", "size": "1.2 MB"},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: const Color(0xFF141C46), size: 18.sp),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          "Attachments",
          style: TextStyle(
            fontSize: 18.sp,
            color: const Color(0xFF141C46),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Grievance ID Header
          _buildHeader(),

          /// Scrollable List
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.all(20.w),
              itemCount: attachments.length,
              separatorBuilder: (context, index) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                final item = attachments[index];
                return _buildAttachmentCard(context, item);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: const Color(0xFF141C46).withOpacity(0.05),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(
              "ID: $grievanceId",
              style: TextStyle(
                fontSize: 12.sp,
                color: const Color(0xFF141C46),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            "Files submitted with the grievance",
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentCard(BuildContext context, Map<String, String> item) {
    return Container(
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
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Row(
          children: [
            /// PDF Icon Box
            Container(
              height: 50.h,
              width: 50.w,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(Icons.picture_as_pdf_rounded,
                  color: Colors.red.shade700, size: 28.sp),
            ),
            SizedBox(width: 12.w),

            /// File Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name']!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF141C46),
                    ),
                  ),
                  Text(
                    "${item['size']} • PDF Document",
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),

            /// Action Icons
            Row(
              children: [
                _actionIconButton(
                  icon: Icons.visibility_outlined,
                  onTap: () => _viewInternalPdf(context, item['path']!, item['name']!),
                  isPrimary: true,
                ),
                SizedBox(width: 8.w),
                _actionIconButton(
                  icon: Icons.file_download_outlined,
                  onTap: () => _downloadFile(context, item['path']!, item['name']!),
                  isPrimary: false,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionIconButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFF141C46) : Colors.transparent,
          borderRadius: BorderRadius.circular(10.r),
          border: isPrimary ? null : Border.all(color: Colors.grey.shade200),
        ),
        child: Icon(
          icon,
          size: 20.sp,
          color: isPrimary ? Colors.white : const Color(0xFF141C46),
        ),
      ),
    );
  }
}

/// INTERNAL PDF VIEWER SCREEN
class InternalPdfScreen extends StatelessWidget {
  final String assetPath;
  final String fileName;

  const InternalPdfScreen({
    super.key,
    required this.assetPath,
    required this.fileName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF141C46),
        elevation: 0,
        centerTitle: true,
        title: Text(
          fileName,
          style: TextStyle(color: Colors.white, fontSize: 16.sp),
        ),
        leading: IconButton(
          icon: const Icon(
              Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SfPdfViewer.asset(
        assetPath,
        onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load PDF: ${details.error}')),
          );
        },
      ),
    );
  }
}