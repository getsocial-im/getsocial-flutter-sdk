import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:getsocial_example/createpolloption.dart';
import 'package:getsocial_flutter_sdk/getsocial_flutter_sdk.dart';

import 'common.dart';
import 'main.dart';

class CreatePoll extends StatefulWidget {
  @override
  CreatePollState createState() => new CreatePollState();
}

class CreatePollState extends State<CreatePoll> {
  static PostActivityTarget? target;

  final _formKey = GlobalKey<FormState>();
  TextEditingController _endDateController = TextEditingController();

  String? _text;
  DateTime? _endDate;
  bool _allowMultipleVotes = false;
  List<CreatePollOptionState> _options = [];

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
      decoration: InputDecoration(labelText: 'Text', hintText: 'Poll Text'),
      onChanged: (value) => setState(() {
        _text = value;
      }),
      initialValue: _text,
    ));

    formWidget.add(new TextFormField(
        controller: _endDateController,
        enabled: false,
        decoration: InputDecoration(labelText: 'End date', hintText: 'Date')));

    formWidget.add(TextButton(
        onPressed: () {
          DatePicker.showDatePicker(context, showTitleActions: true,
              onConfirm: (date) {
            print('date is ${date.millisecondsSinceEpoch}');
            this.setState(() {
              _endDate = date;
              var year = date.year;
              var month = date.month;
              var day = date.day;
              _endDateController.text = '$year/$month/$day';
            });
          }, currentTime: DateTime.now(), locale: LocaleType.en);
        },
        child: Text(
          'Date Picker',
          style: TextStyle(color: Colors.blue),
        )));

    formWidget.add(new CheckboxListTile(
        title: Text('Allow multiple votes?'),
        value: _allowMultipleVotes,
        onChanged: (bool? newValue) => setState(() {
              _allowMultipleVotes = !_allowMultipleVotes;
            })));

    formWidget.add(new ElevatedButton(
        onPressed: addOption,
        style: ElevatedButton.styleFrom(
            primary: Colors.blue, onPrimary: Colors.white),
        child: Text('Add Option')));

    _options.forEach((element) {
      var widget = element.build(context);
      formWidget.add(widget);
    });
    formWidget.add(new ElevatedButton(
        onPressed: executePost,
        style: ElevatedButton.styleFrom(
            primary: Colors.blue, onPrimary: Colors.white),
        child: Text('Create')));

    return formWidget;
  }

  addOption() async {
    var pollOptionState = CreatePollOption().createState();
    pollOptionState.onRemove = () => {
          this.setState(() {
            _options.remove(pollOptionState);
          })
        };
    this.setState(() {
      _options.add(pollOptionState);
    });
  }

  executePost() async {
    var activityContent = ActivityContent();
    activityContent.text = _text;
    var pollContent = PollContent();
    pollContent.allowMultipleVotes = _allowMultipleVotes;
    pollContent.endDate = _endDate == null
        ? null
        : (_endDate!.millisecondsSinceEpoch / 1000).floor();
    _options.forEach((element) {
      pollContent.options.add(element.getPollOptionContent());
    });
    activityContent.poll = pollContent;
    print(pollContent.toJSON());
    Communities.postActivity(activityContent, target!).then((value) {
      showAlert(context, 'Success', 'Poll created');
      this.setState(() {
        _options.clear();
        _text = null;
        _endDate = null;
        _endDateController.clear();
      });
    }).catchError((error) {
      showAlert(context, 'Error', 'Failed to create poll, error: $error');
    });
  }
}
