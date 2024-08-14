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


class LikePostPage extends StatefulWidget {
  const LikePostPage({super.key});

  @override
  State<LikePostPage> createState() => _LikePostPageState();
}

class _LikePostPageState extends State<LikePostPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final controller = TextEditingController();
  List<Post> posts = [];
  List<Post> sortedPosts = [];
  List<Like> likelist = [];
  List<String> followlist = [];
  bool isLoading = true;
  int likeCount = 0;

  @override
  void initState() {
    super.initState();
    _initialize().then((_) {
      setState(() {
        isLoading = false;
      });
    });
  }


  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> fetchPosts() async {
    try {
      final response = await http.get(Uri.parse('${Url}/data'));
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
  
  Future<void> _initialize() async {
    try {

      await fetchPosts();
      // fetchLikedPosts 関数を呼び出して likelist を取得
      likelist = await LIKE().fetchLikedPosts(FirebaseAuth.instance.currentUser!.uid);
      likelist.sort((a, b) => b.likedAt.compareTo(a.likedAt));
      sortedPosts = likelist.map((like) {
        return posts.firstWhere((post) => post.postId == like.postId);
      }).toList();
      likeCount = sortedPosts.length;

      setState(() {
      });
    } catch (e) {
      // エラーハンドリングr
      print('Error loading follow list: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()), // ローディングインジケーター
      );
    }
    return Scaffold(
      key: _scaffoldKey,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title:  Text('いいね ${likeCount}'),
            floating: true,
            pinned: true,
          ),
          SliverList(
            
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                //final post = posts[index];
                final post = sortedPosts[index];
                final created = Timestamp.fromMillisecondsSinceEpoch(post.createdAt * 1000);
                if (likelist.any((like) => like.postId == post.postId)) {
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
              //childCount: posts.length,
              childCount: likelist.length,
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
