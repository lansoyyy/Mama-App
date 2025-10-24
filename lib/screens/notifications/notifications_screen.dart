import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/empty_state.dart';
import '../../models/notification_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = false;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _deleteOldNotifications();
  }

  Future<void> _deleteOldNotifications() async {
    final userId = _authService.currentUserId;
    if (userId != null) {
      await _firestoreService.deleteOldNotifications(userId);
    }
  }

  Future<void> _markAllAsRead() async {
    final userId = _authService.currentUserId;
    if (userId != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _firestoreService.markAllNotificationsAsRead(userId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All notifications marked as read'),
            backgroundColor: AppColors.success,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    try {
      await _firestoreService.markNotificationAsRead(notificationId);
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  Future<void> _deleteNotification(String notificationId) async {
    try {
      await _firestoreService.deleteNotification(notificationId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification deleted'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting notification: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showNotificationDetail(NotificationModel notification) {
    // Mark as read when viewing details
    if (!notification.isRead) {
      _markAsRead(notification.id);
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              notification.iconData,
              color: notification.color,
              size: AppConstants.iconL,
            ),
            const SizedBox(width: AppConstants.paddingM),
            Expanded(child: Text(notification.title)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.message,
              style: const TextStyle(
                fontSize: AppConstants.fontM,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppConstants.paddingM),
            Text(
              notification.timeAgo,
              style: const TextStyle(
                fontSize: AppConstants.fontS,
                color: AppColors.textLight,
              ),
            ),
            if (notification.data != null && notification.data!.isNotEmpty) ...[
              const SizedBox(height: AppConstants.paddingM),
              const Text(
                'Details:',
                style: TextStyle(
                  fontSize: AppConstants.fontS,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppConstants.paddingXS),
              ...notification.data!.entries.map((entry) => Padding(
                    padding:
                        const EdgeInsets.only(bottom: AppConstants.paddingXS),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${entry.key}: ',
                          style: const TextStyle(
                            fontSize: AppConstants.fontS,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            entry.value.toString(),
                            style: const TextStyle(
                              fontSize: AppConstants.fontS,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteNotification(notification.id);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = _authService.currentUserId;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Notifications',
        actions: [
          if (userId != null)
            StreamBuilder<int>(
              stream: _firestoreService.getUnreadNotificationsCount(userId),
              builder: (context, snapshot) {
                final unreadCount = snapshot.data ?? 0;
                return unreadCount > 0
                    ? TextButton(
                        onPressed: _isLoading ? null : _markAllAsRead,
                        child: _isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.textWhite,
                                ),
                              )
                            : const Text(
                                'Mark all read',
                                style: TextStyle(color: AppColors.textWhite),
                              ),
                      )
                    : const SizedBox.shrink();
              },
            ),
        ],
      ),
      body: userId == null
          ? const Center(
              child: Text(
                'Please log in to view notifications',
                style: TextStyle(
                  fontSize: AppConstants.fontL,
                  color: AppColors.textSecondary,
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                await _deleteOldNotifications();
              },
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestoreService.getUserNotifications(userId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: LoadingIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error loading notifications: ${snapshot.error}',
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: AppConstants.fontM,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const EmptyState(
                      icon: Icons.notifications_none,
                      title: 'No notifications',
                      message:
                          'You\'re all caught up! Check back later for updates.',
                    );
                  }

                  // Group notifications by date
                  Map<String, List<QueryDocumentSnapshot>>
                      groupedNotifications = {};
                  for (var doc in snapshot.data!.docs) {
                    final notification = NotificationModel.fromFirestore(
                      doc.data() as Map<String, dynamic>,
                      doc.id,
                    );
                    final dateKey = notification.formattedDate;

                    if (!groupedNotifications.containsKey(dateKey)) {
                      groupedNotifications[dateKey] = [];
                    }
                    groupedNotifications[dateKey]!.add(doc);
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(AppConstants.paddingM),
                    itemCount: groupedNotifications.keys.length,
                    itemBuilder: (context, index) {
                      final dateKey =
                          groupedNotifications.keys.elementAt(index);
                      final notifications = groupedNotifications[dateKey]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dateKey,
                            style: const TextStyle(
                              fontSize: AppConstants.fontL,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppConstants.paddingM),
                          ...notifications.map((doc) {
                            final notification =
                                NotificationModel.fromFirestore(
                              doc.data() as Map<String, dynamic>,
                              doc.id,
                            );
                            return _buildNotificationItem(notification);
                          }).toList(),
                          if (index < groupedNotifications.keys.length - 1)
                            const SizedBox(height: AppConstants.paddingL),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
    );
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
      color:
          notification.isRead ? null : AppColors.primaryLight.withOpacity(0.1),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: notification.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
          ),
          child: Icon(
            notification.iconData,
            color: notification.color,
            size: AppConstants.iconL,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                notification.title,
                style: TextStyle(
                  fontSize: AppConstants.fontL,
                  fontWeight:
                      notification.isRead ? FontWeight.w600 : FontWeight.bold,
                  color: notification.isRead
                      ? AppColors.textPrimary
                      : AppColors.primary,
                ),
              ),
            ),
            if (!notification.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppConstants.paddingXS),
            Text(
              notification.message,
              style: const TextStyle(
                fontSize: AppConstants.fontM,
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppConstants.paddingXS),
            Text(
              notification.timeAgo,
              style: const TextStyle(
                fontSize: AppConstants.fontS,
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
        onTap: () => _showNotificationDetail(notification),
      ),
    );
  }
}
