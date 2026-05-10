import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_theme.dart';

class PecheTechHeader extends StatelessWidget {
  final String? profileImageUrl;
  final int notificationCount;
  final VoidCallback? onProfileTap;
  final VoidCallback? onFuelTap;
  final VoidCallback? onNotificationsTap;

  final bool showBackButton;

  const PecheTechHeader({
    super.key,
    this.profileImageUrl,
    this.notificationCount = 2,
    this.onProfileTap,
    this.onFuelTap,
    this.onNotificationsTap,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppTheme.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Profile Avatar or Back Button
          if (showBackButton)
            IconButton(
              icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
              onPressed: () => Navigator.of(context).pop(),
            )
          else
            GestureDetector(
              onTap: onProfileTap,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white,
                  backgroundImage: profileImageUrl != null
                      ? NetworkImage(profileImageUrl!)
                      : const AssetImage('assets/images/user_profile.png') as ImageProvider,
                ),
              ),
            ),
          const SizedBox(width: 12),

          // Logo PecheTech
          Flexible(
            child: Image.asset(
              'assets/images/pechetech_logoSurInterface.png',
              height: 40,
              fit: BoxFit.contain,
            ),
          ),

          const Spacer(),

          // Fuel Icon
          GestureDetector(
            onTap: onFuelTap,
            child: Container(
              padding: const EdgeInsets.all(4),
              child: const Icon(
                Icons.local_gas_station,
                size: 32, // Slightly larger to match image proportion
                color: AppTheme.primaryGreen,
              ),
            ),
          ),
          const SizedBox(width: 20), // Increased gap to match image
          
          // Notification Icon with Badge
          GestureDetector(
            onTap: onNotificationsTap,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                SvgPicture.asset(
                  'assets/images/icon_notification.svg',
                  width: 28,
                  height: 28,
                  colorFilter: const ColorFilter.mode(
                    AppTheme.textSecondary,
                    BlendMode.srcIn,
                  ),
                ),
                if (notificationCount > 0)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: AppTheme.error,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      child: Text(
                        '$notificationCount',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
