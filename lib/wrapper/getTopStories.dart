import 'package:flutter/material.dart';
import 'package:hackernews/wrapper/getNewsStoriesFromIds.dart';
import 'package:http/http.dart' as http;

class TopStoriesFromAPI extends StatefulWidget {
  @override
  _TopStoriesFromAPIState createState() => _TopStoriesFromAPIState();
}

class _TopStoriesFromAPIState extends State<TopStoriesFromAPI> {
  String body = "";
  Future<List<String>> newsIds;

  //This function fetch the ids of top stories using the API call and this function is called in initState method
  // instead of build method in order to avoid excess requests to server whenever state of the app changes.
  Future<List<String>> getNewsStory() async {
    List<String> ids = [];
    final newsIds = await http.get(
        "https://hacker-news.firebaseio.com/v0/topstories.json?print=pretty");
    if (newsIds.statusCode == 200) {
      body = newsIds.body;
      body = body.substring(2, body.length - 3);
      ids = body.split(",").toList();
    } else {
      throw Exception("cannot fetch news ids");
    }
    return ids;
  }

  @override
  void initState() {
    super.initState();
    newsIds = getNewsStory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: FutureBuilder<List<String>>(
          future: newsIds,
          builder: (context, snap) {
            if (snap.hasData) {
              return NewsStoriesFromIds(snap.data);
            } else if (snap.hasError) {
              return Center(
                child: Text("Error : ${snap.error.toString()}"),
              );
            }
            return Center(
              child: CircularProgressIndicator(
                strokeWidth: 3,
              ),
            );
          },
        ),
      ),
    );
  }
}
