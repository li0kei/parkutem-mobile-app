// =====================================================
// IMPORTS
// =====================================================

import 'package:flutter/material.dart';

import '../../core/services/notification_service.dart';
import '../../core/theme/app_theme.dart';
import '../../models/user_notification.dart';

// =====================================================
// NOTIFICATIONS SCREEN
// =====================================================

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

// =====================================================
// NOTIFICATIONS SCREEN STATE
// =====================================================

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();

  List<UserNotification> _notifications = [];

  bool _showUnreadOnly = false;
  bool _isLoading = true;
  bool _isMarkingRead = false;
  String? _errorMessage;

  // =====================================================
  // INIT STATE
  // =====================================================

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  // =====================================================
  // LOAD NOTIFICATIONS
  // =====================================================

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final List<UserNotification> notifications =
          await _notificationService.getCurrentUserNotifications();

      if (!mounted) return;

      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  // =====================================================
  // FILTERED NOTIFICATIONS
  // =====================================================

  List<UserNotification> get _filteredNotifications {
    if (!_showUnreadOnly) return _notifications;

    return _notifications.where((item) => !item.isRead).toList();
  }

  int get _unreadCount {
    return _notifications.where((item) => !item.isRead).length;
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadNotifications,
          color: AppTheme.primaryBlue,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 24),
                if (_isLoading)
                  _buildLoadingState()
                else if (_errorMessage != null)
                  _buildErrorState()
                else ...[
                  _buildSummaryCard(),
                  const SizedBox(height: 20),
                  _buildFilterBar(),
                  const SizedBox(height: 20),
                  _buildNotificationList(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =====================================================
  // HEADER
  // =====================================================

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        _BackButton(
          onTap: () => Navigator.of(context).pop(),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notifications',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Parking alerts and system updates',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: _unreadCount == 0 || _isMarkingRead ? null : _markAllAsRead,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: _isMarkingRead
                ? const Padding(
                    padding: EdgeInsets.all(13),
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: AppTheme.primaryBlue,
                    ),
                  )
                : Icon(
                    Icons.done_all_rounded,
                    color: _unreadCount == 0
                        ? const Color(0xFF94A3B8)
                        : AppTheme.primaryBlue,
                    size: 24,
                  ),
          ),
        ),
      ],
    );
  }

  // =====================================================
  // LOADING STATE
  // =====================================================

  Widget _buildLoadingState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 58),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE8EEF7),
        ),
      ),
      child: const Column(
        children: [
          CircularProgressIndicator(
            color: AppTheme.primaryBlue,
          ),
          SizedBox(height: 16),
          Text(
            'Loading notifications...',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // ERROR STATE
  // =====================================================

  Widget _buildErrorState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFFECACA),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFEF4444),
            size: 40,
          ),
          const SizedBox(height: 12),
          const Text(
            'Unable to load notifications',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'Something went wrong.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12.5,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadNotifications,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // SUMMARY CARD
  // =====================================================

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppTheme.primaryBlue,
            Color(0xFF056BF1),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.24),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.notifications_active_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ParkUTeM Alerts',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _unreadCount == 0
                      ? 'You are all caught up.'
                      : '$_unreadCount unread notification(s).',
                  style: const TextStyle(
                    color: Color(0xFFDCEBFF),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // FILTER BAR
  // =====================================================

  Widget _buildFilterBar() {
    return Row(
      children: [
        _FilterPill(
          label: 'All',
          isSelected: !_showUnreadOnly,
          onTap: () {
            setState(() {
              _showUnreadOnly = false;
            });
          },
        ),
        const SizedBox(width: 10),
        _FilterPill(
          label: 'Unread',
          isSelected: _showUnreadOnly,
          onTap: () {
            setState(() {
              _showUnreadOnly = true;
            });
          },
        ),
        const Spacer(),
        Text(
          '${_filteredNotifications.length} records',
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 12.2,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // =====================================================
  // NOTIFICATION LIST
  // =====================================================

  Widget _buildNotificationList() {
    final List<UserNotification> items = _filteredNotifications;

    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFFE8EEF7),
          ),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.notifications_none_rounded,
              color: Color(0xFF94A3B8),
              size: 42,
            ),
            SizedBox(height: 10),
            Text(
              'No notifications found',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Your parking alerts will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: items.map((item) {
        return _NotificationTile(
          item: item,
          onTap: () {
            _handleNotificationTap(item);
          },
        );
      }).toList(),
    );
  }

// =====================================================
// HANDLE NOTIFICATION TAP
// =====================================================

Future<void> _handleNotificationTap(UserNotification item) async {
  if (!item.isRead) {
    try {
      await _notificationService.markOneAsRead(item.id);

      if (!mounted) return;

      setState(() {
        _notifications = _notifications.map((notification) {
          if (notification.id != item.id) {
            return notification;
          }

          return notification.copyWith(
            isRead: true,
            readAt: DateTime.now(),
          );
        }).toList();
      });
    } catch (_) {
      if (!mounted) return;

      _showMessage(
        'Unable to update notification status.',
        isError: true,
      );
    }
  }

  if (!mounted) return;

  final String? route = item.relatedRoute;

  if (route == null || route.trim().isEmpty) return;

  Navigator.of(context).pushNamed(route);
}

// =====================================================
// MARK ALL AS READ
// =====================================================

Future<void> _markAllAsRead() async {
  setState(() {
    _isMarkingRead = true;
  });

  try {
    final int updatedCount = await _notificationService.markAllAsRead();

    if (!mounted) return;

    await _loadNotifications();

    if (!mounted) return;

    _showMessage(
      updatedCount == 0
          ? 'No unread notifications.'
          : '$updatedCount notification(s) marked as read.',
    );
  } catch (_) {
    if (mounted) {
      _showMessage(
        'Unable to mark notifications as read.',
        isError: true,
      );
    }
  } finally {
    if (mounted) {
      setState(() {
        _isMarkingRead = false;
      });
    }
  }
}

  // =====================================================
  // SHOW MESSAGE
  // =====================================================

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            isError ? const Color(0xFFEF4444) : AppTheme.primaryBlue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}

// =====================================================
// BACK BUTTON
// =====================================================

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _BackButton({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE8EEF7),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.055),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.arrow_back_rounded,
            color: Color(0xFF0F172A),
            size: 24,
          ),
        ),
      ),
    );
  }
}

