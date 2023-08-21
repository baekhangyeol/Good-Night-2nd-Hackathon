import 'package:flutter/material.dart';
import 'package:hackaton_flutter/pages/movieDetailPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MovieResponse {
  final String title;
  final String genre;
  final bool onScreen;
  final String openDate;
  final String endDate;
  final int id;

  MovieResponse({
    required this.title,
    required this.genre,
    required this.onScreen,
    required this.openDate,
    required this.endDate,
    required this.id,
  });

  factory MovieResponse.fromJson(Map<String, dynamic> json) {
    return MovieResponse( 
      id: json['id'],
      title: json['title'],
      genre: json['genre'],
      onScreen: json['onScreen'],
      openDate: json['openDate'],
      endDate: json['endDate'],
    );
  }
}

class MovieListPage extends StatefulWidget {
  @override
  _MovieListPageState createState() => _MovieListPageState();
}

class _MovieListPageState extends State<MovieListPage> {
  List<MovieResponse> _movies = [];

  Future<void> _fetchMovies() async {
  final String apiUrl = 'http://localhost:8080/api/v1/movies'; // 실제 API 엔드포인트로 변경

  final http.Response response = await http.get(Uri.parse(apiUrl));

  if (response.statusCode == 200) {
    final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes)); // 수정된 부분
    setState(() {
      _movies = jsonList.map((json) => MovieResponse.fromJson(json)).toList();
    });
  } else {
    // Handle error
  }
}

  @override
  void initState() {
    super.initState();
    _fetchMovies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('영화 목록'),
      ),
      body: ListView.builder(
        itemCount: _movies.length,
        itemBuilder: (context, index) {
          final movie = _movies[index];
          return ListTile(
  title: Text(movie.title),
  subtitle: Text('장르: ${movie.genre}\n상영중 여부: ${movie.onScreen ? '상영중' : '상영 종료'}'),
  trailing: Text('개봉일: ${movie.openDate}\n상영마감일: ${movie.endDate}'),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MovieDetailPage(movieId: movie.id)),
    );
  },
);
        },
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: MovieListPage()));
}
