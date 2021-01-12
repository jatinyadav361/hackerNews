import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hackernews/constants/constants.dart';
import 'package:hackernews/home/particularStory.dart';
import 'package:hackernews/models/newsComment.dart';
import 'package:hackernews/models/newsStory.dart';
import 'package:http/http.dart' as http;

class ParticularStoryWrapper extends StatefulWidget {
  final NewsStory newsStory;
  ParticularStoryWrapper(this.newsStory);
  @override
  _ParticularStoryWrapperState createState() => _ParticularStoryWrapperState();
}

class _ParticularStoryWrapperState extends State<ParticularStoryWrapper> {
  int progressBar = 0;

  Future<List<NewsComment>> parentComments;

  Future<List<NewsComment>> fetchCommentsFromStory(NewsStory newsStory) async {
    List<NewsComment> newsComment = List<NewsComment>(newsStory.kids.length);
    print("${newsStory.kids != null ? newsStory.kids.length : "No kids"}");
    for (int i = 0; i < newsStory.kids.length; i++) {
      final response = await http.get(
          "https://hacker-news.firebaseio.com/v0/item/${newsStory.kids[i].toString().trim()}.json?print=pretty");
      if (response.statusCode == 200) {
        print("${NewsStory.fromJson(jsonDecode(response.body)).title}");
        newsComment[i] = NewsComment.fromJson(jsonDecode(response.body));
      } else {
        throw Exception("cannot fetch data");
      }
      if (mounted)
        setState(() {
          progressBar = progressBar + (100 ~/ (newsStory.kids.length));
        });
    }
    return newsComment;
  }

  @override
  void initState() {
    super.initState();
    parentComments = fetchCommentsFromStory(widget.newsStory);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hacker News"),
      ),
      body: Container(
        child: FutureBuilder<List<NewsComment>>(
          future: parentComments,
          builder: (context, snap) {
            if (snap.hasData) {
              return ParticularNewsStory(widget.newsStory, snap.data);
            } else if (snap.hasError) {
              return Padding(
                padding: EdgeInsets.only(left: 15, right: 15),
                child: Center(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    widget.newsStory.kids == null
                        ? Text(
                            "No comments posted till now",
                            textScaleFactor: 1.5,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : Text("Error : ${snap.error.toString()}"),
                  ],
                )),
              );
            }
            return loadingIndicator(progressBar);
          },
        ),
      ),
    );
  }
}
