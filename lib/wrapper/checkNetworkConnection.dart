//Currently not implemented in the app
//This will check whether the user's device is connected to Internet or not

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hackernews/wrapper/getTopStories.dart';

class CheckNetworkConnection extends StatefulWidget {
  @override
  _CheckNetworkConnectionState createState() => _CheckNetworkConnectionState();
}

class _CheckNetworkConnectionState extends State<CheckNetworkConnection> {
  Future<int> requestResult;
  bool showAppBar = false;

  Future<int> checkForNetworkConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {
          showAppBar = true;
        });
        return 1;
      } else {
        return 0;
      }
    } on SocketException catch (err) {
      print('not connected \nError : $err');
      return 0;
    }
  }

  @override
  void initState() {
    super.initState();
    requestResult = checkForNetworkConnection();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar == true
          ? AppBar(
              title: Text("Hacker News"),
            )
          : AppBar(),
      body: Container(
        child: FutureBuilder<int>(
          future: requestResult,
          builder: (context, snap) {
            if (snap.hasData) {
              if (snap.data == 1) {
                return TopStoriesFromAPI();
              } else {
                return Center(
                  child: Text("You are not connected to Internet"),
                );
              }
            } else if (snap.hasError) {
              return Center(
                child: Text(snap.error.toString()),
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
}
