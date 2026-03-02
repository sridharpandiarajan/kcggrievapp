import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'grievance_success_page.dart';
import '../../grievance_provider.dart';

class RegisterGrievancePage extends ConsumerStatefulWidget {
  const RegisterGrievancePage({super.key});

  @override
  ConsumerState<RegisterGrievancePage> createState() =>
      _RegisterGrievancePageState();
}

class _RegisterGrievancePageState
    extends ConsumerState<RegisterGrievancePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  List<PlatformFile> pickedFiles = [];
  static const Color primaryColor = Color(0xFF141C46);

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: true,
      );

      if (result != null) {
        List<PlatformFile> validFiles = [];
        for (var file in result.files) {
          if (file.size <= 10 * 1024 * 1024) {
            validFiles.add(file);
          } else {
            _showErrorSnackBar(
                "File ${file.name} exceeds 10 MB limit");
          }
        }
        setState(() {
          pickedFiles.addAll(validFiles);
        });
      }
    } catch (_) {
      _showErrorSnackBar("Error picking file");
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message),
          backgroundColor: Colors.redAccent),
    );
  }

  Future<void> _submitGrievance() async {
    if (!_formKey.currentState!.validate()) return;

    await ref
        .read(grievanceControllerProvider.notifier)
        .createGrievance(
          title: titleController.text.trim().isEmpty
              ? null
              : titleController.text.trim(),
          description: descriptionController.text.trim(),
          isAnonymous: false,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(grievanceControllerProvider);
    final isLoading = state is AsyncLoading;

    /// Listen for success / error
    ref.listen<AsyncValue<void>>(
        grievanceControllerProvider, (previous, next) {
      next.whenOrNull(
        data: (_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) =>
                    const GrievanceSuccessPage()),
          );
        },
        error: (e, _) {
          _showErrorSnackBar(
              "Failed to submit grievance");
        },
      );
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Register Grievance",
          style: TextStyle(
              color: Colors.black,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600),
        ),
        leading: const BackButton(color: Colors.black),
      ),
      body: Padding(
        padding: EdgeInsets.all(18.w),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _label("Title (optional)"),
              SizedBox(height: 6.h),
              _textField(
                controller: titleController,
                hint: "Enter title",
              ),

              SizedBox(height: 18.h),

              Row(
                children: [
                  _label("Description"),
                  SizedBox(width: 4.w),
                  Text(
                    "(required)",
                    style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.red,
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),
              SizedBox(height: 6.h),
              _textField(
                controller: descriptionController,
                hint:
                    "Provide a clear and factual description.",
                maxLines: 6,
                validator: (val) =>
                    val == null || val.isEmpty
                        ? "Description is required"
                        : null,
              ),

              SizedBox(height: 18.h),

              /// Attachments
              _label("Add attachments (optional)"),
              SizedBox(height: 8.h),

              SizedBox(
                height: 52.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12.r)),
                  ),
                  onPressed:
                      isLoading ? null : _submitGrievance,
                  child: isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white)
                      : Text(
                          "Submit Grievance",
                          style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight:
                                  FontWeight.bold),
                        ),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87),
      );

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: TextStyle(fontSize: 14.sp),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.all(16.w),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r)),
      ),
    );
  }
}