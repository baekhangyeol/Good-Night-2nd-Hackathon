import 'package:flutter/material.dart';
import 'package:hackaton_flutter/pages/movieListPage.dart';
import 'package:hackaton_flutter/provider/AuthProvider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:provider/provider.dart';

class MovieRegistrationPage extends StatefulWidget {
  @override
  _MovieRegistrationPageState createState() => _MovieRegistrationPageState();
}

class _MovieRegistrationPageState extends State<MovieRegistrationPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _openDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  String _selectedGenre = 'ACTION'; // Default genre value

  void _clearFormFields() {
    _titleController.clear();
    _openDateController.clear();
    _endDateController.clear();
    setState(() {
      _selectedGenre = 'ACTION';
    });
  }

  Future<void> _registerMovie() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    authProvider.setAdminStatus(true);
    if(authProvider.isAdmin) {
      final String apiUrl = 'http://localhost:8080/api/v1/movies'; // 자신의 엔드포인트로 변경하세요

    if (_titleController.text.isEmpty ||
        _openDateController.text.isEmpty ||
        _endDateController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('에러'),
            content: Text('모든 항목을 기입해주세요!'),
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
      return;
    }

    final Map<String, dynamic> requestData = {
      'title': _titleController.text,
      'genre': _selectedGenre,
      'openDate': _openDateController.text,
      'endDate': _endDateController.text,
    };

    final http.Response response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestData),
    );

    if (response.statusCode == 200) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('성공'),
            content: Text('영화가 등록되었습니다!'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                  _clearFormFields();
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => MovieListPage(),
                  ));
                },
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('에러'),
            content: Text('영화 등록에 실패하였습니다!'),
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
    else {
      
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('영화 등록'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(labelText: '제목'),
            ),
            DropdownButtonFormField(
              value: _selectedGenre,
              items: [
                DropdownMenuItem(value: 'ACTION', child: Text('ACTION')),
                DropdownMenuItem(value: 'THRILLER', child: Text('THRILLER')),
                DropdownMenuItem(value: 'ROMANCE', child: Text('ROMANCE')),
                DropdownMenuItem(value: 'COMEDY', child: Text('COMEDY')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedGenre = value.toString();
                });
              },
              decoration: InputDecoration(labelText: '장르'),
            ),
            TextFormField(
              readOnly: true,
              controller: _openDateController,
              onTap: () async {
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                  _openDateController.text =
                      pickedDate.toLocal().toString().split(' ')[0];
                }
              },
              decoration: InputDecoration(labelText: '개봉일 (yyyy-MM-dd)'),
            ),
            TextFormField(
              readOnly: true,
              controller: _endDateController,
              onTap: () async {
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                  _endDateController.text =
                      pickedDate.toLocal().toString().split(' ')[0];
                }
              },
              decoration: InputDecoration(labelText: '상영마감일 (yyyy-MM-dd)'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _registerMovie,
              child: Text('등록'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // 뒤로가기 버튼
              },
              child: Text('뒤로가기'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: MovieRegistrationPage()));
}
