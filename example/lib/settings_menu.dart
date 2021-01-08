import 'package:flutter/material.dart';
import 'package:getsocial_example/base_list.dart';
import 'package:getsocial_example/common.dart';
import 'main.dart';

class SettingsMenu extends BaseListView {
  SettingsMenu(StateProvider stateProvider) : super(stateProvider);

  @override
  List<ListButton> get buttons => [
        ListButton('< Back', (context) {
          buildContextList.removeLast();
          Navigator.pop(context);
        }),
        ListButton('Languages',
            (context) => Navigator.pushNamed(context, '/language_menu')),
        ListButton(
            'Push Notifications',
            (context) =>
                Navigator.pushNamed(context, '/notifications_settings')),
      ];

  updateState() {
    stateProvider.updateState();
  }
}
