import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../auth/data/auth_service.dart';
import '../../auth/presentation/login_screen.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_toast.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4), // Light mint background from mockup
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMainProfileCard(),
            const SizedBox(height: 24),
            _buildKeyStatistics(),
            const SizedBox(height: 24),
            _buildBadgesSection(),
            const SizedBox(height: 24),
            _buildActionMenu(context),
            const SizedBox(height: 120), // Space for bottom nav
          ],
        ),
      ),
    );
  }

  Widget _buildMainProfileCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFF1F5F9), width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/user_profile.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: 5,
                right: 5,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified,
                    color: AppTheme.primaryGreen,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            "Capitaine Diop",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Pêcheur Artisan",
            style: TextStyle(
              fontSize: 18,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_on, color: AppTheme.primaryGreen, size: 16),
                SizedBox(width: 6),
                Text(
                  "DAKAR, SÉNÉGAL",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyStatistics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Statistiques Clés",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildStatCard("CAPTURES TOTALES", "1.2t", false)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard("SCORE DURABILITÉ", "94", true)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard("JOURS EN MER", "156", false)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, bool isHighlight) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: isHighlight ? AppTheme.primaryGreen : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: isHighlight ? Colors.white : AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: isHighlight ? Colors.white.withValues(alpha: 0.8) : AppTheme.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Badges & Succès",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                "Voir tout",
                style: TextStyle(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildBadgeTile("Gardien de la Mer", Icons.shield, const Color(0xFF0D9488)),
              const SizedBox(width: 12),
              _buildBadgeTile("Pêcheur Expert", Icons.stars, const Color(0xFFF59E0B)),
              const SizedBox(width: 12),
              _buildBadgeTile("Éco-Respon.", Icons.eco, const Color(0xFF10B981)),
              const SizedBox(width: 12),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBadgeTile(String label, IconData icon, Color color) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActionMenu(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuItem(Icons.edit, "Modifier le profil", const Color(0xFFF1F5F9), const Color(0xFF64748B), onTap: () {}),
          _buildMenuItem(Icons.menu_book, "Journal d'activité", const Color(0xFFF1F5F9), const Color(0xFF64748B), onTap: () {}),
          _buildMenuItem(Icons.settings, "Paramètres", const Color(0xFFF1F5F9), const Color(0xFF64748B), onTap: () {}),
          _buildMenuItem(
            Icons.logout,
            "Déconnexion",
            const Color(0xFFFEF2F2),
            Colors.red,
            isLast: true,
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text("Déconnexion"),
        content: const Text("Êtes-vous sûr de vouloir vous déconnecter de PecheTech ?"),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Annuler"),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              // Close the dialog
              Navigator.of(context, rootNavigator: true).pop();
              
              try {
                // Perform logout logic
                await AuthService().signOut();
                
                if (context.mounted) {
                  // Explicitly redirect to login screen for immediate feedback
                  Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                  
                  CustomToast.show(
                    context,
                    message: "Déconnexion réussie. À bientôt !",
                    type: ToastType.success,
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  CustomToast.show(
                    context,
                    message: "Erreur lors de la déconnexion : $e",
                    type: ToastType.error,
                  );
                }
              }
            },
            child: const Text("Se déconnecter"),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String label,
    Color iconBg,
    Color iconColor, {
    bool isLast = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(isLast ? 24 : 0),
      child: Column(
        children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: iconColor == Colors.red ? Colors.red : AppTheme.textPrimary,
                  ),
                ),
              ),
              Icon(
                iconColor == Colors.red ? Icons.logout : Icons.chevron_right,
                color: iconColor.withValues(alpha: 0.3),
                size: 20,
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(height: 1, color: Color(0xFFF1F5F9), indent: 70),
      ],
    ),
  );
}
}
