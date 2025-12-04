import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../models/page_model.dart';
import '../services/api_service.dart';
import '../widgets/custom_app_bar.dart';

class PageDetailScreen extends StatefulWidget {
  final PageModel page;

  const PageDetailScreen({super.key, required this.page});

  @override
  State<PageDetailScreen> createState() => _PageDetailScreenState();
}

class _PageDetailScreenState extends State<PageDetailScreen> {
  PageModel? fullPage;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFullPageContent();
  }

  Future<void> _loadFullPageContent() async {
    try {
      final pageData = await ApiService.getPage(widget.page.id);
      if (pageData != null) {
        setState(() {
          fullPage = pageData;
          isLoading = false;
        });
      } else {
        // Jika API gagal, gunakan data halaman asli
        setState(() {
          fullPage = widget.page;
          isLoading = false;
        });
      }
    } catch (e) {
      // Jika terjadi error, gunakan data halaman asli
      setState(() {
        fullPage = widget.page;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final page = fullPage ?? widget.page;
    
    return Scaffold(
      appBar: CustomAppBar(
        title: page.title,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              _sharePage(context);
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: SpinKitFadingCircle(
                color: Colors.blue,
                size: 50,
              ),
            )
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Utama
            if (page.picture.isNotEmpty)
              CachedNetworkImage(
                imageUrl: ApiService.getImageUrl(page.picture),
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 250,
                  color: Colors.grey[300],
                  child: const Center(
                    child: SpinKitFadingCircle(
                      color: Colors.grey,
                      size: 50,
                    ),
                  ),
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
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  
                  // Konten
                  Html(
                    data: page.content,
                    style: {
                      "body": Style(
                        fontSize: FontSize(16),
                        lineHeight: LineHeight.number(1.6),
                      ),
                      "p": Style(
                        margin: Margins.only(bottom: 16),
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
                      "ul, ol": Style(
                        margin: Margins.only(bottom: 16),
                        padding: HtmlPaddings.only(left: 20),
                      ),
                      "li": Style(
                        margin: Margins.only(bottom: 8),
                      ),
                      "table": Style(
                        border: Border.all(color: Colors.grey),
                        margin: Margins.only(top: 16, bottom: 16),
                      ),
                      "th, td": Style(
                        border: Border.all(color: Colors.grey),
                        padding: HtmlPaddings.all(8),
                      ),
                      "th": Style(
                        backgroundColor: Colors.grey[100],
                        fontWeight: FontWeight.bold,
                      ),
                    },
                    onLinkTap: (url, attributes, element) {
                      if (url != null) {
                        _launchUrl(url);
                      }
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Bagian Footer
                 
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sharePage(BuildContext context) {
    // Fitur berbagi sederhana
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Share: ${(fullPage ?? widget.page).title}'),
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
}
