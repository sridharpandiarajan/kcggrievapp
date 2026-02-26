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
}
