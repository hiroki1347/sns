import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class Post {
  final int createdAt;
  final String posterName;
  final String posterImageUrl;
  final String posterId;
  final String text;
  final String imageName;

  Post({
    required this.createdAt,
    required this.posterName,
    required this.posterImageUrl,
    required this.posterId,
    required this.text,
    required this.imageName,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      createdAt: json['createdAt'],
      posterName: json['posterName'],
      posterImageUrl: json['posterImageUrl'],
      posterId: json['posterId'],
      text: json['text'],
      imageName: json['imageName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'createdAt': createdAt,
      'posterName': posterName,
      'posterImageUrl': posterImageUrl,
      'posterId': posterId,
      'text': text,
      'imageName': imageName,
    };
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PostListScreen(),
    );
  }
}

class PostListScreen extends StatefulWidget {
  @override
  _PostListScreenState createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  List<Post> Posts = [];

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    final response = await http.get(Uri.parse('http://192.168.0.200:3000/data'));
    if (response.statusCode == 200) {
      List<dynamic> jsonlist = jsonDecode(response.body);

      // リストの各要素をPostオブジェクトに変換
      List<Post> fetchedPosts = jsonlist.map((json) => Post.fromJson(json)).toList();

      setState(() {
        Posts = fetchedPosts;
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          'user_name',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      body: Posts.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: Posts.length,
              itemBuilder: (context, index) {
                final Post = Posts[index];
                return ListTile(
                  title: Text("${Post.createdAt}"),
                  subtitle: Text('Age: ${Post.text}'),
                  trailing: Text('ID: ${Post.imageName}'),
                );
              },
            ),
    );
  }
}
