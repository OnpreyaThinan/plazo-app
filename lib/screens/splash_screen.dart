import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PlazoSplashScreen extends StatefulWidget {
  const PlazoSplashScreen({super.key});

  @override
  State<PlazoSplashScreen> createState() => _PlazoSplashScreenState();
}

class _PlazoSplashScreenState extends State<PlazoSplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Entrance animation only
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.8, curve: Curves.easeOut)),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.8, curve: Curves.easeOutQuart)),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Theme Colors from your app
    const mintColor = Color(0xFFA2D2BB);
    const mintDarkColor = Color(0xFF2D4A44);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Subtle Background Glow
          Positioned(
            top: -150,
            left: -150,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: mintColor.withValues(alpha: 0.05),
              ),
            ),
          ),

          // Central Content
          Center(
            child: FadeTransition(
              opacity: _fadeInAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo Pz (Static)
                    SizedBox(
                      width: 250,
                      height: 180,
                      child: Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          // Soft Glow behind logo
                          Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: mintColor.withValues(alpha: 0.1),
                                  blurRadius: 60,
                                  spreadRadius: 20,
                                ),
                              ],
                            ),
                          ),
                          // P and z (Static)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _buildLetter(
                                'P',
                                150,
                                const [
                                  Color(0xFF8EDCBD),
                                  Color(0xFF74C7A6),
                                  Color(0xFF5DAE90),
                                ],
                              ),
                              Transform.translate(
                                offset: const Offset(-15, 0),
                                child: _buildLetter(
                                  'z',
                                  100,
                                  const [
                                    Color(0xFF9DE5C5),
                                    Color(0xFF7FCFAE),
                                    Color(0xFF68B89A),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          // Graduation Cap (Static Position)
                          Positioned(
                            top: 30,
                            right: -14,
                            child: Transform.rotate(
                              angle: 0.14,
                              child: SizedBox(
                                width: 52,
                                height: 36,
                                child: CustomPaint(
                                  painter: const _SplashCapPainter(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 50),
                    // App Name (Sans-serif, Bold, Uppercase)
                    Text(
                      'PLAZO',
                      style: GoogleFonts.outfit(
                        fontSize: 40,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 6,
                        color: mintDarkColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Opacity(
                      opacity: 0.4,
                      child: Text(
                        'YOUR STUDY COMPANION',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 5,
                          color: mintDarkColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLetter(String char, double size, List<Color> colors) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: colors,
      ).createShader(bounds),
      child: Text(
        char,
        style: GoogleFonts.dynaPuff(
          fontSize: size,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          height: 1,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplashCapPainter extends CustomPainter {
  const _SplashCapPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final boardFill = Paint()
      ..color = const Color(0xFF0E1020)
      ..style = PaintingStyle.fill;
    final headFill = Paint()
      ..color = const Color(0xFF171626)
      ..style = PaintingStyle.fill;
    final innerFill = Paint()
      ..color = const Color(0xFF201E31)
      ..style = PaintingStyle.fill;
    final tassel = Paint()
      ..color = const Color(0xFFE8CC4F)
      ..style = PaintingStyle.fill;
    final tasselStroke = Paint()
      ..color = const Color(0xFFE8CC4F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final board = Path()
      ..moveTo(size.width * 0.07, size.height * 0.22)
      ..lineTo(size.width * 0.56, size.height * 0.13)
      ..lineTo(size.width * 0.92, size.height * 0.44)
      ..lineTo(size.width * 0.43, size.height * 0.53)
      ..close();
    canvas.drawPath(board, boardFill);

    final head = Path()
      ..moveTo(size.width * 0.30, size.height * 0.52)
      ..lineTo(size.width * 0.24, size.height * 0.78)
      ..lineTo(size.width * 0.62, size.height * 0.90)
      ..lineTo(size.width * 0.64, size.height * 0.58)
      ..close();
    canvas.drawPath(head, headFill);

    final inner = Path()
      ..moveTo(size.width * 0.34, size.height * 0.50)
      ..quadraticBezierTo(
        size.width * 0.52,
        size.height * 0.56,
        size.width * 0.66,
        size.height * 0.66,
      )
      ..lineTo(size.width * 0.64, size.height * 0.58)
      ..lineTo(size.width * 0.33, size.height * 0.52)
      ..close();
    canvas.drawPath(inner, innerFill);

    final rope = Path()
      ..moveTo(size.width * 0.84, size.height * 0.43)
      ..quadraticBezierTo(
        size.width * 0.80,
        size.height * 0.62,
        size.width * 0.82,
        size.height * 0.70,
      );
    canvas.drawPath(rope, tasselStroke);
    canvas.drawCircle(Offset(size.width * 0.83, size.height * 0.45), 3, tassel);

    final tasselShape = Path()
      ..moveTo(size.width * 0.79, size.height * 0.70)
      ..lineTo(size.width * 0.74, size.height * 0.95)
      ..lineTo(size.width * 0.86, size.height * 0.98)
      ..lineTo(size.width * 0.89, size.height * 0.72)
      ..close();
    canvas.drawPath(tasselShape, tassel);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
