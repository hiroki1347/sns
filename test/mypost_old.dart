import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'json_upload.dart';
//import 'package:firebase_core/firebase_core.dart';
//import 'firebase_options.dart';
import '../lib/post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'my_page.dart';
//import 'package:intl/intl.dart';
import '../lib/PostView.dart';
//import 'main.dart';
import '../lib/ChatPage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';


class MypostPage extends StatefulWidget {
  const MypostPage({super.key});

  @override
  State<MypostPage> createState() => _MypostPageState();
}

class _MypostPageState extends State<MypostPage> {
  final controller = TextEditingController();
  List<Post> posts = [];
  Timer? timer;

  @override
  void initState() {
    super.initState();
    fetchPosts();
    //startPolling();
  }

  void startPolling() {
    timer = Timer.periodic(Duration(seconds: 50), (timer) {
      fetchPosts();
    });
  }

  @override
  void dispose() {
    controller.dispose();
    timer?.cancel();
    super.dispose();
  }

  Future<void> fetchPosts() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.0.200:3000/data'));
      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        List<Post> fetchedPosts = jsonList.map((json) => Post.fromJson(json)).toList();
        setState(() {
          posts = fetchedPosts.reversed.toList(); // リストを逆順にして設定
        });
      } else {
        print('Failed to load data with status code: ${response.statusCode}');
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 150.0,
            floating: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
                title: Text('Mypost'),
              ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final post = posts[index];
                final created = Timestamp.fromMillisecondsSinceEpoch(post.createdAt * 1000);
                if (FirebaseAuth.instance.currentUser!.uid == post.posterId) {
                  return PostWidget(post: post, created: created, );
                } else {
                  return SizedBox.shrink();
                }
              },
              childCount: posts.length,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) {
              return ChatPage();
            }),
          );
          fetchPosts();
        },
      ),
    );
  }
}