// =====================================================
// FILTER PILL
// =====================================================

class _FilterPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.primaryBlue,
            fontSize: 12.5,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

// =====================================================
// NOTIFICATION TILE
// =====================================================

class _NotificationTile extends StatelessWidget {
  final UserNotification item;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.item,
    required this.onTap,
  });

  Color get color {
    switch (item.type) {
      case UserNotificationType.anpr:
        return const Color(0xFF22C55E);
      case UserNotificationType.reservation:
        return AppTheme.primaryBlue;
      case UserNotificationType.wallet:
        return const Color(0xFFF59E0B);
      case UserNotificationType.support:
        return const Color(0xFF8B5CF6);
      case UserNotificationType.reminder:
        return const Color(0xFF06B6D4);
      case UserNotificationType.system:
        return const Color(0xFF64748B);
    }
  }

  IconData get icon {
    switch (item.type) {
      case UserNotificationType.anpr:
        return Icons.camera_alt_rounded;
      case UserNotificationType.reservation:
        return Icons.event_available_rounded;
      case UserNotificationType.wallet:
        return Icons.account_balance_wallet_rounded;
      case UserNotificationType.support:
        return Icons.support_agent_rounded;
      case UserNotificationType.reminder:
        return Icons.alarm_rounded;
      case UserNotificationType.system:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: item.isRead
                ? Colors.white
                : AppTheme.primaryBlue.withValues(alpha: 0.045),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: item.isRead
                  ? const Color(0xFFE8EEF7)
                  : AppTheme.primaryBlue.withValues(alpha: 0.18),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.035),
                blurRadius: 14,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: const TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 14.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        if (!item.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryBlue,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      item.message,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12.3,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      _formatRelativeTime(item.createdAt),
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatRelativeTime(DateTime value) {
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(value);

    if (difference.inMinutes < 1) {
      return 'Just now';
    }

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    }

    if (difference.inHours < 24) {
      return '${difference.inHours} hour(s) ago';
    }

    if (difference.inDays == 1) {
      return 'Yesterday';
    }

    return '${value.day}/${value.month}/${value.year}';
  }
}