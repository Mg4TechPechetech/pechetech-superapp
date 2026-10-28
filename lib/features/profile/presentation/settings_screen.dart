import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/pechetech_header.dart';
import '../../notifications/data/services/notification_service.dart';
import '../../notifications/presentation/notifications_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            StreamBuilder<int>(
              stream: NotificationService().getUnreadCount(userId),
              builder: (context, snapshot) {
                return PecheTechHeader(
                  showBackButton: true,
                  notificationCount: snapshot.data ?? 0,
                  onNotificationsTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                    );
                  },
                );
              }
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Paramètres",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Gérez votre compte et vos préférences d'application",
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    _buildSectionTitle("PRÉFÉRENCES"),
                    _buildSettingsGroup([
                      _buildSettingsItem(
                        icon: Icons.translate,
                        title: "Langue",
                        subtitle: "Français / Wolof",
                        trailingText: "Français",
                      ),
                      _buildSettingsItem(
                        icon: Icons.notifications_none,
                        title: "Notifications",
                        subtitle: "Alertes de pêche, communauté",
                        isLast: true,
                      ),
                    ]),
                    
                    const SizedBox(height: 24),
                    _buildSectionTitle("SÉCURITÉ"),
                    _buildSettingsGroup([
                      _buildSettingsItem(
                        icon: Icons.shield_outlined,
                        title: "Confidentialité",
                        subtitle: "Gérer la visibilité des données",
                      ),
                      _buildSettingsItem(
                        icon: Icons.devices,
                        title: "Appareils connectés",
                        subtitle: "2 sessions actives",
                        isLast: true,
                      ),
                    ]),
                    
                    const SizedBox(height: 24),
                    _buildSectionTitle("À PROPOS"),
                    _buildSettingsGroup([
                      _buildSettingsItem(
                        icon: Icons.help_outline,
                        title: "Aide & Support",
                        subtitle: "Guide d'utilisation, FAQ",
                      ),
                      _buildSettingsItem(
                        icon: Icons.description_outlined,
                        title: "Conditions d'utilisation",
                        subtitle: "Légal et confidentialité",
                        isLast: true,
                      ),
                    ]),

                    const SizedBox(height: 48),
                    const Center(
                      child: Text(
                        "PecheTech Version 1.0",
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppTheme.textSecondary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    String? trailingText,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF065F46), // Dark green icon color
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (trailingText != null) ...[
                  Text(
                    trailingText,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                const Icon(
                  Icons.chevron_right,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
          if (!isLast)
            const Divider(
              height: 1,
              color: Color(0xFFF1F5F9),
              indent: 72,
              endIndent: 16,
            ),
        ],
      ),
    );
  }
}
