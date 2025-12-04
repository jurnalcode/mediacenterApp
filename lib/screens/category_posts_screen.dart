import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../providers/app_provider.dart';
import '../models/category.dart';
import '../models/post.dart';
import '../services/api_service.dart';
import '../utils/date_formatter.dart';
import '../widgets/shimmer_loading.dart';
import 'post_detail_screen.dart';
import '../widgets/custom_app_bar.dart';

class CategoryPostsScreen extends StatefulWidget {
  final Category category;
  final Color color;

  const CategoryPostsScreen({
    super.key,
    required this.category,
    required this.color,
  });

  @override
  State<CategoryPostsScreen> createState() => _CategoryPostsScreenState();
}

class _CategoryPostsScreenState extends State<CategoryPostsScreen> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  List<Post> _categoryPosts = [];
  bool _isLoading = false;
  int _currentPage = 1;
  bool _hasMorePosts = true;

  @override
  void initState() {
    super.initState();
    _loadCategoryPosts(refresh: true);
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _loadCategoryPosts({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMorePosts = true;
      _categoryPosts.clear();
    }

    if (!_hasMorePosts && !refresh) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.getPosts(
        page: _currentPage,
        limit: 10,
        categoryId: widget.category.id,
      );

      if (response.success) {
        if (refresh) {
          _categoryPosts = response.data;
        } else {
          _categoryPosts.addAll(response.data);
        }
        
        _currentPage++;
        _hasMorePosts = response.data.length >= 10;
      }
    } catch (e) {
      // Tangani error tanpa menampilkan pesan
      
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _onRefresh() async {
    await _loadCategoryPosts(refresh: true);
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    await _loadCategoryPosts();
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.category.title,
        backgroundColor: widget.color,
      ),
      body: Column(
        children: [
          // Daftar Artikel
          Expanded(
            child: _isLoading && _categoryPosts.isEmpty
                ? const Center(
                    child: SpinKitFadingCircle(
                      color: Colors.blue,
                      size: 50.0,
                    ),
                  )
                : _categoryPosts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.article_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Tidak ada postingan dalam kategori ini',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : SmartRefresher(
                        controller: _refreshController,
                        enablePullDown: true,
                        enablePullUp: _hasMorePosts,
                        onRefresh: _onRefresh,
                        onLoading: _onLoading,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _categoryPosts.length,
                          itemBuilder: (context, index) {
                            final post = _categoryPosts[index];
                            return _buildPostCard(post);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(Post post) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PostDetailScreen(post: post),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar
            if (post.picture.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: CachedNetworkImage(
                  imageUrl: ApiService.getImageUrl(post.picture),
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => ShimmerLoading(
                    width: double.infinity,
                    height: 200,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(
                        Icons.error,
                        size: 40,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            
            // Konten
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul
                  Text(
                    post.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  
                  // Pratinjau Konten
                  Text(
                    post.contentPreview,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  
                  // Informasi Meta
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormatter.formatWithTime(post.date, post.time),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.visibility,
                        size: 16,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post.hits} views',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                      const Spacer(),
                      Consumer<AppProvider>(
                        builder: (context, appProvider, child) {
                          return IconButton(
                            icon: Icon(
                              appProvider.isFavorite(post.id)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: appProvider.isFavorite(post.id)
                                  ? Colors.red
                                  : Colors.grey,
                            ),
                            onPressed: () {
                              appProvider.toggleFavorite(post.id);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
