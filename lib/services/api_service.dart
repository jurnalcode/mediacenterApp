import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show debugPrint;
import '../config/app_config.dart';
import '../models/post.dart';
import '../models/category.dart';
import '../models/page_model.dart';
import '../models/settings.dart';

class ApiService {
  static String get baseUrl => '${AppConfig.baseUrl}/po-includes/api';
  static String get imageBaseUrl => '${AppConfig.baseUrl}/po-content/uploads';
  static String get thumbBaseUrl => '${AppConfig.baseUrl}/po-content/thumbs';
  // Ambil semua artikel
  static Future<PostResponse> getPosts({
    int page = 1,
    int limit = 10,
    int? categoryId,
    String? search,
  }) async {
    try {
      String url = '$baseUrl/posts.php?page=$page&limit=$limit';
      
      if (categoryId != null) {
        url += '&category=$categoryId';
      }
      
      if (search != null && search.isNotEmpty) {
        url += '&search=${Uri.encodeComponent(search)}';
      }
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return PostResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load posts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching posts: $e');
    }
  }

  // Ambil satu artikel
  static Future<Post?> getPost(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/posts.php?id=$id'));
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          return Post.fromJson(jsonData['data']);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error getting post: $e');
      return null;
    }
  }

  // Ambil semua kategori
  static Future<CategoryResponse> getCategories() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/categories.php'));
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return CategoryResponse.fromJson(jsonData);
      } else {
        return CategoryResponse(
          success: false,
          data: [],
          message: 'Failed to load categories: ${response.statusCode}',
        );
      }
    } catch (e) {
      return CategoryResponse(
        success: false,
        data: [],
        message: 'Error: $e',
      );
    }
  }

  // Ambil satu kategori
  static Future<Category?> getCategory(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/categories.php?id=$id'));
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          return Category.fromJson(jsonData['data']);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error getting category: $e');
      return null;
    }
  }

  // Ambil semua halaman
  static Future<PageResponse> getPages() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/pages.php'));
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return PageResponse.fromJson(jsonData);
      } else {
        return PageResponse(
          success: false,
          data: [],
          message: 'Failed to load pages: ${response.statusCode}',
        );
      }
    } catch (e) {
      return PageResponse(
        success: false,
        data: [],
        message: 'Error: $e',
      );
    }
  }

  // Ambil satu halaman
  static Future<PageModel?> getPage(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/pages.php?id=$id'));
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          return PageModel.fromJson(jsonData['data']);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error getting page: $e');
      return null;
    }
  }

  static Future<SettingsModel?> getSettings() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/settings.php'));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          return SettingsModel.fromJson(jsonData['data']);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error getting settings: $e');
      return null;
    }
  }

  // Kirim formulir kontak
  static Future<Map<String, dynamic>> submitContact({
    required String name,
    required String email,
    required String subject,
    required String message,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/contact.php'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': name,
          'email': email,
          'subject': subject,
          'message': message,
        }),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Failed to submit contact form: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // Metode bantu untuk mendapatkan URL gambar penuh
  static String getImageUrl(String imageName) {
    if (imageName.isEmpty) return '';
    return '$imageBaseUrl/$imageName';
  }

  // Metode bantu untuk mendapatkan URL thumbnail penuh
  static String getThumbUrl(String imageName) {
    if (imageName.isEmpty) return '';
    return '$thumbBaseUrl/$imageName';
  }

  static Future<Map<String, dynamic>> getComments(int postId, {int page = 1, int limit = 10}) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/comments.php?post_id=$postId&page=$page&limit=$limit'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'success': false, 'message': 'Failed: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> submitComment({
    required int postId,
    required String name,
    required String email,
    String? url,
    required String comment,
    int parentId = 0,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/comments.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'post_id': postId,
          'parent_id': parentId,
          'name': name,
          'email': email,
          'url': url ?? '',
          'comment': comment,
        }),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'success': false, 'message': 'Failed: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': username, 'password': password}),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'success': false, 'message': 'Failed: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> register({
    required String username,
    required String password,
    required String name,
    required String email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
          'name': name,
          'email': email,
        }),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'success': false, 'message': 'Failed: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
