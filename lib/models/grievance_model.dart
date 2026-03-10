import 'timeline_model.dart';

class GrievanceModel {
  final String id;
  final String title;
  final String status;
  final String description;
  final String channel;
  final String category;
  final String submittedDate;
  // 1. ADD THE TIMELINE FIELD
  final List<TimelineModel> timeline;

  const GrievanceModel({
    required this.id,
    required this.title,
    required this.status,
    required this.description,
    required this.channel,
    required this.category,
    required this.submittedDate,
    required this.timeline, // 2. ADD TO CONSTRUCTOR
  });

  factory GrievanceModel.fromJson(Map<String, dynamic> json) {
    // 3. PARSE THE TIMELINE LIST SAFELY
    List<TimelineModel> parsedTimeline = [];
    if (json['timeline'] != null && json['timeline'] is List) {
      parsedTimeline = (json['timeline'] as List)
          .map((e) => TimelineModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    /// If backend does not send timeline, ensure at least "Submitted" exists
    if (parsedTimeline.isEmpty) {
      parsedTimeline.add(
        TimelineModel(
          status: "Submitted",
          actor: "Student",
          date: _formatDate(json['created_at']),
        ),
      );
    }

    return GrievanceModel(
      id: _safeString(json['id']),
      title: _safeString(json['title']),
      description: _safeString(json['description']),
      status: _safeString(json['status_name'], defaultValue: "Pending"),
      channel: _safeString(json['channel_name'], defaultValue: "Yet to Assign"),
      category: _safeString(json['category_name'], defaultValue: "Yet to Assign"),
      submittedDate: _formatDate(json['created_at']),
      timeline: parsedTimeline, // 4. PASS TO CONSTRUCTOR
    );
  }

  /// Used for caching in Hive
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "status": status,
      "description": description,
      "channel": channel,
      "category": category,
      "submittedDate": submittedDate,
      "timeline": timeline.map((e) => e.toJson()).toList(), // 5. ADD TO TOJSON
    };
  }

  static String _safeString(
      dynamic value, {
        String defaultValue = '',
      }) {
    if (value == null) return defaultValue;
    return value.toString();
  }

  static String _formatDate(dynamic date) {
    if (date == null) return "N/A";

    try {
      final parsed = DateTime.parse(date.toString());
      return "${parsed.day.toString().padLeft(2, '0')}/"
          "${parsed.month.toString().padLeft(2, '0')}/"
          "${parsed.year}";
    } catch (_) {
      return date.toString();
    }
  }
}