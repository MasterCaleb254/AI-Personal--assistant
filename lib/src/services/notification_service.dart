import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ai_personal_assistant/src/utils/errors/notification_failure.dart';
import 'package:ai_personal_assistant/src/utils/logger.dart';

/// Notification service with:
/// - Push notifications (FCM)
/// - Local notifications
/// - Notification channels
/// - Deep linking
class NotificationService {
  final FirebaseMessaging _firebaseMessaging;
  final FlutterLocalNotificationsPlugin _localNotifications;
  final Logger _logger;
  Stream<RemoteMessage>? _onMessageStream;

  NotificationService({
    FirebaseMessaging? firebaseMessaging,
    FlutterLocalNotificationsPlugin? localNotifications,
    Logger? logger,
  })  : _firebaseMessaging = firebaseMessaging ?? FirebaseMessaging.instance,
        _localNotifications = localNotifications ?? 
            FlutterLocalNotificationsPlugin(),
        _logger = logger ?? Logger();

  /// Initialize notification services
  Future<void> initialize() async {
    try {
      // Request permissions
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        _logger.info('Notification permissions granted');
      } else {
        _logger.warning('Notification permissions: ${settings.authorizationStatus}');
      }

      // Initialize local notifications
      await _initLocalNotifications();

      // Set up foreground message handling
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Get initial message if app launched from notification
      final initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }

      // Background message handler
      FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

      // Setup notification channels
      await _createNotificationChannels();
    } catch (e, stackTrace) {
      _logger.error('Notification init failed', 
                    error: e, stackTrace: stackTrace);
      throw NotificationFailure('Initialization failed: ${e.toString()}');
    }
  }

  Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOSSettings = DarwinInitializationSettings();
    
    await _localNotifications.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iOSSettings,
      ),
      onDidReceiveNotificationResponse: (response) {
        _handleNotificationResponse(response);
      },
    );
  }

  Future<void> _createNotificationChannels() async {
    // Android notification channel
    const androidChannel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  /// Handle foreground notifications
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    _logger.info('Foreground message received: ${message.messageId}');
    await _showLocalNotification(message);
  }

  /// Background message handler (top-level function)
  @pragma('vm:entry-point')
  static Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
    // Implement background handler logic
  }

  /// Display local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification == null) return;

    final androidDetails = android != null
        ? AndroidNotificationDetails(
            android.channelId ?? 'high_importance_channel',
            android.channelId ?? 'High Importance',
            channelDescription: 'Important notifications',
            importance: Importance.max,
            priority: Priority.high,
            icon: android.smallIcon,
          )
        : null;

    final iOSDetails = const DarwinNotificationDetails();

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch,
      notification.title,
      notification.body,
      NotificationDetails(
        android: androidDetails,
        iOS: iOSDetails,
      ),
      payload: message.data['deep_link'],
    );
  }

  /// Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    final deepLink = message.data['deep_link'];
    if (deepLink != null) {
      _logger.info('Launching deep link: $deepLink');
      // Implement deep link navigation
    }
  }

  /// Handle local notification response
  void _handleNotificationResponse(NotificationResponse response) {
    if (response.payload != null) {
      _logger.info('Local notification tapped: ${response.payload}');
      // Implement deep link navigation
    }
  }

  /// Get FCM token for device
  Future<String?> getDeviceToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e, stackTrace) {
      _logger.error('Token retrieval failed', 
                    error: e, stackTrace: stackTrace);
      throw NotificationFailure('Token retrieval failed');
    }
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
    } catch (e, stackTrace) {
      _logger.error('Topic subscription failed', 
                    error: e, stackTrace: stackTrace);
      throw NotificationFailure('Subscription failed');
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
    } catch (e, stackTrace) {
      _logger.error('Topic unsubscription failed', 
                    error: e, stackTrace: stackTrace);
      throw NotificationFailure('Unsubscription failed');
    }
  }
}