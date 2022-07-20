import 'package:flutter/material.dart';
import 'package:getsocial_example/creategroup.dart';
import 'package:getsocial_example/groupmembers.dart';
import 'package:getsocial_example/postactivity.dart';
import 'package:getsocial_flutter_sdk/getsocial_flutter_sdk.dart';

import 'activities.dart';
import 'activities_with_polls.dart';
import 'announcements.dart';
import 'announcements_with_polls.dart';
import 'common.dart';
import 'createpoll.dart';
import 'main.dart';
import 'platform_action_sheet.dart';

class Groups extends StatefulWidget {
  @override
  GroupsState createState() => new GroupsState();
}

class GroupsState extends State<Groups> {
  static bool showSearch = true;
  static GroupsQuery? query;
  List<Group> groups = [];
  late String searchText;
  late String searchLabels;
  late String searchProperties;
  static bool showOnlyTrending = false;

  @override
  void initState() {
    searchText = '';
    searchLabels = '';
    searchProperties = '';
    executeSearch();
    super.initState();
  }

  showDetail(int index) async {
    var createdAt =
        DateTime.fromMillisecondsSinceEpoch(groups[index].createdAt * 1000);
    var updatedAt =
        DateTime.fromMillisecondsSinceEpoch(groups[index].updatedAt * 1000);
    var groupStr = groups[index].toString();
    showAlert(context, 'Details',
        '$groupStr, createdAt: $createdAt, updatedAt: $updatedAt');
  }

  followGroup(int index) {
    var groupId = groups[index].id;
    var query = FollowQuery.groups([groupId]);
    Communities.follow(query).then((result) {
      executeSearch();
      showAlert(context, 'Success', 'Now you follow $result groups');
    }).catchError((error) {
      showError(context, error.toString());
    });
  }

  unfollowGroup(int index) {
    var groupId = groups[index].id;
    var query = FollowQuery.groups([groupId]);
    Communities.unfollow(query).then((result) {
      executeSearch();
      showAlert(context, 'Success', 'Now you follow $result groups');
    }).catchError((error) {
      showError(context, error.toString());
    });
  }

  approveInvite(int index) {
    Group group = groups[index];
    Communities.joinGroup(JoinGroupQuery.create(group.id)
            .withInvitationToken(group.membership!.invitationToken!))
        .then((result) {
      executeSearch();
      showAlert(context, 'Success', 'Accepted the invite to join the group');
    }).catchError((error) {
      showError(context, error.toString());
    });
  }

  joinGroup(int index) {
    Group group = groups[index];
    Communities.joinGroup(JoinGroupQuery.create(group.id)).then((result) {
      executeSearch();
      showAlert(context, 'Success', 'Joined to group');
    }).catchError((error) {
      showError(context, error.toString());
    });
  }

  editGroup(int index) {
    CreateGroupState.oldGroup = groups[index];
    Navigator.pushNamed(context, "/creategroup").then((result) {
      if (result != null) {
        executeSearch();
      }
    });
  }

  deleteGroup(int index) {
    Group group = groups[index];
    Communities.removeGroups([group.id]).then((result) {
      executeSearch();
      showAlert(context, 'Success', 'Group deleted');
    }).catchError((error) {
      showError(context, error.toString());
    });
  }

  leaveGroup(int index) {
    Group group = groups[index];
    RemoveGroupMembersQuery query = RemoveGroupMembersQuery.create(
        group.id, UserId.currentUser().asUserIdList());
    Communities.removeGroupMembers(query).then((result) {
      executeSearch();
      showAlert(context, 'Success', 'User left group');
    }).catchError((error) {
      showError(context, error.toString());
    });
  }

  showMembers(int index) {
    Group group = groups[index];
    GroupMembersState.currentUserRole = group.membership?.role;
    GroupMembersState.groupId = group.id;
    Navigator.pushNamed(context, "/groupmembers").then((result) {
      if (result != null) {
        executeSearch();
      }
    });
  }

