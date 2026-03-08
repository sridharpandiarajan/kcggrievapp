import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'grievance_success_page.dart';
import '../../grievance_provider.dart';

class RegisterGrievancePage extends ConsumerStatefulWidget {
  const RegisterGrievancePage({super.key});

  @override
  ConsumerState<RegisterGrievancePage> createState() => _RegisterGrievancePageState();
}

class _RegisterGrievancePageState extends ConsumerState<RegisterGrievancePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  List<PlatformFile> pickedFiles = [];
  bool _isSubmitting = false;
  static const Color primaryColor = Color(0xFF141C46);

  // --- Logic ---

  Future<void> _pickFile() async {
    HapticFeedback.selectionClick();
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          pickedFiles.addAll(result.files.where((file) => file.size <= 10 * 1024 * 1024));
        });
        if (result.files.any((file) => file.size > 10 * 1024 * 1024)) {
          _showErrorSnackBar("Files exceeding 10MB were skipped.");
        }
      }
    } catch (_) {
      _showErrorSnackBar("Error picking file");
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _submitGrievance() async {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.vibrate();
      return;
    }

    setState(() => _isSubmitting = true);
    await HapticFeedback.heavyImpact();

    await ref.read(grievanceControllerProvider.notifier).createGrievance(
      title: titleController.text
          .trim()
          .isEmpty ? null : titleController.text.trim(),
      description: descriptionController.text.trim(),
      isAnonymous: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(grievanceControllerProvider);
    final isLoading = state.isLoading || _isSubmitting;

    // Robust Navigation Listener
    ref.listen<AsyncValue>(grievanceControllerProvider, (previous, next) {
      next.whenOrNull(
        data: (_) {
          HapticFeedback.lightImpact();

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const GrievanceSuccessPage(),
            ),
          );
        },
        error: (e, _) {
          _showErrorSnackBar("Submission failed. Please try again.");
        },
      );
    });

    return PopScope(
      canPop: !isLoading && titleController.text.isEmpty && descriptionController.text.isEmpty,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        _showDiscardDialog();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6F8),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Text("Register Grievance", style: TextStyle(color: Colors.black, fontSize: 16.sp, fontWeight: FontWeight.bold)),
          leading: BackButton(color: Colors.black, onPressed: () => _handleBackNavigation(isLoading)),
        ),
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.all(22.w),
                  children: [
                    _label("Title (optional)"),
                    SizedBox(height: 8.h),
                    _textField(controller: titleController, hint: "Short title of your issue", enabled: !isLoading),
                    SizedBox(height: 24.h),
                    _label("Description (required)"),
                    SizedBox(height: 8.h),
                    _textField(
                      controller: descriptionController,
                      hint: "Explain your grievance in detail...",
                      maxLines: 5,
                      enabled: !isLoading,
                      validator: (val) => val == null || val.isEmpty ? "Please enter a description" : null,
                    ),
                    SizedBox(height: 24.h),
                    _label("Attachments (PDF, Max 10MB)"),
                    SizedBox(height: 12.h),
                    _buildFilePickerBtn(isLoading),
                    _buildFilePreviewList(),
                  ],
                ),
              ),
              _buildSubmitButton(isLoading),
            ],
          ),
        ),
      ),
    );
  }

  // --- Sub-Widgets ---

  Widget _buildSubmitButton(bool isLoading) {
    return Container(
      padding: EdgeInsets.fromLTRB(22.w, 12.h, 22.w, 32.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52.h,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            disabledBackgroundColor: primaryColor.withOpacity(0.6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            elevation: 0,
          ),
          onPressed: isLoading ? null : _submitGrievance,
          child: isLoading
              ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 18.h, width: 18.w, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
              SizedBox(width: 12.w),
              Text("Submitting your Grievance...", style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          )
              : Text("Submit Grievance", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildFilePreviewList() {
    if (pickedFiles.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(top: 10.h),
      child: Column(
        children: pickedFiles.map((file) => Card(
          margin: EdgeInsets.only(bottom: 8.h),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r), side: BorderSide(color: Colors.grey.shade200)),
          child: ListTile(
            dense: true,
            leading: Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: 22.sp),
            title: Text(file.name, style: TextStyle(fontSize: 13.sp), overflow: TextOverflow.ellipsis),
            trailing: IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.grey, size: 20.sp),
              onPressed: () {
                HapticFeedback.selectionClick();
                setState(() => pickedFiles.remove(file));
              },
            ),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildFilePickerBtn(bool isLoading) {
    return Opacity(
      opacity: isLoading ? 0.6 : 1.0,
      child: InkWell(
        onTap: isLoading ? null : _pickFile,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
          decoration: BoxDecoration(
            // Using a very light version of your primary color for the background
            color: primaryColor.withOpacity(0.04),
            borderRadius: BorderRadius.circular(16.r),
            // Dashed border effect (Simulated with BorderSide and opacity)
            border: Border.all(
              color: primaryColor.withOpacity(0.2),
              width: 1.5,
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon container for a premium "app" look
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.cloud_upload_outlined,
                  color: primaryColor,
                  size: 28.sp,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                "Select PDF Documents",
                style: TextStyle(
                  fontSize: 15.sp,
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                "PDF files only • Max 10MB each",
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.black45,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Methods ---

  void _handleBackNavigation(bool isLoading) {
    if (isLoading) return;

    // Check if there is any data that would be lost
    final hasData = titleController.text.trim().isNotEmpty ||
        descriptionController.text.trim().isNotEmpty ||
        pickedFiles.isNotEmpty;

    if (hasData) {
      _showDiscardDialog();
    } else {
      HapticFeedback.lightImpact();
      Navigator.pop(context);
    }
  }

  void _showDiscardDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Visual warning icon
              CircleAvatar(
                radius: 28.r,
                backgroundColor: Colors.orange.withOpacity(0.1),
                child: Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 32.sp),
              ),
              SizedBox(height: 20.h),
              Text(
                "Discard Grievance?",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: const Color(0xFF141C46)),
              ),
              SizedBox(height: 12.h),
              Text(
                "Your progress and any attached documents will be lost. This action cannot be undone.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.sp, color: Colors.black54, height: 1.4),
              ),
              SizedBox(height: 28.h),
              Row(
                children: [
                  // Neutral Action
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      child: const Text("Keep Editing", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  // Destructive Action
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        Navigator.pop(context); // Close dialog
                        Navigator.pop(context); // Go back
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      child: const Text("Discard", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: Colors.black54));

  Widget _textField({required TextEditingController controller, required String hint, int maxLines = 1, bool enabled = true, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      enabled: enabled,
      validator: validator,
      style: TextStyle(fontSize: 14.sp),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: Colors.grey.shade300)),
      ),
    );
  }
}