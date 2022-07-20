import 'package:flutter/material.dart';
import 'package:getsocial_example/base_list.dart';
import 'package:getsocial_example/common.dart';
import 'package:getsocial_flutter_sdk/getsocial_flutter_sdk.dart';

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
        ListButton('Manual Init', (context) async {
          bool isInitialized = await GetSocial.isInitialized();
          if (!isInitialized) {
            GetSocial.initWithAppId("m0S9ry0998C04");
          }
        }),
      ];

  updateState() {
    stateProvider.updateState();
  }
}
