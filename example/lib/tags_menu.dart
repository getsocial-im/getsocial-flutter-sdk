import 'package:flutter/material.dart';
import 'package:getsocial_example/base_list.dart';
import 'package:getsocial_example/common.dart';
import 'package:getsocial_example/tags.dart';
import 'package:getsocial_flutter_sdk/getsocial_flutter_sdk.dart';

import 'main.dart';

class TagsMenu extends BaseListView {
  TagsMenu(StateProvider stateProvider) : super(stateProvider);

  @override
  List<ListButton> get buttons => [
        ListButton("< Back", (context) {
          buildContextList.removeLast();
          Navigator.pop(context);
        }),
        ListButton("Search", (context) {
          TagsState.query = null;
          Navigator.pushNamed(context, "/tags");
        }),
        ListButton("Tags followed by me", (context) {
          TagsState.query = TagsQuery.all().followedBy(UserId.currentUser());
          Navigator.pushNamed(context, "/tags");
        }),
      ];

  updateState() {
    stateProvider.updateState();
  }
}
