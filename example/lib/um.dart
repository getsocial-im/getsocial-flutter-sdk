import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:getsocial_flutter_sdk/getsocial_flutter_sdk.dart';
import 'base_list.dart';
import 'common.dart';
import 'package:file_picker/file_picker.dart';

import 'main.dart';

class UserManagement extends BaseListView {
  UserManagement(StateProvider stateProvider) : super(stateProvider);

  //d
  @override
  List<ListButton> get buttons => [
        ListButton("< Back", (context) {
          buildContextList.removeLast();
          Navigator.pop(context);
        }),
        ListButton("Show details",
            (context) => Navigator.pushNamed(context, '/um_userdetails')),
        ListButton("Change name", changeName),
        ListButton("Change avatar URL", changeAvatarUrl),
        ListButton("Change avatar", changeAvatar),
        ListButton("Add Custom Identity", addCustomIdentity),
        //ListButton("Add Facebook Identity", addFacebookIdentity),
        ListButton("Remove Custom Identity", removeCustomIdentity),
        //ListButton("Remove Facebook Identity", removeFacebookIdentity),
        ListButton("Add Public Property", addPublicProperty),
        ListButton("Add Private Property", addPrivateProperty),
        ListButton("Remove Public Property", removePublicProperty),
        ListButton("Remove Private Property", removePrivateProperty),
        ListButton("Log out", logOut),
      ];

  final List<String> _displayNames = [
    'Batman',
    'Spiderman',
    'Captain America',
    'Green Lantern',
    'Wolverine',
    'Catwomen',
    'Iron Man',
    'Superman',
    'Wonder Woman',
    'Aquaman'
  ];

  updateState() {
    stateProvider.updateState();
  }

  String randomAvatarUrl() {
    int rn = DateTime.now().millisecondsSinceEpoch;
    return 'http://api.adorable.io/avatars/200/$rn.png';
  }

  changeName(BuildContext context) async {
    var random = new Random();
    var user = await GetSocial.currentUser;
    var rn = _displayNames[random.nextInt(_displayNames.length - 1)];
    user
        .updateDetails(UserUpdate().updateDisplayName(rn))
        .then((v) => updateState())
        .catchError((error) => {showError(context, error.toString())});
  }

  changeAvatarUrl(BuildContext context) async {
    var user = await GetSocial.currentUser;
    user
        .updateDetails(UserUpdate().updateAvatarUrl(randomAvatarUrl()))
        .then((value) => updateState())
        .catchError((error) => {showError(context, error.toString())});
  }

  changeAvatar(BuildContext context) async {
    var user = await GetSocial.currentUser;
    final pickedFile = await FilePicker.getFile(type: FileType.image);
    final bytes = await pickedFile.readAsBytes();
    var userUpdate = UserUpdate().updateBase64Avatar(base64Encode(bytes));
    user
        .updateDetails(userUpdate)
        .then((value) => updateState())
        .catchError((error) => {showError(context, error.toString())});
  }

  addCustomIdentity(BuildContext context) async {
    showDialogWithInput(
        context,
        "Add Identity",
        ["Provider", "UserId", "Token"],
        (inputs) => {
              addIdentity(
                  context, Identity.custom(inputs[0], inputs[1], inputs[2]))
            });
  }

  addIdentity(BuildContext context, Identity identity) async {
    var user = await GetSocial.currentUser;
    user.addIdentity(
        identity,
        () => {
              showAlert(context, 'Success', 'Identity was added'),
              stateProvider.updateState()
            },
        (conflictUser) => {showConflict(context, conflictUser, identity)},
        (error) => {showError(context, error.toString())});
  }

  showConflict(
      BuildContext context, ConflictUser conflictUser, Identity identity) {
    showDialogWithInput(context, "Change to " + conflictUser.toString(), [],
        (inputs) => {GetSocial.switchUser(identity)});
  }

