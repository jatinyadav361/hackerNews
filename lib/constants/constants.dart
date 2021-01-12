import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share/share.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

// function to get formatted time from API's time field
String readTimestamp(int timestamp) {
  var now = DateTime.now();
  var date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);

  var diff = now.difference(date);
  var time = '';

  if (diff.inSeconds <= 0 || (diff.inSeconds > 0 && diff.inMinutes == 0)) {
    time = "${diff.inSeconds} seconds ago";
  } else if (diff.inMinutes > 0 && diff.inHours == 0) {
    time = "${diff.inMinutes} minutes ago";
  } else if (diff.inHours > 0 && diff.inDays == 0) {
    time = "${diff.inHours} hours ago";
  } else if (diff.inDays > 0 && diff.inDays < 7) {
    if (diff.inDays == 1) {
      time = diff.inDays.toString() + ' day ago';
    } else {
      time = diff.inDays.toString() + ' days ago';
    }
  } else {
    if (diff.inDays == 7) {
      time = (diff.inDays / 7).floor().toString() + ' week ago';
    } else {
      time = (diff.inDays / 7).floor().toString() + ' weeks ago';
    }
  }

  return time;
}

// function to get formatted time from milliSecondsEpoch
String readTimestampFromMillisecondsEpoch(int milliSecondsEpoch) {
  var now = DateTime.now();
  var date = DateTime.fromMillisecondsSinceEpoch(milliSecondsEpoch);

  var diff = now.difference(date);
  var time = '';

  if (diff.inSeconds <= 0 || (diff.inSeconds > 0 && diff.inMinutes == 0)) {
    time = "${diff.inSeconds} seconds ago";
  } else if (diff.inMinutes > 0 && diff.inHours == 0) {
    time = "${diff.inMinutes} minutes ago";
  } else if (diff.inHours > 0 && diff.inDays == 0) {
    time = "${diff.inHours} hours ago";
  } else if (diff.inDays > 0 && diff.inDays < 7) {
    if (diff.inDays == 1) {
      time = diff.inDays.toString() + ' day ago';
    } else {
      time = diff.inDays.toString() + ' days ago';
    }
  } else {
    if (diff.inDays == 7) {
      time = (diff.inDays / 7).floor().toString() + ' week ago';
    } else {
      time = (diff.inDays / 7).floor().toString() + ' weeks ago';
    }
  }

  return time;
}

// function to launch a url in a browser
Future launchUrl(String url) async {
  try {
    if (await canLaunch(url)) {
      await launch(url);
    }
  } catch (e) {
    Fluttertoast.showToast(
      msg: e.toString(),
      backgroundColor: Colors.black,
      textColor: Colors.white,
    );
  }
}

//Comment, Vote, Share Menu WIDGET for displaying these parameters for news story
Widget commentAndVoteMenu(
    int numVotes, int numComments, bool shareOption, String shareUrl) {
  return Padding(
    padding: EdgeInsets.only(left: 10, right: 10, bottom: 5),
    child: Row(
      children: [
        Expanded(
          flex: 1,
          child: Row(
            children: [
              Icon(Icons.arrow_upward_sharp),
              Text("\t${numVotes.toString()}"),
              Icon(Icons.arrow_downward_sharp),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Row(
            children: [
              Icon(
                Icons.comment,
                color: Colors.grey,
              ),
              Text("\t${numComments.toString()}"),
            ],
          ),
        ),
        shareOption == true
            ? Expanded(
                flex: 1,
                child: Row(
                  children: [
                    Icon(
                      Icons.share,
                      color: Colors.grey,
                    ),
                    GestureDetector(
                      child: Text(" Share"),
                      onTap: () {
                        Share.share("$shareUrl",
                            subject: "Have a look at this story");
                      },
                    ),
                  ],
                ),
              )
            : Text(""),
      ],
    ),
  );
}

//Loading Indicator widget
Widget loadingIndicator(int progressBar) {
  return Center(
    child: CircularStepProgressIndicator(
      totalSteps: 100,
      currentStep: progressBar,
      selectedColor: Colors.blue,
      unselectedColor: Colors.grey[300],
      child: Center(
        child: Text("Loading  $progressBar %"),
      ),
      padding: 0,
      width: 150,
      height: 150,
    ),
  );
}
