import 'package:flutter/material.dart';
import 'package:hackaton_flutter/pages/movieDetailPage.dart';
import 'package:hackaton_flutter/pages/movieRegistrationPage.dart';
import 'package:hackaton_flutter/pages/movieUpdatePage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MovieWithAvgScoreResponse {
  final int id;
  final String title;
  final DateTime openDate;
  final DateTime endDate;
  final bool onScreen;
  final String genre;
  final double avgScore;

  MovieWithAvgScoreResponse({
    required this.id,
    required this.title,
    required this.openDate,
    required this.endDate,
    required this.onScreen,
    required this.genre,
    required this.avgScore,
  });

  factory MovieWithAvgScoreResponse.fromJson(Map<String, dynamic> json) {
    return MovieWithAvgScoreResponse(
      id: json['id'],
      title: json['title'],
      openDate: DateTime.parse(json['openDate']),
      endDate: DateTime.parse(json['endDate']),
      onScreen: json['onScreen'],
      genre: json['genre'],
      avgScore: json['avgScore'] != null ? json['avgScore'].toDouble() : 0.0,
    );
  }
}


class MovieListPage extends StatefulWidget {
  @override
  _MovieListPageState createState() => _MovieListPageState();
}

class _MovieListPageState extends State<MovieListPage> {
  List<MovieWithAvgScoreResponse> _movies = [];
  String? _selectedGenre;
  bool? _selectedOnScreen;
  int _currentPage = 0;
  int _totalPages = 1;
  double? _selectedAvgScore;

  void _fetchMovies(int page) async {
    final String apiUrl = 'http://localhost:8080/api/v1/movies/avg?page=0&size=10';

    final http.Response response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      final List<dynamic> jsonList = jsonResponse['items'];

      final List<MovieWithAvgScoreResponse> filteredMovies = jsonList
          .map((json) => MovieWithAvgScoreResponse.fromJson(json))
          .cast<MovieWithAvgScoreResponse>()
          .where((movie) => _selectedAvgScore == null || movie.avgScore >= _selectedAvgScore!)
          .toList();

      setState(() {
        _movies = filteredMovies;
      });
    }
  }


  Future<void> _deleteMovie(MovieWithAvgScoreResponse movie) async {
    final apiUrl = 'http://localhost:8080/api/v1/movies/${movie.id}';
    final http.Response response = await http.delete(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('확인'),
            content: Text('영화가 삭제되었습니다!'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      _fetchMovies(_currentPage);
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('에러'),
            content: Text('영화 삭제에 실패하였습니다!'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context, MovieWithAvgScoreResponse movie) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('영화 삭제'),
          content: Text('정말 삭제하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              child: Text('네'),
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteMovie(movie);
              },
            ),
            TextButton(
              child: Text('아니요'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _selectedGenre = null;
    _selectedOnScreen = null;
    _fetchMovies(0);
  }

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('영화 목록'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: DropdownButton<double>(
              value: _selectedAvgScore,
              hint: Text('평균 평점으로 필터링'),
              items: [
                DropdownMenuItem<double>(value: null, child: Text('전체')),
                DropdownMenuItem<double>(value: 1.0, child: Text('1.0 이상')),
                DropdownMenuItem<double>(value: 2.0, child: Text('2.0 이상')),
                DropdownMenuItem<double>(value: 3.0, child: Text('3.0 이상')),
                DropdownMenuItem<double>(value: 4.0, child: Text('4.0 이상')),
                DropdownMenuItem<double>(value: 4.5, child: Text('4.5 이상')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedAvgScore = value;
                  _fetchMovies(_currentPage);
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _movies.length,
              itemBuilder: (context, index) {
                final movie = _movies[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MovieDetailPage(movieId: movie.id)),
                    );
                  },
                  child: ListTile(
                    title: Text(movie.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('장르: ${movie.genre}'),
                        Text('상영중 여부: ${movie.onScreen ? '상영중' : '상영 종료'}'),
                        Text('평균 평점: ${movie.avgScore.toStringAsFixed(2)}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => MovieUpdatePage(movie: movie, onMovieUpdated: () => _fetchMovies(_currentPage))),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () async {
                            _showDeleteConfirmationDialog(context, movie);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MovieRegistrationPage()),
            );
          },
          child: Text('영화 추가'),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: MovieListPage()));
}
