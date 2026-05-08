import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/app_theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FBF7),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeSection(),
              const SizedBox(height: 24),
              _buildWeatherCard(),
              const SizedBox(height: 20),
              _buildBalanceCard(),
              const SizedBox(height: 24),
              _buildRecentActivities(),
              const SizedBox(height: 24),
              _buildActiveFishingZones(),
              const SizedBox(height: 80), // space for bottom nav
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Bonjour, Moussa",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 4),
        Text(
          "Prêt pour la marée d'aujourd'hui ?",
          style: TextStyle(
            fontSize: 16,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF34D399), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF059669).withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "MÉTÉO MARINE",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              SvgPicture.asset('assets/images/icon_weather_cloud.svg', height: 24, colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "Yoff, Dakar",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "24°",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
              SizedBox(width: 12),
              Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Text(
                  "Ciel clair",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 1,
            color: Colors.white24,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SvgPicture.asset('assets/images/icon_wind.svg', height: 20, colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
                  const SizedBox(width: 8),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Vents", style: TextStyle(color: Colors.white70, fontSize: 12)),
                      Text("12 km/h NO", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  SvgPicture.asset('assets/images/icon_waves.svg', height: 20, colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
                  const SizedBox(width: 8),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Houle", style: TextStyle(color: Colors.white70, fontSize: 12)),
                      Text("1.2m / 8s", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "SOLDE PARTAGE",
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              SvgPicture.asset('assets/images/icon_wallet.svg', height: 20, colorFilter: const ColorFilter.mode(AppTheme.primaryGreen, BlendMode.srcIn)),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "145.200 FCFA",
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              SvgPicture.asset('assets/images/icon_trend_up.svg', height: 16, colorFilter: const ColorFilter.mode(AppTheme.primaryGreen, BlendMode.srcIn)),
              const SizedBox(width: 4),
              const Text(
                "+12% vs semaine dernière",
                style: TextStyle(
                  color: AppTheme.primaryGreen,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text("Distribuer", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.border),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: () {},
                  icon: SvgPicture.asset('assets/images/icon_stats.svg', height: 24),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Activités récentes",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text("Voir tout", style: TextStyle(color: AppTheme.primaryGreen)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildActivityItem(
          iconPath: 'assets/images/icon_fish.svg',
          iconBgColor: const Color(0xFFD1FAE5),
          iconColor: AppTheme.primaryGreen,
          title: "Capture Enregistrée",
          subtitle: "Thon rouge • 42kg",
          amount: "63.000\nFCFA",
          time: "Il y a 2h",
        ),
        const SizedBox(height: 12),
        _buildActivityItem(
          iconPath: 'assets/images/icon_alert.svg',
          iconBgColor: const Color(0xFFFEF3C7),
          iconColor: const Color(0xFFD97706),
          title: "Alerte Météo",
          subtitle: "Fortes houles prévues à 18h",
          isAlert: true,
        ),
        const SizedBox(height: 12),
        _buildActivityItem(
          iconPath: 'assets/images/icon_payment.svg',
          iconBgColor: const Color(0xFFDBEAFE),
          iconColor: const Color(0xFF2563EB),
          title: "Paiement reçu",
          subtitle: "Coopérative de\nMbour",
          amount: "22.500\nFCFA",
          time: "Hier",
        ),
      ],
    );
  }

  Widget _buildActivityItem({
    required String iconPath,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String subtitle,
    String? amount,
    String? time,
    bool isAlert = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(iconPath, height: 20, colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          if (isAlert)
            const Icon(Icons.chevron_right, color: AppTheme.textSecondary)
          else if (amount != null && time != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amount,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildActiveFishingZones() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Zones de pêche actives",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFFE2E8F0), Color(0xFFCBD5E1)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                bottom: 16,
                left: 16,
                child: Row(
                  children: [
                    SvgPicture.asset('assets/images/icon_location_pin.svg', height: 20, colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
                    const SizedBox(width: 8),
                    const Text(
                      "3 pirogues actives à proximité",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
