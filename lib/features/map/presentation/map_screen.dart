import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Dark slate for map base
      body: Stack(
        children: [
          // Background Map (Placeholder with satellite-like look)
          Positioned.fill(
            child: Image.asset(
              'assets/images/pechetech_logo.png', // Assuming we don't have a real map tile yet
              fit: BoxFit.cover,
              color: Colors.black.withValues(alpha: 0.4),
              colorBlendMode: BlendMode.darken,
            ),
          ),

          // Satellite Map Texture Simulation
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.5,
                  colors: [
                    const Color(0xFF1E293B).withValues(alpha: 0.1),
                    const Color(0xFF0F172A).withValues(alpha: 0.4),
                  ],
                ),
              ),
            ),
          ),

          // Map Overlays (Zones)
          _buildMapZones(),

          // UI Overlays
          Column(
            children: [
              const SizedBox(height: 16),
              // Search and Filters
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildSearchAndFilters(),
              ),
              const Spacer(),
            ],
          ),

          // Legend Card (Bottom Left)
          Positioned(
            bottom: 120, // Space for bottom nav
            left: 20,
            child: _buildLegendCard(),
          ),
        ],
      ),
    );
  }

  Widget _buildMapZones() {
    return Stack(
      children: [
        // Green Zone A-1
        Positioned(
          top: 250,
          left: 50,
          child: Container(
            width: 140,
            height: 200,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primaryGreen, width: 2),
            ),
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  "ZONE A-1",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        ),

        // Red Protected Zone
        Positioned(
          bottom: 300,
          right: 60,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.3),
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.error, width: 2),
            ),
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  "PROTÉGÉE",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.error,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Column(
      children: [
        // Search Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const TextField(
            decoration: InputDecoration(
              icon: Icon(Icons.search, color: AppTheme.textHint),
              hintText: "Rechercher une zone ou région...",
              suffixIcon: Icon(Icons.tune, color: AppTheme.textSecondary),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip("Zones Autorisées", AppTheme.primaryGreen,
                  Icons.check_circle, true),
              const SizedBox(width: 8),
              _buildFilterChip("Aires Protégées", AppTheme.textSecondary,
                  Icons.shield, false),
              const SizedBox(width: 8),
              _buildFilterChip(
                  "Météo", AppTheme.textSecondary, Icons.wb_sunny, false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(
      String label, Color color, IconData icon, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? color : color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? color : color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: isActive ? Colors.white : color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 180,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B).withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Légende",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildLegendItem("Pêche autorisée", AppTheme.primaryGreen),
              const SizedBox(height: 8),
              _buildLegendItem("Zone protégée", Colors.red),
              const SizedBox(height: 8),
              _buildLegendItem("Limite maritime", Colors.white38,
                  isDashed: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, {bool isDashed = false}) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: isDashed ? Colors.transparent : color,
            borderRadius: BorderRadius.circular(4),
            border: isDashed ? Border.all(color: color, width: 2) : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
