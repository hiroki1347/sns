import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'json_upload.dart';
//import 'package:firebase_core/firebase_core.dart';
//import 'firebase_options.dart';
import '../lib/post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../lib/settingpage.dart';
//import 'package:intl/intl.dart';
import '../lib/PostView.dart';
//import 'main.dart';
import '../lib/ChatPage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

//タイムラインの構造
class ViewPage extends StatefulWidget {
  const ViewPage({super.key});

  @override
  State<ViewPage> createState() => _ViewPageState();
}

class _ViewPageState extends State<ViewPage> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final controller = TextEditingController();
  final ScrollController scrollController = ScrollController();
  List<Post> posts = [];
  Timer? timer;

  @override
  void initState() {
    super.initState();
    fetchPosts();
    startPolling();
  }

  void startPolling() {
    timer = Timer.periodic(Duration(seconds: 5), (timer) {
      fetchPosts();
    });
  }
  /// この dispose 関数はこのWidgetが使われなくなったときに実行されます。
  @override
  void dispose() {
    // TextEditingController は使われなくなったら必ず dispose する必要があります。
    controller.dispose();
    scrollController.dispose();
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
    return GestureDetector(
      onTap: () {
        primaryFocus?.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('チャット'),
          actions: [
            // tap 可能にするために InkWell を使います。
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return const MyPage();
                    },
                  ),
                );
              },
              child: CircleAvatar(
                backgroundImage: NetworkImage(
                  FirebaseAuth.instance.currentUser!.photoURL!,
                ),
              ),
            )
          ],
          leading:Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: CircleAvatar(
                backgroundImage: NetworkImage(''),
              ), 
              onPressed: () {
                _scaffoldKey.currentState!.openDrawer();
              },
            );
          },
        ),
        ),
        drawer: Drawer(
          child: ListView(
            children: <Widget>[
              DrawerHeader(
                child: Text('Drawer Header'),
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
              ),
              ListTile(
                title: Text('Profile'),
                onTap: () {
                  // Do something
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Item'),
                onTap: () {
                  // Do something
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
        body: 
        Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                //reverse: true, // リストを逆順に表示
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  final created = Timestamp.fromMillisecondsSinceEpoch(post.createdAt * 1000);
                  return PostWidget(post: post,created: created); // PostWidget をそのまま使用
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () async {
          // 投稿画面に遷移
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (context) {
                return ChatPage();
              }),
            );
            fetchPosts();
          },
        ),
        // drawer: Drawer(
        //   child: ListView(
        //     children: <Widget>[
        //       DrawerHeader(
        //         child: Text('Drawer Header'),
        //         decoration: BoxDecoration(
        //           color: Colors.blue,
        //         ),
        //       ),
        //       ListTile(
        //         title: Text('Profile'),
        //         onTap: () {
        //           // Do something
        //           Navigator.pop(context);
        //         },
        //       ),
        //       ListTile(
        //         title: Text('Item'),
        //         onTap: () {
        //           // Do something
        //           Navigator.pop(context);
        //         },
        //       ),
        //     ],
        //   ),
        // ),
      ),
    );
  }
}