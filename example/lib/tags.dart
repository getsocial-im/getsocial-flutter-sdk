import 'package:flutter/material.dart';
import 'package:getsocial_flutter_sdk/getsocial_flutter_sdk.dart';
import 'feed.dart';
import 'main.dart';

class TagSearch extends StatefulWidget {
  @override
  TagSearchState createState() => new TagSearchState();
}

class TagSearchState extends State<TagSearch> {
  List<String> tags = [];
  String searchText;

  @override
  void initState() {
    executeSearch();
    super.initState();
  }

  executeSearch() async {
    TagsQuery query = TagsQuery.find(searchText);
    Communities.getTags(query).then((entries) {
      this.setState(() {
        tags = entries;
      });
    });
  }

  showFeedWithTags(String tag) async {
    Navigator.pop(context);
    FeedState.query = ActivitiesQuery.everywhere().withTag(tag);
    FeedState.canInteract = true;
    FeedState.isComment = false;
    Navigator.pushNamed(context, '/feed');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
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
        Row(
          children: [
            Expanded(
              child: TextFormField(
                  onChanged: (value) => setState(() {
                        searchText = value;
                      })),
            ),
            RaisedButton(
              onPressed: () {
                executeSearch();
              },
              child: Text('Search'),
            )
          ],
        ),
        Expanded(
            child: ListView.builder(
                padding: const EdgeInsets.all(0),
                itemCount: tags.length,
                itemBuilder: (BuildContext context, int index) {
                  var tag = tags[index];
                  return Container(
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(tag),
                          ),
                          FlatButton(
                            onPressed: () => showFeedWithTags(tag),
                            child: Text('Show all posts'),
                            color: Colors.blue,
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
