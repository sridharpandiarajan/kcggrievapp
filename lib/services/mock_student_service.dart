import '../models/grievance_model.dart';

class MockStudentService {
  Future<List<GrievanceModel>> getGrievances() async {
    await Future.delayed(const Duration(seconds: 1));

    return [
      GrievanceModel(
        id: "G-2026-0123",
        title: "Delay in Semester 5 Result Publication",
        status: "Resolved",
        description:
        "I am writing to report a delay in the publication of my Semester 5 examination results for the academic year 2025–2026.\n\n"
            "The results were expected to be published by the first week of January, but as of today, they have not been released.\n\n"
            "This delay is affecting my internship application process, as result verification is required by the recruiting organization.",
        channel: "UGC Grievance",
        category: "Academics & Evaluation",
        submittedDate: "12 January 2026 · 10:42 AM",
      ),
      GrievanceModel(
        id: "S-2026-0457",
        title: "Water supply issue in hostel",
        status: "Pending",
        description: "Hostel water supply interruption issue.",
        channel: "Internal",
        category: "Hostel & Facilities",
        submittedDate: "10 January 2026 · 09:10 AM",
      ),
      GrievanceModel(
        id: "G-2026-0784",
        title: "Request for Re-evaluation",
        status: "Rejected",
        description: "Requesting re-evaluation of answer sheet.",
        channel: "UGC Grievance",
        category: "Academics & Evaluation",
        submittedDate: "05 January 2026 · 11:30 AM",
      ),
    ];
  }
}
