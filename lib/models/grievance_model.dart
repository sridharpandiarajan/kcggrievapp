class GrievanceModel {
  final String id;
  final String title;
  final String status;
  final String description;
  final String channel;
  final String category;
  final String submittedDate;

  const GrievanceModel({
    required this.id,
    required this.title,
    required this.status,
    required this.description,
    required this.channel,
    required this.category,
    required this.submittedDate,
  });

  factory GrievanceModel.fromJson(Map<String, dynamic> json) {
    return GrievanceModel(
      id: _safeString(json['id']),
      title: _safeString(json['title']),
      description: _safeString(json['description']),
      status: _safeString(json['status_name'], defaultValue: "Pending"),
      channel: _safeString(json['channel_name'], defaultValue: "Yet to Assign"),
      category: _safeString(json['category_name'], defaultValue: "Yet to Assign"),
      submittedDate: _formatDate(json['created_at']),
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