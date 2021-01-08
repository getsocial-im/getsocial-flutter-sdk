import 'package:flutter/material.dart';
import 'package:getsocial_example/common.dart';
import 'package:getsocial_flutter_sdk/getsocial_flutter_sdk.dart';

import 'main.dart';

class SetReferrer extends StatefulWidget {
  @override
  SetReferrerState createState() => new SetReferrerState();
}

class SetReferrerState extends State<SetReferrer> {
  final _formKey = GlobalKey<FormState>();
  var _userIdKey = GlobalKey<FormFieldState>();
  var _providerIdKey = GlobalKey<FormFieldState>();
  var _eventKey = GlobalKey<FormFieldState>();
  var _customDataKey1 = GlobalKey<FormFieldState>();
  var _customDataValue1 = GlobalKey<FormFieldState>();
  var _customDataKey2 = GlobalKey<FormFieldState>();
  var _customDataValue2 = GlobalKey<FormFieldState>();

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

    formWidget.add(new TextFormField(
      key: _userIdKey,
      decoration: InputDecoration(labelText: 'User Id', hintText: 'Id'),
    ));
    formWidget.add(new TextFormField(
      key: _providerIdKey,
      decoration:
          InputDecoration(labelText: 'Provider Id', hintText: 'Provider'),
    ));
    formWidget.add(new TextFormField(
      key: _eventKey,
      decoration: InputDecoration(labelText: 'Event', hintText: 'Event'),
    ));
    formWidget.add(new TextFormField(
      key: _customDataKey1,
      decoration: InputDecoration(labelText: 'Key1', hintText: 'Key1'),
    ));
    formWidget.add(new TextFormField(
      key: _customDataValue1,
      decoration: InputDecoration(labelText: 'Value1', hintText: 'Value1'),
    ));
    formWidget.add(new TextFormField(
      key: _customDataKey2,
      decoration: InputDecoration(labelText: 'Key2', hintText: 'Key2'),
    ));
    formWidget.add(new TextFormField(
      key: _customDataValue2,
      decoration: InputDecoration(labelText: 'Value2', hintText: 'Value2'),
    ));
    formWidget.add(new RaisedButton(
        onPressed: setReferrer,
        color: Colors.blue,
        textColor: Colors.white,
        child: new Text('Set Referrer')));
    return formWidget;
  }

  setReferrer() async {
    UserId userId = UserId.createWithProvider(
        _userIdKey.currentState.value, _providerIdKey.currentState.value);
    Map<String, String> customData = new Map();
    if (_customDataKey1.currentState.value != null &&
        _customDataValue1.currentState.value != null) {
      customData[_customDataKey1.currentState.value] =
          _customDataValue1.currentState.value;
    }
    if (_customDataKey2.currentState.value != null &&
        _customDataValue2.currentState.value != null) {
      customData[_customDataKey2.currentState.value] =
          _customDataValue2.currentState.value;
    }
    Invites.setReferrer(userId, _eventKey.currentState.value, customData)
        .then((value) => showAlert(context, 'Success', 'Referrer was set'))
        .catchError((error) => showError(context, error.toString()));
  }
}
