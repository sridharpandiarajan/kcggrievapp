class GrievanceModel {
  final String id;
  final String title;
  final String status;
  final String description;
  final String channel;
  final String category;
  final String submittedDate;

  GrievanceModel({
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
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Pending',
      description: json['description']?.toString() ?? '',
      channel: json['channel']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      submittedDate: json['createdAt']?.toString() ??
          json['submittedDate']?.toString() ??
          '',
    );
  }
}