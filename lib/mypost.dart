import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:firebase_core/firebase_core.dart';
//import 'firebase_options.dart';
import 'post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'my_page.dart';
//import 'package:intl/intl.dart';
import 'PostView.dart';
//import 'main.dart';
import 'ChatPage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'json_data.dart';


class MypostPage extends StatefulWidget {
  const MypostPage({super.key});

  @override
  State<MypostPage> createState() => _MypostPageState();
}

class _MypostPageState extends State<MypostPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final controller = TextEditingController();
  List<Post> posts = [];
  List<Like> likelist = [];
  Timer? timer;
  int postCount = 0;

  @override
  void initState() {
    super.initState();
    fetchPosts();
    _initialize();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> fetchPosts() async {
    String posterId = FirebaseAuth.instance.currentUser!.uid;
    try {
      final response = await http.get(Uri.parse('${Url}/user_post?posterId=$posterId'));
      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        List<Post> fetchedPosts = jsonList.map((json) => Post.fromJson(json)).toList();
        postCount = fetchedPosts.length;

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

  Future<void> _initialize() async {
    try {
      // fetchLikedPosts 関数を呼び出して likelist を取得
      likelist = await LIKE().fetchLikedPosts(FirebaseAuth.instance.currentUser!.uid);

      setState(() {
      });
    } catch (e) {
      // エラーハンドリング
      print('Error loading follow list: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 150.0,
            floating: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
                title: Text('Mypost'),
              ),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(30.0),
              child: Text(
                '${postCount}件のポスト',
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final post = posts[index];
                final created = Timestamp.fromMillisecondsSinceEpoch(post.createdAt * 1000);
                if (FirebaseAuth.instance.currentUser!.uid == post.posterId) {
                  return PostWidget(
                    key: ValueKey(post.postId), // postIdをキーとして渡す
                    post: post,
                    created: created,
                    likelist: likelist,
                    );
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
