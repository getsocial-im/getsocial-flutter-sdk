import 'package:flutter/material.dart';
import 'package:getsocial_example/base_list.dart';
import 'package:getsocial_example/common.dart';
import 'main.dart';

class AnalyticsMenu extends BaseListView {
  AnalyticsMenu(StateProvider stateProvider) : super(stateProvider);

  @override
  List<ListButton> get buttons => [
        ListButton('< Back', (context) {
          buildContextList.removeLast();
          Navigator.pop(context);
        }),
        ListButton('Custom Events',
            (context) => Navigator.pushNamed(context, '/custom_events')),
        ListButton('Purchase Event',
            (context) => Navigator.pushNamed(context, '/purchase_event')),
      ];

  updateState() {
    stateProvider.updateState();
  }
}
