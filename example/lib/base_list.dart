import 'package:flutter/material.dart';
import 'package:getsocial_example/main.dart';
import 'common.dart';

abstract class StateProvider {
  Future<void> updateState();
}

abstract class BaseListView extends StatelessWidget {
  final StateProvider stateProvider;
  BaseListView(StateProvider stateProvider)
      : this.stateProvider = stateProvider;

  @override
  Widget build(BuildContext context) {
    buildContextList.add(context);
    return ListView.builder(
        padding: const EdgeInsets.all(0),
        itemCount: buttons.length,
        itemBuilder: (BuildContext context, int index) {
          var button = buttons[index];
          return Container(
              child: FlatButton(
                onPressed: () {
                  button.action(context);
                },
                child: Text(button.name),
              ),
              decoration: new BoxDecoration(
                  color: Colors.white,
                  border: new Border(bottom: new BorderSide())));
        });
  }

  List<ListButton> get buttons;
}
