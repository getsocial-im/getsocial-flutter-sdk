import 'package:flutter/material.dart';
import 'package:getsocial_example/main.dart';
import 'package:getsocial_example/postactivity.dart';
import 'package:getsocial_flutter_sdk/getsocial_flutter_sdk.dart';
import 'activities.dart';
import 'platform_action_sheet.dart';
import 'common.dart';

class Announcements extends StatefulWidget {
  @override
  AnnouncementsState createState() => new AnnouncementsState();
}

class AnnouncementsState extends State<Announcements> {
  static AnnouncementsQuery? query;
  List<GetSocialActivity> activities = [];
  CurrentUser? currentUser;
  static bool canInteract = true;

  @override
  void initState() {
    getCurrentUser();
    executeSearch();

    super.initState();
  }

  getCurrentUser() async {
    currentUser = await GetSocial.currentUser;
  }

  showDetails(int index) async {
    Communities.getActivity(activities[index].id).then((value) {
      var createdAt =
          DateTime.fromMillisecondsSinceEpoch(value.createdAt * 1000);
      var activityStr = value.toString();
      showAlert(context, 'Details', '$activityStr, createdAt: $createdAt');
    }).catchError((error) {
      showAlert(context, 'Error', error.toString());
    });
  }

  showMyReactions(int index) async {
    Communities.getActivity(activities[index].id)
        .then((activity) =>
            showAlert(context, 'My Reactions', activity.myReactions.toString()))
        .catchError((error) => showAlert(context, 'Error', error.toString()));
  }

  showReactions(int index) async {
    var query = ReactionsQuery.forActivity(activities[index].id);
    Communities.getReactions(PagingQuery(query))
        .then(
            (value) => showAlert(context, 'Success', value.entries.toString()))
        .catchError((error) => showAlert(context, 'Error', error.toString()));
  }

  likeActivity(int index) async {
    Communities.addReaction('like', activities[index].id)
        .then((value) => showAlert(context, 'Success', 'Announcement liked'))
        .then((value) => executeSearch())
        .catchError((error) => showAlert(context, 'Error', error.toString()));
  }

  dislikeActivity(int index) async {
    Communities.removeReaction('like', activities[index].id)
        .then((value) => showAlert(context, 'Success', 'Announcement disliked'))
        .then((value) => executeSearch())
        .catchError((error) => showAlert(context, 'Error', error.toString()));
  }

  removeActivity(int index) async {
    var query = RemoveActivitiesQuery.activityIds([activities[index].id]);
    Communities.removeActivities(query).then((value) {
      this.setState(() {
        activities.removeAt(index);
      });
      showAlert(context, 'Success', 'Announcement removed');
    }).catchError((error) {
      showAlert(context, 'Error', error.toString());
    });
  }

  reportActivity(int index) async {
    Communities.reportActivity(
            activities[index].id, ReportingReason.spam, 'Looks like spam')
        .then(
            (value) => {showAlert(context, 'Success', 'Announcement reported')})
        .catchError((error) {
      showAlert(context, 'Error', error.toString());
    });
  }

