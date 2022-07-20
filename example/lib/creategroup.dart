import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:getsocial_flutter_sdk/getsocial_flutter_sdk.dart';

import 'common.dart';
import 'main.dart';

class CreateGroup extends StatefulWidget {
  @override
  CreateGroupState createState() => new CreateGroupState();
}

class CreateGroupState extends State<CreateGroup> {
  static Group? oldGroup;

  TextEditingController actionDataKeyController = TextEditingController();
  TextEditingController actionDataValueController = TextEditingController();
  TextEditingController customActionController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  String? _id = oldGroup?.id;
  String? _title = oldGroup?.title;
  String? _description = oldGroup?.description;
  String? _imageUrl = oldGroup?.avatarUrl;
  String? _labels = oldGroup != null && oldGroup!.settings.labels.isNotEmpty
      ? oldGroup!.settings.labels.toString()
      : null;
  String? _customKey1 =
      oldGroup != null && oldGroup!.settings.properties.isNotEmpty
          ? oldGroup!.settings.properties.keys.first
          : null;
  String? _customValue1 =
      oldGroup != null && oldGroup!.settings.properties.isNotEmpty
          ? oldGroup!.settings.properties.values.first
          : null;
  String? _customKey2 =
      oldGroup != null && oldGroup!.settings.properties.length == 2
          ? oldGroup!.settings.properties.keys.toList()[1]
          : null;
  String? _customValue2 =
      oldGroup != null && oldGroup!.settings.properties.length == 2
          ? oldGroup!.settings.properties.values.toList()[1]
          : null;
  bool _isPrivate = oldGroup != null ? oldGroup!.settings.isPrivate : false;
  bool _isDiscoverable =
      oldGroup != null ? oldGroup!.settings.isDiscoverable : false;

  File? _image;

  List<bool> allowPostSelection = [true, false, false];
  List<bool> allowInteractSelection = [true, false, false];

  @override
  void initState() {
    if (oldGroup != null) {
      int allowPost = oldGroup!.settings.permissions[CommunitiesAction.post]!;
      int allowInteract =
          oldGroup!.settings.permissions[CommunitiesAction.react]!;
      if (allowPost == Role.owner) {
        allowPostSelection = [true, false, false];
      } else if (allowPost == Role.admin) {
        allowPostSelection = [false, true, false];
      } else if (allowPost == Role.member) {
        allowPostSelection = [false, false, true];
      }
      if (allowInteract == Role.owner) {
        allowInteractSelection = [true, false, false];
      } else if (allowPost == Role.admin) {
        allowInteractSelection = [false, true, false];
      } else if (allowPost == Role.member) {
        allowInteractSelection = [false, false, true];
      }
    }
    super.initState();
  }

  void removeImage() {
    setState(() {
      _image = null;
    });
  }

