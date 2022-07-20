import 'package:flutter/material.dart';
import 'package:getsocial_example/addgroupmember.dart';
import 'package:getsocial_flutter_sdk/getsocial_flutter_sdk.dart';
import 'common.dart';
import 'platform_action_sheet.dart';

import 'main.dart';

class GroupMembers extends StatefulWidget {
  @override
  GroupMembersState createState() => new GroupMembersState();
}

class GroupMembersState extends State<GroupMembers> {
  static String? groupId;
  static int? currentUserRole;

  List<GroupMember> members = [];
  CurrentUser? currentUser;

  @override
  void initState() {
    getCurrentUser();
    executeSearch();
    super.initState();
  }

  getCurrentUser() async {
    currentUser = await GetSocial.currentUser;
  }

  showDetail(int index) async {
    showAlert(context, 'Details', members[index].toString());
  }

  removeMember(int index) async {
    GroupMember member = members[index];
    RemoveGroupMembersQuery query = RemoveGroupMembersQuery.create(
        groupId!, UserIdList.create([member.userId]));
    Communities.removeGroupMembers(query).then((result) {
      executeSearch();
      showAlert(context, 'Success', 'Removed user from group');
    }).catchError((error) {
      showError(context, error.toString());
    });
  }

  leaveGroup(int index) async {
    RemoveGroupMembersQuery query = RemoveGroupMembersQuery.create(
        groupId!, UserId.currentUser().asUserIdList());
    Communities.removeGroupMembers(query).then((result) {
      executeSearch();
      currentUserRole = -1;
      showAlert(context, 'Success', 'Removed user from group');
    }).catchError((error) {
      showError(context, error.toString());
    });
  }

  approveMember(int index) async {
    GroupMember member = members[index];
    UpdateGroupMembersQuery query = UpdateGroupMembersQuery.create(
            groupId!, UserIdList.create([member.userId]))
        .withMemberStatus(MemberStatus.member)
        .withRole(Role.member);
    Communities.updateGroupMembers(query).then((result) {
      executeSearch();
      showAlert(context, 'Success', 'Approved user to join to group');
    }).catchError((error) {
      showError(context, error.toString());
    });
  }

  List<ActionSheetAction> generateActions(int index) {
    List<ActionSheetAction> actions = [];
    actions.add(ActionSheetAction(
      text: "Details",
      onPressed: () => {Navigator.pop(context), showDetail(index)},
      hasArrow: true,
    ));
    GroupMember member = members[index];
    if ((currentUserRole == Role.admin || currentUserRole == Role.owner) &&
        member.userId != currentUser?.userId &&
        member.membership.role != Role.owner) {
      actions.add(ActionSheetAction(
        text: 'Remove Member',
        onPressed: () {
          Navigator.pop(context);
          removeMember(index);
        },
      ));
      if (member.membership.status == MemberStatus.approvalPending) {
        actions.add(ActionSheetAction(
          text: 'Approve',
          onPressed: () {
            Navigator.pop(context);
            approveMember(index);
          },
        ));
      }
    }
    if (member.userId == currentUser?.userId && currentUserRole != Role.owner) {
      actions.add(ActionSheetAction(
        text: 'Leave',
        onPressed: () {
          Navigator.pop(context);
          leaveGroup(index);
        },
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
    PlatformActionSheet()
        .displaySheet(context, Text(''), Text(''), generateActions(index));
  }

  executeSearch() async {
    MembersQuery query = MembersQuery.ofGroup(groupId!);
    Communities.getGroupMembers(PagingQuery(query)).then((value) {
      if (value.entries.isEmpty) {
        showAlert(context, 'Info', 'No members found');
      }
      this.setState(() {
        members = value.entries;
      });
    }).catchError((error) {
      showError(context, error.toString());
    });
  }

  String getMemberRole(GroupMember member) {
    switch (member.membership.role) {
      case Role.member:
        return 'Member';
      case Role.owner:
        return 'Owner';
      case Role.admin:
        return 'Admin';
    }
    return 'Unknown';
  }

  String getMemberStatus(GroupMember member) {
    switch (member.membership.status) {
      case MemberStatus.member:
        return 'Member';
      case MemberStatus.approvalPending:
        return 'Approval pending';
      case MemberStatus.invitationPending:
        return 'Invitation pending';
    }
    return 'Unknown';
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
                Navigator.pop(context, {'reload': true});
              },
              child: new Text('< Back'),
              style: TextButton.styleFrom(
                  backgroundColor: Colors.blue, primary: Colors.white),
            ),
            decoration: new BoxDecoration(
                color: Colors.white,
                border: new Border(bottom: new BorderSide()))),
        currentUserRole == Role.admin || currentUserRole == Role.owner
            ? Container(
                child: new TextButton(
                  onPressed: () {
                    AddGroupMemberState.groupId = groupId;
                    Navigator.pushNamed(context, '/addgroupmember')
                        .then((result) {
                      if (result != null) {
                        executeSearch();
                      }
                    });
                  },
                  child: new Text('Add Member'),
                  style: TextButton.styleFrom(
                      backgroundColor: Colors.blue, primary: Colors.white),
                ),
                decoration: new BoxDecoration(
                    color: Colors.white,
                    border: new Border(bottom: new BorderSide())))
            : SizedBox(
                height: 1,
              ),
        Expanded(
            child: ListView.builder(
                padding: const EdgeInsets.all(0),
                itemCount: members.length,
                itemBuilder: (BuildContext context, int index) {
                  var member = members[index];
                  return Container(
                      child: Row(
                        children: [
                          Expanded(
                              child: Column(children: [
                            Align(
                                child: Text(member.displayName),
                                alignment: Alignment.centerLeft),
                            Align(
                              child: Text('UserId: ' + member.userId),
                              alignment: Alignment.centerLeft,
                            ),
                            Align(
                              child: Text('Status: ' + getMemberStatus(member)),
                              alignment: Alignment.centerLeft,
                            ),
                            Align(
                              child: Text('Role: ' + getMemberRole(member)),
                              alignment: Alignment.centerLeft,
                            )
                          ])),
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
