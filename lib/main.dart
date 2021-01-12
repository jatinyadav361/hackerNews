import 'package:flutter/material.dart';
import 'package:hackernews/wrapper/getTopStories.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TopStoriesFromAPI(),
      debugShowCheckedModeBanner: false,
    );
  }
}
