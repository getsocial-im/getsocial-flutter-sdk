import 'package:flutter/material.dart';
import 'package:getsocial_example/main.dart';
import 'package:getsocial_flutter_sdk/getsocial_flutter_sdk.dart';

class UserDetailsView extends StatelessWidget {
  final CurrentUser currentUser;

  UserDetailsView(this.currentUser);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 10),
        Row(
          children: [
            Container(
              child: Text('User Details',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              height: 20,
            )
          ],
          mainAxisAlignment: MainAxisAlignment.center,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            new Expanded(
              child: new Container(
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
                      border: new Border(bottom: new BorderSide()))),
            ),
          ],
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text('User Id: ', style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(child: Text(currentUser.userId))
          ],
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text('Display Name: ',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(child: Text(currentUser.displayName))
          ],
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text('Avatar Url: ', style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(child: Text(currentUser.avatarUrl))
          ],
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text('Identities: ', style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(child: Text(currentUser.identities.toString()))
          ],
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text('Public properties: ',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(child: Text(currentUser.publicProperties.toString()))
          ],
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text('Private properties: ',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(child: Text(currentUser.privateProperties.toString()))
          ],
        ),
      ],
    );
//    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
//      Row(children: [Expanded(child: Text('User Details', style: TextStyle(fontWeight: FontWeight.bold)))],),
//      new Container(
//          child: new FlatButton(
//            onPressed: () => Navigator.pop(context),
//            child: new Text('< Back'),
//            color: Colors.white,
//          ),
//          decoration:
//          new BoxDecoration(
//              color: Colors.white,
//              border: new Border(
//                  bottom: new BorderSide()
//              )
//          )
//      ),
//    ],);
  }
}
