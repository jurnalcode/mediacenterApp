import 'package:flutter/material.dart';
import '../config/app_config.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final bool showBackButton;
  final Color? backgroundColor;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.showBackButton = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(100),
      child: ClipPath(
        clipper: CurvedHeaderClipper(),
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            gradient: backgroundColor != null 
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    backgroundColor!,
                    backgroundColor!.withValues(alpha: 0.8),
                  ],
                  stops: const [0.0, 1.0],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppConfig.primaryGradient[0],
                    AppConfig.primaryGradient[1],
                  ],
                  stops: const [0.0, 1.0],
                ),
            boxShadow: [
              BoxShadow(
                color: (backgroundColor ?? AppConfig.primaryGradient[1]).withValues(alpha: 0.3),
                offset: const Offset(0, 4),
                blurRadius: 8,
              ),
            ],
          ),
          child: AppBar(
            title: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                fontSize: 24,
                letterSpacing: 0.5,
                color: Colors.white,
                shadows: [
                  Shadow(
                    offset: Offset(0, 2),
                    blurRadius: 4,
                    color: Color.fromRGBO(0, 0, 0, 0.3),
                  ),
                ],
              ),
            ),
            centerTitle: centerTitle,
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: leading,
            automaticallyImplyLeading: showBackButton,
            foregroundColor: Colors.white,
            actions: actions,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(100);
}

class CurvedHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    
    // Mulai dari kiri atas
    path.lineTo(0, 0);
    
    // Gambar sisi atas
    path.lineTo(size.width, 0);
    
    // Gambar sisi kanan ke titik awal kurva
    path.lineTo(size.width, size.height - 20);
    
    // Buat tepi bawah melengkung yang lebih natural menggunakan quadratic bezier
    // Ini membuat kurva lebih halus dan natural seperti pada gambar referensi
    final controlPoint = Offset(size.width * 0.5, size.height + 15);
    final endPoint = Offset(0, size.height - 20);
    
    path.quadraticBezierTo(
      controlPoint.dx, controlPoint.dy,
      endPoint.dx, endPoint.dy,
    );
    
    // Tutup jalur
    path.close();
    
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
