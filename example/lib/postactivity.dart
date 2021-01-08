import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:getsocial_flutter_sdk/common/media_attachment.dart';
import 'package:getsocial_flutter_sdk/getsocial_flutter_sdk.dart';
import 'package:file_picker/file_picker.dart';
import 'common.dart';
import 'main.dart';

class PostActivity extends StatefulWidget {
  @override
  PostActivityState createState() => new PostActivityState();
}

class PostActivityState extends State<PostActivity> {
  static PostActivityTarget target;
  static Activity oldActivity;
  static bool isComment = false;

  TextEditingController actionDataKeyController = TextEditingController();
  TextEditingController actionDataValueController = TextEditingController();
  TextEditingController customActionController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  String _text = oldActivity != null ? oldActivity.text : null;
  String _imageUrl = oldActivity != null && oldActivity.attachments.isNotEmpty
      ? oldActivity.attachments.first.imageUrl
      : null;
  String _customKey1 = oldActivity != null && oldActivity.properties.isNotEmpty
      ? oldActivity.properties.keys.first
      : null;
  String _customValue1 =
      oldActivity != null && oldActivity.properties.isNotEmpty
          ? oldActivity.properties.values.first
          : null;
  String _customKey2 = oldActivity != null && oldActivity.properties.length == 2
      ? oldActivity.properties.keys.toList()[1]
      : null;
  String _customValue2 =
      oldActivity != null && oldActivity.properties.length == 2
          ? oldActivity.properties.values.toList()[1]
          : null;
  String _action = oldActivity != null &&
          oldActivity.button != null &&
          oldActivity.button.action != null
      ? (['open_profile', 'open_url', 'open_activity', 'open_invites']
              .contains(oldActivity.button.action.type)
          ? oldActivity.button.action.type
          : 'custom')
      : 'default';
  String _buttonTitle = oldActivity != null && oldActivity.button != null
      ? oldActivity.button.title
      : null;

  File _image;
  File _video;

  @override
  void initState() {
    actionDataKeyController.text = oldActivity != null &&
            oldActivity.button != null &&
            oldActivity.button.action.data.isNotEmpty
        ? oldActivity.button.action.data.keys.first
        : null;
    actionDataValueController.text = oldActivity != null &&
            oldActivity.button != null &&
            oldActivity.button.action.data.isNotEmpty
        ? oldActivity.button.action.data.values.first
        : null;
    customActionController.text = oldActivity != null &&
            oldActivity.button != null &&
            oldActivity.button.action != null
        ? oldActivity.button.action.type
        : null;
    super.initState();
  }

  void removeImage() {
    setState(() {
      _image = null;
    });
  }

  void removeVideo() {
    setState(() {
      _video = null;
    });
  }

  Future getImage() async {
    final pickedFile = await FilePicker.getFile(type: FileType.image);
    setState(() {
      _image = File(pickedFile.path);
    });
  }

  Future getVideo() async {
    final pickedFile = await FilePicker.getFile(type: FileType.video);
    setState(() {
      _video = File(pickedFile.path);
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
      decoration: InputDecoration(labelText: 'Text', hintText: 'Text'),
      onChanged: (value) => setState(() {
        _text = value;
      }),
      initialValue: _text,
    ));

    formWidget.add(new TextFormField(
      decoration:
          InputDecoration(labelText: 'Image Url', hintText: 'Remote Url'),
      onChanged: (value) => setState(() {
        _imageUrl = value;
      }),
      initialValue: _imageUrl,
    ));

    formWidget.add(mediaWidget());

    formWidget
        .add(Text('Properties', style: TextStyle(fontWeight: FontWeight.bold)));

    formWidget.add(new TextFormField(
      decoration: InputDecoration(labelText: 'Key1', hintText: 'Key1'),
      onChanged: (value) => setState(() {
        _customKey1 = value;
      }),
      initialValue: _customKey1,
    ));

    formWidget.add(new TextFormField(
      decoration: InputDecoration(labelText: 'Value1', hintText: 'Value1'),
      onChanged: (value) => setState(() {
        _customValue1 = value;
      }),
      initialValue: _customValue1,
    ));

    formWidget.add(new TextFormField(
      decoration: InputDecoration(labelText: 'Key2', hintText: 'Key2'),
      onChanged: (value) => setState(() {
        _customKey2 = value;
      }),
      initialValue: _customKey2,
    ));

    formWidget.add(new TextFormField(
      decoration: InputDecoration(labelText: 'Value2', hintText: 'Value2'),
      onChanged: (value) => setState(() {
        _customValue2 = value;
      }),
      initialValue: _customValue2,
    ));

    formWidget.add(
        Text('Activity button', style: TextStyle(fontWeight: FontWeight.bold)));
    formWidget.add(new TextFormField(
      decoration: InputDecoration(labelText: 'Button title', hintText: 'Title'),
      onChanged: (value) => setState(() {
        _buttonTitle = value;
      }),
      initialValue: _buttonTitle,
    ));
    formWidget.add(DropdownButtonFormField(
        value: _action,
        items: [
          DropdownMenuItem(
            child: Text('Default'),
            value: 'default',
          ),
          DropdownMenuItem(
            child: Text('Custom'),
            value: 'custom',
          ),
          DropdownMenuItem(
            child: Text('Open Profile'),
            value: 'open_profile',
          ),
          DropdownMenuItem(
            child: Text('Open Url'),
            value: 'open_url',
          ),
          // DropdownMenuItem(child: Text('Open Activity'), value: 'open_activity',),
          // DropdownMenuItem(child: Text('Open Invites'), value: 'open_invites',),
        ],
        onChanged: (value) {
          setState(() {
            _action = value;
            if (value == 'open_url') {
              actionDataKeyController.text = '\$url';
            } else if (value == 'open_profile') {
              actionDataKeyController.text = '\$user_id';
            } else if (value == 'custom') {
              actionDataKeyController.text = '';
              customActionController.text = '';
            } else {
              actionDataKeyController.text = '';
            }
            actionDataValueController.text = '';
          });
        }));
    formWidget.add(new TextFormField(
      decoration: InputDecoration(labelText: 'Action name', hintText: 'Name'),
      controller: customActionController,
      enabled: _action == 'custom',
    ));
    formWidget.add(new TextFormField(
      decoration:
          InputDecoration(labelText: 'Action data key', hintText: 'Key'),
      controller: actionDataKeyController,
    ));

    formWidget.add(new TextFormField(
      decoration:
          InputDecoration(labelText: 'Action data value', hintText: 'Value'),
      controller: actionDataValueController,
    ));
    formWidget.add(new RaisedButton(
        onPressed: executePost,
        color: Colors.blue,
        textColor: Colors.white,
        child: Text(oldActivity == null ? 'Create' : 'Update')));

    return formWidget;
  }

