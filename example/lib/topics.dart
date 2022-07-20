import 'dart:core';

import 'package:flutter/material.dart';
import 'package:getsocial_flutter_sdk/getsocial_flutter_sdk.dart';

import 'activities.dart';
import 'activities_with_polls.dart';
import 'announcements.dart';
import 'announcements_with_polls.dart';
import 'common.dart';
import 'createpoll.dart';
import 'followers.dart';
import 'main.dart';
import 'platform_action_sheet.dart';
import 'postactivity.dart';

class Topics extends StatefulWidget {
  @override
  TopicsState createState() => new TopicsState();
}

class TopicsState extends State<Topics> {
  static TopicsQuery? query;
  List<Topic> topics = [];
  late String searchText;
  late String searchLabels;
  late String searchProperties;
  static bool showOnlyTrending = false;

  bool _isLoading = true;
  String _nextCursor = '';

  @override
  void initState() {
    searchText = '';
    searchLabels = '';
    searchProperties = '';

    _isLoading = true;
    _nextCursor = '';

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
    }).catchError((error) {
      showError(context, error.toString());
    });
  }

  unfollowTopic(int index) {
    var topicId = topics[index].id;
    var query = FollowQuery.topics([topicId]);
    Communities.unfollow(query).then((result) {
      executeSearch();
      showAlert(context, 'Success', 'Now you follow $result topics');
    }).catchError((error) {
      showError(context, error.toString());
    });
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
        ActivitiesState.query = ActivitiesQuery.inTopic(topics[index].id)
            .withPollStatus(PollStatus.withoutPoll);
        ActivitiesState.canInteract =
            topics[index].settings.isActionAllowed(CommunitiesAction.react);
        ActivitiesState.isComment = false;
        ActivitiesState.showSearch = true;
        Navigator.pushNamed(context, '/activities');
      },
      hasArrow: true,
    ));
    actions.add(ActionSheetAction(
      text: 'Show Announcements',
      onPressed: () {
        Navigator.pop(context);
        AnnouncementsState.query = AnnouncementsQuery.inTopic(topics[index].id)
            .withPollStatus(PollStatus.withoutPoll);
        AnnouncementsState.canInteract =
            topics[index].settings.isActionAllowed(CommunitiesAction.react);
        Navigator.pushNamed(context, '/announcements');
      },
      hasArrow: true,
    ));
    actions.add(ActionSheetAction(
      text: 'Show Activities with Polls',
      onPressed: () {
        Navigator.pop(context);
        ActivitiesWithPollsState.query =
            ActivitiesQuery.inTopic(topics[index].id)
                .withPollStatus(PollStatus.withPoll);
        ActivitiesWithPollsState.canInteract =
            topics[index].settings.isActionAllowed(CommunitiesAction.react);
        Navigator.pushNamed(context, '/activities_with_poll');
      },
      hasArrow: true,
    ));
    actions.add(ActionSheetAction(
      text: 'Show Announcements with Polls',
      onPressed: () {
        Navigator.pop(context);
        AnnouncementsWithPollsState.query =
            AnnouncementsQuery.inTopic(topics[index].id)
                .withPollStatus(PollStatus.withPoll);
        AnnouncementsWithPollsState.canInteract =
            topics[index].settings.isActionAllowed(CommunitiesAction.react);
        Navigator.pushNamed(context, '/announcements_with_poll');
      },
      hasArrow: true,
    ));
    actions.add(ActionSheetAction(
      text: 'Activities created by Me',
      onPressed: () {
        Navigator.pop(context);
        ActivitiesState.query = ActivitiesQuery.inTopic(topics[index].id)
            .byUser(UserId.currentUser())
            .withPollStatus(PollStatus.withoutPoll);
        ActivitiesState.canInteract =
            topics[index].settings.isActionAllowed(CommunitiesAction.react);
        ActivitiesState.isComment = false;
        Navigator.pushNamed(context, '/activities');
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
      actions.add(ActionSheetAction(
          text: "Create Poll",
          onPressed: () {
            Navigator.pop(context);
            CreatePollState.target = PostActivityTarget.topic(topics[index].id);
            Navigator.pushNamed(context, "/createpoll");
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
        context, Text(''), Text(''), generatePossibleActions(index));
  }

  executeSearch({bool fromTop = false}) async {
    _isLoading = true;

    TopicsQuery topicsQuery;
    if (TopicsState.query == null) {
      if (searchText != "") {
        topicsQuery = TopicsQuery.find(searchText);
      } else {
        topicsQuery = TopicsQuery.all();
      }

      if (searchProperties != "") {
        Map<String, String> result = {};
        List<String> props = searchProperties.split(",");
        props.forEach((element) {
          List<String> elements = element.split("=");
          if (elements.length == 2) {
            result[elements[0]] = elements[1];
          }
        });
        topicsQuery = topicsQuery.withProperties(result);
      }

      if (searchLabels != "") {
        topicsQuery = topicsQuery.withLabels(searchLabels.split(","));
      }
    } else {
      topicsQuery = TopicsState.query!;
    }

    topicsQuery = topicsQuery.onlyTrending(showOnlyTrending);

    PagingQuery<TopicsQuery> pq = PagingQuery(topicsQuery);
    if (!fromTop) {
      pq.next = _nextCursor;
    }

    Communities.getTopics(pq).then((value) {
      this.setState(() {
        _isLoading = false;
        _nextCursor = value.next;
        if (!fromTop) {
          topics.addAll(value.entries);
        } else {
          topics = value.entries;
        }
      });
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
        Container(
            child: new TextButton(
              onPressed: () {
                buildContextList.removeLast();
                showOnlyTrending = !showOnlyTrending;
                executeSearch(fromTop: true);
              },
              child: new Text(showOnlyTrending ? 'All' : 'Only Trending'),
              style: TextButton.styleFrom(
                  backgroundColor: Colors.blue, primary: Colors.white),
            ),
            decoration: new BoxDecoration(
                color: Colors.white,
                border: new Border(bottom: new BorderSide()))),
        TopicsState.query == null
            ? Container(
                child: TextField(
                  onChanged: (value) => setState(() {
                    searchText = value;
                  }),
                  onEditingComplete: () {
                    executeSearch(fromTop: true);
                  },
                  decoration: InputDecoration(
                    hintStyle: TextStyle(fontSize: 17),
                    hintText: 'Search',
                    suffixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(10),
                  ),
                ),
              )
            : SizedBox(
                height: 0,
              ),
        TopicsState.query == null
            ? Container(
                child: TextField(
                  onChanged: (value) => setState(() {
                    searchLabels = value;
                  }),
                  onEditingComplete: () {
                    executeSearch(fromTop: true);
                  },
                  decoration: InputDecoration(
                    hintStyle: TextStyle(fontSize: 17),
                    hintText: 'label1,label2',
                    suffixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(10),
                  ),
                ),
              )
            : SizedBox(
                height: 0,
              ),
        TopicsState.query == null
            ? Container(
                child: TextField(
                  onChanged: (value) => setState(() {
                    searchProperties = value;
                  }),
                  onEditingComplete: () {
                    executeSearch(fromTop: true);
                  },
                  decoration: InputDecoration(
                    hintStyle: TextStyle(fontSize: 17),
                    hintText: 'key1=value1,key2=value2',
                    suffixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(10),
                  ),
                ),
              )
            : SizedBox(
                height: 0,
              ),
        Expanded(
            child: ListView.builder(
                itemCount:
                    _nextCursor.isNotEmpty ? topics.length + 1 : topics.length,
                padding: const EdgeInsets.all(0),
                itemBuilder: (BuildContext context, int index) {
                  if (index >= topics.length) {
                    // Don't trigger if one async loading is already under way
                    if (!_isLoading) {
                      executeSearch();
                    }
                    return Center(
                      child: SizedBox(
                        child: CircularProgressIndicator(),
                        height: 24,
                        width: 24,
                      ),
                    );
                  }

                  var topic = topics[index];
                  return Container(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(children: [
                              Align(
                                  child: Text(topic.title ?? '',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  alignment: Alignment.centerLeft),
                              Align(
                                  child: Text('Followers: ' +
                                      topic.followersCount.toString()),
                                  alignment: Alignment.centerLeft),
                              Align(
                                  child: Text('Properties: ' +
                                      topic.settings.properties.toString()),
                                  alignment: Alignment.centerLeft),
                              Align(
                                  child: Text('Labels: ' +
                                      topic.settings.labels.toString()),
                                  alignment: Alignment.centerLeft),
                              Align(
                                  child: Text('Popularity: ' +
                                      topic.popularity.toString()),
                                  alignment: Alignment.centerLeft)
                            ]),
                          ),
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
