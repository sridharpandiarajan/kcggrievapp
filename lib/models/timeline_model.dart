class TimelineModel {
  final String status;
  final String actor;
  final String date;

  const TimelineModel({
    required this.status,
    required this.actor,
    required this.date,
  });

  factory TimelineModel.fromJson(Map<String, dynamic> json) {
    return TimelineModel(
      status: json['status_name']?.toString() ?? "",
      actor: json['actor']?.toString() ?? "",
      date: json['date']?.toString() ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "status": status,
      "actor": actor,
      "date": date,
    };
  }
}