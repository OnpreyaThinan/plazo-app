import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../app_colors.dart';
import '../app_strings.dart';
import '../services/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  final String language;
  final Function(String name, String email)? onSignUp;
  const SignUpScreen({super.key, required this.language, this.onSignUp});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();
  final _authService = AuthService();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isFormValid = false;
  bool _attemptedSubmit = false;
  bool _isLoading = false;

  String _t(String key) => AppStrings.get(key, widget.language);

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateForm);
    _emailController.addListener(_validateForm);
    _passController.addListener(_validateForm);
    _confirmPassController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();
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
      _isFormValid = _nameController.text.isNotEmpty &&
                      _isValidEmail(_emailController.text) && 
                      _passController.text.length >= 8 &&
                      _passController.text == _confirmPassController.text;
    });
  }

  Future<void> _handleSignUp() async {
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
      User? user = await _authService.signUp(
        email: _emailController.text,
        password: _passController.text,
        name: _nameController.text,
      );

      if (user != null && mounted) {
        // Call the optional callback if provided
        if (widget.onSignUp != null) {
          widget.onSignUp!(
            _nameController.text,
            _emailController.text,
          );
        }
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String errorMessage = _t('signUpFailed');
        if (e.code == 'weak-password') {
          errorMessage = _t('weakPassword');
        } else if (e.code == 'email-already-in-use') {
          errorMessage = _t('emailAlreadyInUse');
        } else if (e.code == 'invalid-email') {
          errorMessage = _t('invalidEmailAddress');
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
        child: SafeArea(
          child: Column(
            children: [
              // Header with back button
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppColors.navy),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      const Icon(
                        Icons.person_add_outlined,
                        size: 80,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _t('createAccount'),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: AppColors.navy,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _t('signupSubtitle'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.getSecondaryTextColor(context),
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 40),
                      _buildNameInput(),
                      const SizedBox(height: 20),
                      _buildEmailInput(),
                      const SizedBox(height: 20),
                      _buildPasswordInput(),
                      const SizedBox(height: 20),
                      _buildConfirmPasswordInput(),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleSignUp,
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
                              _t('createAccount'),
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _t('alreadyHaveAccountPrompt'),
                            style: TextStyle(
                              color: AppColors.getSecondaryTextColor(context),
                              fontSize: 13,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Text(
                              _t('signIn'),
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNameInput() {
    String? errorText;
    if (_attemptedSubmit && _nameController.text.isEmpty) {
      errorText = _t('pleaseEnterYourName');
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 6, bottom: 8),
          child: Text(
            _t('fullName'),
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
          ),
        ),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: _t('enterFullName'),
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
                color: AppColors.getSecondaryTextColor(context),
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

  Widget _buildConfirmPasswordInput() {
    String? errorText;
    if (_attemptedSubmit) {
      if (_confirmPassController.text.isEmpty) {
        errorText = _t('pleaseConfirmPassword');
      } else if (_passController.text != _confirmPassController.text) {
        errorText = _t('passwordsDoNotMatch');
      }
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 6, bottom: 8),
          child: Text(
            _t('confirmPassword'),
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
          ),
        ),
        TextField(
          controller: _confirmPassController,
          obscureText: _obscureConfirmPassword,
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
                _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                color: AppColors.getSecondaryTextColor(context),
              ),
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}
