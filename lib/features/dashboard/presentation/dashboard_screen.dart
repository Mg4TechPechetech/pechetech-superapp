import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/app_theme.dart';
import '../../weather/data/models/weather_model.dart';
import '../../weather/data/weather_service.dart';
import '../../map/data/models/fishing_zone_model.dart';
import '../../map/data/prediction_service.dart';
import '../../profile/data/services/profile_service.dart';
import '../../profile/data/models/user_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  bool _showErrorBanner = false;
  
  WeatherModel? _currentWeatherModel;
  final WeatherService _weatherService = WeatherService();

  UserModel? _userProfile;
  final ProfileService _profileService = ProfileService();

  List<FishingZoneModel> _fishingZones = [];
  final PredictionService _predictionService = PredictionService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _hasError = false;
      _showErrorBanner = false;
    });

    try {
      // 1. Récupérer le profil de l'utilisateur pour connaître sa zone de pêche
      _userProfile = await _profileService.getCurrentUserProfile();
      
      // 2. Déterminer le site ID (par défaut 'yoff' si non défini)
      final String siteId = (_userProfile?.fishingZone != null && _userProfile!.fishingZone.isNotEmpty)
          ? _userProfile!.fishingZone
          : 'yoff';

      // 3. Charger la météo pour cette zone spécifique
      // ⚡ Bolt Optimization: Run independent network requests in parallel
      // Expected performance impact: Reduces total wait time from (time_weather + time_zones) to max(time_weather, time_zones).
      // Uses Dart 3 records parallelization for strict type safety compared to Future.wait([])
      final (weatherData, zonesData) = await (
        _weatherService.getCurrentWeather(siteId: siteId),
        _predictionService.getFishingZonesToday(),
      ).wait;
      
      if (mounted) {
        setState(() {
          _currentWeatherModel = weatherData;
          _fishingZones = zonesData;
          _isLoading = false;
          _hasError = false;
        });
      }
    } catch (e) {

      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _showErrorBanner = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen))
          : _hasError 
              ? _buildErrorState() 
              : _buildNormalState(),
    );
  }

  Widget _buildErrorState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      child: Column(
        children: [
          if (_showErrorBanner) _buildErrorBanner(),
          if (_showErrorBanner) const SizedBox(height: 16),
          _buildErrorCard(),
        ],
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: IntrinsicHeight(
          child: Row(
            children: [
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
                      const Icon(Icons.error, color: AppTheme.error, size: 24),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Erreur de connexion",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Impossible de synchroniser vos données.",
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showErrorBanner = false;
                          });
                        },
                        child: const Icon(Icons.close, color: AppTheme.textHint, size: 20),
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

  Widget _buildErrorCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE2E8F0), Color(0xFFCBD5E1)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.error.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.cloud_off,
              color: AppTheme.error,
              size: 48,
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            "Problème technique",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Erreur de connexion. Veuillez réessayer. Nous ne parvenons pas à charger vos données pour le moment.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // Trigger a real data reload
                _loadData();
              },
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text(
                "Réessayer",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {},
            child: const Text(
              "Contacter le support",
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.accentGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNormalState() {
    return SingleChildScrollView(
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
    );
  }

  Widget _buildWelcomeSection() {
    return StreamBuilder<UserModel?>(
      stream: ProfileService().currentUserProfileStream,
      builder: (context, snapshot) {
        final userName = snapshot.data?.fullName ?? "Utilisateur";
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Bonjour, $userName",
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Prêt pour la marée d'aujourd'hui ?",
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        );
      }
    );
  }

  Widget _buildWeatherCard() {
    if (_currentWeatherModel == null) {
      return const SizedBox(
        height: 200, 
        width: double.infinity,
        child: Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen))
      );
    }

    List<Color> gradientColors;
    Color shadowColor;
    IconData alertIcon;

    switch (_currentWeatherModel!.condition) {
      case 'good':
        gradientColors = [const Color(0xFF10B981), AppTheme.accentGreen];
        shadowColor = AppTheme.accentGreen;
        alertIcon = Icons.check_circle_outline;
        break;
      case 'moderate':
        gradientColors = [const Color(0xFFF59E0B), const Color(0xFFD97706)];
        shadowColor = const Color(0xFFD97706);
        alertIcon = Icons.warning_amber_rounded;
        break;
      case 'critical':
      default:
        gradientColors = [AppTheme.error, const Color(0xFF991B1B)];
        shadowColor = AppTheme.error;
        alertIcon = Icons.error_outline;
        break;
    }

    return GestureDetector(
      onTap: () {
        // Trigger reload to see dynamic changes (in real app, use refresh)
        _loadData();
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: shadowColor.withValues(alpha: 0.3),
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
                Row(
                  children: [
                    Icon(alertIcon, color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      _currentWeatherModel!.alertText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                SvgPicture.asset('assets/images/icon_weather_cloud.svg', height: 24, colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _userProfile?.fishingZone.isNotEmpty == true 
                  ? _userProfile!.fishingZone 
                  : "Yoff, Dakar",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "${_currentWeatherModel!.temperature}°",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 12),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    _currentWeatherModel!.statusText,
                    style: const TextStyle(
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
                    Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Vents", style: TextStyle(color: Colors.white70, fontSize: 12)),
                        Text("${_currentWeatherModel!.windSpeed} km/h ${_currentWeatherModel!.windDirection}", style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    SvgPicture.asset('assets/images/icon_waves.svg', height: 20, colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
                    const SizedBox(width: 8),
                    Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Houle", style: TextStyle(color: Colors.white70, fontSize: 12)),
                        Text("${_currentWeatherModel!.waveHeight}m / ${_currentWeatherModel!.wavePeriod}s", style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
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
                  child: const Text("Distribuer", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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
                    Text(
                      "${_fishingZones.length} zones favorables détectées",
                      style: const TextStyle(
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

