// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'newsComment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NewsComment _$NewsCommentFromJson(Map<String, dynamic> json) {
  return NewsComment(
    by: json['by'] as String,
    id: json['id'] as int,
    kids: (json['kids'] as List)?.map((e) => e as int)?.toList(),
    parent: json['parent'] as int,
    text: json['text'] as String,
    time: json['time'] as int,
    type: json['type'] as String,
    dead: json['dead'] as bool,
    deleted: json['deleted'] as bool,
    paddingLayer: json['paddingLayer'] as int,
  );
}

Map<String, dynamic> _$NewsCommentToJson(NewsComment instance) =>
    <String, dynamic>{
      'by': instance.by,
      'id': instance.id,
      'kids': instance.kids,
      'parent': instance.parent,
      'text': instance.text,
      'time': instance.time,
      'type': instance.type,
      'deleted': instance.deleted,
      'dead': instance.dead,
      'paddingLayer': instance.paddingLayer,
    };
