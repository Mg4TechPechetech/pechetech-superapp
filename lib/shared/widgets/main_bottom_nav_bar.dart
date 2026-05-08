import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MainBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const MainBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 32,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFF10B981),
          unselectedItemColor: const Color(0xFF64748B),
          selectedLabelStyle: GoogleFonts.publicSans(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.publicSans(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          items: [
            _buildNavItem('assets/images/icon_nav_home.png', 'Accueil'),
            _buildNavItem('assets/images/icon_nav_journal.png', 'Journal'),
            _buildNavItem('assets/images/icon_nav_map.png', 'Carte'),
            _buildNavItem('assets/images/icon_nav_community.png', 'Communauté'),
            _buildNavItem('assets/images/icon_nav_profile.png', 'Profil'),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(String iconPath, String label) {
    return BottomNavigationBarItem(
      icon: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Image.asset(iconPath, width: 20, height: 20),
      ),
      activeIcon: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Column(
          children: [
            Image.asset(
              iconPath,
              width: 20,
              height: 20,
              color: const Color(0xFF10B981),
            ),
            const SizedBox(height: 4),
            Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: Color(0xFF10B981),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
      label: label,
    );
  }
}
