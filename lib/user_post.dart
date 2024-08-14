import 'dart:ui';
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


class UserpostPage extends StatefulWidget {
  const UserpostPage({
    super.key,
    required this.user_data_json,
  });

  final User_inf user_data_json;

  @override
  State<UserpostPage> createState() => _UserpostPageState();
}

class _UserpostPageState extends State<UserpostPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final controller = TextEditingController();
  List<Post> posts = [];
  List<Like> likelist = [];
  List<Follow> followlist = [];
  Timer? timer;
  String follower_id = FirebaseAuth.instance.currentUser!.uid;
  bool isfollowed = false;
  bool isLoading = true; // ローディングフラグ
  int postCount = 0;

  @override
  void initState() {
    super.initState();
    _initialize().then((_) {
      setState(() {
        isLoading = false;
      });
    });
    fetchPosts();
    startPolling();
  }

  void startPolling() {
    timer = Timer.periodic(Duration(seconds: 5), (timer) {
      fetchPosts();
    });
  }

  @override
  void dispose() {
    controller.dispose();
    timer?.cancel();
    super.dispose();
  }

  void togglefollow() async {
    
    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId != null) {
        setState(() {
          isfollowed = !isfollowed;
        });

        if (isfollowed) {
          await FOLLOW().follow(follower_id,widget.user_data_json.user_id);
        } else {
          await FOLLOW().unfollow(follower_id,widget.user_data_json.user_id);
        }
        print("User: $userId, Followee: ${widget.user_data_json.user_id}, followed: $isfollowed");
      } else {
        print("User not ged in.");
      }
    } catch (e) {
      print("Error liking post: $e");
    }
  }

  Future<void> fetchPosts() async {
    String posterId = widget.user_data_json.user_id;
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
      // followUser 関数を呼び出して followlist を取得
      followlist = await FOLLOW().followUser(FirebaseAuth.instance.currentUser!.uid);
      // fetchLikedPosts 関数を呼び出して likelist を取得
      likelist = await LIKE().fetchLikedPosts(FirebaseAuth.instance.currentUser!.uid);

      // isfollow を更新
      setState(() {
        isfollowed = followlist.any((follow) => follow.followee_id == widget.user_data_json.user_id);
      });
    } catch (e) {
      // エラーハンドリング
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
            expandedHeight: 150.0,
            floating: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false, // タイトルを中央に配置
              titlePadding: EdgeInsets.only(left: 60, bottom: 18), // パディングを調整
              title: Row(
                children: [
                  Text(
                    '${widget.user_data_json.user_name}',
                    style: TextStyle(fontSize: 20.0), // フォントサイズを調整
                  ),

                  SizedBox(
                    width: 10,
                    ),
                  
                  SizedBox(
                    width: 95, // ボタンの幅
                    height: 20, // ボタンの高さ
                    child: OutlinedButton(
                      child: Text(
                      isfollowed ? 'フォロー中' : 'フォローする', // 条件に応じてテキストを変更
                      style: TextStyle(
                        fontSize: 9,
                        letterSpacing: -1.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                  
                      ),
                      style: OutlinedButton.styleFrom(
                        shape: const StadiumBorder(),
                        side: const BorderSide(color: Colors.green),
                        backgroundColor: isfollowed ? Colors.green:Colors.white, // 中身の色（背景色）を設定
                      ),
                      onPressed: () {
                        togglefollow();
                      }
                    ),
                  ),                 
                ],
              ),
            ),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(60.0),
              child: Container(
                child: Text(
                  '${postCount}件のポスト',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final post = posts[index];
                final created = Timestamp.fromMillisecondsSinceEpoch(post.createdAt * 1000);
                if (widget.user_data_json.user_id == post.posterId) {
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
