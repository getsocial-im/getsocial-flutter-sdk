import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:getsocial_example/common.dart';
import 'package:getsocial_flutter_sdk/common/media_attachment.dart';
import 'package:getsocial_flutter_sdk/getsocial_flutter_sdk.dart';
import 'package:file_picker/file_picker.dart';

import 'main.dart';

class SendCustomInvite extends StatefulWidget {
  @override
  SendCustomInviteState createState() => new SendCustomInviteState();
}

class SendCustomInviteState extends State<SendCustomInvite> {
  final _formKey = GlobalKey<FormState>();
  String _subject;
  String _text;
  String _imageUrl;
  String _lpTitle;
  String _lpDescription;
  String _lpImageUrl;
  String _lpVideoUrl;
  String _customKey1;
  String _customValue1;
  String _customKey2;
  String _customValue2;

  File _image;
  File _video;

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
      decoration: InputDecoration(labelText: 'Subject', hintText: 'Subject'),
      onChanged: (value) => setState(() {
        _subject = value;
      }),
      initialValue: _subject,
    ));
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

    formWidget.add(
        Text('Landing Page', style: TextStyle(fontWeight: FontWeight.bold)));

    formWidget.add(new TextFormField(
      decoration: InputDecoration(labelText: 'Title', hintText: 'Title'),
      onChanged: (value) => setState(() {
        _lpTitle = value;
      }),
      initialValue: _lpTitle,
    ));

    formWidget.add(new TextFormField(
      decoration:
          InputDecoration(labelText: 'Description', hintText: 'Description'),
      onChanged: (value) => setState(() {
        _lpDescription = value;
      }),
      initialValue: _lpDescription,
    ));

    formWidget.add(new TextFormField(
      decoration:
          InputDecoration(labelText: 'Image Url', hintText: 'Remote Url'),
      onChanged: (value) => setState(() {
        _lpImageUrl = value;
      }),
      initialValue: _lpImageUrl,
    ));

    formWidget.add(new TextFormField(
      decoration:
          InputDecoration(labelText: 'Video Url', hintText: 'Remote Url'),
      onChanged: (value) => setState(() {
        _lpVideoUrl = value;
      }),
      initialValue: _lpVideoUrl,
    ));

    formWidget.add(
        Text('Custom Data', style: TextStyle(fontWeight: FontWeight.bold)));

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
      initialValue: _customKey1,
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

    formWidget.add(new RaisedButton(
        onPressed: showInviteChannels,
        color: Colors.blue,
        textColor: Colors.white,
        child: new Text('Send')));

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

  showInviteChannels() async {
    List<InviteChannel> channels = await Invites.getAvailableChannels();
    channels.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    List<String> channelIds = channels.map((e) => e.channelId).toList();
    showDialogWithOptions(context, 'Select Invite Channel', channelIds,
        (channelId) => sendInvite(channelId));
  }

  sendInvite(String channelId) async {
    InviteContent content = new InviteContent();
    if (_subject != null && _subject.length > 0) {
      content.subject = _subject;
    }
    if (_text != null && _text.length > 0) {
      content.text = _text;
    }
    if (_imageUrl != null && _imageUrl.length > 0) {
      content.mediaAttachment = MediaAttachment.withImageUrl(_imageUrl);
    } else if (_image != null) {
      final bytes = await File(_image.path).readAsBytes();
      content.mediaAttachment =
          MediaAttachment.withBase64Image(base64Encode(bytes));
    } else if (_video != null) {
      final bytes = await File(_video.path).readAsBytes();
      content.mediaAttachment =
          MediaAttachment.withBase64Video(base64Encode(bytes));
    }
    content.linkParams = new Map();
    if (_lpTitle != null && _lpTitle.length > 0) {
      content.linkParams[LinkParamsKeys.customTitle] = _lpTitle;
    }
    if (_lpDescription != null && _lpDescription.length > 0) {
      content.linkParams[LinkParamsKeys.customDescription] = _lpDescription;
    }
    if (_lpImageUrl != null && _lpImageUrl.length > 0) {
      content.linkParams[LinkParamsKeys.customImage] = _lpImageUrl;
    }
    if (_lpVideoUrl != null && _lpVideoUrl.length > 0) {
      content.linkParams[LinkParamsKeys.customYouTubeVideo] = _lpVideoUrl;
    }
    if (_customKey1 != null && _customValue1 != null) {
      content.linkParams[_customKey1] = _customValue1;
    }
    if (_customKey2 != null && _customValue2 != null) {
      content.linkParams[_customKey2] = _customValue2;
    }

    Invites.send(
        content,
        channelId,
        () => showAlert(context, 'Success', 'Invite sent'),
        () => showAlert(context, 'Cancel', 'Invite cancelled'),
        (error) => showError(context, error.toString()));
  }
}
