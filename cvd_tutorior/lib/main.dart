import 'package:cvd_tutorior/record_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Audio Recorder Demo',
      theme: ThemeData(
        primaryColor: Colors.blueGrey,
      ),
      home: Scaffold(
        body: RecordPage(),
      )
    );
  }
}