  List<ActionSheetAction> generatePossibleActions(int index) {
    List<ActionSheetAction> actions = [];
    actions.add(ActionSheetAction(
      text: 'Details',
      onPressed: () => {Navigator.pop(context), showDetail(index)},
      hasArrow: true,
    ));
    Group group = this.groups[index];
    int role = group.membership?.role ?? -1;
    int status = group.membership?.status ?? -1;
    if (!group.settings.isPrivate || status == MemberStatus.member) {
      actions.add(ActionSheetAction(
        text: 'Show Activities',
        onPressed: () {
          Navigator.pop(context);
          ActivitiesState.query = ActivitiesQuery.inGroup(groups[index].id)
              .withPollStatus(PollStatus.withoutPoll);
          ActivitiesState.canInteract =
              groups[index].settings.isActionAllowed(CommunitiesAction.react);
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
          AnnouncementsState.query =
              AnnouncementsQuery.inGroup(groups[index].id)
                  .withPollStatus(PollStatus.withoutPoll);
          AnnouncementsState.canInteract =
              groups[index].settings.isActionAllowed(CommunitiesAction.react);
          Navigator.pushNamed(context, '/announcements');
        },
        hasArrow: true,
      ));
      actions.add(ActionSheetAction(
        text: 'Show Activities with Polls',
        onPressed: () {
          Navigator.pop(context);
          ActivitiesWithPollsState.query =
              ActivitiesQuery.inGroup(groups[index].id)
                  .withPollStatus(PollStatus.withPoll);
          ActivitiesWithPollsState.canInteract =
              groups[index].settings.isActionAllowed(CommunitiesAction.react);
          Navigator.pushNamed(context, '/activities_with_poll');
        },
        hasArrow: true,
      ));
      actions.add(ActionSheetAction(
        text: 'Show Announcements with Polls',
        onPressed: () {
          Navigator.pop(context);
          AnnouncementsWithPollsState.query =
              AnnouncementsQuery.inGroup(groups[index].id)
                  .withPollStatus(PollStatus.withPoll);
          AnnouncementsWithPollsState.canInteract =
              groups[index].settings.isActionAllowed(CommunitiesAction.react);
          Navigator.pushNamed(context, '/announcements_with_poll');
        },
        hasArrow: true,
      ));
      actions.add(ActionSheetAction(
        text: 'Activities created by Me',
        onPressed: () {
          Navigator.pop(context);
          ActivitiesState.query = ActivitiesQuery.inGroup(groups[index].id)
              .byUser(UserId.currentUser())
              .withPollStatus(PollStatus.withoutPoll);
          ActivitiesState.canInteract =
              groups[index].settings.isActionAllowed(CommunitiesAction.react);
          ActivitiesState.isComment = false;
          Navigator.pushNamed(context, '/activities');
        },
        hasArrow: true,
      ));
    }
    if (status == MemberStatus.member) {
      actions.add(ActionSheetAction(
        text: "Show Members",
        onPressed: () {
          Navigator.pop(context);
          showMembers(index);
        },
        hasArrow: true,
      ));
      if (group.settings.isActionAllowed(CommunitiesAction.post)) {
        actions.add(ActionSheetAction(
            text: "Post",
            onPressed: () {
              Navigator.pop(context);
              PostActivityState.target =
                  PostActivityTarget.group(groups[index].id);
              PostActivityState.isComment = false;
              PostActivityState.oldActivity = null;
              Navigator.pushNamed(context, "/postactivity");
            }));
        actions.add(ActionSheetAction(
            text: "Create Poll",
            onPressed: () {
              Navigator.pop(context);
              CreatePollState.target =
                  PostActivityTarget.group(groups[index].id);
              Navigator.pushNamed(context, "/createpoll");
            }));
      }
      if (role == Role.admin || role == Role.owner) {
        actions.add(ActionSheetAction(
          text: "Edit",
          onPressed: () {
            Navigator.pop(context);
            editGroup(index);
          },
          hasArrow: true,
        ));
        actions.add(ActionSheetAction(
          text: "Delete",
          onPressed: () {
            Navigator.pop(context);
            deleteGroup(index);
          },
          hasArrow: true,
        ));
      }
      actions.add(ActionSheetAction(
        text: (groups[index].isFollowedByMe ? 'Unfollow' : 'Follow'),
        onPressed: () {
          Navigator.pop(context);
          groups[index].isFollowedByMe
              ? unfollowGroup(index)
              : followGroup(index);
        },
      ));
    }
    if (group.membership == null) {
      actions.add(ActionSheetAction(
        text: "Join",
        onPressed: () {
          Navigator.pop(context);
          joinGroup(index);
        },
        hasArrow: true,
      ));
    }
    if (group.membership != null && role != Role.owner) {
      actions.add(ActionSheetAction(
        text: "Leave",
        onPressed: () {
          Navigator.pop(context);
          leaveGroup(index);
        },
        hasArrow: true,
      ));
    }
    if (status == MemberStatus.invitationPending) {
      actions.add(ActionSheetAction(
        text: "Approve invitation",
        onPressed: () {
          Navigator.pop(context);
          approveInvite(index);
        },
        hasArrow: true,
      ));
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

  executeSearch() async {
    GroupsQuery groupsQuery;
    if (GroupsState.query == null) {
      if (searchText != "") {
        groupsQuery = GroupsQuery.find(searchText);
      } else {
        groupsQuery = GroupsQuery.all();
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
        groupsQuery = groupsQuery.withProperties(result);
      }

      if (searchLabels != "") {
        groupsQuery = groupsQuery.withLabels(searchLabels.split(","));
      }
    } else {
      groupsQuery = GroupsState.query!;
    }

    groupsQuery = groupsQuery.onlyTrending(showOnlyTrending);
    Communities.getGroups(PagingQuery(groupsQuery)).then((value) {
      this.setState(() {
        groups = value.entries;
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
        showSearch
            ? Container(
                child: TextField(
                  onChanged: (value) => setState(() {
                    searchText = value;
                  }),
                  onEditingComplete: () {
                    executeSearch();
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
        showSearch
            ? Container(
                child: TextField(
                  onChanged: (value) => setState(() {
                    searchLabels = value;
                  }),
                  onEditingComplete: () {
                    executeSearch();
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
        showSearch
            ? Container(
                child: TextField(
                  onChanged: (value) => setState(() {
                    searchProperties = value;
                  }),
                  onEditingComplete: () {
                    executeSearch();
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
                padding: const EdgeInsets.all(0),
                itemCount: groups.length,
                itemBuilder: (BuildContext context, int index) {
                  var group = groups[index];
                  return Container(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(children: [
                              Align(
                                  child: Text(group.title ?? '',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  alignment: Alignment.centerLeft),
                              Align(
                                  child: Text('Members: ' +
                                      group.membersCount.toString()),
                                  alignment: Alignment.centerLeft),
                              Align(
                                  child: Text('Followers: ' +
                                      group.followersCount.toString()),
                                  alignment: Alignment.centerLeft),
                              Align(
                                  child: Text('Properties: ' +
                                      group.settings.properties.toString()),
                                  alignment: Alignment.centerLeft),
                              Align(
                                  child: Text('Labels: ' +
                                      group.settings.labels.toString()),
                                  alignment: Alignment.centerLeft),
                              Align(
                                  child: Text('Popularity: ' +
                                      group.popularity.toString()),
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
