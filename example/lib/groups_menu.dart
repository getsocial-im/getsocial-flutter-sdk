import 'package:flutter/material.dart';
import 'package:getsocial_example/base_list.dart';
import 'package:getsocial_example/creategroup.dart';
import 'package:getsocial_flutter_sdk/getsocial_flutter_sdk.dart';
import 'package:getsocial_example/common.dart';

import 'groups.dart';
import 'main.dart';

class GroupsMenu extends BaseListView {
  GroupsMenu(StateProvider stateProvider) : super(stateProvider);

  @override
  List<ListButton> get buttons => [
        ListButton("< Back", (context) {
          buildContextList.removeLast();
          Navigator.pop(context);
        }),
        ListButton("Create", (context) {
          CreateGroupState.oldGroup = null;
          Navigator.pushNamed(context, "/creategroup");
        }),
        ListButton("Search", (context) {
          GroupsState.query = null;
          GroupsState.showSearch = true;
          Navigator.pushNamed(context, "/groups");
        }),
        ListButton("My Groups", (context) {
          GroupsState.showSearch = false;
          GroupsState.query =
              GroupsQuery.all().withMember(UserId.currentUser());
          Navigator.pushNamed(context, "/groups");
        }),
      ];

  updateState() {
    stateProvider.updateState();
  }
}
