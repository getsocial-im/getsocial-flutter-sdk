import 'package:flutter/material.dart';
import 'package:getsocial_example/base_list.dart';
import 'package:getsocial_flutter_sdk/getsocial_flutter_sdk.dart';
import 'package:getsocial_example/common.dart';

import 'main.dart';

class CustomEventsMenu extends BaseListView {
  CustomEventsMenu(StateProvider stateProvider) : super(stateProvider);

  trackEvent(BuildContext context, String event,
      Map<String, String> properties) async {
    Analytics.trackCustomEvent(event, properties)
        .then((value) => showAlert(context, 'Success', 'Event tracked'))
        .catchError((error) => showAlert(context, 'Error', error.toString()));
  }

  @override
  List<ListButton> get buttons => [
        ListButton('< Back', (context) {
          buildContextList.removeLast();
          Navigator.pop(context);
        }),
        ListButton(
            'Level completed',
            (context) =>
                trackEvent(context, 'level_completed', {'level': '1'})),
        ListButton('Tutorial completed',
            (context) => trackEvent(context, 'tutorial_completed', {})),
        ListButton(
            'Achievement unlocked',
            (context) => trackEvent(context, 'achievement_unlocked',
                {'achievement': 'early_backer', 'item': 'car001'})),
      ];

  updateState() {
    stateProvider.updateState();
  }
}
