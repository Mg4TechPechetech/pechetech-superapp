import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/pechetech_header.dart';
import '../../fuel_subsidies/presentation/fuel_path_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/models/notification_model.dart';
import '../data/services/notification_service.dart';
import 'package:intl/intl.dart';
import '../../auth/presentation/home_navigation_wrapper.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: StreamBuilder<List<NotificationModel>>(
          stream: NotificationService().getNotifications(userId),
          builder: (context, snapshot) {
            final notifications = snapshot.data ?? [];
            final unreadCount = notifications.where((n) => !n.isRead).length;

            return Column(
              children: [
                PecheTechHeader(
                  showBackButton: true,
                  notificationCount: unreadCount,
                  onFuelTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const FuelPathScreen()),
                    );
                  },
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
                      if (unreadCount > 0)
                        TextButton(
                          onPressed: () => NotificationService().markAllAsRead(),
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
                  child: snapshot.connectionState == ConnectionState.waiting
                      ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen))
                      : notifications.isEmpty
                          ? _buildEmptyState(userId)
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: notifications.length,
                              itemBuilder: (context, index) {
                                final notification = notifications[index];
                                
                                // Simple logic for section headers
                                bool showHeader = false;
                                if (index == 0) {
                                  showHeader = true;
                                } else {
                                  final prev = notifications[index - 1];
                                  if (!_isSameDay(prev.timestamp, notification.timestamp)) {
                                    showHeader = true;
                                  }
                                }

                                return Dismissible(
                                  key: Key(notification.id),
                                  direction: DismissDirection.endToStart,
                                  background: Container(
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 20.0),
                                    margin: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      color: AppTheme.error,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
                                  ),
                                  onDismissed: (direction) {
                                    NotificationService().deleteNotification(notification.id);
                                  },
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (showHeader) 
                                        _buildSectionHeader(_formatDateHeader(notification.timestamp)),
                                      _buildNotificationCard(
                                        id: notification.id,
                                        title: notification.title,
                                        description: notification.description,
                                        time: _formatTime(notification.timestamp),
                                        type: notification.type,
                                        isUnread: !notification.isRead,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                ),
              ],
            );
          }
        ),
      ),
    );
  }

  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    if (_isSameDay(date, now)) return "AUJOURD'HUI";
    if (_isSameDay(date, now.subtract(const Duration(days: 1)))) return "HIER";
    return DateFormat('d MMMM', 'fr_FR').format(date).toUpperCase();
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return "Il y a ${diff.inMinutes} min";
    if (diff.inHours < 24) return "Il y a ${diff.inHours}h";
    return DateFormat('HH:mm').format(date);
  }

  Widget _buildEmptyState(String? userId) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none,
              size: 64, color: AppTheme.textHint.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          const Text(
            "Aucune notification",
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
          ),
          const SizedBox(height: 24),
          if (userId != null)
            ElevatedButton(
              onPressed: () async {
                await NotificationService().seedDemoNotifications(userId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Générer des notifications de démo"),
            ),
        ],
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
    required String id,
    required String title,
    required String description,
    required String time,
    required String type,
    bool isUnread = false,
  }) {
    return NotificationCard(
      id: id,
      title: title,
      description: description,
      time: time,
      type: type,
      isUnread: isUnread,
    );
  }
}

class NotificationCard extends StatefulWidget {
  final String id;
  final String title;
  final String description;
  final String time;
  final String type;
  final bool isUnread;

  const NotificationCard({
    super.key,
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.type,
    required this.isUnread,
  });

  @override
  State<NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<NotificationCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    String icon = 'assets/images/icon_notification.svg';
    Color iconColor = AppTheme.primaryGreen;
    Color iconBg = AppTheme.primaryGreen.withValues(alpha: 0.1);
    bool hasAlert = false;

    switch (widget.type) {
      case 'weather':
        icon = 'assets/images/icon_weather_cloud.svg';
        iconColor = AppTheme.error;
        iconBg = AppTheme.error.withValues(alpha: 0.1);
        hasAlert = true;
        break;
      case 'fuel':
        icon = 'assets/images/icon_payment.svg';
        iconColor = AppTheme.primaryGreen;
        iconBg = AppTheme.primaryGreen.withValues(alpha: 0.1);
        break;
      case 'market':
        icon = 'assets/images/icon_trend_up.svg';
        iconColor = const Color(0xFF6366F1);
        iconBg = const Color(0xFF6366F1).withValues(alpha: 0.1);
        break;
      case 'journal':
        icon = 'assets/images/icon_nav_journal.svg';
        iconColor = const Color(0xFFF59E0B);
        iconBg = const Color(0xFFF59E0B).withValues(alpha: 0.1);
        break;
      case 'community':
        icon = 'assets/images/icon_nav_community.svg';
        iconColor = const Color(0xFFEC4899);
        iconBg = const Color(0xFFEC4899).withValues(alpha: 0.1);
        break;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
        if (widget.isUnread) {
          NotificationService().markAsRead(widget.id);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: widget.isUnread ? const Color(0xFFF8FAFC) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.isUnread ? AppTheme.primaryGreen.withValues(alpha: 0.1) : AppTheme.border,
            width: 1,
          ),
          boxShadow: [
            if (widget.isUnread)
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
                                      widget.title,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                  ),
                                  if (widget.isUnread)
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: AppTheme.primaryGreen,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  Icon(
                                    _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                    size: 20,
                                    color: AppTheme.textHint,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              if (_isExpanded)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4, bottom: 8),
                                      child: Text(
                                        widget.description,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppTheme.textSecondary,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: OutlinedButton(
                                        onPressed: () {
                                          if (widget.isUnread) {
                                            NotificationService().markAsRead(widget.id);
                                          }

                                          switch (widget.type) {
                                            case 'fuel':
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(builder: (context) => const FuelPathScreen()),
                                              );
                                              break;
                                            case 'journal':
                                              HomeNavigationWrapper.selectedTab.value = 0;
                                              Navigator.pop(context);
                                              break;
                                            case 'community':
                                              HomeNavigationWrapper.selectedTab.value = 3;
                                              Navigator.pop(context);
                                              break;
                                            case 'weather':
                                            case 'market':
                                              HomeNavigationWrapper.selectedTab.value = 2; // Dashboard
                                              Navigator.pop(context);
                                              break;
                                            default:
                                              Navigator.pop(context);
                                          }
                                        },
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: iconColor,
                                          side: BorderSide(color: iconColor.withValues(alpha: 0.5)),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                          minimumSize: const Size(0, 32),
                                        ),
                                        child: Text(
                                          _getButtonLabel(widget.type),
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              Text(
                                widget.time,
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
      ),
    );
  }

  String _getButtonLabel(String type) {
    switch (type) {
      case 'weather':
        return "Voir la météo";
      case 'fuel':
        return "Gérer mon carburant";
      case 'market':
        return "Prix du marché";
      case 'journal':
        return "Mon journal de bord";
      case 'community':
        return "Espace communautaire";
      default:
        return "Voir les détails";
    }
  }
}
