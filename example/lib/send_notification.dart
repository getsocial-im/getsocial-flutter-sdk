import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:getsocial_flutter_sdk/common/media_attachment.dart';
import 'package:getsocial_flutter_sdk/getsocial_flutter_sdk.dart';
import 'package:file_picker/file_picker.dart';
import 'common.dart';
import 'main.dart';

class SendNotification extends StatefulWidget {
  @override
  SendNotificationState createState() => new SendNotificationState();
}

class SendNotificationState extends State<SendNotification> {
  static SendNotificationTarget target;

  TextEditingController actionDataKeyController = TextEditingController();
  TextEditingController actionDataValueController = TextEditingController();
  TextEditingController customActionController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  String _templateName;
  String _text;
  String _title;
  String _textColor;
  String _titleColor;
  String _imageUrl;
  String _videoUrl;
  String _backgroundImageUrl;
  String _templateDataKey1;
  String _templateDataValue1;
  String _templateDataKey2;
  String _templateDataValue2;

  String _action = 'no_action';
  String _actionButtonTitle1;
  String _actionButtonActionId1;

  String _actionButtonTitle2;
  String _actionButtonActionId2;

  File _image;
  File _video;

  String _actionDataKey1;
  String _actionDataValue1;
  String _actionDataKey2;
  String _actionDataValue2;

  String _badgeCount;
  String _badgeIncrease;

  bool _sendToFriends = false;
  bool _sendToReferrer = false;
  bool _sendToReferredUsers = false;

  String _userId1;
  String _userId2;

