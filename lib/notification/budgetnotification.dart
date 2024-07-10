
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LocalNotifications {
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static final onClickNotification = BehaviorSubject<String>();

// on tap on any notification
  static void onNotificationTap(NotificationResponse notificationResponse) {
    onClickNotification.add(notificationResponse.payload!);
  }

// initialize the local notifications
  static Future init() async {
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      onDidReceiveLocalNotification: (id, title, body, payload) =>null,
    );
    final LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: 'Open notification');
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsDarwin,
            linux: initializationSettingsLinux);

    // request notification permissions 
    _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()!.requestPermission();
  
    
    _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onNotificationTap,
        onDidReceiveBackgroundNotificationResponse: onNotificationTap);
  }

  // show a simple notification
  static Future showSimpleNotification({
    required String title,
    required String body,
    required String payload,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('your channel id', 'your channel name',
            channelDescription: 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await _flutterLocalNotificationsPlugin
        .show(0, title, body, notificationDetails, payload: payload);
  }

  // to show periodic notification at regular interval



    static Future showPeriodicTotalBudgetsNotifications({
    required String title,
    required String body,
    required String payload,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('channel 2', 'your channel name',
            channelDescription: 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    tz.initializeTimeZones();
    final now = tz.TZDateTime.now(tz.local);
    final endOfCurrentMonth = tz.TZDateTime(tz.local, now.year, now.month + 1, 0, 23, 59, 59);
    
    // Start scheduling from the next day
    final startDate = tz.TZDateTime(tz.local, now.year, now.month, now.day + 1, now.hour, now.minute, now.second);

    // Schedule notifications daily from the next day until the end of the current month
    for (var i = startDate.day; i <= endOfCurrentMonth.day; i++) {
      final scheduledDate = tz.TZDateTime(tz.local, startDate.year, startDate.month, i, startDate.hour, startDate.minute, startDate.second);
      if (scheduledDate.isBefore(endOfCurrentMonth)) {
        await _flutterLocalNotificationsPlugin.zonedSchedule(
          i,
          title,
          body,
          scheduledDate,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          payload: payload,
        );
      }
    }
  }


  static Future showCategorywiseNotifications({
    required String title,
    required String body,
    required String payload,
    required int id
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('channel 3', 'your channel name',
            channelDescription: 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    tz.initializeTimeZones();
    final now = tz.TZDateTime.now(tz.local);
    final endOfCurrentMonth = tz.TZDateTime(tz.local, now.year, now.month + 1, 0, 23, 59, 59);
    
    // Start scheduling from the next day
    final startDate = tz.TZDateTime(tz.local, now.year, now.month, now.day + 1, now.hour, now.minute, now.second);

    // Schedule notifications daily from the next day until the end of the current month
    for (var i = startDate.day; i <= endOfCurrentMonth.day; i++) {
      final scheduledDate = tz.TZDateTime(tz.local, startDate.year, startDate.month, i, startDate.hour, startDate.minute, startDate.second);
      if (scheduledDate.isBefore(endOfCurrentMonth)) {
        await _flutterLocalNotificationsPlugin.zonedSchedule(
          id+i,
          title,
          body,
          scheduledDate,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          payload: payload,
        );
      }
    }
  }


 

  // to schedule a local notification
  static Future showScheduleNotification({
    required String title,
    required String body,
    required String payload,
  }) async {
    tz.initializeTimeZones();
    await _flutterLocalNotificationsPlugin.zonedSchedule(
        2,
        title,
        body,
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
        const NotificationDetails(
            android: AndroidNotificationDetails(
                'channel 4', 'your channel name',
                channelDescription: 'your channel description',
                importance: Importance.max,
                priority: Priority.high,
                ticker: 'ticker')),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload);
  }

  // close a specific channel notification
  static Future cancel(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  // close all the notifications available
  static Future cancelAll() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }


 static Future cancelTotalBudgetNotifiactionFromDay(int startDay) async {
    tz.initializeTimeZones();
    final now = tz.TZDateTime.now(tz.local);
    final endOfCurrentMonth = tz.TZDateTime(tz.local, now.year, now.month + 1, 0, 23, 59, 59);

    for (var i = startDay; i <= endOfCurrentMonth.day; i++) {
      await _flutterLocalNotificationsPlugin.cancel(i);
    }
  }



  static Future cancelallCategoryNotificationFromDay(int startDay) async {
    tz.initializeTimeZones();
    final now = tz.TZDateTime.now(tz.local);
    final endOfCurrentMonth = tz.TZDateTime(tz.local, now.year, now.month + 1, 0, 23, 59, 59);

    for (var i = startDay; i <= endOfCurrentMonth.day; i++) {
      await _flutterLocalNotificationsPlugin.cancel(i);
    }
  }






}
