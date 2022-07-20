import 'dart:convert';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:getsocial_flutter_sdk/getsocial_flutter_sdk.dart';

import 'base_list.dart';
import 'common.dart';
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
        ListButton("Show Ban Info", showBanInfo),
        ListButton("Change name", changeName),
        ListButton("Change avatar URL", changeAvatarUrl),
        ListButton("Change avatar", changeAvatar),
        ListButton("Add Custom Identity", addCustomIdentity),
        ListButton("Add Trusted Identity", addTrustedIdentity),
        //ListButton("Add Facebook Identity", addFacebookIdentity),
        ListButton("Remove Custom Identity", removeIdentity),
        ListButton("Remove Trusted Identity", removeIdentity),
        //ListButton("Remove Facebook Identity", removeFacebookIdentity),
        ListButton("Add Public Property", addPublicProperty),
        ListButton("Add Private Property", addPrivateProperty),
        ListButton("Remove Public Property", removePublicProperty),
        ListButton("Remove Private Property", removePrivateProperty),
        ListButton("Refresh User Details", refreshUserDetails),
        ListButton("Init with Custom Identity", initWithCustomIdentity),
        ListButton("Init with Trusted Identity", initWithTrustedIdentity),
        ListButton("Reset without Init", resetWithoutInit),
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

  showBanInfo(BuildContext context) async {
    var user = await GetSocial.currentUser;
    if (user != null) {
      bool isBanned = await user.isBanned();

      if (isBanned) {
        var banInfo = await user.getBanInfo();
        showAlert(context, 'Ban Info', 'User is banned "$banInfo"');
      } else {
        showAlert(context, 'Ban Info', 'User is not banned');
      }
    }
  }

  changeName(BuildContext context) async {
    var random = new Random();
    var user = await GetSocial.currentUser;
    var rn = _displayNames[random.nextInt(_displayNames.length - 1)];
    if (user != null) {
      user
          .updateDetails(UserUpdate().updateDisplayName(rn))
          .then((v) => updateState())
          .catchError((error) => {showError(context, error.toString())});
    }
  }

  changeAvatarUrl(BuildContext context) async {
    var user = await GetSocial.currentUser;
    if (user != null) {
      user
          .updateDetails(UserUpdate().updateAvatarUrl(randomAvatarUrl()))
          .then((value) => updateState())
          .catchError((error) => {showError(context, error.toString())});
    }
  }

  changeAvatar(BuildContext context) async {
    var user = await GetSocial.currentUser;
    final result = await FilePicker.platform
        .pickFiles(type: FileType.image, withData: true);
    if (result != null) {
      final bytes = result.files.single.bytes;
      if (bytes != null) {
        var userUpdate = UserUpdate().updateBase64Avatar(base64Encode(bytes));
        user
            ?.updateDetails(userUpdate)
            .then((value) => updateState())
            .catchError((error) => {showError(context, error.toString())});
      } else {
        showError(context, 'Invalid image selected');
      }
    }
  }

  resetWithoutInit(BuildContext context) async {
    GetSocial.reset().then((value) {
      showAlert(context, 'Success', 'User was reset');
      updateState();
    }).catchError((error) {
      showError(context, error.toString());
    });
  }

  refreshUserDetails(BuildContext context) async {
    var user = await GetSocial.currentUser;
    if (user != null) {
      user
          .refresh()
          .then((value) => updateState())
          .catchError((error) => {showError(context, error.toString())});
    }
  }

  initWithCustomIdentity(BuildContext context) async {
    showDialogWithInput(
        context,
        "Init with Custom Identity",
        ["Provider", "UserId", "Token"],
        (inputs) => {
              initWithIdentity(
                  context, Identity.custom(inputs[0], inputs[1], inputs[2]))
            });
  }

  initWithTrustedIdentity(BuildContext context) async {
    showDialogWithInput(
        context,
        "Init with Trusted Identity",
        ["Provider", "Token"],
        (inputs) => {
              initWithIdentity(context, Identity.trusted(inputs[0], inputs[1]))
            });
  }

  initWithIdentity(BuildContext context, Identity identity) async {
    GetSocial.initWithIdentity(identity).then((value) {
      showAlert(context, 'Success', 'Initialized with identity');
    }).catchError((error) {
      showError(context, error.toString());
    });
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

  addTrustedIdentity(BuildContext context) async {
    showDialogWithInput(
        context,
        "Add Identity",
        ["Provider", "Token"],
        (inputs) =>
            {addIdentity(context, Identity.trusted(inputs[0], inputs[1]))});
  }

  addIdentity(BuildContext context, Identity identity) async {
    var user = await GetSocial.currentUser;
    if (user != null) {
      user.addIdentity(
          identity,
          () => {
                showAlert(context, 'Success', 'Identity was added'),
                stateProvider.updateState()
              },
          (conflictUser) => {showConflict(context, conflictUser, identity)},
          (error) => {showError(context, error.toString())});
    }
  }

  showConflict(
      BuildContext context, ConflictUser conflictUser, Identity identity) {
    showDialogWithInput(context, "Change to " + conflictUser.toString(), [],
        (inputs) => {GetSocial.switchUser(identity)});
  }

  logOut(BuildContext context) {
    GetSocial.resetUser().then((value) => globalReferralData = null);
  }

  addFacebookIdentity(BuildContext context) {}

  removeIdentity(BuildContext context) async {
    var user = await GetSocial.currentUser;
    showDialogWithInput(
        context,
        "Enter Provider",
        ["Provider Id"],
        (inputs) => {
              user?.removeIdentity(inputs[0]).then((value) => {
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
                      ?.updateDetails(
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
                      ?.updateDetails(
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
                  ?.updateDetails(UserUpdate().removePublicProperty(inputs[0]))
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
                  ?.updateDetails(UserUpdate().removePrivateProperty(inputs[0]))
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
          Widget okButton = TextButton(
            child: Text("OK"),
            onPressed: () {
              onOk(controllers.map((controller) {
                return controller.text;
              }).toList());
              Navigator.pop(context);
            },
          );

          Widget cancelButton = TextButton(
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
