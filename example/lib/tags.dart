import 'package:flutter/material.dart';
import 'package:getsocial_flutter_sdk/getsocial_flutter_sdk.dart';

import 'activities.dart';
import 'common.dart';
import 'followers.dart';
import 'main.dart';
import 'platform_action_sheet.dart';

class Tags extends StatefulWidget {
  @override
  TagsState createState() => new TagsState();
}

class TagsState extends State<Tags> {
  static TagsQuery? query;
  List<Tag> tags = [];
  late String searchText;
  static bool showOnlyTrending = false;

  @override
  void initState() {
    searchText = '';
    executeSearch();
    super.initState();
  }

  showDetail(int index) async {
    var tagStr = tags[index].toString();
    showAlert(context, 'Details', '$tagStr');
  }

  followTag(int index) {
    var tagId = tags[index].name;
    var query = FollowQuery.tags([tagId]);
    Communities.follow(query).then((result) {
      executeSearch();
      showAlert(context, 'Success', 'Now you follow $result tags');
    }).catchError((error) {
      showError(context, error.toString());
    });
  }

  unfollowTag(int index) {
    var tagId = tags[index].name;
    var query = FollowQuery.tags([tagId]);
    Communities.unfollow(query).then((result) {
      executeSearch();
      showAlert(context, 'Success', 'Now you follow $result tags');
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
        ActivitiesState.query = ActivitiesQuery.everywhere()
            .withTag(tags[index].name)
            .withPollStatus(PollStatus.withoutPoll);
        ActivitiesState.isComment = false;
        ActivitiesState.showSearch = true;
        Navigator.pushNamed(context, '/activities');
      },
      hasArrow: true,
    ));
    actions.add(ActionSheetAction(
      text: (tags[index].isFollowedByMe ? 'Unfollow' : 'Follow'),
      onPressed: () {
        Navigator.pop(context);
        tags[index].isFollowedByMe ? unfollowTag(index) : followTag(index);
      },
    ));
    actions.add(ActionSheetAction(
      text: "Followers",
      onPressed: () {
        FollowersState.query = FollowersQuery.ofTag(tags[index].name);
        Navigator.pushNamed(context, "/followers");
      },
      hasArrow: true,
    ));
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

  executeSearch() async {
    TagsQuery query =
        TagsState.query == null ? TagsQuery.find(searchText) : TagsState.query!;
    query = query.onlyTrending(showOnlyTrending);

    Communities.getTags(PagingQuery(query)).then((value) {
      this.setState(() {
        tags = value.entries;
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
                executeSearch();
              },
              child: new Text(showOnlyTrending ? 'All' : 'Only Trending'),
              style: TextButton.styleFrom(
                  backgroundColor: Colors.blue, primary: Colors.white),
            ),
            decoration: new BoxDecoration(
                color: Colors.white,
                border: new Border(bottom: new BorderSide()))),
        TagsState.query == null
            ? Row(
                children: [
                  Expanded(
                    child: TextFormField(
                        onChanged: (value) => setState(() {
                              searchText = value;
                            })),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      executeSearch();
                    },
                    child: Text('Search'),
                  )
                ],
              )
            : SizedBox(
                height: 1,
              ),
        Expanded(
            child: ListView.builder(
                padding: const EdgeInsets.all(0),
                itemCount: tags.length,
                itemBuilder: (BuildContext context, int index) {
                  var tag = tags[index];
                  return Container(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(children: [
                              Align(
                                  child: Text(tag.name),
                                  alignment: Alignment.centerLeft),
                              Align(
                                  child: Text('FollowersCount: ' +
                                      tag.followersCount.toString()),
                                  alignment: Alignment.centerLeft),
                              Align(
                                  child: Text('ActivitiesCount: ' +
                                      tag.activitiesCount.toString()),
                                  alignment: Alignment.centerLeft),
                              Align(
                                  child: Text('Popularity: ' +
                                      tag.popularity.toString()),
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
