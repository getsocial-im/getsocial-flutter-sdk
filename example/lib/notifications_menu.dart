import 'package:flutter/material.dart';
import 'package:getsocial_example/base_list.dart';
import 'package:getsocial_example/common.dart';
import 'main.dart';

class NotificationsMenu extends BaseListView {
  NotificationsMenu(StateProvider stateProvider) : super(stateProvider);

  @override
  List<ListButton> get buttons => [
        ListButton("< Back", (context) {
          buildContextList.removeLast();
          Navigator.pop(context);
        }),
        ListButton("Notifications List", (context) {
          Navigator.pushNamed(context, "/notifications_list");
        }),
        ListButton("Send Notification", (context) {
          Navigator.pushNamed(context, "/send_notification");
        }),
      ];

  updateState() {
    stateProvider.updateState();
  }
}
