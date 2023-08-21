import 'package:flutter/material.dart';
import 'movieRegistrationPage.dart'; // 영화 등록 페이지 파일명에 맞게 수정하세요

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie Registration App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainPage(), // 메인 페이지로 시작
    );
  }
}

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('영화 등록 앱'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // 영화 등록 페이지로 전환
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MovieRegistrationPage()),
            );
          },
          child: Text('영화 등록하기'),
        ),
      ),
    );
  }
}
