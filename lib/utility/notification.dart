import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'ch102',
  "Channel 2",
  description: "this is a test channel",
  groupId: "groupkey102",
  importance: Importance.max,
);
AndroidNotificationChannelGroup channelGroup =
    const AndroidNotificationChannelGroup('groupkey102', "gk102");
final FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();

class NotificationService {
  Future<void> initNotification() async {
    await notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestPermission();

    AndroidInitializationSettings initializationSettingsAndroid =
        const AndroidInitializationSettings('@drawable/ic_stat_name');
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannelGroup(channelGroup);
    await notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    await notificationsPlugin.initialize(
      initializationSettings,
    );
  }

  notificationDetails(String channelName, String channelID, String groupKey) {
    return NotificationDetails(
        android: AndroidNotificationDetails(
      channelID,
      channelName,
      importance: Importance.max,
      priority: Priority.high,
      groupKey: groupKey,
    ));
  }

  Future showNotification({
    required int groupid,
    String? groupKey,
    channelID,
    channelName,
    int id = 0,
    String? title,
    String? body,
  }) async {
    notificationsPlugin.show(
        id,
        title,
        body,
        await notificationDetails(
            channel.name, channel.id, groupKey ?? channelGroup.id));
    await groupNotifications(groupKey, groupid);
  }

  Future<void> groupNotifications(String? groupKey, int groupid) async {
    List<ActiveNotification>? activeNotifications = await notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.getActiveNotifications();

    // Filter active notifications by groupKey
    List<ActiveNotification> groupNotifications = activeNotifications!
        .where((notification) =>
            notification.groupKey == (groupKey ?? channelGroup.id))
        .toList();

    // Calculate the total number of updates for the group

    // Create lines for InboxStyleInformation
    List<String> lines = groupNotifications
        .map((notification) => notification.title.toString())
        .toList();

    InboxStyleInformation inboxStyleInformation = InboxStyleInformation(
      lines,
      contentTitle: "${groupNotifications.length - 1} Updates",
      summaryText: "${groupNotifications.length - 1} Updates",
    );

    AndroidNotificationDetails groupNotificationDetails =
        AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: inboxStyleInformation,
      setAsGroupSummary: true,
      groupKey: groupKey ?? channelGroup.id,
    );
    NotificationDetails groupNotificationDetailsPlatformSpefics =
        NotificationDetails(android: groupNotificationDetails);
    await notificationsPlugin.show(
        groupid, '', '', groupNotificationDetailsPlatformSpefics);
  }
}
