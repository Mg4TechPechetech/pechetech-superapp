import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart' show FirebaseAuthPlatform;

import 'registration_screen.dart';
import '../data/auth_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_toast.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _isPhoneMode = false;
  bool _codeSent = false;
  String _verificationId = '';

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);
    try {
      final user = await _authService.loginWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );
      setState(() => _isLoading = false);

      if (user != null) {
        if (mounted) {
          CustomToast.show(
            context,
            message: 'Connexion réussie !',
            type: ToastType.success,
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);
      String errorMessage = 'Erreur de connexion.';
      if (e.code == 'user-not-found') errorMessage = 'Utilisateur non trouvé.';
      if (e.code == 'wrong-password') errorMessage = 'Mot de passe incorrect.';

      if (mounted) {
        CustomToast.show(context, message: errorMessage, type: ToastType.error);
      }
    } catch (_) {
      setState(() => _isLoading = false);
      if (mounted) {
        CustomToast.show(
          context,
          message: 'Une erreur inattendue est survenue.',
          type: ToastType.error,
        );
      }
    }
  }

  Future<void> _handleSendOTP() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      CustomToast.show(
        context,
        message: 'Veuillez entrer votre numéro de téléphone.',
        type: ToastType.warning,
      );
      return;
    }

    setState(() => _isLoading = true);
    
    // Create RecaptchaVerifier for Web as per documentation
    RecaptchaVerifier? webVerifier;
    if (kIsWeb) {
      webVerifier = RecaptchaVerifier(
        auth: FirebaseAuthPlatform.instance,
        container: 'recaptcha-container',
        size: RecaptchaVerifierSize.compact,
      );
    }

    await _authService.verifyPhoneNumber(
      phoneNumber: phone,
      webVerifier: webVerifier,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _authService.signInWithPhone(credential: credential);
        setState(() => _isLoading = false);
        if (mounted) {
          CustomToast.show(context,
              message: 'Connexion réussie !', type: ToastType.success);
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        setState(() => _isLoading = false);
        if (mounted) {
          CustomToast.show(context,
              message: 'Vérification échouée : ${e.message}',
              type: ToastType.error);
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _isLoading = false;
          _codeSent = true;
          _verificationId = verificationId;
        });
        if (mounted) {
          CustomToast.show(context,
              message: 'Code envoyé !', type: ToastType.success);
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  Future<void> _handleVerifyOTP() async {
    final code = _otpController.text.trim();
    if (code.isEmpty) {
      CustomToast.show(context,
          message: 'Veuillez entrer le code reçu.', type: ToastType.warning);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = await _authService.signInWithPhone(
        smsCode: code,
        credential: PhoneAuthProvider.credential(
          verificationId: _verificationId,
          smsCode: code,
        ),
      );
      setState(() => _isLoading = false);

      if (user != null && mounted) {
        CustomToast.show(context,
            message: 'Connexion réussie !', type: ToastType.success);
      }
    } on FirebaseAuthException catch (_) {
      setState(() => _isLoading = false);
      if (mounted) {
        CustomToast.show(context,
            message: 'Code invalide.', type: ToastType.error);
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    final user = await _authService.signInWithGoogle();
    setState(() => _isLoading = false);

    if (user != null) {
      if (mounted) {
        CustomToast.show(
          context,
          message: 'Connexion Google réussie !',
          type: ToastType.success,
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background with blurs
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF4FBF4), Color(0xFFF4FBF4)],
              ),
            ),
          ),
          Positioned(
            top: 44,
            right: 19,
            child: _BlurCircle(
              color: AppTheme.accentGreen.withValues(alpha: 0.1),
              size: 500,
            ),
          ),
          Positioned(
            bottom: 44,
            left: 19,
            child: _BlurCircle(
              color: const Color(0xFFA43A3A).withValues(alpha: 0.1),
              size: 400,
            ),
          ),
          Positioned(
            top: 353,
            left: 78,
            child: _BlurCircle(
              color: AppTheme.primaryGreen.withValues(alpha: 0.2),
              size: 300,
            ),
          ),

          // Background Blur Layer
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
              child: const SizedBox.shrink(),
            ),
          ),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Center(
                    child: SizedBox(
                      height: 111,
                      child: Image.asset(
                        'assets/images/pechetech_logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Bienvenue !',
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Gérez votre activité maritime en toute simplicité.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 40),

                  // Login Form Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Mode Toggle
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _isPhoneMode = false),
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: !_isPhoneMode
                                            ? AppTheme.primaryGreen
                                            : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    'E-MAIL',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: !_isPhoneMode
                                          ? AppTheme.primaryGreen
                                          : Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _isPhoneMode = true),
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: _isPhoneMode
                                            ? AppTheme.primaryGreen
                                            : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    'TÉLÉPHONE',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: _isPhoneMode
                                          ? AppTheme.primaryGreen
                                          : Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        if (!_isPhoneMode) ...[
                          const Text(
                            'ADRESSE E-MAIL',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              color: Color(0xFF1D1D1F),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              hintText: 'moussa@exemple.com',
                              prefixIcon: Icon(Icons.email_outlined,
                                  color: Color(0xFF3C4A42)),
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'MOT DE PASSE',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                  color: Color(0xFF1D1D1F),
                                ),
                              ),
                              TextButton(
                                onPressed: () {},
                                child: const Text(
                                  'Mot de passe oublié ?',
                                  style: TextStyle(
                                    color: AppTheme.accentGreen,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              hintText: '••••••••',
                              prefixIcon: const Icon(Icons.lock_outline,
                                  color: Color(0xFF3C4A42)),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: const Color(0xFF3C4A42),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                          ),
                        ] else ...[
                          const Text(
                            'NUMÉRO DE TÉLÉPHONE',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              color: Color(0xFF1D1D1F),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _phoneController,
                            decoration: const InputDecoration(
                              hintText: '+221 77 000 00 00',
                              prefixIcon: Icon(Icons.phone_outlined,
                                  color: Color(0xFF3C4A42)),
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                          if (_codeSent) ...[
                            const SizedBox(height: 24),
                            const Text(
                              'CODE DE VÉRIFICATION (OTP)',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                                color: Color(0xFF1D1D1F),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _otpController,
                              decoration: const InputDecoration(
                                hintText: '123456',
                                prefixIcon: Icon(Icons.sms_outlined,
                                    color: Color(0xFF3C4A42)),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ],
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            const Expanded(
                                child: Divider(color: Color(0x80BBCABF))),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'OU',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(color: const Color(0xFFBBCABF)),
                              ),
                            ),
                            const Expanded(
                                child: Divider(color: Color(0x80BBCABF))),
                          ],
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : (_isPhoneMode
                                  ? (_codeSent
                                      ? _handleVerifyOTP
                                      : _handleSendOTP)
                                  : _handleLogin),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00E676),
                            minimumSize: const Size.fromHeight(56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  _isPhoneMode
                                      ? (_codeSent
                                          ? 'VÉRIFIER LE CODE'
                                          : 'ENVOYER LE CODE')
                                      : 'Se connecter',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Google Login Button
                  OutlinedButton(
                    onPressed: _isLoading ? null : _handleGoogleSignIn,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.8),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/google.png',
                          height: 24,
                          width: 24,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Continuer avec Google',
                          style: TextStyle(
                            color: Color(0xFF161D19),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Pas encore de compte ? ',
                        style: TextStyle(color: Color(0xFF3C4A42), fontSize: 16),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const RegistrationScreen()),
                          );
                        },
                        child: const Text(
                          "S'inscrire",
                          style: TextStyle(
                            color:AppTheme.accentGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlurCircle extends StatelessWidget {
  final Color color;
  final double size;

  const _BlurCircle({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
