import 'package:flutter/material.dart';

import 'package:getsocial_flutter_sdk/getsocial_flutter_sdk.dart';

class CreatePollOption extends StatefulWidget {
  @override
  CreatePollOptionState createState() => new CreatePollOptionState();
}

class CreatePollOptionState extends State<CreatePollOption> {
  String? _optionId;
  String? _text;
  String? _imageUrl;
  String? _videoUrl;
  late Function onRemove;

  @override
  void initState() {
    super.initState();
  }

  PollOptionContent getPollOptionContent() {
    var content = PollOptionContent();
    content.optionId = _optionId;
    content.text = _text;
    if (_imageUrl != null && _imageUrl!.isNotEmpty) {
      content.attachment = MediaAttachment.withImageUrl(_imageUrl!);
    } else if (_videoUrl != null && _videoUrl!.isNotEmpty) {
      content.attachment = MediaAttachment.withVideoUrl(_videoUrl!);
    }
    return content;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        new TextFormField(
          decoration: InputDecoration(labelText: 'Option ID', hintText: 'ID'),
          onChanged: (value) => _optionId = value,
          initialValue: _optionId,
        ),
        new TextFormField(
          decoration: InputDecoration(labelText: 'Text', hintText: 'Text'),
          onChanged: (value) => _text = value,
          initialValue: _text,
        ),
        new TextFormField(
          decoration: InputDecoration(labelText: 'Image URL', hintText: 'URL'),
          onChanged: (value) => _imageUrl = value,
          initialValue: _imageUrl,
        ),
        new TextFormField(
          decoration: InputDecoration(labelText: 'Video URL', hintText: 'URL'),
          onChanged: (value) => _videoUrl = value,
          initialValue: _videoUrl,
        ),
        new ElevatedButton(
            onPressed: () => onRemove(),
            style: ElevatedButton.styleFrom(
                primary: Colors.blue, onPrimary: Colors.white),
            child: Text('Remove')),
      ],
    );
  }
}
