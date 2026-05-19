import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/auth_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_toast.dart';
import '../../profile/data/services/profile_service.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  final _profileService = ProfileService();
  bool _isLoading = false;
  bool _acceptTerms = false;
  bool _obscurePassword = true;

  final List<String> _roles = [
    'Pêcheur',
    'Capitaine',
    'Pompiste',
    'Transformateur(trice)',
    'GIE',
    'Trésorier GIE',
  ];
  late String _selectedRole;

  @override
  void initState() {
    super.initState();
    _selectedRole = 'Capitaine'; // Capitaine par défaut
  }

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty) {
      CustomToast.show(
        context,
        message: 'Veuillez entrer votre nom complet.',
        type: ToastType.warning,
      );
      return;
    }

    if (email.isEmpty || !email.contains('@')) {
      CustomToast.show(
        context,
        message: 'Veuillez entrer une adresse e-mail valide.',
        type: ToastType.warning,
      );
      return;
    }

    if (phone.isEmpty) {
      CustomToast.show(
        context,
        message: 'Veuillez entrer votre numéro de téléphone.',
        type: ToastType.warning,
      );
      return;
    }

    if (password.isEmpty) {
      CustomToast.show(
        context,
        message: 'Veuillez entrer un mot de passe.',
        type: ToastType.warning,
      );
      return;
    }

    if (password.length < 8) {
      CustomToast.show(
        context,
        message: 'Le mot de passe doit contenir au moins 8 caractères.',
        type: ToastType.warning,
      );
      return;
    }

    if (!password.contains(RegExp(r'[A-Z]'))) {
      CustomToast.show(
        context,
        message: 'Le mot de passe doit contenir au moins une majuscule.',
        type: ToastType.warning,
      );
      return;
    }

    if (!password.contains(RegExp(r'[0-9]'))) {
      CustomToast.show(
        context,
        message: 'Le mot de passe doit contenir au moins un chiffre.',
        type: ToastType.warning,
      );
      return;
    }

    if (!_acceptTerms) {
      CustomToast.show(
        context,
        message: 'Veuillez accepter les conditions.',
        type: ToastType.warning,
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = await _authService.registerWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );

      setState(() => _isLoading = false);

      if (user != null) {
        await _profileService.createInitialProfile(
          uid: user.user!.uid,
          fullName: name,
          email: email,
          phoneNumber: phone,
          role: _selectedRole,
        );

        if (mounted) {
          FocusScope.of(context).unfocus();
          CustomToast.show(
            context,
            message: 'Inscription réussie !',
            type: ToastType.success,
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);
      String errorMessage = 'Une erreur est survenue.';

      if (e.code == 'email-already-in-use') {
        errorMessage = 'Cette adresse e-mail est déjà utilisée.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'L\'adresse e-mail n\'est pas valide.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'Le mot de passe est trop faible.';
      }

      if (mounted) {
        CustomToast.show(context, message: errorMessage, type: ToastType.error);
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final user = await _authService.signInWithGoogle();
      setState(() => _isLoading = false);

      if (user != null) {
        if (mounted) {
          FocusScope.of(context).unfocus();
          CustomToast.show(
            context,
            message: 'Connexion Google réussie !',
            type: ToastType.success,
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        CustomToast.show(
          context,
          message: 'Erreur lors de la connexion Google.',
          type: ToastType.error,
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF4FBF4), Color(0xFFF4FBF4)],
              ),
            ),
          ),

          // Overlay Blurs for a premium look
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

          // Global Background Blur Layer
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
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
                  // Header
                  Center(
                    child: Image.asset(
                      'assets/images/pechetech_logo.png',
                      height: 111,
                      // width: 265,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Créer un compte',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: const Color(0xFF161D19),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28.5),
                    child: Text(
                      'Rejoignez la plateforme leader pour les professionnels de la pêche en Afrique de l\'Ouest.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF3C4A42),
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Main Card
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 33,
                          vertical: 21,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF006C49,
                              ).withValues(alpha: 0.08),
                              blurRadius: 32,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel(context, 'NOM COMPLET'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              hintText: 'Ex: Moussa Ndiaye',
                              prefixIconPath: 'assets/images/icon_user.svg',
                              controller: _nameController,
                            ),
                            const SizedBox(height: 24),
                            _buildLabel(context, 'VOTRE RÔLE / ACTIVITÉ'),
                            const SizedBox(height: 8),
                            _buildDropdownField(
                              value: _selectedRole,
                              items: _roles,
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _selectedRole = value);
                                }
                              },
                              prefixIcon: Icons.badge_outlined,
                            ),
                            const SizedBox(height: 24),
                            _buildLabel(context, 'ADRESSE E-MAIL'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              hintText: 'nom@exemple.com',
                              prefixIconPath: 'assets/images/icon_email.svg',
                              controller: _emailController,
                            ),
                            const SizedBox(height: 24),
                            _buildLabel(context, 'NUMÉRO DE TÉLÉPHONE'),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildCountryCode(),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildTextField(
                                    hintText: '70 000 00 00',
                                    prefixIconPath:
                                        'assets/images/icon_phone.svg',
                                    keyboardType: TextInputType.phone,
                                    controller: _phoneController,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            _buildLabel(context, 'MOT DE PASSE'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              hintText: '••••••••',
                              prefixIconPath: 'assets/images/icon_lock.svg',
                              obscureText: true,
                              suffixIconPath: 'assets/images/icon_eye.svg',
                              controller: _passwordController,
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Text(
                                'Minimum 8 caractères, une majuscule et un chiffre.',
                                style: GoogleFonts.publicSans(
                                  color: AppTheme.textHint,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  height: 1.4,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Terms Checkbox
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: Checkbox(
                                    value: _acceptTerms,
                                    onChanged: (value) =>
                                        setState(() => _acceptTerms = value!),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    side: BorderSide(
                                      color: Colors.white.withValues(
                                        alpha: 0.6,
                                      ),
                                    ),
                                    fillColor: WidgetStateProperty.resolveWith((
                                      states,
                                    ) {
                                      if (states.contains(
                                        WidgetState.selected,
                                      )) {
                                        return AppTheme.accentGreen;
                                      }
                                      return Colors.white.withValues(
                                        alpha: 0.3,
                                      );
                                    }),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      style: GoogleFonts.publicSans(
                                        color: const Color(0xFF3C4A42),
                                        fontSize: 14,
                                        height: 1.4,
                                      ),
                                      children: const [
                                        TextSpan(text: "J'accepte les "),
                                        TextSpan(
                                          text: "Conditions d'utilisation",
                                          style: TextStyle(
                                            color: Color(0xFF06C755),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        TextSpan(text: " et la "),
                                        TextSpan(
                                          text: "Politique de confidentialité",
                                          style: TextStyle(
                                            color: Color(0xFF06C755),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        TextSpan(text: " de PecheTech."),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),

                            // Join Button
                            ElevatedButton(
                              onPressed: _isLoading ? null : _handleRegister,
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text('Rejoindre PecheTech'),
                                        SizedBox(width: 8),
                                        Icon(
                                          Icons.arrow_forward,
                                          size: 18,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Vous avez déjà un compte ? ',
                        style: GoogleFonts.publicSans(
                          color: const Color(0xFF3C4A42),
                          fontSize: 16,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Se connecter',
                          style: TextStyle(
                            color: Color(0xFF06C755),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Divider
                  Row(
                    children: [
                      const Expanded(child: Divider(color: Color(0x4DBBCABF))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "OU S'INSCRIRE AVEC",
                          style: GoogleFonts.publicSans(
                            color: const Color(0xFF6C7A71),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider(color: Color(0x4DBBCABF))),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Google Button
                  OutlinedButton(
                    onPressed: _isLoading ? null : _handleGoogleSignIn,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.5),
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/images/google_logo.png', width: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Continuer avec Google',
                          style: GoogleFonts.manrope(
                            color: const Color(0xFF161D19),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.labelLarge?.copyWith(color: const Color(0xFF3C4A42)),
    );
  }

  Widget _buildTextField({
    required String hintText,
    required String prefixIconPath,
    String? suffixIconPath,
    bool obscureText = false,
    TextInputType? keyboardType,
    TextEditingController? controller,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText ? _obscurePassword : false,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(
          prefixIconPath.contains('user')
              ? Icons.person_outline
              : prefixIconPath.contains('email')
              ? Icons.email_outlined
              : prefixIconPath.contains('phone')
              ? Icons.phone_outlined
              : prefixIconPath.contains('lock')
              ? Icons.lock_outline
              : Icons.help_outline,
          color: const Color(0xFF3C4A42),
        ),
        suffixIcon: obscureText
            ? IconButton(
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
              )
            : (suffixIconPath != null
                  ? Icon(
                      suffixIconPath.contains('eye')
                          ? Icons.visibility_outlined
                          : Icons.help_outline,
                      color: const Color(0xFF3C4A42),
                    )
                  : null),
      ),
    );
  }

  Widget _buildCountryCode() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 17),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/images/senegal_flag.png', width: 24),
          const SizedBox(width: 4),
          Text(
            '+221',
            style: GoogleFonts.publicSans(
              color: const Color(0xFF161D19),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
    required IconData prefixIcon,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      items: items.map((String role) {
        return DropdownMenuItem<String>(
          value: role,
          child: Text(
            role,
            style: GoogleFonts.publicSans(
              color: const Color(0xFF161D19),
              fontSize: 16,
            ),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF3C4A42)),
      dropdownColor: const Color(0xFFF4FBF4),
      decoration: InputDecoration(
        prefixIcon: Icon(prefixIcon, color: const Color(0xFF3C4A42)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.6)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.6)),
        ),
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
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