  Future getImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      print('selectedimage:' + result.files.single.path!);
      setState(() {
        _image = File(result.files.single.path!);
      });
    }
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
      decoration: InputDecoration(labelText: 'Group ID', hintText: 'ID'),
      onChanged: (value) => setState(() {
        _id = value;
      }),
      initialValue: _id,
    ));

    formWidget.add(new TextFormField(
      decoration: InputDecoration(labelText: 'Name', hintText: 'Name'),
      onChanged: (value) => setState(() {
        _title = value;
      }),
      initialValue: _title,
    ));

    formWidget.add(new TextFormField(
      decoration:
          InputDecoration(labelText: 'Description', hintText: 'Description'),
      onChanged: (value) => setState(() {
        _description = value;
      }),
      initialValue: _description,
    ));

    formWidget.add(new TextFormField(
      decoration:
          InputDecoration(labelText: 'Avatar Url', hintText: 'Remote Url'),
      onChanged: (value) => setState(() {
        _imageUrl = value;
      }),
      initialValue: _imageUrl,
    ));

    formWidget.add(mediaWidget());

    formWidget
        .add(Text('Allow Post', style: TextStyle(fontWeight: FontWeight.bold)));
    formWidget.add(new ToggleButtons(
      children: [
        Text('Owner', style: TextStyle(fontWeight: FontWeight.bold)),
        Text('Admin', style: TextStyle(fontWeight: FontWeight.bold)),
        Text('Member', style: TextStyle(fontWeight: FontWeight.bold)),
      ],
      onPressed: (index) => setState(() {
        for (int buttonIndex = 0;
            buttonIndex < this.allowPostSelection.length;
            buttonIndex++) {
          if (buttonIndex == index) {
            this.allowPostSelection[buttonIndex] = true;
          } else {
            this.allowPostSelection[buttonIndex] = false;
          }
        }
      }),
      isSelected: this.allowPostSelection,
    ));

    formWidget.add(
        Text('Allow Interact', style: TextStyle(fontWeight: FontWeight.bold)));

    formWidget.add(new ToggleButtons(
      children: [
        Text('Owner', style: TextStyle(fontWeight: FontWeight.bold)),
        Text('Admin', style: TextStyle(fontWeight: FontWeight.bold)),
        Text('Member', style: TextStyle(fontWeight: FontWeight.bold)),
      ],
      onPressed: (index) => setState(() {
        for (int buttonIndex = 0;
            buttonIndex < this.allowInteractSelection.length;
            buttonIndex++) {
          if (buttonIndex == index) {
            this.allowInteractSelection[buttonIndex] = true;
          } else {
            this.allowInteractSelection[buttonIndex] = false;
          }
        }
      }),
      isSelected: this.allowInteractSelection,
    ));

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

    formWidget
        .add(Text('Labels', style: TextStyle(fontWeight: FontWeight.bold)));

    formWidget.add(new TextFormField(
      decoration: InputDecoration(
          labelText: 'Label1,Label2,Label3', hintText: 'Label1,Label2,Label3'),
      onChanged: (value) => setState(() {
        _labels = value;
      }),
      initialValue: _labels,
    ));

    formWidget.add(new CheckboxListTile(
        title: Text('Private?'),
        value: _isPrivate,
        onChanged: (bool? newValue) => setState(() {
              _isPrivate = !_isPrivate;
            })));

    formWidget.add(new CheckboxListTile(
        title: Text('Discoverable?'),
        value: _isDiscoverable,
        onChanged: (bool? newValue) => setState(() {
              _isDiscoverable = !_isDiscoverable;
            })));

    formWidget.add(new ElevatedButton(
        onPressed: executePost,
        style: ElevatedButton.styleFrom(
            primary: Colors.blue, onPrimary: Colors.white),
        child: Text(oldGroup == null ? 'Create' : 'Update')));

    return formWidget;
  }

  Widget mediaWidget() {
    if (_image == null) {
      return Row(
        children: [
          TextButton(
              child: Text('Add Image'),
              onPressed: () => getImage(),
              style: TextButton.styleFrom(
                  backgroundColor: Colors.orange, primary: Colors.white)),
        ],
      );
    } else if (_image != null) {
      return Column(children: [
        Container(
            child: Image.file(_image!, fit: BoxFit.fill),
            width: 300,
            height: 150),
        TextButton(
          child: Text('Remove'),
          onPressed: () => removeImage(),
          style: TextButton.styleFrom(
              backgroundColor: Colors.orange, primary: Colors.white),
        ),
      ]);
    }
    return Row();
  }

  executePost() async {
    GroupContent content = new GroupContent();
    if (oldGroup == null) {
      if (_id == null || _id!.isEmpty) {
        showError(context, 'ID is mandatory');
        return;
      }
    }
    content.id = _id!;
    content.title = _title;
    content.description = _description;
    if (_imageUrl != null && _imageUrl!.length > 0) {
      content.avatar = MediaAttachment.withImageUrl(_imageUrl!);
    } else if (_image != null) {
      final bytes = await File(_image!.path).readAsBytes();
      content.avatar = MediaAttachment.withBase64Image(base64Encode(bytes));
    }
    if (_customKey1 != null && _customValue1 != null) {
      content.properties[_customKey1!] = _customValue1!;
    }
    if (_customKey2 != null && _customValue2 != null) {
      content.properties[_customKey2!] = _customValue2!;
    }
    if (_labels != null) {
      content.labels = _labels!.split(",");
    }

    int rolePost = Role.owner;
    int roleInteract = Role.owner;
    for (int buttonIndex = 0;
        buttonIndex < this.allowPostSelection.length;
        buttonIndex++) {
      if (this.allowPostSelection[buttonIndex] == true) {
        if (buttonIndex == 0) {
          rolePost = Role.owner;
        }
        if (buttonIndex == 1) {
          rolePost = Role.admin;
        }
        if (buttonIndex == 2) {
          rolePost = Role.member;
        }
      }
    }
    for (int buttonIndex = 0;
        buttonIndex < this.allowInteractSelection.length;
        buttonIndex++) {
      if (this.allowInteractSelection[buttonIndex] == true) {
        if (buttonIndex == 0) {
          roleInteract = Role.owner;
        }
        if (buttonIndex == 1) {
          roleInteract = Role.admin;
        }
        if (buttonIndex == 2) {
          roleInteract = Role.member;
        }
      }
    }
    content.isDiscoverable = _isDiscoverable;
    content.isPrivate = _isPrivate;
    content.permissions[CommunitiesAction.post] = rolePost;
    content.permissions[CommunitiesAction.react] = roleInteract;
    if (oldGroup != null && content.title == null) {
      showAlert(context, 'Error', 'Name field is mandatory');
      return;
    }
    if (CreateGroupState.oldGroup == null) {
      Communities.createGroup(content).then((group) {
        showAlert(context, 'Success', 'Group created');
      }).catchError((error) {
        showError(context, error.toString());
        var errorMessage = 'Failed to create group, error: ' + error.toString();
        showError(context, errorMessage);
      });
    } else {
      Communities.updateGroup(oldGroup!.id, content).then((group) {
        oldGroup = group;
        showAlert(context, 'Success', 'Group updated');
      }).catchError((error) {
        var errorMessage = 'Failed to update group, error: ' + error.toString();
        showError(context, errorMessage);
      });
    }
  }
}
