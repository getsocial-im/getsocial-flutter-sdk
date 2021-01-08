import 'package:flutter/material.dart';
import 'package:getsocial_example/postactivity.dart';
import 'package:getsocial_flutter_sdk/getsocial_flutter_sdk.dart';
import 'common.dart';
import 'package:platform_action_sheet/platform_action_sheet.dart';

import 'feed.dart';
import 'followers.dart';
import 'main.dart';

class Topics extends StatefulWidget {
  @override
  TopicsState createState() => new TopicsState();
}

class TopicsState extends State<Topics> {
  static TopicsQuery query;
  List<Topic> topics = [];
  String searchText;

  @override
  void initState() {
    executeSearch();
    super.initState();
  }

  showDetail(int index) async {
    var createdAt =
        DateTime.fromMillisecondsSinceEpoch(topics[index].createdAt * 1000);
    var updatedAt =
        DateTime.fromMillisecondsSinceEpoch(topics[index].updatedAt * 1000);
    var topicStr = topics[index].toString();
    showAlert(context, 'Details',
        '$topicStr, createdAt: $createdAt, updatedAt: $updatedAt');
  }

  followTopic(int index) {
    var topicId = topics[index].id;
    var query = FollowQuery.topics([topicId]);
    Communities.follow(query).then((result) {
      executeSearch();
      showAlert(context, 'Success', 'Now you follow $result topics');
    }).catchError((error) => showError(context, error.toString()));
  }

  unfollowTopic(int index) {
    var topicId = topics[index].id;
    var query = FollowQuery.topics([topicId]);
    Communities.unfollow(query).then((result) {
      executeSearch();
      showAlert(context, 'Success', 'Now you follow $result topics');
    }).catchError((error) => showError(context, error.toString()));
  }

  List<ActionSheetAction> generatePossibleActions(int index) {
    List<ActionSheetAction> actions = [];
    actions.add(ActionSheetAction(
      text: 'Details',
      onPressed: () => {Navigator.pop(context), showDetail(index)},
      hasArrow: true,
    ));
    actions.add(ActionSheetAction(
      text: 'Show Activities',
      onPressed: () {
        Navigator.pop(context);
        FeedState.query = ActivitiesQuery.inTopic(topics[index].id);
        FeedState.canInteract =
            topics[index].settings.isActionAllowed(CommunitiesAction.react);
        FeedState.isComment = false;
        Navigator.pushNamed(context, '/feed');
      },
      hasArrow: true,
    ));
    actions.add(ActionSheetAction(
      text: (topics[index].isFollowedByMe ? 'Unfollow' : 'Follow'),
      onPressed: () {
        Navigator.pop(context);
        topics[index].isFollowedByMe
            ? unfollowTopic(index)
            : followTopic(index);
      },
    ));
    actions.add(ActionSheetAction(
      text: "Followers",
      onPressed: () {
        FollowersState.query = FollowersQuery.ofTopic(topics[index].id);
        Navigator.pushNamed(context, "/followers");
      },
      hasArrow: true,
    ));
    if (topics[index].settings.isActionAllowed(CommunitiesAction.post)) {
      actions.add(ActionSheetAction(
          text: "Post",
          onPressed: () {
            Navigator.pop(context);
            PostActivityState.target =
                PostActivityTarget.topic(topics[index].id);
            PostActivityState.isComment = false;
            PostActivityState.oldActivity = null;
            Navigator.pushNamed(context, "/postactivity");
          }));
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
    PlatformActionSheet().displaySheet(
        context: context, actions: generatePossibleActions(index));
  }

  executeSearch() async {
    TopicsQuery query = TopicsState.query == null
        ? TopicsQuery.find(searchText)
        : TopicsState.query;
    Communities.getTopics(PagingQuery(query)).then((value) {
      this.setState(() {
        topics = value.entries;
      });
    });
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
        Row(
          children: [
            Expanded(
              child: TextFormField(
                  onChanged: (value) => setState(() {
                        searchText = value;
                      })),
            ),
            RaisedButton(
              onPressed: () {
                TopicsState.query = null;
                executeSearch();
              },
              child: Text('Search'),
            )
          ],
        ),
        Expanded(
            child: ListView.builder(
                padding: const EdgeInsets.all(0),
                itemCount: topics.length,
                itemBuilder: (BuildContext context, int index) {
                  var topic = topics[index];
                  return Container(
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(topic.title),
                          ),
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
