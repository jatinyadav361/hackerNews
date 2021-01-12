// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'newsStory.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NewsStory _$NewsStoryFromJson(Map<String, dynamic> json) {
  return NewsStory(
    title: json['title'] as String,
    url: json['url'] as String,
    id: json['id'] as int,
    time: json['time'] as int,
    type: json['type'] as String,
    descendants: json['descendants'] as int,
    kids: (json['kids'] as List)?.map((e) => e as int)?.toList(),
    by: json['by'] as String,
    score: json['score'] as int,
    dead: json['dead'] as bool,
    deleted: json['deleted'] as bool,
    storyViewedAt: json['storyViewedAt'] as int,
  );
}

Map<String, dynamic> _$NewsStoryToJson(NewsStory instance) => <String, dynamic>{
      'by': instance.by,
      'descendants': instance.descendants,
      'id': instance.id,
      'kids': instance.kids,
      'score': instance.score,
      'time': instance.time,
      'title': instance.title,
      'type': instance.type,
      'url': instance.url,
      'deleted': instance.deleted,
      'dead': instance.dead,
      'storyViewedAt': instance.storyViewedAt,
    };
