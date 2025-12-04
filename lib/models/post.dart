class Post {
  final int id;
  final String title;
  final String content;
  final String contentPreview;
  final String seotitle;
  final String picture;
  final String pictureDescription;
  final String date;
  final String time;
  final int hits;
  final String category;
  final String? tag;
  final String? headline;

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.contentPreview,
    required this.seotitle,
    required this.picture,
    required this.pictureDescription,
    required this.date,
    required this.time,
    required this.hits,
    required this.category,
    this.tag,
    this.headline,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: int.tryParse(json['id'].toString()) ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? json['content_preview'] ?? '',
      contentPreview: json['content_preview'] ?? '',
      seotitle: json['seotitle'] ?? '',
      picture: json['picture'] ?? '',
      pictureDescription: json['picture_description'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      hits: int.tryParse(json['hits'].toString()) ?? 0,
      category: json['category'] ?? '',
      tag: json['tag'],
      headline: json['headline'],
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
      'picture_description': pictureDescription,
      'date': date,
      'time': time,
      'hits': hits,
      'category': category,
      'tag': tag,
      'headline': headline,
    };
  }
}

class PostResponse {
  final bool success;
  final List<Post> data;
  final Pagination? pagination;
  final String? message;

  PostResponse({
    required this.success,
    required this.data,
    this.pagination,
    this.message,
  });

  factory PostResponse.fromJson(Map<String, dynamic> json) {
    return PostResponse(
      success: json['success'] ?? false,
      data: json['data'] != null
          ? (json['data'] as List).map((item) => Post.fromJson(item)).toList()
          : [],
      pagination: json['pagination'] != null
          ? Pagination.fromJson(json['pagination'])
          : null,
      message: json['message'],
    );
  }
}

class Pagination {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;

  Pagination({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: int.tryParse(json['current_page'].toString()) ?? 1,
      totalPages: int.tryParse(json['total_pages'].toString()) ?? 1,
      totalItems: int.tryParse(json['total_items'].toString()) ?? 0,
      itemsPerPage: int.tryParse(json['items_per_page'].toString()) ?? 10,
    );
  }
}