class Category {
  final int id;
  final String title;
  final String seotitle;
  final String picture;
  final int postsCount;

  Category({
    required this.id,
    required this.title,
    required this.seotitle,
    required this.picture,
    required this.postsCount,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: int.tryParse(json['id'].toString()) ?? 0,
      title: json['title'] ?? '',
      seotitle: json['seotitle'] ?? '',
      picture: json['picture'] ?? '',
      postsCount: int.tryParse(json['posts_count'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'seotitle': seotitle,
      'picture': picture,
      'posts_count': postsCount,
    };
  }
}

class CategoryResponse {
  final bool success;
  final List<Category> data;
  final String? message;

  CategoryResponse({
    required this.success,
    required this.data,
    this.message,
  });

  factory CategoryResponse.fromJson(Map<String, dynamic> json) {
    return CategoryResponse(
      success: json['success'] ?? false,
      data: json['data'] != null
          ? (json['data'] as List).map((item) => Category.fromJson(item)).toList()
          : [],
      message: json['message'],
    );
  }
}