import 'package:flutter/material.dart';
import 'package:getsocial_example/base_list.dart';
import 'package:getsocial_example/topics.dart';
import 'package:getsocial_flutter_sdk/getsocial_flutter_sdk.dart';
import 'package:getsocial_example/common.dart';

import 'main.dart';

class TopicsMenu extends BaseListView {
  TopicsMenu(StateProvider stateProvider) : super(stateProvider);

  @override
  List<ListButton> get buttons => [
        ListButton("< Back", (context) {
          buildContextList.removeLast();
          Navigator.pop(context);
        }),
        ListButton("Search", (context) {
          TopicsState.query = null;
          Navigator.pushNamed(context, "/topics");
        }),
        ListButton("Topics followed by me", (context) {
          TopicsState.query =
              TopicsQuery.all().followedBy(UserId.currentUser());
          Navigator.pushNamed(context, "/topics");
        }),
      ];

  updateState() {
    stateProvider.updateState();
  }
}
