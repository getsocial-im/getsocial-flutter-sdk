import 'package:flutter/material.dart';
import 'package:getsocial_flutter_sdk/getsocial_flutter_sdk.dart';
import 'common.dart';
import 'main.dart';

class CreateVote extends StatefulWidget {
  @override
  CreateVoteState createState() => new CreateVoteState();
}

class CreateVoteState extends State<CreateVote> {
  static String? activityId;

  GetSocialActivity? _activity;

  final _formKey = GlobalKey<FormState>();
  List<String> _selectedPollOptions = [];
  List<String> _myVotes = [];

  @override
  void initState() {
    super.initState();
    loadActivity();
  }

  loadActivity() async {
    _selectedPollOptions.clear();
    _myVotes.clear();
    Communities.getActivity(activityId!).then((value) {
      this.setState(() {
        _activity = value;
        value.poll?.options.forEach((element) {
          if (element.isVotedByMe) {
            _selectedPollOptions.add(element.optionId);
            _myVotes.add(element.optionId);
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    buildContextList.add(context);
    return Form(
        key: _formKey,
        child: new ListView(
            padding: const EdgeInsets.all(10), children: getFormWidget()));
  }

  getVoteCount(PollOption option) {
    var count = option.voteCount;
    return '$count';
  }

  bool isRemoveButtonEnabled() {
    bool result = false;
    _myVotes.forEach((element) {
      if (_selectedPollOptions.contains(element)) {
        result = true;
      }
    });
    return result;
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
    formWidget.add(Container(
      child: Row(children: [
        TextButton(
          onPressed: () => addVotes(),
          child: Text('Add'),
          style: TextButton.styleFrom(
              backgroundColor: Colors.blue, primary: Colors.white),
        ),
        Spacer(),
        TextButton(
          onPressed: () => setVotes(),
          child: Text('Set'),
          style: TextButton.styleFrom(
              backgroundColor: Colors.blue, primary: Colors.white),
        ),
        Spacer(),
        TextButton(
          onPressed: isRemoveButtonEnabled() ? () => removeVotes() : null,
          child: Text('Remove'),
          style: TextButton.styleFrom(
              backgroundColor: Colors.blue, primary: Colors.white),
        ),
      ]),
    ));
    _activity?.poll?.options.forEach((element) {
      formWidget.add(new Text('Option ID: ' + element.optionId));
      formWidget.add(new Text('Text: ' + (element.text ?? '')));
      formWidget
          .add(new Text('Image URL: ' + (element.attachment?.imageUrl ?? '')));
      formWidget
          .add(new Text('Video URL: ' + (element.attachment?.videoUrl ?? '')));
      formWidget.add(new Text('Vote count: ' + getVoteCount(element)));
      formWidget.add(new CheckboxListTile(
          value: _selectedPollOptions.contains(element.optionId),
          onChanged: (bool? newValue) => setState(() {
                if (newValue == true) {
                  _selectedPollOptions.add(element.optionId);
                } else {
                  _selectedPollOptions.remove(element.optionId);
                }
              })));
    });
    return formWidget;
  }

  addVotes() async {
    Communities.addVotes(_selectedPollOptions.toSet(), activityId!)
        .then((value) {
      showAlert(context, 'Success', 'Votes added');
      loadActivity();
    }).catchError((error) {
      showAlert(context, 'Error', 'Failed to add votes, error: $error');
    });
  }

  setVotes() async {
    Communities.setVotes(_selectedPollOptions.toSet(), activityId!)
        .then((value) {
      showAlert(context, 'Success', 'Votes set');
      loadActivity();
    }).catchError((error) {
      showAlert(context, 'Error', 'Failed to set votes, error: $error');
    });
  }

  removeVotes() async {
    Communities.removeVotes(_selectedPollOptions.toSet(), activityId!)
        .then((value) {
      showAlert(context, 'Success', 'Votes removed');
      loadActivity();
    }).catchError((error) {
      showAlert(context, 'Error', 'Failed to remove votes, error: $error');
    });
  }
}
