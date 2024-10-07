import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'follow.dart';
import 'mypost.dart';
import 'post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'settingpage.dart';
import 'PostView.dart';
import 'ChatPage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'json_data.dart';
import 'likeposts.dart';
import 'followerPage.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ViewPage extends StatefulWidget {
  const ViewPage({super.key});

  @override
  State<ViewPage> createState() => _ViewPageState();
}

class _ViewPageState extends State<ViewPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final controller = TextEditingController();
  List<Post> posts = [];
  List<Like> likelist = [];
  User_inf? currentUser;
  //Timer? timer;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPosts();
    _initialize().then((_) {
      if (mounted) { 
        setState(() {
          isLoading = false;
        });
      }
    });
    //startPolling();
  }

  // void startPolling() {
  //   timer = Timer.periodic(Duration(seconds: 5), (timer) {
  //     fetchPosts();
  //   });
  // }
  Future<void> _onRefresh() async {
    await fetchPosts(); // 投稿を再取得
    setState(() {});
  }

  @override
  void dispose() {
    controller.dispose();
    //timer?.cancel();
    super.dispose();
  }

  Future<void> fetchPosts() async {
    try {
      final response = await http.get(Uri.parse('${Url}/data'));
      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        List<Post> fetchedPosts = jsonList.map((json) => Post.fromJson(json)).toList();
        if (mounted) { // mounted をチェック
          setState(() {
            posts = fetchedPosts.reversed.toList(); // リストを逆順にして設定
          });
        }
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
      currentUser = await User_data().getUserdata(FirebaseAuth.instance.currentUser!.uid);

      if (mounted) { // mounted をチェック
      setState(() {});
    }
    } catch (e) {
      // エラーハンドリング
      print('Error loading follow list: $e');
    }
  }


  @override
  Widget build(BuildContext context) {

    if (isLoading || currentUser == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()), // ローディングインジケーター
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      body: RefreshIndicator(
        onRefresh: _onRefresh, // スワイプで呼び出される関数
        displacement: 120.0, // SliverAppBar の高さを考慮して調整
        child: CustomScrollView(
          cacheExtent: 10000.0, // キャッシュ領域を指定（単位はピクセル)
          slivers: [
            SliverAppBar(
              title: const Text('チャット'),
              floating: true,
              pinned: true,
              leading: Builder(
                builder: (BuildContext context) {
                  return IconButton(
                    icon: CircleAvatar(
                      backgroundImage: CachedNetworkImageProvider(currentUser!.userImageUrl),
                    ),
                    onPressed: () {
                      _scaffoldKey.currentState!.openDrawer();
                    },
                  );
                },
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final post = posts[index];
                  final created = Timestamp.fromMillisecondsSinceEpoch(post.createdAt * 1000);
                  return PostWidget(
                      key: ValueKey(post.postId), // postIdをキーとして渡す
                      post: post,
                      created: created,
                      likelist: likelist,
                      );
                },
                childCount: posts.length,
                addRepaintBoundaries: false,
                
              ),
            ),
          ],
        ),
      ),  
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            DrawerHeader(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 20.0,
                    backgroundImage: NetworkImage(currentUser!.userImageUrl),
                  ),
                  SizedBox(height: 10.0),
                  Text('${currentUser!.user_name}'),
                ],
              ),
              decoration: BoxDecoration(
              ),
            ),
            ListTile(
              title: Text('プロフィール'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return const MypostPage();
                    },
                  ),
                );
              },
            ),
            ListTile(
              title: Text('フォロー中'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return const FollowingPage();
                    },
                  ),
                );
              },
            ),
            ListTile(
              title: Text('フォロワー'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return const FollowerPage();
                    },
                  ),
                );
              },
            ),
            ListTile(
              title: Text('いいね'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return const LikePostPage();
                    },
                  ),
                );
              },
            ),
            ListTile(
              title: Text('設定'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return const settingPage();
                    },
                  ),
                );
              },
            ),
          ],
        ),
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
