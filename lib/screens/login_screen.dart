import 'package:flutter/material.dart';

import '../app_colors.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  final Function(String name, String email) onLogin;
  const LoginScreen({super.key, required this.onLogin});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  bool _obscurePassword = true;
  bool _isFormValid = false;
  bool _attemptedSubmit = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateForm);
    _passController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  void _validateForm() {
    setState(() {
      _isFormValid = _isValidEmail(_emailController.text) && 
                      _passController.text.length >= 8;
    });
  }

  void _showForgotPasswordDialog() {
    final resetEmailController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          "Reset Password",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Enter your email address and we'll send you a link to reset your password.",
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: resetEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: "Enter your email",
                hintStyle: const TextStyle(fontSize: 14),
                prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primary),
                filled: true,
                fillColor: AppColors.bgInput,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(
                color: AppColors.getSecondaryTextColor(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (resetEmailController.text.isNotEmpty && 
                  _isValidEmail(resetEmailController.text)) {
                Navigator.pop(context);
                
                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Password reset link has been sent to ${resetEmailController.text}",
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: AppColors.primary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    duration: const Duration(seconds: 4),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("Please enter a valid email address"),
                    backgroundColor: Colors.redAccent,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "Send Link",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withOpacity(0.08),
              AppColors.accentBlue.withOpacity(0.08),
              Colors.white,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Center(
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
              Text(
                "Your companion for academic achievement and organized student life.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.getSecondaryTextColor(context),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              _buildEmailInput(),
              const SizedBox(height: 20),
              _buildPasswordInput(),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    _showForgotPasswordDialog();
                  },
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _attemptedSubmit = true;
                  });
                  if (_isFormValid) {
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
                  Expanded(child: Divider(color: AppColors.getDividerColor(context))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      "Or continue with",
                      style: TextStyle(
                        color: AppColors.getSecondaryTextColor(context),
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: AppColors.getDividerColor(context))),
                ],
              ),
              const SizedBox(height: 22),
              Center(
                child: _socialButton(
                  context,
                  "https://cdn-icons-png.flaticon.com/512/2991/2991148.png",
                  "Google sign-in",
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(
                      color: AppColors.getSecondaryTextColor(context),
                      fontSize: 13,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SignUpScreen(
                            onSignUp: widget.onLogin,
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildEmailInput() {
    String? errorText;
    if (_attemptedSubmit) {
      if (_emailController.text.isEmpty) {
        errorText = "Please enter email address";
      } else if (!_isValidEmail(_emailController.text)) {
        errorText = "Please enter a valid email address";
      }
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 6, bottom: 8),
          child: Text(
            "Email Address",
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
          ),
        ),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: "Enter Email Address",
            hintStyle: TextStyle(
              color: AppColors.getSecondaryTextColor(context),
              fontSize: 14,
            ),
            filled: true,
            fillColor: AppColors.getInputBackgroundColor(context),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30), 
              borderSide: BorderSide.none
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
            errorText: errorText,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordInput() {
    String? errorText;
    if (_attemptedSubmit) {
      if (_passController.text.isEmpty) {
        errorText = "Please enter password";
      } else if (_passController.text.length < 8) {
        errorText = "Password must be at least 8 characters";
      }
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 6, bottom: 8),
          child: Text(
            "Password",
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
          ),
        ),
        TextField(
          controller: _passController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            hintText: "••••••••",
            hintStyle: TextStyle(
              color: AppColors.getSecondaryTextColor(context),
              fontSize: 14,
            ),
            filled: true,
            fillColor: AppColors.getInputBackgroundColor(context),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30), 
              borderSide: BorderSide.none
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
            errorText: errorText,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
        ),
      ],
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
