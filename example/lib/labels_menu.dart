import 'package:flutter/material.dart';
import 'package:getsocial_example/base_list.dart';
import 'package:getsocial_example/common.dart';
import 'package:getsocial_example/labels.dart';
import 'package:getsocial_flutter_sdk/getsocial_flutter_sdk.dart';

import 'main.dart';

class LabelsMenu extends BaseListView {
  LabelsMenu(StateProvider stateProvider) : super(stateProvider);

  @override
  List<ListButton> get buttons => [
        ListButton("< Back", (context) {
          buildContextList.removeLast();
          Navigator.pop(context);
        }),
        ListButton("Search", (context) {
          LabelsState.query = null;
          Navigator.pushNamed(context, "/labels");
        }),
        ListButton("Labels followed by me", (context) {
          LabelsState.query =
              LabelsQuery.all().followedBy(UserId.currentUser());
          Navigator.pushNamed(context, "/labels");
        }),
      ];

  updateState() {
    stateProvider.updateState();
  }
}
