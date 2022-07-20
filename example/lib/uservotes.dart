import 'package:flutter/material.dart';
import 'package:getsocial_example/platform_action_sheet.dart';
import 'package:getsocial_flutter_sdk/getsocial_flutter_sdk.dart';

import 'activities.dart';
import 'common.dart';
import 'main.dart';

class UserVotesList extends StatefulWidget {
  @override
  UserVotesListState createState() => new UserVotesListState();
}

class UserVotesListState extends State<UserVotesList> {
  List<UserVotes> votes = [];
  static VotesQuery? query;

  @override
  void initState() {
    executeSearch();
    super.initState();
  }

  executeSearch() async {
    Communities.getVotes(PagingQuery(query)).then((result) {
      this.setState(() {
        votes = result.entries;
      });
    });
  }

  showFeedWithTags(String tag) async {
    Navigator.pop(context);
    ActivitiesState.query = ActivitiesQuery.everywhere().withTag(tag);
    ActivitiesState.canInteract = true;
    ActivitiesState.isComment = false;
    Navigator.pushNamed(context, '/activities');
  }

  showDetails(int index) async {
    showAlert(context, 'Details', votes[index].toString());
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
                itemCount: votes.length,
                itemBuilder: (BuildContext context, int index) {
                  var vote = votes[index];
                  return Container(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(children: [
                              Align(
                                child: Text('User: ' + vote.user.displayName),
                                alignment: Alignment.centerLeft,
                              ),
                              Align(
                                child: Text('Votes: ' + vote.votes.toString()),
                                alignment: Alignment.centerLeft,
                              ),
                            ]),
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
