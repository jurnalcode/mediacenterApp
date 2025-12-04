class CommentModel {
  final int id;
  final int parentId;
  final String name;
  final String url;
  final String comment;
  final String date;
  final String time;
  final List<CommentModel> children;

  CommentModel({
    required this.id,
    required this.parentId,
    required this.name,
    required this.url,
    required this.comment,
    required this.date,
    required this.time,
    this.children = const [],
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    final List<CommentModel> kids = (json['children'] as List? ?? [])
        .map((e) => CommentModel.fromJson(e))
        .toList();
    return CommentModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      parentId: int.tryParse(json['parent_id'].toString()) ?? 0,
      name: json['name'] ?? '',
      url: json['url'] ?? '',
      comment: json['comment'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      children: kids,
    );
  }
}
