import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/post.dart';
import '../models/category.dart';
import '../models/page_model.dart';
import '../services/api_service.dart';
import '../models/user.dart';
import 'dart:convert';

class AppProvider with ChangeNotifier {
  // Tema
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  // Artikel
  List<Post> _posts = [];
  List<Post> get posts => _posts;
  
  List<Post> _featuredPosts = [];
  List<Post> get featuredPosts => _featuredPosts;
  
  bool _isLoadingPosts = false;
  bool get isLoadingPosts => _isLoadingPosts;
  
  int _currentPage = 1;
  int get currentPage => _currentPage;
  
  bool _hasMorePosts = true;
  bool get hasMorePosts => _hasMorePosts;

  // Kategori
  List<Category> _categories = [];
  List<Category> get categories => _categories;
  
  bool _isLoadingCategories = false;
  bool get isLoadingCategories => _isLoadingCategories;

  // Halaman
  List<PageModel> _pages = [];
  List<PageModel> get pages => _pages;
  
  bool _isLoadingPages = false;
  bool get isLoadingPages => _isLoadingPages;

  // Kategori terpilih untuk penyaringan
  Category? _selectedCategory;
  Category? get selectedCategory => _selectedCategory;

  // Pencarian
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  // Favorit
  List<int> _favoritePostIds = [];
  List<int> get favoritePostIds => _favoritePostIds;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  AppProvider() {
    _loadPreferences();
    loadInitialData();
  }

  // Muat data awal
  Future<void> loadInitialData() async {
    await Future.wait([
      loadCategories(),
      loadPosts(refresh: true),
      loadPages(),
    ]);
  }

  // Metode tema
  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  void setTheme(bool isDark) async {
    _isDarkMode = isDark;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  // Muat preferensi
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    
    // Muat ID artikel favorit
    final favoriteIds = prefs.getStringList('favoritePostIds') ?? [];
    _favoritePostIds = favoriteIds.map((id) => int.parse(id)).toList();
    final userJson = prefs.getString('currentUser');
    if (userJson != null && userJson.isNotEmpty) {
      try {
        final Map<String, dynamic> map = jsonDecode(userJson);
        _currentUser = UserModel.fromJson(map);
      } catch (_) {}
    }
    
    notifyListeners();
  }

  // Metode artikel
  Future<void> loadPosts({bool refresh = false, int? categoryId, String? search}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMorePosts = true;
      _posts.clear();
    }

    if (!_hasMorePosts && !refresh) return;

    _isLoadingPosts = true;
    notifyListeners();

    try {
      final response = await ApiService.getPosts(
        page: _currentPage,
        limit: 10,
        categoryId: categoryId,
        search: search,
      );

      if (response.success) {
        if (refresh) {
          _posts = response.data;
        } else {
          _posts.addAll(response.data);
        }
        
        _currentPage++;
        _hasMorePosts = response.data.length >= 10;
        
        // Perbarui artikel unggulan (5 pertama)
        if (refresh && categoryId == null && search == null) {
          _featuredPosts = _posts.take(5).toList();
        }
      }
    } catch (e) {
      debugPrint('Error loading posts: $e');
    }

    _isLoadingPosts = false;
    notifyListeners();
  }

  // Metode kategori
  Future<void> loadCategories() async {
    _isLoadingCategories = true;
    notifyListeners();

    try {
      final response = await ApiService.getCategories();
      if (response.success) {
        _categories = response.data;
      }
    } catch (e) {
      debugPrint('Error loading categories: $e');
    }

    _isLoadingCategories = false;
    notifyListeners();
  }

  // Metode halaman
  Future<void> loadPages() async {
    _isLoadingPages = true;
    notifyListeners();

    try {
      final response = await ApiService.getPages();
      if (response.success) {
        _pages = response.data;
      }
    } catch (e) {
      debugPrint('Error loading pages: $e');
    }

    _isLoadingPages = false;
    notifyListeners();
  }

  // Metode filter
  void setSelectedCategory(Category? category) {
    _selectedCategory = category;
    notifyListeners();
    loadPosts(refresh: true, categoryId: category?.id);
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
    if (query.isNotEmpty) {
      loadPosts(refresh: true, search: query);
    } else {
      loadPosts(refresh: true);
    }
  }

  void clearFilters() {
    _selectedCategory = null;
    _searchQuery = '';
    notifyListeners();
    loadPosts(refresh: true);
  }

  // Metode favorit
  bool isFavorite(int postId) {
    return _favoritePostIds.contains(postId);
  }

  Future<void> toggleFavorite(int postId) async {
    if (_favoritePostIds.contains(postId)) {
      _favoritePostIds.remove(postId);
    } else {
      _favoritePostIds.add(postId);
    }
    
    notifyListeners();
    
    // Simpan ke preferensi
    final prefs = await SharedPreferences.getInstance();
    final favoriteIds = _favoritePostIds.map((id) => id.toString()).toList();
    await prefs.setStringList('favoritePostIds', favoriteIds);
  }

  List<Post> get favoritePosts {
    return _posts.where((post) => _favoritePostIds.contains(post.id)).toList();
  }

  // Segarkan semua data
  Future<void> refreshAll() async {
    await loadInitialData();
  }

  Future<bool> loginUser(String username, String password) async {
    final res = await ApiService.login(username: username, password: password);
    if (res['success'] == true && res['user'] != null) {
      final user = UserModel.fromJson(res['user']);
      _currentUser = user;
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('currentUser', jsonEncode(user.toJson()));
      return true;
    }
    return false;
  }

  Future<void> logoutUser() async {
    _currentUser = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('currentUser');
  }

  Future<Map<String, dynamic>> registerUser({
    required String username,
    required String password,
    required String name,
    required String email,
  }) async {
    final res = await ApiService.register(username: username, password: password, name: name, email: email);
    if (res['success'] == true && res['user'] != null) {
      final user = UserModel.fromJson(res['user']);
      _currentUser = user;
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('currentUser', jsonEncode(user.toJson()));
    }
    return res;
  }
}
