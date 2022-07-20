import 'package:flutter/material.dart';
import 'package:getsocial_flutter_sdk/getsocial_flutter_sdk.dart';

import 'activities.dart';
import 'common.dart';
import 'followers.dart';
import 'main.dart';
import 'platform_action_sheet.dart';

class Labels extends StatefulWidget {
  @override
  LabelsState createState() => new LabelsState();
}

class LabelsState extends State<Labels> {
  static LabelsQuery? query;
  List<Label> labels = [];
  late String searchText;
  static bool showOnlyTrending = false;

  @override
  void initState() {
    searchText = '';
    executeSearch();
    super.initState();
  }

  showDetail(int index) async {
    var labelStr = labels[index].toString();
    showAlert(context, 'Details', '$labelStr');
  }

  followLabel(int index) {
    var labelId = labels[index].name;
    var query = FollowQuery.labels([labelId]);
    Communities.follow(query).then((result) {
      executeSearch();
      showAlert(context, 'Success', 'Now you follow $result labels');
    }).catchError((error) {
      showError(context, error.toString());
    });
  }

  unfollowLabel(int index) {
    var labelId = labels[index].name;
    var query = FollowQuery.labels([labelId]);
    Communities.unfollow(query).then((result) {
      executeSearch();
      showAlert(context, 'Success', 'Now you follow $result labels');
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
        ActivitiesState.query =
            ActivitiesQuery.everywhere().withLabels([labels[index].name]);
        ActivitiesState.isComment = false;
        ActivitiesState.showSearch = false;
        Navigator.pushNamed(context, '/activities');
      },
      hasArrow: true,
    ));
    actions.add(ActionSheetAction(
      text: (labels[index].isFollowedByMe ? 'Unfollow' : 'Follow'),
      onPressed: () {
        Navigator.pop(context);
        labels[index].isFollowedByMe
            ? unfollowLabel(index)
            : followLabel(index);
      },
    ));
    actions.add(ActionSheetAction(
      text: "Followers",
      onPressed: () {
        FollowersState.query = FollowersQuery.ofLabel(labels[index].name);
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
    LabelsQuery query = LabelsState.query == null
        ? LabelsQuery.find(searchText)
        : LabelsState.query!;
    query = query.onlyTrending(showOnlyTrending);
    Communities.getLabels(PagingQuery(query)).then((value) {
      this.setState(() {
        labels = value.entries;
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
        LabelsState.query == null
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
                itemCount: labels.length,
                itemBuilder: (BuildContext context, int index) {
                  var label = labels[index];
                  return Container(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(children: [
                              Align(
                                  child: Text(label.name),
                                  alignment: Alignment.centerLeft),
                              Align(
                                  child: Text('FollowersCount: ' +
                                      label.followersCount.toString()),
                                  alignment: Alignment.centerLeft),
                              Align(
                                  child: Text('ActivitiesCount: ' +
                                      label.activitiesCount.toString()),
                                  alignment: Alignment.centerLeft),
                              Align(
                                  child: Text('Popularity: ' +
                                      label.popularity.toString()),
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
