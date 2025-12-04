import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../models/post.dart';
import '../models/comment.dart';
import '../providers/app_provider.dart';
import '../services/api_service.dart';
import '../utils/date_formatter.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/custom_app_bar.dart';
import 'login_screen.dart';

class PostDetailScreen extends StatefulWidget {
  final Post post;

  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  bool _submitting = false;
  List<CommentModel> _comments = [];
  bool _loadingComments = true;
  int _commentPage = 1;
  bool _hasMoreComments = true;
  bool _asUser = true;
  CommentModel? _replyTarget;

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  Future<void> _fetchComments({bool append = false}) async {
    setState(() {
      _loadingComments = true;
    });
    final res = await ApiService.getComments(widget.post.id, page: _commentPage, limit: 10);
    if (res['success'] == true && res['data'] is List) {
      final List<CommentModel> items = (res['data'] as List)
          .map((e) => CommentModel.fromJson(e))
          .toList();
      final pagination = res['pagination'] ?? {};
      final totalPages = int.tryParse(pagination['total_pages']?.toString() ?? '1') ?? 1;
      setState(() {
        if (append) {
          _comments = [..._comments, ...items];
        } else {
          _comments = items;
        }
        _hasMoreComments = _commentPage < totalPages;
      });
    }
    setState(() {
      _loadingComments = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Media Center',
        actions: [
          Consumer<AppProvider>(
            builder: (context, appProvider, child) {
              final isFav = appProvider.isFavorite(widget.post.id);
              return IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.red : null,
                ),
                onPressed: () {
                  appProvider.toggleFavorite(widget.post.id);
                  final nowFav = appProvider.isFavorite(widget.post.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        nowFav ? 'Ditambahkan ke favorit' : 'Dihapus dari favorit',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              _sharePost(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Lencana Kategori
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.post.category,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Judul
                  Text(
                    widget.post.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (widget.post.picture.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: ApiService.getImageUrl(widget.post.picture),
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => ImageShimmer(
                        width: double.infinity,
                        height: 200,
                        borderRadius: BorderRadius.circular(0),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 250,
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(
                            Icons.error,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  
                  // Informasi Meta
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormatter.formatWithTime(widget.post.date, widget.post.time),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.visibility,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.post.hits} views',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Konten
                  Html(
                    data: widget.post.content,
                    style: {
                      "body": Style(
                        fontSize: FontSize(16),
                        lineHeight: LineHeight.number(1.6),
                        textAlign: TextAlign.justify,
                      ),
                      "p": Style(
                        margin: Margins.only(bottom: 16),
                        textAlign: TextAlign.justify,
                      ),
                      "h1, h2, h3, h4, h5, h6": Style(
                        fontWeight: FontWeight.bold,
                        margin: Margins.only(top: 16, bottom: 8),
                      ),
                      "img": Style(
                        width: Width(double.infinity),
                        margin: Margins.only(top: 8, bottom: 8),
                      ),
                      "blockquote": Style(
                        border: Border(
                          left: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 4,
                          ),
                        ),
                        padding: HtmlPaddings.only(left: 16),
                        margin: Margins.only(top: 16, bottom: 16),
                        fontStyle: FontStyle.italic,
                      ),
                    },
                    onLinkTap: (url, attributes, element) {
                      if (url != null) {
                        _launchUrl(url);
                      }
                    },
                  ),
                  
                  // Tag (jika tersedia)
                  if (widget.post.tag != null && widget.post.tag!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    const Text(
                      'Tags:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.post.tag!.split(',').map((tag) {
                        return Chip(
                          label: Text(
                            tag.trim(),
                            style: const TextStyle(fontSize: 12),
                          ),
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.1),
                        );
                      }).toList(),
                    ),
                  ],
                  
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text(
                    'Komentar',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 12),
                  if (_loadingComments)
                    const Center(child: SpinKitThreeBounce(color: Colors.grey, size: 24))
                  else ...[
                    Column(
                      children: _comments.map((c) => _buildCommentItem(context, c)).toList(),
                    ),
                    const SizedBox(height: 16),
                    if (_hasMoreComments)
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () async {
                            setState(() { _commentPage += 1; });
                            await _fetchComments(append: true);
                          },
                          child: const Text('Muat lebih banyak'),
                        ),
                      ),
                  ],
                  const Divider(),
                  const SizedBox(height: 12),
                  Consumer<AppProvider>(builder: (context, app, _) {
                    final loggedIn = app.currentUser != null;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Switch(
                              value: _asUser,
                              onChanged: (v) { setState(() { _asUser = v; }); },
                            ),
                            Text(_asUser ? (loggedIn ? 'Sebagai user terdaftar' : 'Sebagai user (perlu login)') : 'Sebagai anonim'),
                            const Spacer(),
                            if (!loggedIn)
                              TextButton(
                                onPressed: () async {
                                  await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
                                  setState(() {});
                                },
                                child: const Text('Login'),
                              ),
                            if (loggedIn)
                              TextButton(
                                onPressed: () async {
                                  await Provider.of<AppProvider>(context, listen: false).logoutUser();
                                  setState(() {});
                                },
                                child: const Text('Logout'),
                              ),
                          ],
                        ),
                        if (_replyTarget != null)
                          Wrap(
                            spacing: 8,
                            children: [
                              Chip(label: Text('Membalas: ${_replyTarget!.name}')),
                              TextButton(onPressed: (){ setState((){ _replyTarget = null; }); }, child: const Text('Batal balas')),
                            ],
                          ),
                      ],
                    );
                  }),
                  const SizedBox(height: 8),
                  const Text(
                    'Tulis Komentar',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Consumer<AppProvider>(builder: (context, app, _) {
                    final loggedIn = app.currentUser != null;
                    final name = loggedIn ? app.currentUser!.name : null;
                    final email = loggedIn ? app.currentUser!.email : null;
                    if (_asUser && loggedIn) {
                      _nameController.text = name ?? '';
                      _emailController.text = email ?? '';
                    }
                    return Column(children: [
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Nama'),
                        readOnly: _asUser && loggedIn,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Email'),
                        keyboardType: TextInputType.emailAddress,
                        readOnly: _asUser && loggedIn,
                      ),
                    ]);
                  }),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Komentar'),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitting ? null : _submitComment,
                      child: _submitting ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Kirim'),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sharePost(BuildContext context) {
    // Fitur berbagi sederhana
    // Dalam aplikasi nyata, Anda bisa menggunakan paket share_plus
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Share: ${widget.post.title}'),
        action: SnackBarAction(
          label: 'Copy',
          onPressed: () {
            // Fitur salin ke clipboard dapat ditambahkan di sini
          },
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildCommentItem(BuildContext context, CommentModel c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(radius: 16, child: Icon(Icons.person, size: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('${c.date} ${c.time}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 8),
          Text(c.comment),
          Row(children: [
            TextButton(onPressed: (){ setState((){ _replyTarget = c; }); }, child: const Text('Balas')),
          ]),
          if (c.children.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.only(left: 16),
              decoration: const BoxDecoration(border: Border(left: BorderSide(color: Colors.grey)) ),
              child: Column(
                children: c.children.map((ch) => _buildCommentItem(context, ch)).toList(),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Future<void> _submitComment() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final comment = _commentController.text.trim();
    if (name.isEmpty || email.isEmpty || comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lengkapi nama, email, dan komentar')));
      return;
    }
    setState(() { _submitting = true; });
    final res = await ApiService.submitComment(postId: widget.post.id, name: name, email: email, comment: comment, parentId: _replyTarget?.id ?? 0);
    setState(() { _submitting = false; });
    if (res['success'] == true) {
      _nameController.clear();
      _emailController.clear();
      _commentController.clear();
      setState(() { _commentPage = 1; _replyTarget = null; });
      await _fetchComments();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Komentar terkirim')));
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message']?.toString() ?? 'Gagal mengirim')));
    }
  }
}
