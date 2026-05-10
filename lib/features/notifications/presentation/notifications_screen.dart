import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/pechetech_header.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const PecheTechHeader(
              showBackButton: true,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Notifications",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      "Tout marquer comme lu",
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildSectionHeader("AUJOURD'HUI"),
                  _buildNotificationCard(
                    title: "Nouvelle subvention disponible",
                    description: "Une nouvelle aide au carburant est disponible pour votre zone de pêche.",
                    time: "Il y a 2h",
                    icon: 'assets/images/icon_payment.svg',
                    iconBg: AppTheme.primaryGreen.withValues(alpha: 0.1),
                    iconColor: AppTheme.primaryGreen,
                    isUnread: true,
                    hasAlert: true,
                  ),
                  _buildNotificationCard(
                    title: "Alerte Météo",
                    description: "Forte houle prévue demain matin. Prudence en mer.",
                    time: "Il y a 5h",
                    icon: 'assets/images/icon_weather_cloud.svg',
                    iconBg: AppTheme.error.withValues(alpha: 0.1),
                    iconColor: AppTheme.error,
                    isUnread: true,
                  ),
                  const SizedBox(height: 16),
                  _buildSectionHeader("PLUS TÔT"),
                  _buildNotificationCard(
                    title: "Prix du marché",
                    description: "Le prix du Thon a augmenté de 15% au port de Dakar.",
                    time: "Hier, 18:30",
                    icon: 'assets/images/icon_trend_up.svg',
                    iconBg: const Color(0xFF6366F1).withValues(alpha: 0.1),
                    iconColor: const Color(0xFF6366F1),
                    isUnread: false,
                  ),
                  _buildNotificationCard(
                    title: "Journal mis à jour",
                    description: "Votre rapport de pêche du 08/05 a été validé.",
                    time: "Hier, 14:15",
                    icon: 'assets/images/icon_nav_journal.svg',
                    iconBg: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                    iconColor: const Color(0xFFF59E0B),
                    isUnread: false,
                  ),
                  _buildNotificationCard(
                    title: "Message de la communauté",
                    description: "Moussa Diouf a répondu à votre message dans le forum.",
                    time: "8 Mai, 10:00",
                    icon: 'assets/images/icon_nav_community.svg',
                    iconBg: const Color(0xFFEC4899).withValues(alpha: 0.1),
                    iconColor: const Color(0xFFEC4899),
                    isUnread: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: AppTheme.textSecondary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildNotificationCard({
    required String title,
    required String description,
    required String time,
    required String icon,
    required Color iconBg,
    required Color iconColor,
    bool isUnread = false,
    bool hasAlert = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isUnread ? const Color(0xFFF8FAFC) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnread ? AppTheme.primaryGreen.withValues(alpha: 0.1) : AppTheme.border,
          width: 1,
        ),
        boxShadow: [
          if (isUnread)
            BoxShadow(
              color: AppTheme.primaryGreen.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            children: [
              if (hasAlert)
                Container(
                  width: 4,
                  color: AppTheme.error,
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: iconBg,
                          shape: BoxShape.circle,
                        ),
                        child: SvgPicture.asset(
                          icon,
                          width: 20,
                          height: 20,
                          colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    title,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                ),
                                if (isUnread)
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppTheme.primaryGreen,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              description,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.textSecondary,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              time,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.textHint,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
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
}
