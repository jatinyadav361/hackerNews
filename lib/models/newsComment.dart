//json_serializable package is used to auto generate the NewsComment template which is a recommended way by official documentaion

import 'package:json_annotation/json_annotation.dart';

part 'newsComment.g.dart';

@JsonSerializable()
class NewsComment {
  String by;
  int id;
  List<int> kids;
  int parent;
  String text;
  int time;
  String type;
  bool deleted;
  bool dead;
  int paddingLayer;

  NewsComment(
      {this.by,
      this.id,
      this.kids,
      this.parent,
      this.text,
      this.time,
      this.type,
      this.dead,
      this.deleted,
      this.paddingLayer});

  factory NewsComment.fromJson(Map<String, dynamic> json) =>
      _$NewsCommentFromJson(json);

  Map<String, dynamic> toJson() => _$NewsCommentToJson(this);
}
