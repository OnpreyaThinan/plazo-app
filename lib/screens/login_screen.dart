import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../app_colors.dart';
import '../app_strings.dart';
import '../services/auth_service.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  final String language;
  final Function(String name, String email)? onLogin;
  const LoginScreen({super.key, required this.language, this.onLogin});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _authService = AuthService();
  bool _obscurePassword = true;
  bool _isFormValid = false;
  bool _attemptedSubmit = false;
  bool _isLoading = false;

  String _t(String key) => AppStrings.get(key, widget.language);

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

  String _authErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'network-request-failed':
        return 'Please check your internet connection';
      case 'wrong-password':
      case 'user-not-found':
        return _t('invalidCredentials');
      case 'timeout':
        return 'Something went wrong. Please try again.';
      case 'invalid-email':
        return _t('pleaseEnterValidEmailAddress');
      case 'missing-android-pkg-name':
      case 'missing-ios-bundle-id':
      case 'unauthorized-continue-uri':
      case 'invalid-continue-uri':
        return 'Something went wrong. Please try again.';
      case 'no-password-provider':
        return _t('passwordResetNeedsPasswordAccount');
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  void _showForgotPasswordDialog() {
    final resetEmailController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          _t('resetPasswordTitle'),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _t('resetPasswordDescription'),
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: resetEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: _t('enterYourEmail'),
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
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              _t('cancel'),
              style: TextStyle(
                color: AppColors.getSecondaryTextColor(dialogContext),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = resetEmailController.text.trim();
              if (email.isNotEmpty && _isValidEmail(email)) {
                try {
                  await _authService.sendPasswordResetEmail(
                    email: email,
                    languageCode: widget.language,
                  );
                  if (!dialogContext.mounted) return;
                  Navigator.pop(dialogContext);
                  if (!dialogContext.mounted) return;
                  
                  // Show success message
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "${_t('resetLinkSent')} $email",
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
                } on FirebaseAuthException catch (e) {
                  if (!dialogContext.mounted) return;
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: Text(_authErrorMessage(e)),
                      backgroundColor: Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }
              } else {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(
                    content: Text(_t('pleaseEnterValidEmailAddress')),
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
            child: Text(
              _t('sendLink'),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ).whenComplete(() {
      resetEmailController.dispose();
    });
  }

  Future<void> _handleSignIn() async {
    setState(() {
      _attemptedSubmit = true;
    });

    if (!_isFormValid) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      User? user = await _authService.signIn(
        email: _emailController.text,
        password: _passController.text,
      );

      if (user != null && mounted) {
        // Call the optional callback if provided
        if (widget.onLogin != null) {
          widget.onLogin!(
            user.displayName ?? _emailController.text.split('@')[0],
            user.email ?? _emailController.text,
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('Sign in failed [${e.code}]: ${e.message}');
      if (mounted) {
        String errorMessage = _t('signInFailed');
        if (e.code == 'network-request-failed') {
          errorMessage = 'Please check your internet connection';
        } else if (e.code == 'timeout') {
          errorMessage = 'Something went wrong. Please try again.';
        } else if (e.code == 'user-not-found' || e.code == 'wrong-password') {
          errorMessage = _t('invalidCredentials');
        } else if (e.code == 'invalid-email') {
          errorMessage = _t('invalidEmailAddress');
        } else if (e.code == 'user-disabled') {
          errorMessage = _t('accountDisabled');
        } else {
          errorMessage = 'Something went wrong. Please try again.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      User? user = await _authService.signInWithGoogle();

      if (user != null && mounted) {
        // Call the optional callback if provided
        if (widget.onLogin != null) {
          widget.onLogin!(
            user.displayName ?? user.email?.split('@')[0] ?? 'User',
            user.email ?? '',
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('Google sign-in failed [${e.code}]: ${e.message}');
      if (mounted) {
        String errorMessage;
        switch (e.code) {
          case 'network-request-failed':
            errorMessage = 'Please check your internet connection';
            break;
          case 'wrong-password':
          case 'user-not-found':
            errorMessage = _t('invalidCredentials');
            break;
          default:
            errorMessage = 'Something went wrong. Please try again.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_t('googleSignInCancelled')),
            backgroundColor: Colors.grey,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
              AppColors.primary.withValues(alpha: 0.08),
              AppColors.accentBlue.withValues(alpha: 0.08),
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
                _t('loginTagline'),
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
                  child: Text(
                    _t('forgotPassword'),
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
                onPressed: _isLoading ? null : _handleSignIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 5,
                  shadowColor: AppColors.primary.withValues(alpha: 0.4),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                      _t('signIn'),
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
                      _t('orContinueWith'),
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
                  _t('googleSignInSemantic'),
                  onTap: _handleGoogleSignIn,
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _t('noAccountPrompt'),
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
                            language: widget.language,
                            onSignUp: widget.onLogin,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      _t('signUp'),
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
        errorText = _t('pleaseEnterEmailAddress');
      } else if (!_isValidEmail(_emailController.text)) {
        errorText = _t('pleaseEnterValidEmailAddress');
      }
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 6, bottom: 8),
          child: Text(
            _t('emailAddress'),
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
          ),
        ),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: _t('enterEmailAddress'),
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
        errorText = _t('pleaseEnterPassword');
      } else if (_passController.text.length < 8) {
        errorText = _t('passwordMinLength');
      }
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 6, bottom: 8),
          child: Text(
            _t('password'),
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
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

  // ignore: unused_element
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

  Widget _socialButton(
    BuildContext context,
    String iconUrl,
    String label, {
    required VoidCallback onTap,
  }) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Image.network(
              iconUrl,
              width: 26,
              height: 26,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.g_mobiledata,
                size: 28,
                color: AppColors.navy,
              ),
            ),
          ),
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
