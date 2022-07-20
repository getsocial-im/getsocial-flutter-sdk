import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:getsocial_flutter_sdk/getsocial_flutter_sdk.dart';

import 'common.dart';
import 'main.dart';

class ChatMessages extends StatefulWidget {
  @override
  ChatMessagesState createState() => new ChatMessagesState();
}

class ChatMessagesState extends State<ChatMessages> {
  static ChatId? chatId;

  final _formKey = GlobalKey<FormState>();
  final _controller = ScrollController();

  String? _text;
  TextEditingController _textController = TextEditingController();

  String? _imageUrl;
  TextEditingController _imageUrlController = TextEditingController();

  String? _videoUrl;
  TextEditingController _videoUrlController = TextEditingController();

  final _imageKey = GlobalKey<FormState>();
  final _videoKey = GlobalKey<FormState>();
  bool _sendImage = false;
  bool _sendVideo = false;
  String? _nextMessages;
  String? _previousMessages;
  String? _refresh;

  ChatMessagesQuery? query;

  List<ChatMessage> messages = [];

  @override
  void initState() {
    loadInitial();

    super.initState();
  }

  showDetails(ChatMessage message) async {
    showAlert(context, 'Details', message.toString());
  }

  String getLastMessageText(ChatMessage? message) {
    String text = 'Text: ';
    if (message != null) {
      text += message.text ?? '';
    }
    return text;
  }

  String getLastMessageImage(ChatMessage? message) {
    String text = 'Image: ';
    if (message != null) {
      if (message.attachments.isNotEmpty) {
        text += message.attachments.first.imageUrl ?? '';
      }
    }
    return text;
  }