  List<ActionSheetAction> generatePossibleActions(int index) {
    List<ActionSheetAction> actions = [];
    actions.add(ActionSheetAction(
      text: 'Details',
      onPressed: () {
        Navigator.pop(context);
        showDetails(index);
      },
      hasArrow: true,
    ));
    actions.add(ActionSheetAction(
      text: 'My Reactions',
      onPressed: () {
        Navigator.pop(context);
        showMyReactions(index);
      },
      hasArrow: true,
    ));
    actions.add(ActionSheetAction(
      text: 'Reactions',
      onPressed: () {
        Navigator.pop(context);
        showReactions(index);
      },
      hasArrow: true,
    ));
    if (canInteract) {
      actions.add(ActionSheetAction(
        text: (activities[index].myReactions.contains('like')
            ? 'Dislike'
            : 'Like'),
        onPressed: () {
          Navigator.pop(context);
          activities[index].myReactions.contains('like')
              ? dislikeActivity(index)
              : likeActivity(index);
        },
      ));
    }
    if (currentUser?.userId != activities[index].author.userId &&
        activities[index].author.userId != "app") {
      actions.add(ActionSheetAction(
          text: 'Report',
          onPressed: () {
            Navigator.pop(context);
            reportActivity(index);
          }));
    }
    if (currentUser?.userId == activities[index].author.userId) {
      actions.add(ActionSheetAction(
          text: 'Remove',
          onPressed: () {
            Navigator.pop(context);
            removeActivity(index);
          }));
    }
    if (currentUser?.userId == activities[index].author.userId) {
      actions.add(ActionSheetAction(
          text: 'Edit',
          onPressed: () {
            Navigator.pop(context);
            PostActivityState.oldActivity = activities[index];
            PostActivityState.isComment = false;
            Navigator.pushNamed(context, "/postactivity").then((result) {
              if (result != null) {
                executeSearch();
              }
            });
          }));
    }

    actions.add(ActionSheetAction(
      text: 'Cancel',
      onPressed: () => Navigator.pop(context),
      isCancel: true,
      defaultAction: true,
    ));
    return actions;
  }

  List<ActionSheetAction> generatePossibleCommentsActions(int index) {
    List<ActionSheetAction> actions = [];
    actions.add(ActionSheetAction(
      text: 'View comments',
      onPressed: () {
        Navigator.pop(context);
        ActivitiesState.query =
            ActivitiesQuery.commentsToActivity(activities[index].id);
        ActivitiesState.isComment = true;
        Navigator.pushNamed(context, '/activities');
      },
    ));
    if (canInteract) {
      actions.add(ActionSheetAction(
        text: 'Add comment',
        onPressed: () {
          Navigator.pop(context);
          PostActivityState.target =
              PostActivityTarget.comment(activities[index].id);
          PostActivityState.isComment = true;
          PostActivityState.oldActivity = null;
          Navigator.pushNamed(context, '/postactivity');
        },
      ));
    }

    actions.add(ActionSheetAction(
      text: 'Cancel',
      onPressed: () => Navigator.pop(context),
      isCancel: true,
      defaultAction: true,
    ));
    return actions;
  }

  showActionSheet(int index) async {
    PlatformActionSheet().displaySheet(
        context, Text(''), Text(''), generatePossibleActions(index));
  }

  showCommentsActionSheet(int index) async {
    PlatformActionSheet().displaySheet(
        context, Text(''), Text(''), generatePossibleCommentsActions(index));
  }

  executeButtonAction(int index) async {
    var action = activities[index].button!.action;
    if (!handleAction(action)) {
      showAlert(context, 'Custom Action', action.toString());
    }
  }

  executeSearch() async {
    Communities.getAnnouncements(query!).then((entries) {
      this.setState(() {
        activities = entries;
      });
    }).catchError((error) {
      showAlert(context, 'Error', error.toString());
    });
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
                itemCount: activities.length,
                itemBuilder: (BuildContext context, int index) {
                  var activity = activities[index];
                  return Container(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Align(
                                  child: Text('Id: ' + activity.id),
                                  alignment: Alignment.centerLeft,
                                ),
                                Align(
                                  child: Text('Text: ' +
                                      (activity.text == null
                                          ? 'null'
                                          : activity.text!)),
                                  alignment: Alignment.centerLeft,
                                ),
                                Align(
                                  child: Text(
                                      'Author: ' + activity.author.displayName),
                                  alignment: Alignment.centerLeft,
                                ),
                                Align(
                                    child: Text('Status: ' + activity.status),
                                    alignment: Alignment.centerLeft),
                                Align(
                                    child: Text('Announcement: ' +
                                        activity.isAnnouncement.toString()),
                                    alignment: Alignment.centerLeft),
                                activity.button != null
                                    ? TextButton(
                                        child: Text(activity.button!.title),
                                        onPressed: () =>
                                            executeButtonAction(index),
                                        style: TextButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            primary: Colors.white),
                                      )
                                    : Text("")
                              ],
                            ),
                          ),
                          Text(" "),
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
