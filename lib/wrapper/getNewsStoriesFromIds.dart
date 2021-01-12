import 'dart:convert';
import 'package:hackernews/constants/constants.dart';
import 'package:hackernews/home/home.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:hackernews/models/newsStory.dart';

class NewsStoriesFromIds extends StatefulWidget {
  final List<String> ids;
  NewsStoriesFromIds(this.ids);
  @override
  _NewsStoriesFromIdsState createState() => _NewsStoriesFromIdsState();
}

class _NewsStoriesFromIdsState extends State<NewsStoriesFromIds> {
  // top 25 stories to be displayed on the home page
  int numStories = 25;

  int progessBar = 0;

  Future<List<NewsStory>> newsStories;

  //This function fetch the top stories using the API calls and ids that were fetched before and this function is called in initState method
  // instead of build method in order to avoid excess requests to server whenever state of the app changes.
  Future<List<NewsStory>> fetchNewsFromId() async {
    List<NewsStory> newsStory = List<NewsStory>(
        numStories < widget.ids.length ? numStories : widget.ids.length);
    for (int i = 0;
        i < (numStories < widget.ids.length ? numStories : widget.ids.length);
        i++) {
      widget.ids[i] = widget.ids[i].trim();
      final response = await http.get(
          "https://hacker-news.firebaseio.com/v0/item/${widget.ids[i]}.json?print=pretty");
      if (response.statusCode == 200) {
        print("${NewsStory.fromJson(jsonDecode(response.body)).title}");
        newsStory[i] = NewsStory.fromJson(jsonDecode(response.body));
      } else {
        throw Exception("cannot fetch data");
      }
      if (mounted)
        setState(() {
          progessBar = progessBar + (100 ~/ numStories);
        });
    }
    return newsStory;
  }

  @override
  void initState() {
    super.initState();
    newsStories = fetchNewsFromId();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: FutureBuilder<List<NewsStory>>(
          future: newsStories,
          builder: (context, snap) {
            if (snap.hasData) {
              return Home(widget.ids, snap.data);
            } else if (snap.hasError) {
              return Center(
                child: Text("Error : ${snap.error.toString()}"),
              );
            }
            return loadingIndicator(progessBar);
          },
        ),
      ),
    );
  }
}
