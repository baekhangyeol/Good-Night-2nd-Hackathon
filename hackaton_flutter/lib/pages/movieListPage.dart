import 'package:flutter/material.dart';
import 'package:hackaton_flutter/pages/movieDetailPage.dart';
import 'package:hackaton_flutter/pages/movieRegistrationPage.dart';
import 'package:hackaton_flutter/pages/movieUpdatePage.dart';
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
  }
}

Future<void> _deleteMovie(MovieResponse movie) async {
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
    // 삭제 성공
    _fetchMovies(); // 영화 목록 다시 불러오기
  } else {
    // 삭제 실패
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

void _showDeleteConfirmationDialog(BuildContext context, MovieResponse movie) {
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
              Navigator.of(context).pop(); // 팝업 창 닫기
              await _deleteMovie(movie); // 영화 삭제 함수 호출
            },
          ),
          TextButton(
            child: Text('아니요'),
            onPressed: () {
              Navigator.of(context).pop(); // 팝업 창 닫기
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
          return InkWell( // 변경된 부분: ListTile 대신 InkWell 사용
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MovieDetailPage(movieId: movie.id)),
              );
            },
            child: ListTile(
              title: Text(movie.title),
              subtitle: Text('장르: ${movie.genre}\n상영중 여부: ${movie.onScreen ? '상영중' : '상영 종료'}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MovieUpdatePage(movie: movie, onMovieUpdated: _fetchMovies)),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete), // 삭제 버튼 아이콘
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
