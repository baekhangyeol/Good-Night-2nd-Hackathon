import 'package:flutter/material.dart';
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

class ReviewResponse {
  final int id;
  final double score;
  final String content;

  ReviewResponse({
    required this.id,
    required this.score,
    required this.content,
  });

  factory ReviewResponse.fromJson(Map<String, dynamic> json) {
    return ReviewResponse(
      id: json['id'],
      score: json['score'],
      content: json['content'],
    );
  }
}


class MovieDetailPage extends StatefulWidget {
  final int movieId;

  MovieDetailPage({required this.movieId});

  @override
  _MovieDetailPageState createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  final TextEditingController _contentController = TextEditingController();
  String _feedbackMessage = '';
  double _rating = 0.0;
  List<ReviewResponse> _reviews = [];
  double _minRatingFilter = 0.0;
  List<ReviewResponse> _filteredReviews = [];
  
  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  void _submitReview(BuildContext context) async {
    final double score = _rating;
    final String content = _contentController.text;

    if (score == 0 || content.isEmpty) {
      _showFeedbackDialog(context, '필수 값이 누락되었습니다', false);
    } else {
      final int movieId = widget.movieId;
      final Map<String, dynamic> reviewData = {
        'movieId': movieId,
        'score': score,
        'content': content,
      };

      final http.Response response = await http.post(
        Uri.parse('http://localhost:8080/api/v1/reviews'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(reviewData),
      );

      if (response.statusCode == 200) {
        _contentController.clear();
        setState(() {
          _rating = 0.0; // Reset the rating after successful submission
        });
        _showFeedbackDialog(context, '리뷰가 등록되었습니다', true);
        
        // Fetch reviews to update the list after submitting a review
        await _fetchReviews();
      } else {
        _showFeedbackDialog(context, '리뷰 등록에 실패했습니다', false);
      }
    }
  }


  void _showFeedbackDialog(BuildContext context, String message, bool isSuccess) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isSuccess ? 'Success' : 'Error'),
          content: Text(message),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                if (isSuccess) {
                  _feedbackMessage = message;
                }
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
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
                  SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('평점 선택: $_rating'),
                      Slider(
                        value: _rating,
                        onChanged: (value) {
                          setState(() {
                            _rating = value;
                          });
                        },
                        min: 0.0,
                        max: 5.0,
                        divisions: 10,
                        label: _rating.toStringAsFixed(1),
                      ),
                    ],
                  ),
                  DropdownButton<double>(
                    value: _minRatingFilter,
                    onChanged: (newValue) {
                      setState(() {
                        _minRatingFilter = newValue!;
                        _applyRatingFilter(); // Apply filter when dropdown changes
                      });
                    },
                    items: [
                      DropdownMenuItem(value: 0.0, child: Text('전체 리뷰')),
                      DropdownMenuItem(value: 1.0, child: Text('1.0점 이상')),
                      DropdownMenuItem(value: 2.0, child: Text('2.0점 이상')),
                      DropdownMenuItem(value: 3.0, child: Text('3.0점 이상')),
                      DropdownMenuItem(value: 4.0, child: Text('4.0점 이상')),
                      DropdownMenuItem(value: 5.0, child: Text('5.0점')),
                    ],
                  ),
                  TextField(
                    controller: _contentController,
                    decoration: InputDecoration(labelText: '리뷰 내용'),
                    maxLines: 3,
                  ),
                  ElevatedButton(
                    onPressed: () => _submitReview(context),
                    child: Text('리뷰 등록'),
                  ),
                  SizedBox(height: 16),
                  Text(
                    _feedbackMessage,
                    style: TextStyle(
                      color: _feedbackMessage.contains('성공') ? Colors.green : Colors.red,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                  _feedbackMessage,
                  style: TextStyle(
                    color: _feedbackMessage.contains('성공') ? Colors.green : Colors.red,
                  ),
                ),
                SizedBox(height: 16),
                Text('리뷰 목록:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                _filteredReviews.isEmpty
                    ? Text('등록된 리뷰가 없습니다.')
                    : Expanded(
                        child: ListView.builder(
                          itemCount: _filteredReviews.length,
                          itemBuilder: (context, index) {
                            final review = _filteredReviews[index];
                            return ListTile(
                              title: Text('평점: ${review.score.toString()}'),
                              subtitle: Text(review.content),
                            );
                          },
                        ),
                      ),
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

  Future<MovieResponse> _fetchMovieDetails() async {
    final String apiUrl = 'http://localhost:8080/api/v1/movies/${widget.movieId}';

    final http.Response response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(utf8.decode(response.bodyBytes));
      return MovieResponse.fromJson(json);
    } else {
      throw Exception('Failed to fetch movie details');
    }
  }

  Future<void> _fetchReviews() async {
    final String apiUrl = 'http://localhost:8080/api/v1/reviews?movieId=${widget.movieId}';

    final http.Response response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
      final List<ReviewResponse> reviews = jsonList.map((json) => ReviewResponse.fromJson(json)).toList();
      setState(() {
        _reviews = reviews;
        _applyRatingFilter(); // Apply the filter after updating reviews
      });
    } else {
      throw Exception('Failed to fetch reviews');
    }
  }

  void _applyRatingFilter() {
    setState(() {
      if (_minRatingFilter > 0) {
        _filteredReviews = _reviews.where((review) => review.score >= _minRatingFilter).toList();
      } else {
        _filteredReviews = _reviews; // Show all reviews when no filter is applied
      }
    });
  }
}