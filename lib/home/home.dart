import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:hackernews/constants/constants.dart';
import 'package:hackernews/home/particularStoryWrapper.dart';
import 'package:hackernews/home/viewedStories.dart';
import 'package:hackernews/models/newsComment.dart';
import 'package:hackernews/models/newsStory.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  final List<NewsStory> newsStories;
  final List<String> ids;
  Home(this.ids, this.newsStories);
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int progessBar = 0;
  Future<List<NewsComment>> comments;
  List<NewsStory> viewedStories = [];
  int viewedStoriesIndex = 0;

  //This function fetch the top 2 comments for each story using the API calls and this function is called in initState method
  // instead of build method in order to avoid excess requests to server whenever state of the app changes.
  Future<List<NewsComment>> fetchCommentsFromAllStories(
      List<NewsStory> newsStories) async {
    int n = newsStories.length;
    List<NewsComment> newsComment = List<NewsComment>((newsStories.length) * 2);
    for (int i = 0; i < newsStories.length; i++) {
      for (int j = 0;
          j <
              (newsStories[i].kids != null
                  ? newsStories[i].kids.length >= 2
                      ? 2
                      : newsStories[i].kids.length
                  : 0);
          j++) {
        final response = await http.get(
            "https://hacker-news.firebaseio.com/v0/item/${newsStories[i].kids[j].toString().trim()}.json?print=pretty");
        if (response.statusCode == 200) {
          print("${NewsStory.fromJson(jsonDecode(response.body)).title}");
          newsComment[(i * 2) + j] =
              NewsComment.fromJson(jsonDecode(response.body));
        } else {
          throw Exception("cannot fetch data");
        }
      }
      if (mounted)
        setState(() {
          progessBar = progessBar + (100 ~/ n);
        });
    }
    return newsComment;
  }

  @override
  void initState() {
    super.initState();
    viewedStories.length = widget.newsStories.length;
    comments = fetchCommentsFromAllStories(widget.newsStories);
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
        actions: [
          FlatButton(
            child: Text(
              "Viewed Stories",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return ViewedStories(viewedStories, viewedStoriesIndex);
              }));
            },
          ),
        ],
      ),
      body: Container(
        child: FutureBuilder<List<NewsComment>>(
          future: comments,
          builder: (context, commentSnapshot) {
            if (commentSnapshot.hasData) {
              return ListView.builder(
                itemCount: widget.newsStories.length,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                        padding: EdgeInsets.only(
                            top: 8, bottom: 8, left: 15, right: 15),
                        child: Text(
                          "Top Stories",
                          textScaleFactor: 1.5,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ));
                  }
                  return Padding(
                    padding: EdgeInsets.only(top: 8, bottom: 8),
                    child: Card(
                      elevation: 3,
                      child: GestureDetector(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  left: 15, right: 15, bottom: 5, top: 5),
                              child: Text(
                                "posted by ${widget.newsStories[index - 1].by} • ${readTimestamp(widget.newsStories[index - 1].time)} • ${widget.newsStories[index - 1].type.toUpperCase()}",
                                style: TextStyle(fontSize: 12),
                              ),
                            ),

                            Padding(
                              padding: EdgeInsets.only(
                                  left: 10, right: 10, bottom: 5),
                              child: widget.newsStories[index - 1].deleted ==
                                      true
                                  ? Text("This story has been deleted")
                                  // Html package is used to convert html text from API to normal text
                                  : Html(
                                      data: widget.newsStories[index - 1].title,
                                      style: {
                                        'html': Style(
                                          fontWeight: FontWeight.bold,
                                          fontSize: FontSize(16),
                                        ),
                                      },
                                      onLinkTap: (url) async {
                                        await launchUrl(url);
                                      },
                                    ),
                            ),

                            commentAndVoteMenu(
                                widget.newsStories[index - 1].score,
                                widget.newsStories[index - 1].descendants,
                                true,
                                widget.newsStories[index - 1].url),
                            Container(
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: 15, right: 15, bottom: 5),
                                child: Text(
                                  "Comments",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                      fontSize: 15),
                                ),
                              ),
                            ),

                            // Showing top 2 comments for each story as a preview on home screen
                            widget.newsStories[index - 1].kids != null
                                ? widget.newsStories[index - 1].kids.length >= 1
                                    ? Card(
                                        elevation: 4,
                                        child: ListTile(
                                          tileColor: Colors.grey[200],
                                          title: Text(
                                            "by ${commentSnapshot.data[(index - 1) * 2].by} • ${readTimestamp(commentSnapshot.data[(index - 1) * 2].time)}",
                                            style: TextStyle(fontSize: 12),
                                          ),
                                          subtitle: commentSnapshot
                                                      .data[(index - 1) * 2]
                                                      .deleted ==
                                                  true
                                              ? Text(
                                                  "This comments has been deleted")
                                              : Html(
                                                  data: commentSnapshot
                                                      .data[(index - 1) * 2]
                                                      .text,
                                                  onLinkTap: (url) async {
                                                    await launchUrl(url);
                                                  },
                                                ),
                                        ),
                                      )
                                    : Text("")
                                : Text(""),

                            widget.newsStories[index - 1].kids != null
                                ? widget.newsStories[index - 1].kids.length >= 2
                                    ? Padding(
                                        padding:
                                            EdgeInsets.only(top: 5, bottom: 5),
                                        child: Card(
                                          elevation: 4,
                                          child: ListTile(
                                            tileColor: Colors.grey[200],
                                            title: Text(
                                              "by ${commentSnapshot.data[((index - 1) * 2) + 1].by} • ${readTimestamp(commentSnapshot.data[((index - 1) * 2) + 1].time)}",
                                              style: TextStyle(fontSize: 12),
                                            ),
                                            subtitle: commentSnapshot
                                                        .data[
                                                            ((index - 1) * 2) +
                                                                1]
                                                        .deleted ==
                                                    true
                                                ? Text(
                                                    "This comment has been deleted")
                                                : Html(
                                                    data: commentSnapshot
                                                        .data[
                                                            ((index - 1) * 2) +
                                                                1]
                                                        .text,
                                                    onLinkTap: (url) async {
                                                      await launchUrl(url);
                                                    },
                                                  ),
                                          ),
                                        ),
                                      )
                                    : Text("")
                                : Text(""),
                            //Show all commments button to show all the comments of a particular story
                            Padding(
                              padding: EdgeInsets.only(left: 10, right: 10),
                              child: FlatButton(
                                child: Text("Show all comments"),
                                onPressed: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return ParticularStoryWrapper(
                                        widget.newsStories[index - 1]);
                                  }));
                                },
                              ),
                            ),
                          ],
                        ),
                        onTap: () async {
                          //storing viewed stories in a separate list
                          viewedStories[viewedStoriesIndex++] =
                              widget.newsStories[index - 1];
                          viewedStories[viewedStoriesIndex - 1].storyViewedAt =
                              DateTime.now().millisecondsSinceEpoch;

                          await launchUrl(widget.newsStories[index - 1].url);

                          for (int i = 0; i < viewedStoriesIndex - 1; i++) {
                            if (viewedStories[viewedStoriesIndex - 1].id ==
                                viewedStories[i].id) {
                              viewedStories[i] =
                                  viewedStories[viewedStoriesIndex - 1];
                              viewedStoriesIndex--;
                              break;
                            }
                          }
                        },
                      ),
                    ),
                  );
                },
              );
            } else if (commentSnapshot.hasError) {
              return Center(
                child: Text("Error : ${commentSnapshot.error.toString()}"),
              );
            }
            return loadingIndicator(progessBar);
          },
        ),
      ),
    );
  }
}
