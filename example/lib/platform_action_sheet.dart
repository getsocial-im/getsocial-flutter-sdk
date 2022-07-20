// Improved version of https://github.com/Amazing-Aidan/platform_action_sheet/

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Display a platform dependent Action Sheet
class PlatformActionSheet {
  /// Function to display the sheet
  void displaySheet(BuildContext context, Widget title, Widget message,
      List<ActionSheetAction> actions) {
    if (Platform.isIOS) {
      _showCupertinoActionSheet(context, title, message, actions);
    } else {
      _settingModalBottomSheet(context, title, message, actions);
    }
  }
}

void _showCupertinoActionSheet(
    BuildContext context, title, message, List<ActionSheetAction> actions) {
  final noCancelOption = -1;
  // Cancel action is treated differently with CupertinoActionSheets
  var indexOfCancel = actions.lastIndexWhere((action) => action.isCancel);
  CupertinoActionSheet actionSheet;
  actionSheet = indexOfCancel == noCancelOption
      ? CupertinoActionSheet(
          actions: actions
              .where((action) => !action.isCancel)
              .map<Widget>(_cupertinoActionSheetActionFromAction)
              .toList())
      : CupertinoActionSheet(
          actions: actions
              .where((action) => !action.isCancel)
              .map<Widget>(_cupertinoActionSheetActionFromAction)
              .toList(),
          cancelButton:
              _cupertinoActionSheetActionFromAction(actions[indexOfCancel]));
  showCupertinoModalPopup(context: context, builder: (_) => actionSheet);
}

CupertinoActionSheetAction _cupertinoActionSheetActionFromAction(
        ActionSheetAction action) =>
    CupertinoActionSheetAction(
      child: Text(action.text),
      onPressed: action.onPressed,
      isDefaultAction: action.defaultAction,
    );

ListTile _listTileFromAction(ActionSheetAction action) => action.hasArrow
    ? ListTile(
        title: Text(action.text),
        onTap: action.onPressed,
        trailing: Icon(Icons.keyboard_arrow_right),
      )
    : ListTile(
        title: Text(
          action.text,
          style: TextStyle(
              fontWeight:
                  action.defaultAction ? FontWeight.bold : FontWeight.normal),
        ),
        onTap: action.onPressed,
      );

void _settingModalBottomSheet(
    context, title, message, List<ActionSheetAction> actions) {
  if (actions.isNotEmpty) {
    showModalBottomSheet(
        context: context,
        builder: (_) {
          final _lastItem = 1, _secondLastItem = 2;
          return Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                actions.length > 5
                    ? Expanded(
                        child: ListView.separated(
                            padding: const EdgeInsets.only(left: 20),
                            shrinkWrap: true,
                            itemCount: actions.length,
                            itemBuilder: (_, index) =>
                                _listTileFromAction(actions[index]),
                            separatorBuilder: (_, index) =>
                                (index == (actions.length - _secondLastItem) &&
                                        actions[actions.length - _lastItem]
                                            .isCancel)
                                    ? Divider()
                                    : Container()))
                    : ListView.separated(
                        padding: const EdgeInsets.only(left: 20),
                        shrinkWrap: true,
                        itemCount: actions.length,
                        itemBuilder: (_, index) =>
                            _listTileFromAction(actions[index]),
                        separatorBuilder: (_, index) => (index ==
                                    (actions.length - _secondLastItem) &&
                                actions[actions.length - _lastItem].isCancel)
                            ? Divider()
                            : Container()),
              ],
            ), // Separator above the last option only
          );
        });
  }
}

/// Data class for Actions in ActionSheet
class ActionSheetAction {
  /// Text to display
  late final String text;

  /// The function which will be called when the action is pressed
  late final VoidCallback onPressed;

  /// Is this a default action - especially for iOS
  final bool defaultAction;

  /// This is a cancel option - especially for iOS
  final bool isCancel;

  /// on Android indicates that further options are next
  final bool hasArrow;

  /// Construction of an ActionSheetAction
  ActionSheetAction({
    required this.text,
    required this.onPressed,
    this.defaultAction = false,
    this.isCancel = false,
    this.hasArrow = false,
  });
}
