import 'package:flutter/material.dart';
import 'package:getsocial_flutter_sdk/getsocial_flutter_sdk.dart';
import 'common.dart';
import 'main.dart';

class AddGroupMember extends StatefulWidget {
  @override
  AddGroupMemberState createState() => new AddGroupMemberState();
}

class AddGroupMemberState extends State<AddGroupMember> {
  static String? groupId;

  final _formKey = GlobalKey<FormState>();
  String? _userId;
  String? _providerId;

  List<bool> memberRole = [true, false];
  List<bool> memberStatus = [true, false];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    buildContextList.add(context);
    return Form(
        key: _formKey,
        child: new ListView(
            padding: const EdgeInsets.all(10), children: getFormWidget()));
  }

  List<Widget> getFormWidget() {
    List<Widget> formWidget = List.empty(growable: true);
    formWidget.add(new Container(
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
            border: new Border(bottom: new BorderSide()))));

    formWidget.add(new TextFormField(
      decoration: InputDecoration(labelText: 'User ID', hintText: 'User ID'),
      onChanged: (value) => setState(() {
        _userId = value;
      }),
      initialValue: _userId,
    ));

    formWidget.add(new TextFormField(
      decoration:
          InputDecoration(labelText: 'Provider ID', hintText: 'Provider ID'),
      onChanged: (value) => setState(() {
        _providerId = value;
      }),
      initialValue: _providerId,
    ));

    formWidget.add(Text('Role', style: TextStyle(fontWeight: FontWeight.bold)));
    formWidget.add(new ToggleButtons(
      children: [
        Text('Admin', style: TextStyle(fontWeight: FontWeight.bold)),
        Text('Member', style: TextStyle(fontWeight: FontWeight.bold)),
      ],
      onPressed: (index) => setState(() {
        for (int buttonIndex = 0;
            buttonIndex < this.memberRole.length;
            buttonIndex++) {
          if (buttonIndex == index) {
            this.memberRole[buttonIndex] = true;
          } else {
            this.memberRole[buttonIndex] = false;
          }
        }
      }),
      isSelected: this.memberRole,
    ));

    formWidget
        .add(Text('Status', style: TextStyle(fontWeight: FontWeight.bold)));

    formWidget.add(new ToggleButtons(
      children: [
        Text('Invite', style: TextStyle(fontWeight: FontWeight.bold)),
        Text('Member', style: TextStyle(fontWeight: FontWeight.bold)),
      ],
      onPressed: (index) => setState(() {
        for (int buttonIndex = 0;
            buttonIndex < this.memberStatus.length;
            buttonIndex++) {
          if (buttonIndex == index) {
            this.memberStatus[buttonIndex] = true;
          } else {
            this.memberStatus[buttonIndex] = false;
          }
        }
      }),
      isSelected: this.memberStatus,
    ));

    formWidget.add(new ElevatedButton(
        onPressed: executeAdd,
        style: ElevatedButton.styleFrom(
            primary: Colors.blue, onPrimary: Colors.white),
        child: Text('Add')));

    return formWidget;
  }

  executeAdd() async {
    if (_userId == null || _userId!.isEmpty) {
      showAlert(context, 'Error', 'User ID is mandatory');
      return;
    }

    int role = Role.admin;
    int status = MemberStatus.member;
    for (int buttonIndex = 0;
        buttonIndex < this.memberRole.length;
        buttonIndex++) {
      if (this.memberRole[buttonIndex] == true) {
        if (buttonIndex == 0) {
          role = Role.admin;
        }
        if (buttonIndex == 1) {
          role = Role.member;
        }
      }
    }
    for (int buttonIndex = 0;
        buttonIndex < this.memberStatus.length;
        buttonIndex++) {
      if (this.memberStatus[buttonIndex] == true) {
        if (buttonIndex == 0) {
          status = MemberStatus.invitationPending;
        }
        if (buttonIndex == 1) {
          status = MemberStatus.member;
        }
      }
    }
    UserIdList userIdList = (_providerId == null || _providerId!.isEmpty)
        ? UserIdList.create([_userId!])
        : UserIdList.createWithProvider([_userId!], _providerId!);
    AddGroupMembersQuery query =
        AddGroupMembersQuery.create(groupId!, userIdList)
            .withRole(role)
            .withMemberStatus(status);

    Communities.addGroupMembers(query).then((member) {
      showAlert(context, 'Success', 'Group member added');
    }).catchError((error) {
      var errorMessage =
          'Failed to add group member, error: ' + error.toString();
      showError(context, errorMessage);
    });
  }
}
