import 'package:flutter/material.dart';
import 'package:getsocial_example/notifications_filter.dart';
import 'package:getsocial_flutter_sdk/getsocial_flutter_sdk.dart';
import 'common.dart';
import 'platform_action_sheet.dart';

import 'main.dart';

// ignore: must_be_immutable
class NotificationsList extends StatefulWidget {
  late NotificationsFilter notificationsFilter;

  NotificationsList(NotificationsFilter notificationsFilter) {
    this.notificationsFilter = notificationsFilter;
  }

  @override
  NotificationsListState createState() =>
      new NotificationsListState(notificationsFilter);
}

class NotificationsListState extends State<NotificationsList> {
  List<GetSocialNotification> notifications = [];
  late NotificationsFilter notificationsFilter;

  NotificationsListState(NotificationsFilter notificationsFilter) {
    this.notificationsFilter = notificationsFilter;
  }

  @override
  void initState() {
    super.initState();
    this.notificationsFilter.getState().onFiltersUpdated = (updatedFilters) {
      executeSearch(updatedFilters);
    };
    executeSearch({});
  }

  showDetail(int index) async {
    var createdAt = DateTime.fromMillisecondsSinceEpoch(
        notifications[index].createdAt * 1000);
    var topicStr = notifications[index].toString();
    showAlert(context, 'Details', '$topicStr, createdAt: $createdAt');
  }

  markAsRead(int index, String newStatus) async {
    Notifications.setStatus(newStatus, [notifications[index].id]).then((value) {
      setState(() {
        notifications[index].status = newStatus;
      });
    }).catchError((error) {
      showAlert(context, 'Error', error.toString());
    });
  }

  List<ActionSheetAction> generatePossibleActions(int index) {
    List<ActionSheetAction> actions = [];
    actions.add(ActionSheetAction(
      text: 'Details',
      onPressed: () => {Navigator.pop(context), showDetail(index)},
      hasArrow: true,
    ));
    var status = notifications[index].status;
    actions.add(ActionSheetAction(
      text: status == NotificationStatus.unread
          ? 'Mark as read'
          : 'Mark as unread',
      onPressed: () => {
        Navigator.pop(context),
        status == NotificationStatus.unread
            ? markAsRead(index, NotificationStatus.read)
            : markAsRead(index, NotificationStatus.unread)
      },
      hasArrow: true,
    ));
    actions.add(ActionSheetAction(
      text: "Cancel",
      onPressed: () => Navigator.pop(context),
      isCancel: true,
      defaultAction: true,
    ));
    return actions;
  }

  showActionSheet(int index) async {
    PlatformActionSheet().displaySheet(
        context, Text(''), Text(''), generatePossibleActions(index));
  }

  executeSearch(Map<String, bool> updatedFilters) async {
    NotificationsQuery query = NotificationsQuery();
    if (updatedFilters[NotificationStatus.consumed] ?? false) {
      query.statuses.add(NotificationStatus.consumed);
    }
    if (updatedFilters[NotificationStatus.ignored] ?? false) {
      query.statuses.add(NotificationStatus.ignored);
    }
    if (updatedFilters[NotificationStatus.read] ?? false) {
      query.statuses.add(NotificationStatus.read);
    }
    if (updatedFilters[NotificationStatus.unread] ?? false) {
      query.statuses.add(NotificationStatus.unread);
    }
    if (updatedFilters.containsKey('AllTypes') &&
        !updatedFilters['AllTypes']!) {
      if (updatedFilters[NotificationType.likeActivity] ?? false) {
        query.types.add(NotificationType.likeActivity);
      }
      if (updatedFilters[NotificationType.likeComment] ?? false) {
        query.types.add(NotificationType.likeComment);
      }
      if (updatedFilters[NotificationType.direct] ?? false) {
        query.types.add(NotificationType.direct);
      }
      if (updatedFilters[NotificationType.inviteAccepted] ?? false) {
        query.types.add(NotificationType.inviteAccepted);
      }
      if (updatedFilters[NotificationType.mentionInActivity] ?? false) {
        query.types.add(NotificationType.mentionInActivity);
      }
      if (updatedFilters[NotificationType.mentionInComment] ?? false) {
        query.types.add(NotificationType.mentionInComment);
      }
      if (updatedFilters[NotificationType.newFriendship] ?? false) {
        query.types.add(NotificationType.newFriendship);
      }
      if (updatedFilters[NotificationType.relatedComment] ?? false) {
        query.types.add(NotificationType.relatedComment);
      }
      if (updatedFilters[NotificationType.replyToComment] ?? false) {
        query.types.add(NotificationType.replyToComment);
      }
      if (updatedFilters[NotificationType.targeting] ?? false) {
        query.types.add(NotificationType.targeting);
      }
    }

    Notifications.get(PagingQuery(query)).then((value) {
      this.setState(() {
        notifications = value.entries;
      });
    });
  }

  Widget createActionButtons(
      BuildContext context, List<NotificationButton> buttons) {
    if (buttons.length != 0) {
      List<TextButton> widgetButtons = [];
      buttons.forEach((element) {
        widgetButtons.add(TextButton(
          onPressed: () => print('button pressed'),
          child: Text(element.title),
          style: TextButton.styleFrom(
              backgroundColor: Colors.orange, primary: Colors.white),
        ));
      });
      return Row(children: widgetButtons);
    }
    return Container();
  }

  Widget createAttachment(BuildContext context, MediaAttachment? attachment) {
    if (attachment != null) {
      if (attachment.imageUrl != null) {
        return Row(children: [
          Container(
              child: Image.network(attachment.imageUrl!, fit: BoxFit.fill),
              width: 300,
              height: 150)
        ]);
      } else if (attachment.videoUrl != null) {
        return Row(children: [Container(child: Text(attachment.videoUrl!))]);
      } else if (attachment.gifUrl != null) {
        return Row(children: [Container(child: Text(attachment.gifUrl!))]);
      }
    }
    return Container();
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
        Container(
            child: new TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/notifications_filter');
              },
              child: new Text('Filter Settings'),
              style: TextButton.styleFrom(
                  backgroundColor: Colors.blue, primary: Colors.white),
            ),
            decoration: new BoxDecoration(
                color: Colors.white,
                border: new Border(bottom: new BorderSide()))),
        Expanded(
            child: ListView.builder(
                padding: const EdgeInsets.all(0),
                itemCount: notifications.length,
                itemBuilder: (BuildContext context, int index) {
                  var notification = notifications[index];
                  var backgroundImage = notification.customization == null
                      ? 'null'
                      : notification
                          .customization!.backgroundImageConfiguration;
                  var textColor = notification.customization == null
                      ? 'null'
                      : notification.customization!.textColor;
                  var titleColor = notification.customization == null
                      ? 'null'
                      : notification.customization!.titleColor;
                  return Container(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text('Status: ' + notification.status),
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                    notification.sender?.displayName ?? ''),
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Text(notification.title ?? ''),
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Text(notification.text ?? ''),
                              ),
                              TextButton(
                                onPressed: () => showActionSheet(index),
                                child: Text('Actions'),
                                style: TextButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    primary: Colors.white),
                              ),
                            ],
                          ),
                          createAttachment(
                              context, notification.mediaAttachment),
                          createActionButtons(
                              context, notification.actionButtons),
                          Row(
                            children: [
                              Expanded(
                                child:
                                    Text('Background image: $backgroundImage'),
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Text('Title color: $titleColor'),
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Text('Text color: $textColor'),
                              )
                            ],
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
