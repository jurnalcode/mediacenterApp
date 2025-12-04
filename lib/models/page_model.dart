class PageModel {
  final int id;
  final String title;
  final String content;
  final String contentPreview;
  final String seotitle;
  final String picture;
  final String date;
  final String time;

  PageModel({
    required this.id,
    required this.title,
    required this.content,
    required this.contentPreview,
    required this.seotitle,
    required this.picture,
    required this.date,
    required this.time,
  });

  factory PageModel.fromJson(Map<String, dynamic> json) {
    return PageModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? json['content_preview'] ?? '',
      contentPreview: json['content_preview'] ?? '',
      seotitle: json['seotitle'] ?? '',
      picture: json['picture'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'content_preview': contentPreview,
      'seotitle': seotitle,
      'picture': picture,
      'date': date,
      'time': time,
    };
  }
}

class PageResponse {
  final bool success;
  final List<PageModel> data;
  final String? message;

  PageResponse({
    required this.success,
    required this.data,
    this.message,
  });

  factory PageResponse.fromJson(Map<String, dynamic> json) {
    return PageResponse(
      success: json['success'] ?? false,
      data: json['data'] != null
          ? (json['data'] as List).map((item) => PageModel.fromJson(item)).toList()
          : [],
      message: json['message'],
    );
  }
}