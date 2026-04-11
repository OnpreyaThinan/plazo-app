import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PlazoSplashScreen extends StatefulWidget {
  const PlazoSplashScreen({super.key});

  @override
  State<PlazoSplashScreen> createState() => _PlazoSplashScreenState();
}

class _PlazoSplashScreenState extends State<PlazoSplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideUp = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart),
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
    const mintDarkColor = Color(0xFF2D4A44);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeIn,
          child: SlideTransition(
            position: _slideUp,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 200,
                  height: 180,
                  child: SvgPicture.string(
                    _plazoLogoSvg,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  'PLAZO',
                  style: GoogleFonts.outfit(
                    fontSize: 56,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                    color: mintDarkColor,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  'YOUR STUDY COMPANION',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 6,
                    color: mintDarkColor.withValues(alpha: 0.3),
                  ),
                ),
              ],
            ),
          ),
        ),
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

const String _plazoLogoSvg = '''
<svg width="300" height="250" viewBox="0 0 300 250" fill="none" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="pageGradient" x1="0%" y1="0%" x2="100%" y2="0%">
      <stop offset="0%" stop-color="#FFF9F0" />
      <stop offset="45%" stop-color="#F5E6D3" />
      <stop offset="50%" stop-color="#E8D5C0" />
      <stop offset="55%" stop-color="#F5E6D3" />
      <stop offset="100%" stop-color="#FFF9F0" />
    </linearGradient>
    <linearGradient id="coverGradient" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" stop-color="#A2D2BB" />
      <stop offset="100%" stop-color="#7FB89D" />
    </linearGradient>
    <linearGradient id="capTopGradient" x1="50%" y1="0%" x2="50%" y2="100%">
      <stop offset="0%" stop-color="#2D4A44" />
      <stop offset="100%" stop-color="#1A2E2A" />
    </linearGradient>
    <linearGradient id="capBaseGradient" x1="0%" y1="0%" x2="100%" y2="0%">
      <stop offset="0%" stop-color="#1A2E2A" />
      <stop offset="50%" stop-color="#2D4A44" />
      <stop offset="100%" stop-color="#1A2E2A" />
    </linearGradient>
    <linearGradient id="tasselGradient" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" stop-color="#F4D03F" />
      <stop offset="100%" stop-color="#D4AC0D" />
    </linearGradient>
  </defs>

  <g transform="translate(20, 70)">
    <path d="M10 165C10 165 70 155 140 165C210 155 270 165 270 165V45C270 45 210 35 140 45C70 35 10 45 10 45V165Z" fill="#86C0A1" />
    <path d="M10 160C10 160 70 150 140 160C210 150 270 160 270 160V40C270 40 210 30 140 40C70 30 10 40 10 40V160Z" fill="url(#coverGradient)" stroke="#86C0A1" stroke-width="1"/>
    <path d="M15 155C15 155 72 145 140 155C208 145 265 155 265 155V35C265 35 208 25 140 35C72 25 15 35 15 35V155Z" fill="#E8D5C0" />
    <path d="M20 150C20 150 75 140 140 150C205 140 260 150 260 150V30C260 30 205 20 140 30C75 20 20 30 20 30V150Z" fill="url(#pageGradient)"/>
    <g opacity="0.15" stroke="#2D4A44" stroke-width="1" stroke-linecap="round">
      <path d="M45 60C45 60 75 57 110 58" /><path d="M45 80C45 80 75 77 110 78" />
      <path d="M45 100C45 100 75 97 110 98" /><path d="M45 120C45 120 75 117 110 118" />
      <path d="M170 58C170 58 205 57 235 60" /><path d="M170 78C170 78 205 77 235 80" />
      <path d="M170 98C170 98 205 97 235 100" /><path d="M170 118C170 118 205 117 235 120" />
    </g>
    <path d="M140 30V150" stroke="#2D4A44" stroke-opacity="0.2" stroke-width="1.5"/>
  </g>

  <g transform="translate(85, 20)">
    <path d="M35 55C35 55 35 80 70 80C105 80 105 55 105 55" fill="#0D1A18"/>
    <path d="M35 55C35 55 35 76 70 76C105 76 105 55 105 55" fill="url(#capBaseGradient)"/>
    <path d="M70 20L135 45L70 70L5 45L70 20Z" fill="#0D1A18"/>
    <path d="M70 15L135 40L70 65L5 40L70 15Z" fill="url(#capTopGradient)" stroke="#2D4A44" stroke-width="0.5"/>
    <circle cx="70" cy="40" r="4.5" fill="#D4AC0D"/>
    <circle cx="70" cy="40" r="3.5" fill="url(#tasselGradient)"/>
    <path d="M70 40C70 40 55 45 45 65" stroke="#D4AC0D" stroke-width="2.5" stroke-linecap="round"/>
    <path d="M70 40C70 40 55 45 45 65" stroke="url(#tasselGradient)" stroke-width="1.5" stroke-linecap="round"/>
    <g>
      <rect x="40" y="65" width="10" height="20" rx="1" fill="#D4AC0D"/>
      <rect x="41" y="65" width="8" height="20" rx="1" fill="url(#tasselGradient)"/>
    </g>
  </g>
</svg>
''';
