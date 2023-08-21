import 'package:flutter/material.dart';
import 'package:hackaton_flutter/pages/movieListPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MovieDetailPage extends StatelessWidget {
  final int movieId;

  MovieDetailPage({required this.movieId});

  Future<MovieResponse> _fetchMovieDetails() async {
    final String apiUrl = 'http://localhost:8080/api/v1/movies/$movieId'; // 실제 API 엔드포인트로 변경

    final http.Response response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(utf8.decode(response.bodyBytes));
      return MovieResponse.fromJson(json);
    } else {
      throw Exception('Failed to fetch movie details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('영화 상세 정보'),
      ),
      body: FutureBuilder<MovieResponse>(
        future: _fetchMovieDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final movie = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('제목: ${movie.title}'),
                  Text('장르: ${movie.genre}'),
                  Text('상영중 여부: ${movie.onScreen ? '상영중' : '상영 종료'}'),
                  Text('개봉일: ${movie.openDate}'),
                  Text('상영마감일: ${movie.endDate}'),
                ],
              ),
            );
          } else {
            return Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}
