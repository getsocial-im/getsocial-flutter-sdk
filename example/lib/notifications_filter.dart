import 'package:flutter/material.dart';
import 'package:getsocial_flutter_sdk/getsocial_flutter_sdk.dart';
import 'main.dart';

// ignore: must_be_immutable
class NotificationsFilter extends StatefulWidget {
  NotificationsFilterState _state = NotificationsFilterState();

  @override
  NotificationsFilterState createState() {
    NotificationsFilterState newState = new NotificationsFilterState();
    newState.onFiltersUpdated = _state.onFiltersUpdated;
    return newState;
  }

  NotificationsFilterState getState() {
    return _state;
  }
}

class NotificationsFilterState extends State<NotificationsFilter> {
  final _formKey = GlobalKey<FormState>();
  var _filterConsumedKey = GlobalKey<FormState>();
  var _filterIgnoredKey = GlobalKey<FormFieldState>();
  var _filterReadKey = GlobalKey<FormFieldState>();
  var _filterUnreadKey = GlobalKey<FormFieldState>();
  var _filterActionAllTypesKey = GlobalKey<FormFieldState>();
  var _filterActionActivityLikeKey = GlobalKey<FormFieldState>();
  var _filterActionCommentLikeKey = GlobalKey<FormFieldState>();
  var _filterActionRelatedCommentKey = GlobalKey<FormFieldState>();
  var _filterActionMentionInCommentKey = GlobalKey<FormFieldState>();
  var _filterActionMentionInActivityKey = GlobalKey<FormFieldState>();
  var _filterActionInviteAcceptedKey = GlobalKey<FormFieldState>();
  var _filterActionNewFriendshipKey = GlobalKey<FormFieldState>();
  var _filterActionReplyToCommentKey = GlobalKey<FormFieldState>();
  var _filterActionTargetingKey = GlobalKey<FormFieldState>();
  var _filterActionDirectKey = GlobalKey<FormFieldState>();

  bool filterConsumed = false;
  bool filterIgnored = false;
  bool filterRead = false;
  bool filterUnread = false;
  bool filterActionAllTypes = true;
  bool filterActionActivityLike = false;
  bool filterActionCommentLike = false;
  bool filterActionRelatedComment = false;
  bool filterActionMentionInComment = false;
  bool filterActionMentionInActivity = false;
  bool filterActionInviteAccepted = false;
  bool filterActionNewFriendship = false;
  bool filterActionReplyToComment = false;
  bool filterActionTargeting = false;
  bool filterActionDirect = false;

  Function(Map<String, bool>) onFiltersUpdated;

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

