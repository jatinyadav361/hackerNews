import 'dart:convert';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:hackernews/constants/constants.dart';
import 'package:hackernews/home/particularComment.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:hackernews/models/newsComment.dart';
import 'package:hackernews/models/newsStory.dart';

class ParticularNewsStory extends StatefulWidget {
  final NewsStory newsStory;
  final List<NewsComment> parentComments;
  ParticularNewsStory(this.newsStory, this.parentComments);
  @override
  _ParticularNewsStoryState createState() => _ParticularNewsStoryState();
}

class _ParticularNewsStoryState extends State<ParticularNewsStory> {
  Future<List<NewsComment>> subComments;
  int progressBar = 0;

  Future<List<NewsComment>> getLastSubComments(
      List<NewsComment> newsComments) async {
    List<NewsComment> newsSubComments = List<NewsComment>(newsComments.length);
    for (int i = 0; i < newsComments.length; i++) {
      if (newsComments[i].kids != null) {
        final httpResponse = await http.get(
            "https://hacker-news.firebaseio.com/v0/item/${newsComments[i].kids[newsComments[i].kids.length - 1]}.json?print=pretty");
        if (httpResponse.statusCode == 200) {
          newsSubComments[i] =
              NewsComment.fromJson(jsonDecode(httpResponse.body));
        } else {
          throw Exception("cannot fetch comment from server");
        }
      }
      if (mounted)
        setState(() {
          progressBar = progressBar + (100 ~/ (newsComments.length));
        });
    }
    return newsSubComments;
  }

  @override
  void initState() {
    super.initState();
    subComments = getLastSubComments(widget.parentComments);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: FutureBuilder<List<NewsComment>>(
          future: subComments,
          builder: (context, subCommentSnap) {
            if (subCommentSnap.hasData) {
              return ListView.builder(
                padding: EdgeInsets.all(5),
                itemCount: widget.parentComments.length + 2,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: EdgeInsets.only(top: 5, bottom: 5),
                      child: Card(
                        elevation: 4,
                        child: GestureDetector(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 10, right: 10, bottom: 5, top: 5),
                                child: Text(
                                  "posted by ${widget.newsStory.by} • ${readTimestamp(widget.newsStory.time)} • ${widget.newsStory.type.toUpperCase()}",
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 10, right: 10, bottom: 5),
                                child: widget.newsStory.deleted == true
                                    ? Text("This story has been deleted")
                                    : Html(
                                        data: widget.newsStory.title,
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
                              SizedBox(
                                height: 10,
                              ),
                              commentAndVoteMenu(
                                  widget.newsStory.score,
                                  widget.newsStory.descendants,
                                  true,
                                  widget.newsStory.url),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                  if (index == 1) {
                    return Padding(
                      padding: EdgeInsets.only(top: 5, bottom: 5),
                      child: Container(
                        child: Padding(
                          padding:
                              EdgeInsets.only(left: 10, right: 10, bottom: 5),
                          child: Text(
                            "Comments",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                          ),
                        ),
                      ),
                    );
                  }
                  return Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Card(
                      elevation: 5,
                      color: Colors.grey[200],
                      child: Column(
                        children: [
                          Card(
                            elevation: 5,
                            child: ListTile(
                              title: Text(
                                  "by ${widget.parentComments[index - 2].by} • ${readTimestamp(widget.parentComments[index - 2].time)}"),
                              subtitle: widget
                                          .parentComments[index - 2].deleted ==
                                      true
                                  ? Text(
                                      "This comment has been deleted",
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontStyle: FontStyle.italic),
                                    )
                                  : Html(
                                      data:
                                          widget.parentComments[index - 2].text,
                                      onLinkTap: (url) async {
                                        await launchUrl(url);
                                      },
                                    ),
                            ),
                          ),
                          widget.parentComments[index - 2].kids != null
                              ? Container(
                                  child: Column(
                                    children: [
                                      widget.parentComments[index - 2].kids
                                                  .length >
                                              1
                                          ? GestureDetector(
                                              child: Text(
                                                "Show previous ${widget.parentComments[index - 2].kids.length - 1} ${widget.parentComments[index - 2].kids.length > 2 ? "replies" : "reply"}",
                                                style: TextStyle(
                                                    color: Colors.blue,
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              onTap: () {
                                                Navigator.push(context,
                                                    MaterialPageRoute(
                                                        builder: (context) {
                                                  return ParticularComment(
                                                      widget.parentComments[
                                                          index - 2],
                                                      widget.newsStory
                                                          .descendants);
                                                }));
                                              },
                                            )
                                          : Text(""),
                                      Padding(
                                        padding: EdgeInsets.only(left: 30),
                                        child: Card(
                                          elevation: 5,
                                          child: ListTile(
                                            title: Text(
                                                "by ${subCommentSnap.data[index - 2].by} • ${readTimestamp(subCommentSnap.data[index - 2].time)}"),
                                            subtitle: subCommentSnap
                                                        .data[index - 2]
                                                        .deleted ==
                                                    true
                                                ? Text(
                                                    "This comment has been deleted",
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontStyle:
                                                            FontStyle.italic),
                                                  )
                                                : Html(
                                                    data: subCommentSnap
                                                        .data[index - 2].text,
                                                    onLinkTap: (url) async {
                                                      await launchUrl(url);
                                                    },
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Text(""),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
            if (subCommentSnap.hasError) {
              return Center(
                child: Text("Error : ${subCommentSnap.error.toString()}"),
              );
            }
            return loadingIndicator(progressBar);
          },
        ),
      ),
    );
  }
}
