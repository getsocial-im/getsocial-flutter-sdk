import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

void showOverlayAlert(String title, String message) async {
  showSimpleNotification(
    Text(message),
    background: Colors.lime,
    foreground: Colors.black,
    autoDismiss: false,
    trailing: Builder(builder: (context) {
      return TextButton(
          style: TextButton.styleFrom(
              backgroundColor: Colors.red, primary: Colors.white),
          onPressed: () {
            OverlaySupportEntry.of(context)?.dismiss();
          },
          child: Text('Dismiss'));
    }),
  );
}

void showAlert(BuildContext context, String title, String message,
    [Function? onClose]) async {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        Widget closeButton = TextButton(
          child: Text("Close"),
          onPressed: () {
            Navigator.pop(context);
            if (onClose != null) {
              onClose();
            }
          },
        );

        // set up the AlertDialog
        return AlertDialog(
            title: Text(title),
            actions: [closeButton],
            content: SingleChildScrollView(
                scrollDirection: Axis.vertical, child: Text(message)));
      });
}

void showError(BuildContext context, String message) async {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        Widget closeButton = TextButton(
          child: Text("Close"),
          onPressed: () {
            Navigator.pop(context);
          },
        );

        // set up the AlertDialog
        return AlertDialog(
            title: Text('Error'),
            actions: [closeButton],
            content: SingleChildScrollView(
                scrollDirection: Axis.vertical, child: Text(message)));
      });
}

class ListButton {
  String name;
  Function(BuildContext) action;
  ListButton(String name, Function(BuildContext) action)
      : name = name,
        action = action;
}

showDialogWithOptions(BuildContext context, String title,
    final List<String> options, Function(String) onOptionSelected) async {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        Widget cancelButton = TextButton(
          child: Text("Cancel"),
          onPressed: () {
            Navigator.pop(context);
          },
        );

        List<Widget> children = options
            .map(
              (input) => TextButton(
                  child: Text(input),
                  onPressed: () =>
                      {Navigator.pop(context), onOptionSelected(input)}),
            )
            .toList();

        // set up the AlertDialog
        return AlertDialog(
            title: Text(title),
            actions: [cancelButton],
            content: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: children,
                )));
      });
}