    formWidget.add(new CheckboxListTile(
        key: _filterConsumedKey,
        title: Text('Consumed'),
        value: filterConsumed,
        onChanged: (bool newValue) => setState(() {
              filterConsumed = newValue;
            })));
    formWidget.add(new CheckboxListTile(
        key: _filterIgnoredKey,
        title: Text('Ignored'),
        value: filterIgnored,
        onChanged: (bool newValue) => setState(() {
              filterIgnored = newValue;
            })));
    formWidget.add(new CheckboxListTile(
        key: _filterReadKey,
        title: Text('Read'),
        value: filterRead,
        onChanged: (bool newValue) => setState(() {
              filterRead = newValue;
            })));
    formWidget.add(new CheckboxListTile(
        key: _filterUnreadKey,
        title: Text('Unread'),
        value: filterUnread,
        onChanged: (bool newValue) => setState(() {
              filterUnread = newValue;
            })));
    formWidget.add(
        Text('Action Types', style: TextStyle(fontWeight: FontWeight.bold)));
    formWidget.add(new CheckboxListTile(
        key: _filterActionAllTypesKey,
        title: Text('All Types'),
        value: filterActionAllTypes,
        onChanged: (bool newValue) => setState(() {
              filterActionAllTypes = false;
              filterActionAllTypes = newValue;
            })));
    formWidget.add(new CheckboxListTile(
        key: _filterActionActivityLikeKey,
        title: Text('Activity Like'),
        value: filterActionActivityLike,
        onChanged: (bool newValue) => setState(() {
              filterActionAllTypes = false;
              filterActionActivityLike = newValue;
            })));
    formWidget.add(new CheckboxListTile(
        key: _filterActionCommentLikeKey,
        title: Text('Comment Like'),
        value: filterActionCommentLike,
        onChanged: (bool newValue) => setState(() {
              filterActionAllTypes = false;
              filterActionCommentLike = newValue;
            })));
    formWidget.add(new CheckboxListTile(
        key: _filterActionRelatedCommentKey,
        title: Text('Related Comment'),
        value: filterActionRelatedComment,
        onChanged: (bool newValue) => setState(() {
              filterActionAllTypes = false;
              filterActionRelatedComment = newValue;
            })));
    formWidget.add(new CheckboxListTile(
        key: _filterActionMentionInActivityKey,
        title: Text('Mention in Activity'),
        value: filterActionMentionInActivity,
        onChanged: (bool newValue) => setState(() {
              filterActionAllTypes = false;
              filterActionMentionInActivity = newValue;
            })));
    formWidget.add(new CheckboxListTile(
        key: _filterActionMentionInCommentKey,
        title: Text('Mention in Comment'),
        value: filterActionMentionInComment,
        onChanged: (bool newValue) => setState(() {
              filterActionAllTypes = false;
              filterActionMentionInComment = newValue;
            })));
    formWidget.add(new CheckboxListTile(
        key: _filterActionInviteAcceptedKey,
        title: Text('Invite Accepted'),
        value: filterActionInviteAccepted,
        onChanged: (bool newValue) => setState(() {
              filterActionAllTypes = false;
              filterActionInviteAccepted = newValue;
            })));
    formWidget.add(new CheckboxListTile(
        key: _filterActionNewFriendshipKey,
        title: Text('New Friendship'),
        value: filterActionNewFriendship,
        onChanged: (bool newValue) => setState(() {
              filterActionAllTypes = false;
              filterActionNewFriendship = newValue;
            })));
    formWidget.add(new CheckboxListTile(
        key: _filterActionReplyToCommentKey,
        title: Text('Reply to Comment'),
        value: filterActionReplyToComment,
        onChanged: (bool newValue) => setState(() {
              filterActionAllTypes = false;
              filterActionReplyToComment = newValue;
            })));
    formWidget.add(new CheckboxListTile(
        key: _filterActionTargetingKey,
        title: Text('Targeting'),
        value: filterActionTargeting,
        onChanged: (bool newValue) => setState(() {
              filterActionAllTypes = false;
              filterActionTargeting = newValue;
            })));
    formWidget.add(new CheckboxListTile(
        key: _filterActionDirectKey,
        title: Text('Direct'),
        value: filterActionDirect,
        onChanged: (bool newValue) => setState(() {
              filterActionAllTypes = false;
              filterActionDirect = newValue;
            })));
    formWidget.add(new RaisedButton(
        onPressed: saveFilters,
        color: Colors.blue,
        textColor: Colors.white,
        child: new Text('Save')));
    return formWidget;
  }

  saveFilters() async {
    Map<String, bool> filters = Map();
    filters[NotificationStatus.consumed] = this.filterConsumed;
    filters[NotificationStatus.ignored] = this.filterIgnored;
    filters[NotificationStatus.read] = this.filterRead;
    filters[NotificationStatus.unread] = this.filterUnread;

    filters['AllTypes'] = this.filterActionAllTypes;
    filters[NotificationType.likeActivity] = this.filterActionActivityLike;
    filters[NotificationType.likeComment] = this.filterActionCommentLike;
    filters[NotificationType.direct] = this.filterActionDirect;
    filters[NotificationType.inviteAccepted] = this.filterActionInviteAccepted;
    filters[NotificationType.mentionInActivity] =
        this.filterActionMentionInActivity;
    filters[NotificationType.mentionInComment] =
        this.filterActionMentionInComment;
    filters[NotificationType.newFriendship] = this.filterActionNewFriendship;
    filters[NotificationType.relatedComment] = this.filterActionRelatedComment;
    filters[NotificationType.replyToComment] = this.filterActionReplyToComment;
    filters[NotificationType.targeting] = this.filterActionTargeting;

    this.onFiltersUpdated(filters);
    buildContextList.removeLast();
    Navigator.pop(context);
  }
}
