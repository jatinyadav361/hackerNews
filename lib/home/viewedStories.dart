import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:hackernews/constants/constants.dart';
import 'package:hackernews/models/newsStory.dart';

class ViewedStories extends StatefulWidget {
  final List<NewsStory> viewedStories;
  final int viewedStoriesIndex;
  ViewedStories(this.viewedStories, this.viewedStoriesIndex);
  @override
  _ViewedStoriesState createState() => _ViewedStoriesState();
}

class _ViewedStoriesState extends State<ViewedStories> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Viewed Stories"),
      ),
      body: widget.viewedStories == null
          ? Center(
              child: Text("No viewed stories yet"),
            )
          : ListView.builder(
              itemCount: widget.viewedStoriesIndex + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      "Stories viewed in this current session : ${widget.viewedStoriesIndex}",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }
                return Padding(
                  padding: EdgeInsets.all(10),
                  child: Card(
                    child: ListTile(
                      title: widget.viewedStories[index - 1].deleted == true
                          ? Text("This story has been deleted")
                          : Html(
                              data: widget.viewedStories[index - 1].title,
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
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "Viewed ${widget.viewedStories[index - 1].storyViewedAt != null ? readTimestampFromMillisecondsEpoch(widget.viewedStories[index - 1].storyViewedAt) : ""}",
                          ),
                        ],
                      ),
                      onTap: () async {
                        await launchUrl(widget.viewedStories[index - 1].url);
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
