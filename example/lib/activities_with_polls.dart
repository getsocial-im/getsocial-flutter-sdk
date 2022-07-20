import 'package:flutter/material.dart';
import 'package:getsocial_example/createvote.dart';
import 'package:getsocial_example/main.dart';
import 'package:getsocial_example/uservotes.dart';
import 'package:getsocial_flutter_sdk/getsocial_flutter_sdk.dart';
import 'platform_action_sheet.dart';
import 'common.dart';

class ActivitiesWithPolls extends StatefulWidget {
  @override
  ActivitiesWithPollsState createState() => new ActivitiesWithPollsState();
}

class ActivitiesWithPollsState extends State<ActivitiesWithPolls> {
  static ActivitiesQuery? query;
  static bool canInteract = true;
  List<GetSocialActivity> activities = [];

  @override
  void initState() {
    executeSearch();

    super.initState();
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

  showKnownVoters(int index) async {
    var activity = activities[index];
    var voters = activity.poll?.knownVoters.toString() ?? '';
    showAlert(context, 'Known Voters', voters);
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

    var selectedActivity = activities[index];
    if (selectedActivity.source.isActionAllowed(CommunitiesAction.react)) {
      actions.add(ActionSheetAction(
        text: 'Vote',
        onPressed: () {
          Navigator.pop(context);
          CreateVoteState.activityId = activities[index].id;
          Navigator.pushNamed(context, '/createvote').then((result) {
            if (result != null) {
              executeSearch();
            }
          });
        },
      ));
    }
    actions.add(ActionSheetAction(
        text: 'Show votes',
        onPressed: () {
          Navigator.pop(context);
          UserVotesListState.query =
              VotesQuery.forActivity(activities[index].id);
          Navigator.pushNamed(context, '/uservoteslist');
        }));

    actions.add(ActionSheetAction(
        text: 'Known voters',
        onPressed: () {
          Navigator.pop(context);
          showKnownVoters(index);
        }));

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

  executeSearch() async {
    Communities.getActivities(PagingQuery(query!)).then((value) {
      this.setState(() {
        activities = value.entries;
      });
    }).catchError((error) {
      showAlert(context, 'Error', error.toString());
    });
  }

  updateQuery(int newStatus) async {
    query = query?.withPollStatus(newStatus);
    executeSearch();
  }

  String getTotalVotes(GetSocialActivity activity) {
    var totalVotes = activity.poll?.totalVotes;
    return '$totalVotes';
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
          child: Row(children: [
            TextButton(
              onPressed: () => updateQuery(PollStatus.withPoll),
              child: Text('All'),
              style: TextButton.styleFrom(
                  backgroundColor: Colors.blue, primary: Colors.white),
            ),
            Spacer(),
            TextButton(
              onPressed: () => updateQuery(PollStatus.notVotedByMe),
              child: Text('Not Voted'),
              style: TextButton.styleFrom(
                  backgroundColor: Colors.blue, primary: Colors.white),
            ),
            Spacer(),
            TextButton(
              onPressed: () => updateQuery(PollStatus.votedByMe),
              child: Text('Voted'),
              style: TextButton.styleFrom(
                  backgroundColor: Colors.blue, primary: Colors.white),
            ),
          ]),
        ),
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
                                  child: Text('Total votes: ' +
                                      getTotalVotes(activity)),
                                  alignment: Alignment.centerLeft,
                                ),
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
