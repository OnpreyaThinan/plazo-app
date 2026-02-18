import 'package:flutter/material.dart';

import '../app_colors.dart';

class LoginScreen extends StatefulWidget {
  final Function(String name, String email) onLogin;
  const LoginScreen({super.key, required this.onLogin});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            children: [
              const SizedBox(height: 10),
              const SizedBox(
                width: 180,
                height: 120,
                child: CustomPaint(
                  painter: GraduationCapPainter(),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "PLAZO",
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: AppColors.navy,
                  letterSpacing: -2,
                ),
              ),
              const Text(
                "Your companion for academic achievement and organized student life.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 40),
              _buildInput("Email Address", "Enter Email Address", _emailController),
              const SizedBox(height: 20),
              _buildInput("Password", "••••••••", _passController, isObscure: true),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  if (_emailController.text.isNotEmpty) {
                    widget.onLogin(
                      _emailController.text.split('@')[0],
                      _emailController.text,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 5,
                  shadowColor: AppColors.primary.withOpacity(0.4),
                ),
                child: const Text(
                  "Sign In",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey[200])),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      "Or continue with",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey[200])),
                ],
              ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _socialButton(
                    context,
                    "https://cdn-icons-png.flaticon.com/512/124/124010.png",
                    "Facebook sign-in",
                  ),
                  const SizedBox(width: 18),
                  _socialButton(
                    context,
                    "https://cdn-icons-png.flaticon.com/512/2991/2991148.png",
                    "Google sign-in",
                  ),
                  const SizedBox(width: 18),
                  _socialButton(
                    context,
                    "https://cdn-icons-png.flaticon.com/512/0/747.png",
                    "Apple sign-in",
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(
    String label,
    String hint,
    TextEditingController controller, {
    bool isObscure = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 6, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
          ),
        ),
        TextField(
          controller: controller,
          obscureText: isObscure,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[300], fontSize: 14),
            filled: true,
            fillColor: AppColors.bgInput,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
          ),
        ),
      ],
    );
  }

  Widget _socialButton(BuildContext context, String iconUrl, String label) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Social login coming soon.")),
          );
        },
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(child: Image.network(iconUrl, width: 26, height: 26)),
        ),
      ),
    );
  }
}

class GraduationCapPainter extends CustomPainter {
  const GraduationCapPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final capPaint = Paint()..color = AppColors.navy;
    final highlightPaint = Paint()..color = AppColors.primary;
    final tasselPaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final top = Path()
      ..moveTo(size.width * 0.1, size.height * 0.5)
      ..lineTo(size.width * 0.5, size.height * 0.2)
      ..lineTo(size.width * 0.9, size.height * 0.5)
      ..lineTo(size.width * 0.5, size.height * 0.8)
      ..close();
    canvas.drawPath(top, capPaint);

    final base = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.75),
        width: size.width * 0.45,
        height: size.height * 0.12,
      ),
      const Radius.circular(8),
    );
    canvas.drawRRect(base, highlightPaint);

    final tasselStart = Offset(size.width * 0.73, size.height * 0.48);
    final tasselEnd = Offset(size.width * 0.78, size.height * 0.88);
    canvas.drawLine(tasselStart, tasselEnd, tasselPaint);
    canvas.drawCircle(tasselEnd, 5, Paint()..color = AppColors.primary);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
