import 'package:flutter/material.dart';
import 'package:getsocial_flutter_sdk/getsocial_flutter_sdk.dart';
import 'common.dart';
import 'platform_action_sheet.dart';

import 'main.dart';

class Friends extends StatefulWidget {
  @override
  FriendsState createState() => new FriendsState();
}

class FriendsState extends State<Friends> {
  static FriendsQuery? query;
  static bool isCurrentUser = false;
  List<User> users = [];
  List<String> followedUsers = [];
  List<String> friends = [];
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

  addFriend(int index) {
    var userId = users[index].userId;
    Communities.addFriends(UserIdList.create([userId]))
        .then((result) =>
            showAlert(context, 'Success', 'Now you have $result friends'))
        .then((value) => loadFollowStatus([userId]))
        .then((value) => loadFriendsStatus([userId]))
        .catchError((error) => showError(context, error.toString()));
  }

  removeFriend(int index) {
    var userId = users[index].userId;
    Communities.removeFriends(UserIdList.create([userId]))
        .then((result) =>
            showAlert(context, 'Success', 'Now you $result friends'))
        .then((value) => executeSearch())
        .catchError((error) => showError(context, error.toString()));
  }

  followUser(int index) {
    var userId = users[index].userId;
    var query = FollowQuery.users(UserIdList.create([userId]));
    Communities.follow(query)
        .then((result) =>
            showAlert(context, 'Success', 'Now you follow $result users'))
        .then((value) => loadFollowStatus([userId]))
        .then((value) => loadFriendsStatus([userId]))
        .catchError((error) => showError(context, error.toString()));
  }

  unfollowUser(int index) {
    var userId = users[index].userId;
    var query = FollowQuery.users(UserIdList.create([userId]));
    Communities.unfollow(query)
        .then((result) =>
            showAlert(context, 'Success', 'Now you follow $result users'))
        .then((value) => loadFollowStatus([userId]))
        .then((value) => loadFriendsStatus([userId]))
        .catchError((error) => showError(context, error.toString()));
  }

  loadFriendsStatus(List<String> userIds) async {
    if (users.isEmpty) {
      return;
    }
    Communities.areFriends(UserIdList.create(userIds)).then((result) {
      this.setState(() {
        if (result.isEmpty) {
          userIds.forEach((userid) {
            friends.remove(userid);
          });
        } else {
          result.forEach((key, value) {
            if (value == true) {
              friends.add(key);
            } else {
              friends.remove(key);
            }
          });
        }
      });
    }).catchError((error) {
      showError(context, error.toString());
    });
  }

  loadFollowStatus(List<String> userIds) async {
    if (users.isEmpty) {
      return;
    }
    var query = FollowQuery.users(UserIdList.create(userIds));
    Communities.isFollowing(UserId.currentUser(), query).then((result) {
      this.setState(() {
        if (result.isEmpty) {
          userIds.forEach((userid) {
            followedUsers.remove(userid);
          });
        } else {
          result.forEach((key, value) {
            if (value == true) {
              followedUsers.add(key);
            } else {
              followedUsers.remove(key);
            }
          });
        }
      });
    }).catchError((error) {
      showError(context, error.toString());
    });
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
        text: (friends.contains(users[index].userId)
            ? 'Remove Friend'
            : 'Add Friend'),
        onPressed: () {
          Navigator.pop(context);
          friends.contains(users[index].userId)
              ? removeFriend(index)
              : addFriend(index);
        },
      ));
      actions.add(ActionSheetAction(
        text: (followedUsers.contains(users[index].userId)
            ? 'Unfollow'
            : 'Follow'),
        onPressed: () {
          Navigator.pop(context);
          followedUsers.contains(users[index].userId)
              ? unfollowUser(index)
              : followUser(index);
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
    Communities.getFriends(PagingQuery(query!))
        .then((value) {
          if (value.entries.isEmpty) {
            showAlert(context, 'Info', 'No friends found');
          }
          this.setState(() {
            users = value.entries;
          });
        })
        .then((value) => loadFollowStatus(users.map((e) => e.userId).toList()))
        .then((value) => loadFriendsStatus(users.map((e) => e.userId).toList()))
        .catchError((error) => showError(context, error.toString()));
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
