import 'package:flutter/material.dart';
import 'package:getsocial_flutter_sdk/getsocial_flutter_sdk.dart';
import 'main.dart';

class NotificationsSettings extends StatefulWidget {
  @override
  NotificationsSettingsState createState() {
    return new NotificationsSettingsState();
  }
}

class NotificationsSettingsState extends State<NotificationsSettings> {
  final _formKey = GlobalKey<FormState>();
  var _settingsKey = GlobalKey<FormState>();

  bool pnEnabled = globalArePushNotificationsEnabled;

  @override
  Widget build(BuildContext context) {
    buildContextList.add(context);
    return Form(
        key: _formKey,
        child: new ListView(
            padding: const EdgeInsets.all(10), children: getFormWidget()));
  }

  List<Widget> getFormWidget() {
    List<Widget> formWidget = new List();
    formWidget.add(new Container(
        child: new FlatButton(
          onPressed: () {
            buildContextList.removeLast();
            Navigator.pop(context);
          },
          child: new Text('< Back'),
          color: Colors.white,
        ),
        decoration: new BoxDecoration(
            color: Colors.white,
            border: new Border(bottom: new BorderSide()))));

    formWidget.add(new CheckboxListTile(
        key: _settingsKey,
        title: Text('Push Notifications Enabled'),
        value: pnEnabled,
        onChanged: (bool newValue) => setState(() {
              updateSettings(newValue);
            })));
    return formWidget;
  }

  updateSettings(bool newValue) async {
    Notifications.setPushNotificationsEnabled(newValue).then((value) {
      setState(() {
        pnEnabled = newValue;
        globalArePushNotificationsEnabled = newValue;
      });
    });
  }
}
