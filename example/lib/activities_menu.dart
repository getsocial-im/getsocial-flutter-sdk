import 'package:flutter/material.dart';
import 'package:getsocial_example/base_list.dart';
import 'package:getsocial_example/main.dart';
import 'package:getsocial_example/postactivity.dart';
import 'package:getsocial_flutter_sdk/getsocial_flutter_sdk.dart';
import 'package:getsocial_example/common.dart';
import 'feed.dart';

class ActivitiesMenu extends BaseListView {
  ActivitiesMenu(StateProvider stateProvider) : super(stateProvider);

  editActivity(BuildContext context) async {
    var query = ActivitiesQuery.inAllTopics();
    query.author = UserId.currentUser();
    Communities.getActivities(PagingQuery(query)).then((result) {
      if (result.entries.isEmpty) {
        showAlert(
            context, 'No activities found', 'Please post an activity first');
      } else {
        var activity = result.entries.first;
        PostActivityState.oldActivity = activity;
        PostActivityState.isComment = false;
        Navigator.pushNamed(context, "/postactivity");
      }
    });
  }

  @override
  List<ListButton> get buttons => [
        ListButton("< Back", (context) {
          buildContextList.removeLast();
          Navigator.pop(context);
        }),
        ListButton("Timeline", (context) {
          FeedState.query = ActivitiesQuery.timeline();
          FeedState.isComment = false;
          Navigator.pushNamed(context, "/feed");
        }),
        ListButton("My Feed", (context) {
          FeedState.query = ActivitiesQuery.feedOf(UserId.currentUser());
          FeedState.isComment = false;
          Navigator.pushNamed(context, "/feed");
        }),
        ListButton("My Posts", (context) {
          FeedState.query =
              ActivitiesQuery.everywhere().byUser(UserId.currentUser());
          FeedState.isComment = false;
          Navigator.pushNamed(context, "/feed");
        }),
        ListButton("Post to Timeline", (context) {
          PostActivityState.target = PostActivityTarget.timeline();
          PostActivityState.oldActivity = null;
          PostActivityState.isComment = false;
          Navigator.pushNamed(context, "/postactivity");
        }),
        ListButton("Demo Topic", (context) {
          FeedState.query = ActivitiesQuery.inTopic('demotopic');
          FeedState.isComment = false;
          Navigator.pushNamed(context, "/feed");
        }),
        ListButton("Edit Last Activity", (context) {
          editActivity(context);
        }),
        // ListButton("Post Activity", checkReferralData),
      ];

  updateState() {
    stateProvider.updateState();
  }
}
