import 'package:flutter/material.dart';
import 'package:getsocial_flutter_sdk/getsocial_flutter_sdk.dart';

import 'common.dart';
import 'main.dart';
import 'platform_action_sheet.dart';

class BlockedUsers extends StatefulWidget {
  @override
  BlockedUsersState createState() => new BlockedUsersState();
}

class BlockedUsersState extends State<BlockedUsers> {
  List<User> users = [];
  CurrentUser? currentUser;

  @override
  void initState() {
    getCurrentUser();
    executeSearch();
    super.initState();
  }

  getCurrentUser() async {
    currentUser = await GetSocial.currentUser;
  }

  showDetail(int index) async {
    showAlert(context, 'Details', users[index].toString());
  }

  unblockUser(int index) {
    var userId = users[index].userId;
    Communities.unblockUsers(UserIdList.create([userId])).then((result) {
      showAlert(context, 'Success', 'User unblocked');
      executeSearch();
    }).catchError((error) => showError(context, error.toString()));
  }

  List<ActionSheetAction> generateActions(int index) {
    List<ActionSheetAction> actions = [];
    actions.add(ActionSheetAction(
      text: "Details",
      onPressed: () => {Navigator.pop(context), showDetail(index)},
      hasArrow: true,
    ));
    if (currentUser?.userId != users[index].userId) {
      actions.add(ActionSheetAction(
        text: ('Unblock'),
        onPressed: () {
          Navigator.pop(context);
          unblockUser(index);
        },
      ));
    }
    actions.add(ActionSheetAction(
      text: "Cancel",
      onPressed: () => Navigator.pop(context),
      isCancel: true,
      defaultAction: true,
    ));
    return actions;
  }

  showActionSheet(int index) async {
    PlatformActionSheet()
        .displaySheet(context, Text(''), Text(''), generateActions(index));
  }

  executeSearch() async {
    var query = PagingQuery.simpleQuery();
    Communities.getBlockedUsers(query).then((value) {
      if (value.entries.isEmpty) {
        showAlert(context, 'Info', 'No users found');
      }
      this.setState(() {
        users = value.entries;
      });
    }).catchError((error) => showError(context, error.toString()));
  }

  @override
  Widget build(BuildContext context) {
    buildContextList.add(context);
    return Column(
      children: [
        Container(
            child: new TextButton(
              onPressed: () {
                buildContextList.removeLast();
                Navigator.pop(context);
              },
              child: new Text('< Back'),
              style: TextButton.styleFrom(
                  backgroundColor: Colors.blue, primary: Colors.white),
            ),
            decoration: new BoxDecoration(
                color: Colors.white,
                border: new Border(bottom: new BorderSide()))),
        Expanded(
            child: ListView.builder(
                padding: const EdgeInsets.all(0),
                itemCount: users.length,
                itemBuilder: (BuildContext context, int index) {
                  var user = users[index];
                  return Container(
                      child: Row(
                        children: [
                          Expanded(
                              child: Column(children: [
                            Align(
                                child: Text(user.displayName),
                                alignment: Alignment.centerLeft),
                            Align(
                              child: Text('UserId: ' + user.userId),
                              alignment: Alignment.centerLeft,
                            )
                          ])),
                          TextButton(
                            onPressed: () => showActionSheet(index),
                            child: Text('Actions'),
                            style: TextButton.styleFrom(
                                backgroundColor: Colors.blue,
                                primary: Colors.white),
                          ),
                        ],
                      ),
                      decoration: new BoxDecoration(
                          color: Colors.white,
                          border: new Border(bottom: new BorderSide())));
                })),
      ],
    );
  }
}
