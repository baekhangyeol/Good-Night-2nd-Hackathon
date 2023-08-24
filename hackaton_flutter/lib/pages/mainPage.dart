import 'package:flutter/material.dart';
import 'package:hackaton_flutter/pages/movieListPageFilter.dart';
import 'movieRegistrationPage.dart';
import 'movieListPage.dart';

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
      home: MainPage(),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MovieRegistrationPage()),
                );
              },
              child: Text('영화 등록하기'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MovieListPage()),
                );
              },
              child: Text('영화 목록 보기'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MovieListPageFilter()),
                );
              },
              child: Text('영화 목록 보기 (필터링)'),
            ),
          ],
        ),
      ),
    );
  }
}
