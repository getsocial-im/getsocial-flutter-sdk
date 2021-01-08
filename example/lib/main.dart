import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:getsocial_example/followers.dart';
import 'package:getsocial_example/friends.dart';
import 'package:getsocial_example/invites_sendcustom.dart';
import 'package:getsocial_example/invites_setreferrer.dart';
import 'package:getsocial_example/notifications_filter.dart';
import 'package:getsocial_example/notifications_settings.dart';
import 'package:getsocial_example/postactivity.dart';
import 'package:getsocial_example/send_notification.dart';
import 'package:getsocial_example/settings_menu.dart';
import 'package:getsocial_example/tags.dart';
import 'package:getsocial_example/topics.dart';
import 'package:getsocial_example/topics_menu.dart';
import 'package:getsocial_example/user_details.dart';
import 'package:getsocial_example/users.dart';
import 'package:getsocial_flutter_sdk/getsocial_flutter_sdk.dart';
import 'package:getsocial_example/base_list.dart';
import 'package:getsocial_example/um.dart';
import 'package:getsocial_example/invites_menu.dart';

import 'activities_menu.dart';
import 'common.dart';
import 'feed.dart';
import 'language_menu.dart';
import 'notifications_list.dart';
import 'notifications_menu.dart';

List<BuildContext> buildContextList = [];
ReferralData globalReferralData;
bool globalArePushNotificationsEnabled = false;

void main() {
  runApp(MyApp());
  registerListeners();
}

void registerListeners() {
  Invites.setOnReferralDataReceivedListener((received) {
    globalReferralData = received;
    showAlert(buildContextList.last, 'Referral Data Received', '$received');
  });

  Notifications.setOnNotificationReceivedListener((notification) {
    print('Notification received: $notification');
    if (!handleAction(notification.notificationAction)) {
      showAlert(
          buildContextList.last, 'Notification Received', '$notification');
    }
  });
  Notifications.setOnNotificationClickedListener((notification, context) {
    print('Notification clicked: $notification, context: $context');
    if (!handleAction(notification.notificationAction)) {
      showAlert(buildContextList.last, 'Notification Clicked', '$notification');
    } else {
      print('action handled');
    }
  });
  Notifications.setOnTokenReceivedListener(
      (token) => print("Push Notification token received: $token"));
}

bool handleAction(GetSocialAction action) {
  if (action.type == 'open_url') {
    GetSocial.handleAction(action);
    return true;
  } else if (action.type == 'open_profile') {
    showUserDetail(action.data['\$user_id']);
    return true;
  }
  print('action not handled, return with false');
  return false;
}

showUserDetail(String userId) async {
  Communities.getUsers(UserIdList.create([userId])).then((value) {
    if (value.isEmpty) {
      showAlert(buildContextList.last, 'Error', 'User not found');
    } else {
      showAlert(buildContextList.last, 'User', value[userId].toString());
    }
  }).catchError(
      (error) => showAlert(buildContextList.last, 'Error', error.toString()));
}

class MyApp extends StatefulWidget {
  static AppState _state;

  @override
  State<StatefulWidget> createState() {
    _state = AppState();
    return _state;
  }

  AppState getState() {
    return _state;
  }
}

class HomePage extends BaseListView {
  HomePage(StateProvider stateProvider) : super(stateProvider);

  @override
  List<ListButton> get buttons => [
        ListButton("User Management",
            (context) => Navigator.pushNamed(context, "/um")),
        ListButton(
            "Invites", (context) => Navigator.pushNamed(context, "/invites")),
        ListButton("Activities",
            (context) => Navigator.pushNamed(context, "/activities")),
        ListButton("Topics",
            (context) => Navigator.pushNamed(context, "/topics_menu")),
        ListButton("Friends", (context) {
          FriendsState.query = FriendsQuery.ofUser(UserId.currentUser());
          Navigator.pushNamed(context, "/friends");
        }),
        ListButton(
            "Users", (context) => Navigator.pushNamed(context, "/users")),
        ListButton("Tags", (context) => Navigator.pushNamed(context, "/tags")),
        ListButton("Notifications",
            (context) => Navigator.pushNamed(context, "/notifications_menu")),
        ListButton(
            "Settings", (context) => Navigator.pushNamed(context, "/settings")),
      ];
}

class AppState extends State<MyApp> implements StateProvider {
  CurrentUser _currentUser;

  @override
  void initState() {
    super.initState();
    updateState();
    GetSocial.addOnInitializedListener(() {
      updateState();
      Notifications.arePushNotificationsEnabled().then((value) {
        globalArePushNotificationsEnabled = value;
      });
    });
    GetSocial.addOnCurrentUserChangedListener((user) => {
          setState(() => {_currentUser = user})
        });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> updateState() async {
    if (!mounted) return;
    CurrentUser user = await GetSocial.currentUser;

    setState(() {
      _currentUser = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    buildContextList.add(context);
    var notificationsFilter = NotificationsFilter();
    var notificationsList = NotificationsList(notificationsFilter);
    return MaterialApp(
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => {
                    Clipboard.setData(ClipboardData(text: _currentUser.userId))
                  },
                  child: _currentUser?.avatarUrl == null ||
                          _currentUser.avatarUrl.length == 0
                      ? Image.asset(
                          "images/avatar_default.png",
                          width: 50,
                          height: 50,
                        )
                      : Image.network(
                          _currentUser.avatarUrl,
                          width: 50,
                          height: 50,
                        ),
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentUser?.displayName ?? "Initializing...",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(_currentUser == null
                        ? ""
                        : _currentUser.isAnonymous
                            ? "Anonymous"
                            : _currentUser.identities.entries
                                .map((e) => e.key + "=" + e.value)
                                .join(", ")),
                  ],
                )
              ],
            ),
          ),
          body: child,
        );
      },
      initialRoute: '/',
      routes: {
        '/': (BuildContext context) => HomePage(this),
        '/um': (BuildContext context) => UserManagement(this),
        '/um_userdetails': (BuildContext context) =>
            UserDetailsView(_currentUser),
        '/invites': (BuildContext context) => InvitesMenu(this),
        '/invite_sendcustom': (BuildContext context) => SendCustomInvite(),
        '/invite_setreferrer': (BuildContext context) => SetReferrer(),
        '/topics_menu': (BuildContext context) => TopicsMenu(this),
        '/topics': (BuildContext context) => Topics(),
        '/activities': (BuildContext context) => ActivitiesMenu(this),
        '/feed': (BuildContext context) => Feed(),
        '/friends': (BuildContext context) => Friends(),
        '/users': (BuildContext context) => Users(),
        '/tags': (BuildContext context) => TagSearch(),
        '/followers': (BuildContext context) => Followers(),
        '/postactivity': (BuildContext context) => PostActivity(),
        '/settings': (BuildContext context) => SettingsMenu(this),
        '/notifications_menu': (BuildContext context) =>
            NotificationsMenu(this),
        '/notifications_list': (BuildContext context) => notificationsList,
        '/notifications_filter': (BuildContext context) => notificationsFilter,
        '/notifications_settings': (BuildContext context) =>
            NotificationsSettings(),
        '/send_notification': (BuildContext context) => SendNotification(),
        '/language_menu': (BuildContext context) => LanguageMenu(this),
      },
    );
  }
}
