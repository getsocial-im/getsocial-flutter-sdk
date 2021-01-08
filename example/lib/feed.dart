import 'package:flutter/material.dart';
import 'package:getsocial_example/main.dart';
import 'package:getsocial_example/postactivity.dart';
import 'package:getsocial_flutter_sdk/getsocial_flutter_sdk.dart';
import 'package:platform_action_sheet/platform_action_sheet.dart';
import 'common.dart';

class Feed extends StatefulWidget {
  @override
  FeedState createState() => new FeedState();
}

class FeedState extends State<Feed> {
  static ActivitiesQuery query;
  static bool isComment = false;
  static bool canInteract = true;
  List<Activity> activities = [];
  CurrentUser currentUser;

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
    }).catchError((error) => showAlert(context, 'Error', error.toString()));
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
        .then((value) => showAlert(
            context, 'Success', isComment ? 'Comment liked' : 'Activity liked'))
        .then((value) => executeSearch())
        .catchError((error) => showAlert(context, 'Error', error.toString()));
  }

  dislikeActivity(int index) async {
    Communities.removeReaction('like', activities[index].id)
        .then((value) => showAlert(context, 'Success',
            isComment ? 'Comment disliked' : 'Activity disliked'))
        .then((value) => executeSearch())
        .catchError((error) => showAlert(context, 'Error', error.toString()));
  }

  removeActivity(int index) async {
    var query = RemoveActivitiesQuery.activityIds([activities[index].id]);
    Communities.removeActivities(query).then((value) {
      this.setState(() {
        activities.removeAt(index);
      });
      showAlert(context, 'Success',
          isComment ? 'Comment removed' : 'Activity removed');
    }).catchError((error) => showAlert(context, 'Error', error.toString()));
  }

  reportActivity(int index) async {
    Communities.reportActivity(
            activities[index].id, ReportingReason.spam, 'Looks like spam')
        .then((value) => {
              showAlert(context, 'Success',
                  isComment ? 'Comment reported' : 'Activity reported')
            })
        .catchError((error) => showAlert(context, 'Error', error.toString()));
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
      print(activities[index].myReactions);
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
    if (currentUser.userId != activities[index].author.userId &&
        activities[index].author.userId != "app") {
      actions.add(ActionSheetAction(
          text: 'Report',
          onPressed: () {
            Navigator.pop(context);
            reportActivity(index);
          }));
    }
    if (currentUser.userId == activities[index].author.userId) {
      actions.add(ActionSheetAction(
          text: 'Remove',
          onPressed: () {
            Navigator.pop(context);
            removeActivity(index);
          }));
    }
    if (currentUser.userId == activities[index].author.userId) {
      actions.add(ActionSheetAction(
          text: 'Edit',
          onPressed: () {
            Navigator.pop(context);
            PostActivityState.oldActivity = activities[index];
            PostActivityState.isComment = FeedState.isComment;
            Navigator.pushNamed(context, "/postactivity");
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
        FeedState.query =
            ActivitiesQuery.commentsToActivity(activities[index].id);
        FeedState.isComment = true;
        Navigator.pushNamed(context, '/feed');
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
        context: context, actions: generatePossibleActions(index));
  }

  showCommentsActionSheet(int index) async {
    PlatformActionSheet().displaySheet(
        context: context, actions: generatePossibleCommentsActions(index));
  }

  executeButtonAction(int index) async {
    var action = activities[index].button.action;
    if (!handleAction(action)) {
      showAlert(context, 'Custom Action', action.toString());
    }
  }

  executeSearch() async {
    Communities.getActivities(PagingQuery(query))
        .then((value) {
          this.setState(() {
            activities = value.entries;
          });
        })
        .then((value) => this.loadAnnouncements())
        .catchError((error) => showAlert(context, 'Error', error.toString()));
  }

  loadAnnouncements() async {
    var aQuery = query.asAnnouncementsQuery();
    if (aQuery == null) {
      return;
    }
    Communities.getAnnouncements(aQuery).then((entries) {
      this.setState(() {
        entries.forEach((element) => activities.insert(0, element));
      });
    }).catchError((error) => showAlert(context, 'Error', error));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
            child: new FlatButton(
              onPressed: () {
                buildContextList.removeLast();
                Navigator.pop(context);
              },
              child: new Text('< Back'),
              color: Colors.white,
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
                                          : activity.text)),
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
                                    ? FlatButton(
                                        child: Text(activity.button.title),
                                        onPressed: () =>
                                            executeButtonAction(index),
                                        color: Colors.green,
                                      )
                                    : Text("")
                              ],
                            ),
                          ),
                          !isComment
                              ? FlatButton(
                                  onPressed: () =>
                                      showCommentsActionSheet(index),
                                  child: Text('Comments'),
                                  color: Colors.blue,
                                )
                              : Text(" "),
                          Text(" "),
                          FlatButton(
                            onPressed: () => showActionSheet(index),
                            child: Text('Actions'),
                            color: Colors.blue,
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
