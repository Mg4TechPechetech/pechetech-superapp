import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/pechetech_header.dart';
import '../../../core/widgets/custom_toast.dart';
import '../data/models/user_model.dart';
import '../data/services/profile_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:convert';
import '../../auth/data/auth_service.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../notifications/data/services/notification_service.dart';
import '../../notifications/presentation/notifications_screen.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _boatNameController;
  late TextEditingController _zoneController;

  final ProfileService _profileService = ProfileService();
  final AuthService _authService = AuthService();
  UserModel? _currentUser;
  bool _isFetching = true;
  bool _isLoading = false;

  final List<String> _fishingZones = [
    'CLPA de Dakar Ouest',
    'CLPA de Hann',
    'CLPA de Pikine',
    'CLPA de Rufisque Bargny',
    'CLPA de Yenn Dialao',
    'CLPA de Sindia',
    'CLPA de Mbour',
    'CLPA de Fass Boye',
    'CLPA de Fimela',
    'CLPA de Foundiougne',
    'CLPA de Missirah',
    'CLPA de Toubacouta',
    'CLPA de Sokone',
    'CLPA de Elinkine',
    'CLPA de Ziguinchor',
  ];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _boatNameController = TextEditingController();
    _zoneController = TextEditingController();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await _profileService.getCurrentUserProfile();
    if (mounted) {
      setState(() {
        _currentUser = profile;
        if (profile != null) {
          _nameController.text = profile.fullName;
          _phoneController.text = profile.phoneNumber;
          _emailController.text = profile.email;
          _boatNameController.text = profile.boatName;
          _zoneController.text = profile.fishingZone;
        }
        _isFetching = false;
      });
    }
  }

  Future<void> _pickAndUploadImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024, // Higher resolution for cropping
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image != null && _currentUser != null) {
      if (!mounted) return;
      // Cropping step
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1), // Square crop
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Recadrer la photo',
            toolbarColor: AppTheme.primaryGreen,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Recadrer la photo',
            aspectRatioLockEnabled: true,
          ),
          WebUiSettings(
            context: context,
            presentStyle: WebPresentStyle.page,
            size: const CropperSize(width: 520, height: 520),
          ),
        ],
      );

      if (croppedFile != null) {
        if (mounted) setState(() => _isLoading = true);
        try {
          final bytes = await croppedFile.readAsBytes();
          final url = await _profileService.uploadProfileImage(
            _currentUser!.uid,
            bytes,
          );

          if (mounted) {
            setState(() {
              _currentUser = _currentUser!.copyWith(photoUrl: url);
              _isLoading = false;
            });
            CustomToast.show(
              context,
              message: "Image mise à jour !",
              type: ToastType.success,
            );
          }
        } catch (e) {
          if (mounted) {
            setState(() => _isLoading = false);
            CustomToast.show(
              context,
              message: "Erreur lors de l'upload.",
              type: ToastType.error,
            );
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _boatNameController.dispose();
    _zoneController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      if (mounted) setState(() => _isLoading = true);

      try {
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != null) {
          final updatedUser =
              _currentUser?.copyWith(
                fullName: _nameController.text.trim(),
                phoneNumber: _phoneController.text.trim(),
                email: _emailController.text.trim(),
                boatName: _boatNameController.text.trim(),
                fishingZone: _zoneController.text.trim(),
              ) ??
              UserModel(
                uid: uid,
                fullName: _nameController.text.trim(),
                email: _emailController.text.trim(),
                phoneNumber: _phoneController.text.trim(),
                role: 'Pêcheur',
                boatName: _boatNameController.text.trim(),
                fishingZone: _zoneController.text.trim(),
              );

          await _profileService.saveUserProfile(updatedUser);

          if (mounted) {
            CustomToast.show(
              context,
              message: "Profil mis à jour avec succès !",
              type: ToastType.success,
            );
            Navigator.pop(context);
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          CustomToast.show(
            context,
            message: "Erreur lors de la sauvegarde : $e",
            type: ToastType.error,
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  bool _isPasswordValid(String password) {
    return password.length >= 8 &&
        password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[0-9]'));
  }

  void _showPasswordChangeSheet() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool isUpdating = false;
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Changer le mot de passe",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                "Veuillez saisir votre mot de passe actuel pour valider les changements.",
                style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 24),
              _buildPopupTextField(
                controller: currentPasswordController,
                label: "Mot de passe actuel",
                obscureText: obscureCurrent,
                onToggle: () =>
                    setSheetState(() => obscureCurrent = !obscureCurrent),
              ),
              const SizedBox(height: 16),
              _buildPopupTextField(
                controller: newPasswordController,
                label: "Nouveau mot de passe",
                obscureText: obscureNew,
                onToggle: () => setSheetState(() => obscureNew = !obscureNew),
                onChanged: (_) => setSheetState(() {}),
              ),
              const SizedBox(height: 16),
              _buildPopupTextField(
                controller: confirmPasswordController,
                label: "Confirmer le nouveau mot de passe",
                obscureText: obscureConfirm,
                onToggle: () =>
                    setSheetState(() => obscureConfirm = !obscureConfirm),
                onChanged: (_) => setSheetState(() {}),
                hasError:
                    confirmPasswordController.text.isNotEmpty &&
                    (confirmPasswordController.text !=
                            newPasswordController.text ||
                        !_isPasswordValid(newPasswordController.text)),
              ),
              const SizedBox(height: 8),
              Text(
                'Minimum 8 caractères, une majuscule et un chiffre.',
                style: GoogleFonts.publicSans(
                  color: AppTheme.textHint,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isUpdating
                      ? null
                      : () async {
                          final current = currentPasswordController.text;
                          final next = newPasswordController.text;
                          final confirm = confirmPasswordController.text;

                          if (current.isEmpty ||
                              next.isEmpty ||
                              confirm.isEmpty) {
                            CustomToast.show(
                              context,
                              message: "Tous les champs sont requis.",
                              type: ToastType.warning,
                            );
                            return;
                          }

                          if (next != confirm) {
                            CustomToast.show(
                              context,
                              message:
                                  "Les mots de passe ne correspondent pas.",
                              type: ToastType.warning,
                            );
                            return;
                          }

                          // Constraints check
                          if (next.length < 8 ||
                              !next.contains(RegExp(r'[A-Z]')) ||
                              !next.contains(RegExp(r'[0-9]'))) {
                            CustomToast.show(
                              context,
                              message:
                                  "Le nouveau mot de passe ne respecte pas les contraintes.",
                              type: ToastType.warning,
                            );
                            return;
                          }

                          setSheetState(() => isUpdating = true);
                          try {
                            await _authService.changePassword(current, next);
                            if (mounted) {
                              Navigator.pop(context);
                              CustomToast.show(
                                context,
                                message: "Mot de passe modifié !",
                                type: ToastType.success,
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              String error = "Erreur de validation.";
                              if (e is FirebaseAuthException &&
                                  e.code == 'wrong-password') {
                                error = "Mot de passe actuel incorrect.";
                              }
                              CustomToast.show(
                                context,
                                message: error,
                                type: ToastType.error,
                              );
                            }
                          } finally {
                            setSheetState(() => isUpdating = false);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: isUpdating
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Mettre à jour",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopupTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    VoidCallback? onToggle,
    ValueChanged<String>? onChanged,
    bool hasError = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: hasError ? Colors.red : AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          onChanged: onChanged,
          cursorColor: hasError ? Colors.red : AppTheme.primaryGreen,
          decoration: InputDecoration(
            filled: true,
            fillColor: hasError
                ? Colors.red.withValues(alpha: 0.05)
                : AppTheme.border.withValues(alpha: 0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: hasError
                  ? const BorderSide(color: Colors.red, width: 1.5)
                  : BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: hasError
                  ? const BorderSide(color: Colors.red, width: 1.5)
                  : BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: hasError
                  ? const BorderSide(color: Colors.red, width: 2)
                  : const BorderSide(color: AppTheme.primaryGreen, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            suffixIcon: onToggle != null
                ? IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility,
                      color: hasError ? Colors.red : AppTheme.textHint,
                      size: 20,
                    ),
                    onPressed: onToggle,
                  )
                : null,
          ),
          style: TextStyle(color: hasError ? Colors.red : AppTheme.textPrimary),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isFetching) {
      return const Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryGreen),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            StreamBuilder<int>(
              stream: NotificationService().getUnreadCount(
                FirebaseAuth.instance.currentUser?.uid,
              ),
              builder: (context, snapshot) {
                return PecheTechHeader(
                  showBackButton: true,
                  notificationCount: snapshot.data ?? 0,
                  onNotificationsTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationsScreen(),
                      ),
                    );
                  },
                );
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Modifier le profil",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Mettez à jour vos informations personnelles et professionnelles.",
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Profile Picture Edit
                      Center(
                        child: Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppTheme.border,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child:
                                    _currentUser?.photoUrl != null &&
                                        _currentUser!.photoUrl.isNotEmpty
                                    ? (_currentUser!.photoUrl.startsWith(
                                            'data:image',
                                          )
                                          ? Image.memory(
                                              base64Decode(
                                                _currentUser!.photoUrl.split(
                                                  ',',
                                                )[1],
                                              ),
                                              fit: BoxFit.cover,
                                            )
                                          : Image.network(
                                              _currentUser!.photoUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => Image.asset(
                                                    'assets/images/user_profile.png',
                                                    fit: BoxFit.cover,
                                                  ),
                                            ))
                                    : Image.asset(
                                        'assets/images/user_profile.png',
                                        fit: BoxFit.cover,
                                        width: 100,
                                        height: 100,
                                      ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _isLoading ? null : _pickAndUploadImage,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryGreen,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.camera_alt,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      _buildInputField(
                        controller: _nameController,
                        label: "Nom Complet",
                        icon: Icons.person_outline,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Le nom est requis";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      _buildInputField(
                        controller: _emailController,
                        label: "Adresse Email",
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        readOnly: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "L'email est requis";
                          }
                          if (!value.contains('@')) {
                            return "Email invalide";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      _buildInputField(
                        controller: _phoneController,
                        label: "Numéro de téléphone",
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        readOnly: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Le numéro est requis";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      _buildInputField(
                        controller: _boatNameController,
                        label: "Nom du Navire / Pirogue",
                        icon: Icons.directions_boat_outlined,
                      ),
                      const SizedBox(height: 20),

                      _buildDropdownField(
                        label: "Zone de pêche principale",
                        icon: Icons.location_on_outlined,
                        value: _fishingZones.contains(_zoneController.text)
                            ? _zoneController.text
                            : null,
                        items: _fishingZones,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _zoneController.text = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 24),

                      // Change Password Button
                      TextButton.icon(
                        onPressed: _showPasswordChangeSheet,
                        icon: const Icon(
                          Icons.lock_reset,
                          color: AppTheme.accentGreen,
                        ),
                        label: const Text(
                          "Changer le mot de passe",
                          style: TextStyle(
                            color: AppTheme.accentGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  "Enregistrer les modifications",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          readOnly: readOnly,
          style: TextStyle(
            fontSize: 15,
            color: readOnly ? AppTheme.textSecondary : AppTheme.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: "Saisissez votre ${label.toLowerCase()}",
            hintStyle: TextStyle(
              color: AppTheme.textSecondary.withValues(alpha: 0.5),
            ),
            prefixIcon: Icon(icon, color: AppTheme.primaryGreen, size: 20),
            filled: true,
            fillColor: readOnly
                ? AppTheme.border.withValues(alpha: 0.3)
                : Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppTheme.border.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppTheme.primaryGreen,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppTheme.error, width: 1),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(fontSize: 15)),
            );
          }).toList(),
          decoration: InputDecoration(
            hintText: "Sélectionnez votre zone",
            prefixIcon: Icon(icon, color: AppTheme.primaryGreen, size: 20),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.primaryGreen,
                width: 2,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "La zone est requise";
            }
            return null;
          },
        ),
      ],
    );
  }
}