  Widget mediaWidget() {
    if (_image == null && _video == null) {
      return Row(
        children: [
          FlatButton(
              child: Text('Add Image'),
              onPressed: () => getImage(),
              color: Colors.orange),
          Padding(padding: EdgeInsets.only(left: 20.0)),
          FlatButton(
              child: Text('Add Video'),
              onPressed: () => getVideo(),
              color: Colors.orange),
        ],
      );
    } else if (_image != null) {
      return Column(children: [
        Container(
            child: Image.file(_image, fit: BoxFit.fill),
            width: 300,
            height: 150),
        FlatButton(
          child: Text('Remove'),
          onPressed: () => removeImage(),
          color: Colors.orange,
        ),
      ]);
    } else if (_video != null) {
      return Column(
        children: [
          Container(
              child:
                  Image.asset('images/video-thumbnail.jpg', fit: BoxFit.fill),
              width: 300,
              height: 150),
          FlatButton(
              child: Text('Remove'),
              onPressed: () => removeVideo(),
              color: Colors.orange),
        ],
      );
    }
    return Row();
  }

  executePost() async {
    ActivityContent content = new ActivityContent();
    if (_text != null && _text.length > 0) {
      content.text = _text;
    }
    if (_imageUrl != null && _imageUrl.length > 0) {
      content.attachments.add(MediaAttachment.withImageUrl(_imageUrl));
    } else if (_image != null) {
      final bytes = await File(_image.path).readAsBytes();
      content.attachments
          .add(MediaAttachment.withBase64Image(base64Encode(bytes)));
    }
    if (_video != null) {
      final bytes = await File(_video.path).readAsBytes();
      content.attachments
          .add(MediaAttachment.withBase64Video(base64Encode(bytes)));
    }
    if (_customKey1 != null && _customValue1 != null) {
      content.properties[_customKey1] = _customValue1;
    }
    if (_customKey2 != null && _customValue2 != null) {
      content.properties[_customKey2] = _customValue2;
    }

    if (_action != 'default') {
      String _actionKey1 = actionDataKeyController.text;
      String _actionValue1 = actionDataValueController.text;
      if (_actionKey1 == null ||
          _actionKey1.length == 0 ||
          _actionValue1 == null ||
          _actionValue1.length == 0) {
        showAlert(context, 'Error', 'Action data key and value must be set');
        return;
      }
      var actionName =
          _action == 'custom' ? customActionController.text : _action;
      Map<String, String> actionData = {};
      actionData[_actionKey1] = _actionValue1;
      content.activityButton =
          ActivityButton(_buttonTitle, GetSocialAction(actionName, actionData));
    }
    if (content.text == null &&
        content.attachments.isEmpty &&
        content.activityButton == null) {
      showAlert(context, 'Error',
          'Either "text", "attachment" or "action" must be set');
      return;
    }
    var postTarget = PostActivityState.target == null
        ? PostActivityTarget.timeline()
        : target;
    if (PostActivityState.oldActivity == null) {
      Communities.postActivity(content, postTarget).then((activity) {
        showAlert(context, 'Success',
            isComment ? 'Comment created' : 'Activity created');
      }).catchError((error) {
        showError(context, error.toString());
        var errorMessage = isComment
            ? 'Failed to create comment, error: '
            : 'Failed to create activity, error: ';
        errorMessage += error.toString();
        showError(context, errorMessage);
      });
    } else {
      Communities.updateActivity(oldActivity.id, content).then((activity) {
        oldActivity = activity;
        showAlert(context, 'Success',
            isComment ? 'Comment updated' : 'Activity updated');
      }).catchError((error) {
        var errorMessage = isComment
            ? 'Failed to update comment, error: '
            : 'Failed to update activity, error: ';
        errorMessage += error.toString();
        showError(context, errorMessage);
      });
    }
  }
}
