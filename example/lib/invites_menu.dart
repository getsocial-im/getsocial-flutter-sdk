import 'package:flutter/material.dart';
import 'package:getsocial_example/base_list.dart';
import 'package:getsocial_example/main.dart';
import 'package:getsocial_flutter_sdk/getsocial_flutter_sdk.dart';
import 'package:getsocial_example/common.dart';

class InvitesMenu extends BaseListView {
  InvitesMenu(StateProvider stateProvider) : super(stateProvider);

  @override
  List<ListButton> get buttons => [
        ListButton("< Back", (context) {
          buildContextList.removeLast();
          Navigator.pop(context);
        }),
        ListButton("Send Custom Invite",
            (context) => Navigator.pushNamed(context, "/invite_sendcustom")),
        ListButton("Create Invite URL", createURL),
        ListButton("Check Referred Users", checkReferredUsers),
        ListButton("Check Referrer Users", checkReferrerUsers),
        ListButton("Set Referrer",
            (context) => Navigator.pushNamed(context, "/invite_setreferrer")),
        ListButton("Check Referral Data", checkReferralData),
      ];

  updateState() {
    stateProvider.updateState();
  }

  createURL(BuildContext context) async {
    Invites.createURL(null)
        .then((value) => showAlert(context, 'Invite URL', value))
        .catchError((error) => showError(context, error.toString()));
  }

  checkReferredUsers(BuildContext context) async {
    ReferralUsersQuery query = ReferralUsersQuery.allUsers();
    Invites.getReferredUsers(new PagingQuery(query))
        .then((value) =>
            showAlert(context, 'Referred Users', value.entries.toString()))
        .catchError((error) => showError(context, error.toString()));
  }

  checkReferrerUsers(BuildContext context) async {
    ReferralUsersQuery query = ReferralUsersQuery.allUsers();
    Invites.getReferrerUsers(new PagingQuery(query))
        .then((value) =>
            showAlert(context, 'Referrer Users', value.entries.toString()))
        .catchError((error) => showError(context, error.toString()));
  }

  checkReferralData(BuildContext context) {
    if (globalReferralData == null) {
      showAlert(context, 'Referral Data', 'No referral data');
    } else {
      showAlert(context, 'Referral Data', '$globalReferralData');
    }
  }
}
