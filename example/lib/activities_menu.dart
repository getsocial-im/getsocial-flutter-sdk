import 'package:flutter/material.dart';
import 'package:getsocial_example/base_list.dart';
import 'package:getsocial_example/common.dart';
import 'package:getsocial_example/main.dart';
import 'package:getsocial_example/postactivity.dart';
import 'package:getsocial_flutter_sdk/getsocial_flutter_sdk.dart';

import 'activities.dart';

class ActivitiesMenu extends BaseListView {
  ActivitiesMenu(StateProvider stateProvider) : super(stateProvider);

  editActivity(BuildContext context) async {
    var query = ActivitiesQuery.everywhere();
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
          ActivitiesState.query =
              ActivitiesQuery.timeline().withPollStatus(PollStatus.withoutPoll);
          ActivitiesState.isComment = false;
          Navigator.pushNamed(context, "/activities");
        }),
        ListButton("My Feed", (context) {
          ActivitiesState.query = ActivitiesQuery.feedOf(UserId.currentUser())
              .withPollStatus(PollStatus.withoutPoll);
          ActivitiesState.isComment = false;
          Navigator.pushNamed(context, "/activities");
        }),
        ListButton("My Posts", (context) {
          ActivitiesState.query = ActivitiesQuery.everywhere()
              .byUser(UserId.currentUser())
              .withPollStatus(PollStatus.withoutPoll);
          ActivitiesState.isComment = false;
          Navigator.pushNamed(context, "/activities");
        }),
        ListButton("Post to Timeline", (context) {
          PostActivityState.target = PostActivityTarget.timeline();
          PostActivityState.oldActivity = null;
          PostActivityState.isComment = false;
          Navigator.pushNamed(context, "/postactivity");
        }),
        ListButton("Demo Topic", (context) {
          ActivitiesState.query = ActivitiesQuery.inTopic('demotopic')
              .withPollStatus(PollStatus.withoutPoll);
          ActivitiesState.isComment = false;
          ActivitiesState.showSearch = true;
          Navigator.pushNamed(context, "/activities");
        }),
        ListButton("Edit Last Activity", (context) {
          editActivity(context);
        }),
        ListButton("All App mentions", (context) {
          ActivitiesState.query = ActivitiesQuery.everywhere()
              .withMentions([UserId.createForApp()]);
          ActivitiesState.isComment = false;
          ActivitiesState.showSearch = false;
          Navigator.pushNamed(context, "/activities");
        }),
        ListButton("All Bookmarks", (context) {
          ActivitiesState.query = ActivitiesQuery.bookmarkedActivities();
          ActivitiesState.isComment = false;
          ActivitiesState.showSearch = false;
          Navigator.pushNamed(context, "/activities");
        }),
        ListButton("All reacted activities", (context) {
          ActivitiesState.query = ActivitiesQuery.reactedActivities(null);
          ActivitiesState.isComment = false;
          ActivitiesState.showSearch = false;
          Navigator.pushNamed(context, "/activities");
        }),
        ListButton("All liked activities", (context) {
          ActivitiesState.query = ActivitiesQuery.reactedActivities(["like"]);
          ActivitiesState.isComment = false;
          ActivitiesState.showSearch = false;
          Navigator.pushNamed(context, "/activities");
        }),
        ListButton("All voted activities", (context) {
          ActivitiesState.query = ActivitiesQuery.votedActivities(null);
          ActivitiesState.isComment = false;
          ActivitiesState.showSearch = false;
          Navigator.pushNamed(context, "/activities");
        }),
        // ListButton("Post Activity", checkReferralData),
      ];

  updateState() {
    stateProvider.updateState();
  }
}