  logOut(BuildContext context) {
    GetSocial.resetUser();
  }

  addFacebookIdentity(BuildContext context) {}

  removeCustomIdentity(BuildContext context) async {
    var user = await GetSocial.currentUser;
    showDialogWithInput(
        context,
        "Enter Provider",
        ["Provider Id"],
        (inputs) => {
              user.removeIdentity(inputs[0]).then((value) => {
                    showAlert(context, 'Success', 'Identity was removed'),
                    updateState()
                  })
            }).catchError((error) => {showError(context, error.toString())});
  }

  removeFacebookIdentity(BuildContext context) {}

  addPublicProperty(BuildContext context) async {
    var user = await GetSocial.currentUser;
    showDialogWithInput(
        context,
        "Update Public Property",
        ["Enter key", "Enter value"],
        (inputs) => {
              if (inputs[1].length == 0)
                {
                  showAlert(context, 'Error',
                      'Setting an empty property is not allowed')
                }
              else
                {
                  user
                      .updateDetails(
                          UserUpdate().setPublicProperty(inputs[0], inputs[1]))
                      .then((v) => {
                            updateState(),
                            showAlert(
                                context, 'Success', 'Public property was added')
                          })
                      .catchError(
                          (error) => {showError(context, error.toString())})
                }
            });
  }

  addPrivateProperty(BuildContext context) async {
    var user = await GetSocial.currentUser;
    showDialogWithInput(
        context,
        "Update Private Property",
        ["Enter key", "Enter value"],
        (inputs) => {
              if (inputs[1].length == 0)
                {
                  showAlert(context, 'Error',
                      'Setting an empty property is not allowed')
                }
              else
                {
                  user
                      .updateDetails(
                          UserUpdate().setPrivateProperty(inputs[0], inputs[1]))
                      .then((v) => {
                            updateState(),
                            showAlert(context, 'Success',
                                'Private property was added')
                          })
                      .catchError(
                          (error) => {showError(context, error.toString())})
                }
            });
  }

  removePublicProperty(BuildContext context) async {
    var user = await GetSocial.currentUser;
    showDialogWithInput(
        context,
        "Remove Public Property",
        ["Enter key"],
        (inputs) => {
              user
                  .updateDetails(UserUpdate().removePublicProperty(inputs[0]))
                  .then((v) => {
                        updateState(),
                        showAlert(
                            context, 'Success', 'Public property was removed')
                      })
                  .catchError((error) => {showError(context, error.toString())})
            });
  }

  removePrivateProperty(BuildContext context) async {
    var user = await GetSocial.currentUser;
    showDialogWithInput(
        context,
        "Remove Private Property",
        ["Enter key"],
        (inputs) => {
              user
                  .updateDetails(UserUpdate().removePrivateProperty(inputs[0]))
                  .then((v) => {
                        updateState(),
                        showAlert(
                            context, 'Success', 'Private property was removed')
                      })
                  .catchError((error) => {showError(context, error.toString())})
            });
  }

  showDialogWithInput(BuildContext context, String title,
      final List<String> inputs, Function(List<String>) onOk) async {
    final controllers = inputs.map((input) {
      return TextEditingController();
    }).toList();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          Widget okButton = FlatButton(
            child: Text("OK"),
            onPressed: () {
              onOk(controllers.map((controller) {
                return controller.text;
              }).toList());
              Navigator.pop(context);
            },
          );

          Widget cancelButton = FlatButton(
            child: Text("Cancel"),
            onPressed: () {
              Navigator.pop(context);
            },
          );

          List<Widget> children = inputs
              .map(
                (input) => TextField(
                  controller: controllers[inputs.indexOf(input)],
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: input,
                  ),
                ),
              )
              .toList();

          // set up the AlertDialog
          return AlertDialog(
              title: Text(title),
              actions: [okButton, cancelButton],
              content: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: children,
                  )));
        });
  }
}
