import 'package:flutter/material.dart';
import 'package:getsocial_flutter_sdk/getsocial_flutter_sdk.dart';
import 'main.dart';
import 'common.dart';
import 'chatmessages.dart';

class Chats extends StatefulWidget {
  @override
  ChatsState createState() => new ChatsState();
}

class ChatsState extends State<Chats> {
  List<Chat> chats = [];

  @override
  void initState() {
    executeSearch();
    super.initState();
  }

  executeSearch() async {
    PagingQuery query = PagingQuery.simpleQuery();
    Communities.getChats(query).then((result) {
      this.setState(() {
        chats = result.entries;
      });
    });
  }

  showChatMessages(Chat chat) async {
    ChatMessagesState.chatId = ChatId.create(chat.id);
    Navigator.pushNamed(context, "/chatmessages");
  }

  showDetails(Chat chat) async {
    showAlert(context, 'Details', chat.toString());
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
        Container(
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
                border: new Border(bottom: new BorderSide()))),
        Expanded(
            child: ListView.builder(
                padding: const EdgeInsets.all(0),
                itemCount: chats.length,
                itemBuilder: (BuildContext context, int index) {
                  var chat = chats[index];
                  return Container(
                      child: Row(
                        children: [
                          Expanded(
                              child: Column(
                            children: [
                              Text('Title:' + chat.title),
                              Text(getLastMessageText(chat.lastMessage)),
                              Text(getLastMessageImage(chat.lastMessage)),
                              Text(getLastMessageVideo(chat.lastMessage)),
                            ],
                            crossAxisAlignment: CrossAxisAlignment.start,
                          )),
                          TextButton(
                            onPressed: () => showChatMessages(chat),
                            child: Text('Open'),
                            style: TextButton.styleFrom(
                                backgroundColor: Colors.blue,
                                primary: Colors.white),
                          ),
                          TextButton(
                            onPressed: () => showDetails(chat),
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
}
