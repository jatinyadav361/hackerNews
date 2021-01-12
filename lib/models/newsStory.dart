//json_serializable package is used to auto generate the NewsStory template which is a recommended way by official documentaion

import 'package:json_annotation/json_annotation.dart';

part 'newsStory.g.dart';

@JsonSerializable()
class NewsStory {
  String by;
  int descendants;
  int id;
  List<int> kids;
  int score;
  int time;
  String title;
  String type;
  String url;
  bool deleted;
  bool dead;
  int storyViewedAt;

  NewsStory(
      {this.title,
      this.url,
      this.id,
      this.time,
      this.type,
      this.descendants,
      this.kids,
      this.by,
      this.score,
      this.dead,
      this.deleted,
      this.storyViewedAt});

  factory NewsStory.fromJson(Map<String, dynamic> json) =>
      _$NewsStoryFromJson(json);

  Map<String, dynamic> toJson() => _$NewsStoryToJson(this);
}
