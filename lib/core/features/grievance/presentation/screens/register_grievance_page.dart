import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'grievance_success_page.dart';

class RegisterGrievancePage extends StatefulWidget {
  const RegisterGrievancePage({super.key});

  @override
  State<RegisterGrievancePage> createState() => _RegisterGrievancePageState();
}

class _RegisterGrievancePageState extends State<RegisterGrievancePage> {
  final _formKey = GlobalKey<FormState>();

  String? selectedChannel;
  String? selectedCategory;
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
            _showErrorSnackBar("File ${file.name} exceeds 10 MB limit");
          }
        }
        setState(() {
          pickedFiles.addAll(validFiles);
        });
      }
    } catch (e) {
      _showErrorSnackBar("Error picking file");
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Register Grievance",
          style: TextStyle(color: Colors.black, fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
        leading: const BackButton(color: Colors.black),
      ),
      body: Padding(
        padding: EdgeInsets.all(18.w),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _label("Channel"),
              SizedBox(height: 6.h),
              _dropdownField(
                hint: "Select the type of grievance",
                value: selectedChannel,
                items: ["UGC Grievance", "Hostel", "Academics"],
                onChanged: (val) => setState(() => selectedChannel = val),
              ),

              SizedBox(height: 18.h),
              _label("Category"),
              SizedBox(height: 6.h),
              _dropdownField(
                hint: "Select the applicable category",
                value: selectedCategory,
                items: ["Academics & Evaluation", "Infrastructure", "Examination"],
                onChanged: (val) => setState(() => selectedCategory = val),
              ),

              SizedBox(height: 18.h),
              _label("Title (optional)"),
              SizedBox(height: 6.h),
              _textField(controller: titleController, hint: "Enter title"),

              SizedBox(height: 18.h),
              Row(
                children: [
                  _label("Description"),
                  SizedBox(width: 4.w),
                  Text("(required)", style: TextStyle(fontSize: 12.sp, color: Colors.red, fontWeight: FontWeight.bold))
                ],
              ),
              SizedBox(height: 6.h),
              _textField(
                controller: descriptionController,
                hint: "Provide a clear and factual description.",
                maxLines: 6,
                validator: (val) => val == null || val.isEmpty ? "Description is required" : null,
              ),

              SizedBox(height: 18.h),

              /// ATTACHMENT SECTION
              _label("Add attachments (optional)"),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.all(18.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: Colors.black.withOpacity(0.05)),
                ),
                child: Column(
                  children: [
                    if (pickedFiles.isNotEmpty)
                      Column(
                        children: pickedFiles.map((file) => Container(
                          margin: EdgeInsets.only(bottom: 8.h),
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F2F5),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: 18),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Text(
                                  file.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500),
                                ),
                              ),
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                                onPressed: () => setState(() => pickedFiles.remove(file)),
                                icon: Icon(Icons.cancel, color: Colors.grey.shade600, size: 20.sp),
                              )
                            ],
                          ),
                        )).toList(),
                      ),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.upload_file, size: 18.sp),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                        ),
                        onPressed: _pickFile,
                        label: Text(pickedFiles.isEmpty ? "Browse files" : "Add more files"),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      "Maximum upload file size is 10 MB per file. Only PDF files are allowed.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11.sp, color: Colors.black45),
                    )
                  ],
                ),
              ),

              SizedBox(height: 32.h),

              /// SUBMIT BUTTON
              SizedBox(
                height: 52.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const GrievanceSuccessPage()),
                      );
                    }
                  },
                  child: Text("Submit Grievance", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.black87));

  Widget _textField({required TextEditingController controller, required String hint, int maxLines = 1, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: TextStyle(fontSize: 14.sp),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.all(16.w),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide(color: Colors.black.withOpacity(0.05))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: const BorderSide(color: primaryColor, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: const BorderSide(color: Colors.redAccent)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: const BorderSide(color: Colors.redAccent)),
      ),
    );
  }

  /// ENHANCED DROPDOWN
  Widget _dropdownField({
    required String hint,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      elevation: 2,
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(16.r),
      style: TextStyle(fontSize: 14.sp, color: Colors.black, fontWeight: FontWeight.w500),
      icon: Icon(Icons.keyboard_arrow_down_rounded, color: primaryColor, size: 22.sp),
      decoration: InputDecoration(
        filled: true,
        // Changes color slightly once a value is selected for better UX
        fillColor: value == null ? Colors.white : primaryColor.withOpacity(0.03),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: Colors.black.withOpacity(0.05)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
      hint: Text(hint, style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w400)),
      items: items.map((e) => DropdownMenuItem(
        value: e,
        child: Text(e, style: TextStyle(fontSize: 14.sp)),
      )).toList(),
      onChanged: onChanged,
      validator: (val) => val == null ? "Field is required" : null,
    );
  }
}