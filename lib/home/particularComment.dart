import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:hackernews/constants/constants.dart';
import 'package:hackernews/models/newsComment.dart';
import 'package:http/http.dart' as http;

class ParticularComment extends StatefulWidget {
  final NewsComment parentComment;
  final int descendants;
  ParticularComment(this.parentComment, this.descendants);
  @override
  _ParticularCommentState createState() => _ParticularCommentState();
}

class _ParticularCommentState extends State<ParticularComment> {
  Future<int> numTotalComments;

  Future<List<NewsComment>> allComments;
  int index = 0;

  List<NewsComment> commentsList = [];

  @override
  void initState() {
    super.initState();
    commentsList.length = widget.descendants;
    allComments = getAllComments(widget.parentComment, 1);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Comments"),
      ),
      body: Container(
        child: FutureBuilder<List<NewsComment>>(
          future: allComments,
          builder: (context, snap) {
            if (snap.hasData) {
              return ListView.builder(
                itemCount: index + 1,
                itemBuilder: (context, i) {
                  if (i == 0) {
                    return Wrap(
                      children: [
                        Card(
                          elevation: 2,
                          child: ListTile(
                            title: Text(
                                "${widget.parentComment.by} • ${readTimestamp(widget.parentComment.time)}"),
                            subtitle: widget.parentComment.deleted == true
                                ? Text(
                                    "This comment has been deleted",
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontStyle: FontStyle.italic),
                                  )
                                : Html(
                                    data: widget.parentComment.text,
                                    onLinkTap: (url) async {
                                      await launchUrl(url);
                                    },
                                  ),
                          ),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.only(left: 10, right: 10, top: 20),
                          child: Text(
                            "Replies",
                            textScaleFactor: 1.5,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                  return Container(
                    child: Stack(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            left: snap.data[i - 1].paddingLayer * 20.0,
                            right: 5,
                            top: snap.data[i - 1].parent ==
                                    widget.parentComment.id
                                ? 30
                                : 4,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                                color: Color.fromRGBO(60, 80, 110, 0.15),
                                borderRadius: BorderRadius.circular(15)),
                            child: ListTile(
                              title: Text(
                                  "${snap.data[i - 1].by} • ${readTimestamp(snap.data[i - 1].time)}"),
                              subtitle: snap.data[i - 1].deleted == true
                                  ? Text(
                                      "This comment has been deleted",
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontStyle: FontStyle.italic),
                                    )
                                  : Html(
                                      data: snap.data[i - 1].text,
                                      onLinkTap: (url) async {
                                        await launchUrl(url);
                                      },
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            } else if (snap.hasError) {
              return Center(
                child: Text("Error : ${snap.error.toString()}"),
              );
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }

  //Recursive function to find all the sub comments of a comments then all the subcommnets
  // of original comment's subcomments and so on until complete comment tree has been traversed
  //padding layer is used to automatically apply padding to the childs of the comments so that their parent and subcomments can be clearly recognised
  Future<List<NewsComment>> getAllComments(
      NewsComment newsComment, int paddingLayer) async {
    bool started = true;
    if (newsComment.kids != null) {
      for (int i = 0; i < newsComment.kids.length; i++) {
        final response = await http.get(
            "https://hacker-news.firebaseio.com/v0/item/${newsComment.kids[i].toString().trim()}.json?print=pretty");
        var comment;
        if (response.statusCode == 200) {
          comment = NewsComment.fromJson(jsonDecode(response.body));
          commentsList[index++] = comment;
          commentsList[index - 1].paddingLayer = paddingLayer;
          print("${comment.id}   ${comment.text}");
        } else {
          debugPrint("Cannot fetch commments");
        }
        if (comment != null) await getAllComments(comment, paddingLayer + 1);
      }
    }
    //mounted is used to check whether the current state is still in the widget tree or not
    if (mounted)
      setState(() {
        started = false;
      });
    return commentsList;
  }
}
