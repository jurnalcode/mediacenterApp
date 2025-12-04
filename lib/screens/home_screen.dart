import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'dart:async';
import '../config/app_config.dart';
import '../models/post.dart';
import '../providers/app_provider.dart';
import '../services/api_service.dart';
import '../utils/date_formatter.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/custom_app_bar.dart';
import 'post_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  final TextEditingController _searchController = TextEditingController();
  final PageController _sliderController = PageController();
  int _sliderIndex = 0;
  Timer? _sliderTimer;
  final List<String> _sliderImages = const [
    'lib/assets/slider1.jpg',
    'lib/assets/slider2.jpg',
    'lib/assets/slider3.jpg',
    'lib/assets/slider4.jpg',
  ];

  @override
  void initState() {
    super.initState();
    // Muat data awal saat layar pertama kali dibuat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      appProvider.loadPosts(refresh: true);
      appProvider.loadCategories();
      appProvider.loadPages();
    });
    _sliderTimer = Timer.periodic(const Duration(seconds: 4), (t) {
      if (_sliderImages.isEmpty) return;
      _sliderIndex = (_sliderIndex + 1) % _sliderImages.length;
      _sliderController.animateToPage(
        _sliderIndex,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _searchController.dispose();
    _sliderTimer?.cancel();
    _sliderController.dispose();
    super.dispose();
  }

  void _onRefresh() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    await appProvider.loadPosts(refresh: true);
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    await appProvider.loadPosts();
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppConfig.appName,
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _showSearchDialog();
            },
          ),
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return SmartRefresher(
            controller: _refreshController,
            enablePullDown: true,
            enablePullUp: true,
            onRefresh: _onRefresh,
            onLoading: _onLoading,
            child: CustomScrollView(
              slivers: [
                // Bagian Artikel Unggulan
                if (appProvider.featuredPosts.isNotEmpty) ...
                  _buildFeaturedSection(appProvider.featuredPosts),
                SliverToBoxAdapter(child: _buildSlider()),
                
                // Bagian Semua Artikel
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const Text(
                          'Informasi Terbaru',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        if (appProvider.selectedCategory != null)
                          TextButton(
                            onPressed: () {
                              appProvider.clearFilters();
                            },
                            child: const Text('Clear Filter'),
                          ),
                      ],
                    ),
                  ),
                ),
                
                // Daftar Artikel
                if (appProvider.posts.isEmpty && appProvider.isLoadingPosts)
                  const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(50.0),
                        child: SpinKitFadingCircle(
                          color: Colors.blue,
                          size: 50.0,
                        ),
                      ),
                    ),
                  )
                else if (appProvider.posts.isEmpty)
                  const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(50.0),
                        child: Text(
                          'No posts available',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final post = appProvider.posts[index];
                        return _buildPostCard(post, appProvider);
                      },
                      childCount: appProvider.posts.length,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildFeaturedSection(List<Post> featuredPosts) {
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Pilihan Redaksi',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            physics: const BouncingScrollPhysics(),
            itemCount: featuredPosts.length,
            itemBuilder: (context, index) {
              final post = featuredPosts[index];
              return _buildFeaturedCard(post);
            },
          ),
        ),
      ),
      const SliverToBoxAdapter(
        child: SizedBox(height: 20),
      ),
    ];
  }

  Widget _buildSlider() {
    if (_sliderImages.isEmpty) return const SizedBox.shrink();
    final width = MediaQuery.of(context).size.width;
    final height = width * 0.6;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: height,
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _sliderController,
                    itemCount: _sliderImages.length,
                    onPageChanged: (i) {
                      setState(() { _sliderIndex = i; });
                    },
                    itemBuilder: (context, index) {
                      return Image.asset(
                        _sliderImages[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                      );
                    },
                  ),
                  Positioned(
                    bottom: 8,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_sliderImages.length, (i) {
                        final active = i == _sliderIndex;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: active ? 16 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: active ? Theme.of(context).colorScheme.primary : Colors.white.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCard(Post post) {
    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PostDetailScreen(post: post),
              ),
            );
          },
          child: Stack(
            children: [
              // Gambar Latar
              if (post.picture.isNotEmpty)
                CachedNetworkImage(
                  imageUrl: ApiService.getImageUrl(post.picture),
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => ImageShimmer(
                    width: double.infinity,
                    height: 200,
                    borderRadius: BorderRadius.circular(0),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.error),
                  ),
                ),
              
              // Lapisan Gradien
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
              
              // Konten
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${DateFormatter.formatToIndonesianShort(post.date)} • ${post.category}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostCard(Post post, AppProvider appProvider) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PostDetailScreen(post: post),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gambar
              if (post.picture.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: ApiService.getThumbUrl(post.picture),
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => ImageShimmer(
                      width: 80,
                      height: 80,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[300],
                      child: const Icon(Icons.error),
                    ),
                  ),
                ),
              
              const SizedBox(width: 16),
              
              // Konten
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      post.contentPreview,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormatter.formatToIndonesianShort(post.date),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.category,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            post.category,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
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
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Search News'),
          content: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Enter search keywords...',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final query = _searchController.text.trim();
                if (query.isNotEmpty) {
                  Provider.of<AppProvider>(context, listen: false)
                      .setSearchQuery(query);
                }
                Navigator.pop(context);
                _searchController.clear();
              },
              child: const Text('Search'),
            ),
          ],
        );
      },
    );
  }
}
