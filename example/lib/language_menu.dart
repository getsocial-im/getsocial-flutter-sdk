import 'package:flutter/material.dart';
import 'package:getsocial_example/base_list.dart';
import 'package:getsocial_flutter_sdk/getsocial_flutter_sdk.dart';
import 'package:getsocial_example/common.dart';

import 'main.dart';

class LanguageMenu extends BaseListView {
  LanguageMenu(StateProvider stateProvider) : super(stateProvider);

  getCurrentLanguage(BuildContext context) async {
    GetSocial.getLanguage().then((value) => showAlert(
        context, 'Check current language', 'Current language is "$value"'));
  }

  changeLanguage(BuildContext context, String languageCode) async {
    GetSocial.setLanguage(languageCode)
        .then((value) => showAlert(
            context, 'Success', 'Language changed to "$languageCode"'))
        .catchError((error) => showAlert(context, 'Error', error.toString()));
  }

  @override
  List<ListButton> get buttons => [
        ListButton("< Back", (context) {
          buildContextList.removeLast();
          Navigator.pop(context);
        }),
        ListButton(
            "Current language", (context) => getCurrentLanguage(context)),
        ListButton("Set English", (context) => changeLanguage(context, 'en')),
        ListButton("Set Ukrainian", (context) => changeLanguage(context, 'uk')),
      ];

  updateState() {
    stateProvider.updateState();
  }
}
