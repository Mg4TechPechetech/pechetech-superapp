import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../dashboard/presentation/dashboard_screen.dart';
import '../../community/presentation/community_screen.dart';
import '../../journal/presentation/journal_screen.dart';
import '../../map/presentation/map_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../fuel_subsidies/presentation/fuel_path_screen.dart';
import '../../notifications/presentation/notifications_screen.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/pechetech_header.dart';

class HomeNavigationWrapper extends StatefulWidget {
  const HomeNavigationWrapper({super.key});

  @override
  State<HomeNavigationWrapper> createState() => _HomeNavigationWrapperState();
}

class _HomeNavigationWrapperState extends State<HomeNavigationWrapper> {
  int _currentIndex = 2; // Default to ACCUEIL
  bool _isListening = false; // For voice feature

  final List<Widget> _pages = [
    const JournalScreen(),
    const MapScreen(),
    const DashboardScreen(),
    const CommunityScreen(),
    const ProfileScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _toggleListening() {
    setState(() {
      _isListening = !_isListening;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: SafeArea(
        bottom: false, // Don't clip bottom nav
        child: Stack(
          children: [
            Column(
              children: [
                PecheTechHeader(
                  onFuelTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const FuelPathScreen()),
                    );
                  },
                  onNotificationsTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const NotificationsScreen()),
                    );
                  },
                ),
                Expanded(
                  child: IndexedStack(
                    index: _currentIndex,
                    children: _pages,
                  ),
                ),
              ],
            ),

            // Voice listening blur overlay
            if (_isListening)
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
              ),

            // Microphone FAB + Listening Pill
            Positioned(
              bottom: 100, // Above nav bar
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_isListening)
                    Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                            color: Colors.green.withValues(alpha: 0.3)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.more_horiz, color: AppTheme.primaryGreen),
                          SizedBox(width: 8),
                          Text(
                            "En écoute...",
                            style: TextStyle(
                              color: AppTheme.primaryGreen,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  FloatingActionButton(
                    onPressed: _toggleListening,
                    backgroundColor: AppTheme.primaryGreen,
                    elevation: 4,
                    shape: const CircleBorder(),
                    child: const Icon(Icons.mic, color: Colors.white, size: 28),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 95,
      color: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 70,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                    child: _buildNavItem(
                        0, "Journal", "assets/images/icon_nav_journal.svg")),
                Expanded(
                    child: _buildNavItem(
                        1, "Carte", "assets/images/icon_nav_map.svg")),
                Expanded(child: _buildCenterHomeItem()),
                Expanded(
                    child: _buildNavItem(3, "Communauté",
                        "assets/images/icon_nav_community.svg")),
                Expanded(
                    child: _buildNavItem(
                        4, "Profil", "assets/images/icon_nav_profile.svg")),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterHomeItem() {
    final isSelected = _currentIndex == 2;
    final iconColor = isSelected ? Colors.white : AppTheme.textSecondary;
    final circleFillColor = isSelected ? AppTheme.primaryGreen : Colors.white;
    final textColor =
        isSelected ? AppTheme.primaryGreen : AppTheme.textSecondary;
    const borderColor = Color(0xFF064E3B); // Dark green border

    return GestureDetector(
      onTap: () => _onTabTapped(2),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                color: circleFillColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: borderColor,
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: SizedBox(
                  height: 24,
                  width: 24,
                  child: SvgPicture.asset(
                    "assets/images/icon_nav_home.svg",
                    colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                "ACCUEIL",
                style: TextStyle(
                  color: textColor,
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String label, String iconPath) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? AppTheme.primaryGreen : AppTheme.textSecondary;

    return GestureDetector(
      onTap: () => _onTabTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0)
            .copyWith(bottom: 8),
        height:
            70, // explicitly set height to 70 for alignment with the background base
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: Center(
                child: SvgPicture.asset(
                  iconPath,
                  colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