  String getLastMessageVideo(ChatMessage? message) {
    String text = 'Video: ';
    if (message != null) {
      if (message.attachments.isNotEmpty) {
        text += message.attachments.first.videoUrl ?? '';
      }
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    buildContextList.add(context);
    return Column(
      children: [
        Form(
            key: _formKey,
            child: new ListView(
                shrinkWrap: true,
                itemExtent: 40,
                padding: const EdgeInsets.all(10),
                children: getFormWidget())),
        Expanded(
            child: ListView.builder(
                controller: _controller,
                padding: const EdgeInsets.all(0),
                itemCount: messages.length,
                itemBuilder: (BuildContext context, int index) {
                  var message = messages[index];
                  return Container(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Align(
                                  child: Text('Id: ' + message.id),
                                  alignment: Alignment.centerLeft,
                                ),
                                Align(
                                  child: Text(
                                      'Author: ' + message.author.displayName),
                                  alignment: Alignment.centerLeft,
                                ),
                                Align(
                                  child: Text(getLastMessageText(message)),
                                  alignment: Alignment.centerLeft,
                                ),
                                Align(
                                    child: Text(getLastMessageImage(message)),
                                    alignment: Alignment.centerLeft),
                                Align(
                                    child: Text(getLastMessageVideo(message)),
                                    alignment: Alignment.centerLeft),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () => showDetails(message),
                            child: Text('Details'),
                            style: TextButton.styleFrom(
                                backgroundColor: Colors.blue,
                                primary: Colors.white),
                          ),
                        ],
                      ),
                      decoration: new BoxDecoration(
                          color: Colors.white,
                          border: new Border(bottom: new BorderSide())));
                })),
      ],
    );
  }

  List<Widget> getFormWidget() {
    List<Widget> formWidget = List.empty(growable: true);
    formWidget.add(new Container(
        child: new TextButton(
          onPressed: () {
            buildContextList.removeLast();
            Navigator.pop(context);
          },
          child: new Text('< Back'),
          style: TextButton.styleFrom(
              backgroundColor: Colors.blue, primary: Colors.white),
        ),
        decoration: new BoxDecoration(
            color: Colors.white,
            border: new Border(bottom: new BorderSide()))));

    formWidget.add(new TextFormField(
      decoration: InputDecoration(hintText: 'Text'),
      onChanged: (value) => setState(() {
        _text = value;
      }),
      controller: _textController,
    ));

    formWidget.add(new TextFormField(
      decoration: InputDecoration(hintText: 'Image Url'),
      onChanged: (value) => setState(() {
        _imageUrl = value;
      }),
      controller: _imageUrlController,
    ));

    formWidget.add(new TextFormField(
      decoration: InputDecoration(hintText: 'Video Url'),
      onChanged: (value) => setState(() {
        _videoUrl = value;
      }),
      controller: _videoUrlController,
    ));

    formWidget.add(new CheckboxListTile(
        key: _imageKey,
        title: Text('Send Image'),
        value: _sendImage,
        onChanged: (bool? newValue) => setState(() {
              _sendImage = newValue!;
            })));

    formWidget.add(new CheckboxListTile(
        key: _videoKey,
        title: Text('Send Video'),
        value: _sendVideo,
        onChanged: (bool? newValue) => setState(() {
              _sendVideo = newValue!;
            })));

    formWidget.add(Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
            onPressed: executeSendMessage,
            style: ElevatedButton.styleFrom(
                primary: Colors.blue, onPrimary: Colors.white),
            child: new Text('Send')),
        ElevatedButton(
            onPressed: (_previousMessages == null || _previousMessages!.isEmpty
                ? null
                : loadPrevious),
            style: ElevatedButton.styleFrom(
                primary: Colors.blue, onPrimary: Colors.white),
            child: new Text('Previous')),
        ElevatedButton(
            onPressed: (_nextMessages == null || _nextMessages!.isEmpty
                ? null
                : loadNext),
            style: ElevatedButton.styleFrom(
                primary: Colors.blue, onPrimary: Colors.white),
            child: new Text('Next')),
        ElevatedButton(
            onPressed: (_refresh == null || _refresh!.isEmpty ? null : refresh),
            style: ElevatedButton.styleFrom(
                primary: Colors.blue, onPrimary: Colors.white),
            child: new Text('Refresh'))
      ],
    ));

    return formWidget;
  }

  Future<List<ChatMessage>> loadMessages(ChatMessagesPagingQuery pagingQuery,
      {bool storeRefresh = true}) async {
    return Communities.getChatMessages(pagingQuery).then((result) {
      _nextMessages = result.nextMessagesCursor;
      _previousMessages = result.previousMessagesCursor;
      if (storeRefresh) {
        _refresh = result.refreshCursor;
      }
      return result.entries;
    }).catchError((error) {
      showError(context, error.toString());
    });
  }

  loadInitial() async {
    ChatMessagesQuery query = ChatMessagesQuery.messagesInChat(chatId!);
    ChatMessagesPagingQuery pagingQuery = ChatMessagesPagingQuery(query);
    loadMessages(pagingQuery).then((value) {
      setState(() {
        messages = value;
        Timer(
          Duration(seconds: 1),
          () {
            _controller.animateTo(_controller.position.maxScrollExtent,
                curve: Curves.easeOut,
                duration: const Duration(milliseconds: 500));
          },
        );
      });
    });
  }

  refresh() async {
    if (_refresh == null || _refresh!.isEmpty) {
      return;
    }
    ChatMessagesQuery query = ChatMessagesQuery.messagesInChat(chatId!);
    ChatMessagesPagingQuery pagingQuery = ChatMessagesPagingQuery(query);
    pagingQuery.nextMessagesCursor = _refresh!;
    loadMessages(pagingQuery).then((value) => setState(() {
          messages.addAll(value);
          Timer(
            Duration(seconds: 1),
            () {
              _controller.animateTo(_controller.position.maxScrollExtent,
                  curve: Curves.easeOut,
                  duration: const Duration(milliseconds: 500));
            },
          );
        }));
  }

  loadNext() async {
    if (_nextMessages == null || _nextMessages!.isEmpty) {
      return;
    }
    ChatMessagesQuery query = ChatMessagesQuery.messagesInChat(chatId!);
    ChatMessagesPagingQuery pagingQuery = ChatMessagesPagingQuery(query);
    pagingQuery.nextMessagesCursor = _nextMessages!;
    loadMessages(pagingQuery).then((value) => setState(() {
          messages.addAll(value);
          Timer(
            Duration(seconds: 1),
            () {
              _controller.animateTo(_controller.position.maxScrollExtent,
                  curve: Curves.easeOut,
                  duration: const Duration(milliseconds: 500));
            },
          );
        }));
  }

  loadPrevious() async {
    if (_previousMessages == null || _previousMessages!.isEmpty) {
      return;
    }
    ChatMessagesQuery query = ChatMessagesQuery.messagesInChat(chatId!);
    ChatMessagesPagingQuery pagingQuery = ChatMessagesPagingQuery(query);
    pagingQuery.previousMessagesCursor = _previousMessages!;
    loadMessages(pagingQuery, storeRefresh: false).then((value) => setState(() {
          messages.insertAll(0, value);
        }));
  }

  executeSendMessage() async {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    ChatMessageContent content = ChatMessageContent();
    if (_text != null && _text!.length > 0) {
      content.text = _text;
    }
    if (_imageUrl != null && _imageUrl!.length > 0) {
      content.attachments.add(MediaAttachment.withImageUrl(_imageUrl!));
    }
    if (_videoUrl != null && _videoUrl!.length > 0) {
      content.attachments.add(MediaAttachment.withVideoUrl(_videoUrl!));
    }
    if (_sendImage) {
      final data = await rootBundle.load('images/activityImage.png');
      Uint8List rawData =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      List<int> intList = rawData.cast<int>();
      content.attachments
          .add(MediaAttachment.withBase64Image(base64Encode(intList)));
    }
    if (_sendVideo) {
      final data = await rootBundle.load('images/giphy.mp4');
      Uint8List rawData =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      List<int> intList = rawData.cast<int>();
      content.attachments
          .add(MediaAttachment.withBase64Video(base64Encode(intList)));
    }

    if (content.text == null && content.attachments.isEmpty) {
      showAlert(context, 'Error', 'Either "text", "attachment" must be set');
      return;
    }
    Communities.sendChatMessage(content, chatId!).then((message) {
      //showAlert(context, 'Success', 'Message sent');
      setState(() {
        if (messages.isEmpty) {
          loadInitial();
        } else {
          refresh();
        }
        _textController.clear();
        _text = null;
        _imageUrlController.clear();
        _imageUrl = null;
        _videoUrlController.clear();
        _videoUrl = null;
        _sendImage = false;
        _sendVideo = false;
        Timer(
          Duration(seconds: 1),
          () {
            _controller.animateTo(_controller.position.maxScrollExtent,
                curve: Curves.easeOut,
                duration: const Duration(milliseconds: 500));
          },
        );
      });
    }).catchError((error) {
      showError(context, error.toString());
    });
  }
}