  @override
  void initState() {
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
      decoration: InputDecoration(
          labelText: 'Template name', hintText: 'Template name'),
      onChanged: (value) => setState(() {
        _templateName = value;
      }),
      initialValue: _templateName,
    ));

    formWidget.add(
        Text('Template Data', style: TextStyle(fontWeight: FontWeight.bold)));

    formWidget.add(new TextFormField(
      decoration: InputDecoration(labelText: 'Key1', hintText: 'Key1'),
      onChanged: (value) => setState(() {
        _templateDataKey1 = value;
      }),
      initialValue: _templateDataKey1,
    ));

    formWidget.add(new TextFormField(
      decoration: InputDecoration(labelText: 'Value1', hintText: 'Value1'),
      onChanged: (value) => setState(() {
        _templateDataValue1 = value;
      }),
      initialValue: _templateDataValue1,
    ));

    formWidget.add(new TextFormField(
      decoration: InputDecoration(labelText: 'Key2', hintText: 'Key2'),
      onChanged: (value) => setState(() {
        _templateDataKey2 = value;
      }),
      initialValue: _templateDataKey2,
    ));

    formWidget.add(new TextFormField(
      decoration: InputDecoration(labelText: 'Value2', hintText: 'Value2'),
      onChanged: (value) => setState(() {
        _templateDataValue2 = value;
      }),
      initialValue: _templateDataValue2,
    ));

    formWidget
        .add(Text('Content', style: TextStyle(fontWeight: FontWeight.bold)));

    formWidget.add(new TextFormField(
      decoration: InputDecoration(
          labelText: 'Notification Text', hintText: 'Notification Text'),
      onChanged: (value) => setState(() {
        _text = value;
      }),
      initialValue: _text,
    ));

    formWidget.add(new TextFormField(
      decoration:
          InputDecoration(labelText: 'Title', hintText: 'Notification Title'),
      onChanged: (value) => setState(() {
        _title = value;
      }),
      initialValue: _title,
    ));

    formWidget.add(new TextFormField(
      decoration:
          InputDecoration(labelText: 'Image Url', hintText: 'Image Url'),
      onChanged: (value) => setState(() {
        _imageUrl = value;
      }),
      initialValue: _imageUrl,
    ));

    formWidget.add(new TextFormField(
      decoration:
          InputDecoration(labelText: 'Video Url', hintText: 'Video Url'),
      onChanged: (value) => setState(() {
        _videoUrl = value;
      }),
      initialValue: _videoUrl,
    ));

    formWidget.add(mediaWidget());

    formWidget
        .add(Text('Action', style: TextStyle(fontWeight: FontWeight.bold)));

    formWidget.add(DropdownButtonFormField(
        value: _action,
        items: [
          DropdownMenuItem(
            child: Text('No Action'),
            value: 'no_action',
          ),
          DropdownMenuItem(
            child: Text('Default'),
            value: 'default',
          ),
          DropdownMenuItem(
            child: Text('Add Friend'),
            value: 'add_friend',
          ),
          DropdownMenuItem(
            child: Text('Custom'),
            value: 'custom',
          ),
          DropdownMenuItem(
            child: Text('Open Activity'),
            value: 'open_activity',
          ),
          DropdownMenuItem(
            child: Text('Open Invite'),
            value: 'open_invite',
          ),
          DropdownMenuItem(
            child: Text('Open Profile'),
            value: 'open_profile',
          ),
          DropdownMenuItem(
            child: Text('Open Url'),
            value: 'open_url',
          ),
        ],
        onChanged: (value) {
          setState(() {
            _action = value;
            if (value == 'open_url') {
              actionDataKeyController.text = '\$url';
            } else if (value == 'open_profile') {
              actionDataKeyController.text = '\$user_id';
            } else if (value == 'open_activity') {
              actionDataKeyController.text = '\$activity_id';
            } else if (value == 'add_friend') {
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

    formWidget.add(
        Text('Action Buttons', style: TextStyle(fontWeight: FontWeight.bold)));

    formWidget.add(new TextFormField(
      decoration:
          InputDecoration(labelText: 'Button 1 Title', hintText: 'Title'),
      onChanged: (value) => setState(() {
        _actionButtonTitle1 = value;
      }),
      initialValue: _actionButtonTitle1,
    ));

    formWidget.add(new TextFormField(
      decoration: InputDecoration(
          labelText: 'Button 1 Action Id', hintText: 'Action Id'),
      onChanged: (value) => setState(() {
        _actionButtonActionId1 = value;
      }),
      initialValue: _actionButtonActionId1,
    ));

    formWidget.add(new TextFormField(
      decoration:
          InputDecoration(labelText: 'Button 2 Title', hintText: 'Title'),
      onChanged: (value) => setState(() {
        _actionButtonTitle2 = value;
      }),
      initialValue: _actionButtonTitle2,
    ));

    formWidget.add(new TextFormField(
      decoration: InputDecoration(
          labelText: 'Button 2 Action Id', hintText: 'Action Id'),
      onChanged: (value) => setState(() {
        _actionButtonActionId2 = value;
      }),
      initialValue: _actionButtonActionId2,
    ));

    formWidget.add(Text('Notification Data',
        style: TextStyle(fontWeight: FontWeight.bold)));

    formWidget.add(new TextFormField(
      decoration: InputDecoration(labelText: 'Data 1 Key', hintText: 'Key'),
      onChanged: (value) => setState(() {
        _actionDataKey1 = value;
      }),
      initialValue: _actionDataKey1,
    ));

    formWidget.add(new TextFormField(
      decoration: InputDecoration(labelText: 'Data 1 Value', hintText: 'Value'),
      onChanged: (value) => setState(() {
        _actionDataValue1 = value;
      }),
      initialValue: _actionDataValue1,
    ));

    formWidget.add(new TextFormField(
      decoration: InputDecoration(labelText: 'Data 2 Key', hintText: 'Key'),
      onChanged: (value) => setState(() {
        _actionDataKey2 = value;
      }),
      initialValue: _actionDataKey2,
    ));

    formWidget.add(new TextFormField(
      decoration: InputDecoration(labelText: 'Data 2 Value', hintText: 'Value'),
      onChanged: (value) => setState(() {
        _actionDataValue2 = value;
      }),
      initialValue: _actionDataValue2,
    ));

    formWidget.add(
        Text('Customization', style: TextStyle(fontWeight: FontWeight.bold)));

    formWidget.add(new TextFormField(
      decoration: InputDecoration(
          labelText: 'Background Image', hintText: 'Background Image'),
      onChanged: (value) => setState(() {
        _backgroundImageUrl = value;
      }),
      initialValue: _backgroundImageUrl,
    ));

    formWidget.add(new TextFormField(
      decoration:
          InputDecoration(labelText: 'Title Color', hintText: 'Title Color'),
      onChanged: (value) => setState(() {
        _titleColor = value;
      }),
      initialValue: _titleColor,
    ));

    formWidget.add(new TextFormField(
      decoration:
          InputDecoration(labelText: 'Text Color', hintText: 'Text Color'),
      onChanged: (value) => setState(() {
        _textColor = value;
      }),
      initialValue: _textColor,
    ));

    // formWidget
    //     .add(Text('Badge', style: TextStyle(fontWeight: FontWeight.bold)));
    //
    // formWidget.add(new TextFormField(
    //   decoration:
    //   InputDecoration(labelText: 'Badge Count', hintText: 'Badge Count'),
    //   onChanged: (value) => setState(() {
    //     _badgeCount = value;
    //   }),
    //   keyboardType: TextInputType.number,
    //   initialValue: _badgeCount,
    // ));
    //
    // formWidget.add(new TextFormField(
    //   decoration:
    //   InputDecoration(labelText: 'Badge Increase', hintText: 'Badge Increase'),
    //   onChanged: (value) => setState(() {
    //     _badgeIncrease = value;
    //   }),
    //   keyboardType: TextInputType.number,
    //   initialValue: _badgeIncrease,
    // ));

    formWidget
        .add(Text('Recipients', style: TextStyle(fontWeight: FontWeight.bold)));

    formWidget.add(new SwitchListTile(
      title: Text("Friends"),
      onChanged: (value) => setState(() {
        _sendToFriends = value;
      }),
      value: _sendToFriends,
    ));

    formWidget.add(new SwitchListTile(
      title: Text("Referrer"),
      onChanged: (value) => setState(() {
        _sendToReferrer = value;
      }),
      value: _sendToReferrer,
    ));

    formWidget.add(new SwitchListTile(
      title: Text("Referred Users"),
      onChanged: (value) => setState(() {
        _sendToReferredUsers = value;
      }),
      value: _sendToReferredUsers,
    ));

    formWidget.add(new TextFormField(
      decoration: InputDecoration(labelText: 'User Id 1', hintText: 'User Id'),
      onChanged: (value) => setState(() {
        _userId1 = value;
      }),
      initialValue: _userId1,
    ));

    formWidget.add(new TextFormField(
      decoration: InputDecoration(labelText: 'User Id 2', hintText: 'User Id'),
      onChanged: (value) => setState(() {
        _userId2 = value;
      }),
      initialValue: _userId2,
    ));

    formWidget.add(new RaisedButton(
        onPressed: executeSend,
        color: Colors.blue,
        textColor: Colors.white,
        child: Text('Send')));

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

  executeSend() async {
    NotificationContent content = new NotificationContent();
    if (_templateName != null && _templateName.isNotEmpty) {
      content.templateName = _templateName;
    }
    if (_templateDataKey1 != null &&
        _templateDataKey1.isNotEmpty &&
        _templateDataValue1 != null &&
        _templateDataValue1.isNotEmpty) {
      content.templatePlaceholders[_templateDataKey1] = _templateDataValue1;
    }
    if (_templateDataKey2 != null &&
        _templateDataKey2.isNotEmpty &&
        _templateDataValue2 != null &&
        _templateDataValue2.isNotEmpty) {
      content.templatePlaceholders[_templateDataKey2] = _templateDataValue2;
    }
    if (_text != null && _text.isNotEmpty) {
      content.text = _text;
    }
    if (_title != null && _title.isNotEmpty) {
      content.title = _title;
    }
    if (_imageUrl != null && _imageUrl.isNotEmpty) {
      content.mediaAttachment = MediaAttachment.withImageUrl(_imageUrl);
    } else if (_image != null) {
      final bytes = await File(_image.path).readAsBytes();
      content.mediaAttachment =
          MediaAttachment.withBase64Image(base64Encode(bytes));
    }
    if (_videoUrl != null && _videoUrl.isNotEmpty) {
      content.mediaAttachment = MediaAttachment.withVideoUrl(_videoUrl);
    } else if (_video != null) {
      final bytes = await File(_video.path).readAsBytes();
      content.mediaAttachment =
          MediaAttachment.withBase64Video(base64Encode(bytes));
    }
    if ((_backgroundImageUrl != null && _backgroundImageUrl.isNotEmpty) ||
        (_titleColor != null && _titleColor.isNotEmpty) ||
        (_textColor != null && _textColor.isNotEmpty)) {
      var customization = new NotificationCustomization();
      customization.backgroundImageConfiguration = _backgroundImageUrl;
      customization.titleColor = _titleColor;
      customization.textColor = _textColor;
      content.customization = customization;
    }
    if ((_badgeCount != null && _badgeCount.isNotEmpty) ||
        (_badgeIncrease != null && _badgeIncrease.isNotEmpty)) {
      var badge = new NotificationBadge();
      if (_badgeIncrease != null && _badgeIncrease.isNotEmpty) {
        badge.increase = int.parse(_badgeIncrease);
      }
      if (_badgeCount != null && _badgeCount.isNotEmpty) {
        badge.badge = int.parse(_badgeCount);
      }
      content.badge = badge;
    }
    if (_action != 'no_action' && _action != 'default') {
      Map<String, String> actionData = {};
      if (_actionDataKey1 != null &&
          _actionDataKey1.isNotEmpty &&
          _actionDataValue1 != null &&
          _actionDataValue1.isNotEmpty) {
        actionData[_actionDataKey1] = _actionDataValue1;
      }
      if (_actionDataKey2 != null &&
          _actionDataKey2.isNotEmpty &&
          _actionDataValue2 != null &&
          _actionDataValue2.isNotEmpty) {
        actionData[_actionDataKey2] = _actionDataValue2;
      }

      content.action = GetSocialAction(_action, actionData);
    }
    List<NotificationButton> buttons = [];
    if (_actionButtonTitle1 != null &&
        _actionButtonTitle1.isNotEmpty &&
        _actionButtonActionId1 != null &&
        _actionButtonActionId1.isNotEmpty) {
      buttons
          .add(NotificationButton(_actionButtonTitle1, _actionButtonActionId1));
    }
    if (_actionButtonTitle2 != null &&
        _actionButtonTitle2.isNotEmpty &&
        _actionButtonActionId2 != null &&
        _actionButtonActionId2.isNotEmpty) {
      buttons
          .add(NotificationButton(_actionButtonTitle2, _actionButtonActionId2));
    }
    if (buttons.isNotEmpty) {
      content.actionButtons = buttons;
    }

    var sendTarget = SendNotificationTarget();
    if (_sendToReferredUsers) {
      sendTarget.receiverPlaceholders
          .add(NotificationReceiverPlaceholder.referredUsers);
    }
    if (_sendToFriends) {
      sendTarget.receiverPlaceholders
          .add(NotificationReceiverPlaceholder.friends);
    }
    if (_sendToReferrer) {
      sendTarget.receiverPlaceholders
          .add(NotificationReceiverPlaceholder.referrer);
    }
    List<String> userIds = [];
    if (_userId1 != null && _userId1.isNotEmpty) {
      userIds.add(_userId1);
    }
    if (_userId2 != null && _userId2.isNotEmpty) {
      userIds.add(_userId2);
    }
    if (userIds.isNotEmpty) {
      sendTarget.userIdList = UserIdList.create(userIds);
    }
    Notifications.send(content, sendTarget)
        .then((any) => showAlert(context, 'Success', 'Notification sent'))
        .catchError((onError) =>
            showError(context, 'Failed to send notification, error: $onError'));
  }
}
