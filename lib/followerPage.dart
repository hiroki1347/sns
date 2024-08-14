import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:firebase_core/firebase_core.dart';
//import 'firebase_options.dart';
import 'post.dart';
import 'dart:async';
import 'json_data.dart';
import 'user_post.dart';

class FollowerPage extends StatefulWidget {
  const FollowerPage({
    super.key,
  });

  @override
  State<FollowerPage> createState() => _FollowerPagePageState();
}

class _FollowerPagePageState extends State<FollowerPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Follow> followerlist = [];
  int followerCount = 0;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    super.dispose();
  }


  Future<void> _initialize() async {
    try {
      // getFollower 関数を呼び出して followerlist を取得
      followerlist = await FOLLOW().getFollower(FirebaseAuth.instance.currentUser!.uid);
      followerCount = followerlist.length;
      
      setState(() {
      });
    } catch (e) {
      // エラーハンドリング
      print('Error loading follower list: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: false,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true, // タイトルを中央に配置
              title: Text(
                'フォロワー ${followerCount}人',
                style: TextStyle(fontSize: 20.0), // フォントサイズを調整
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                Follow followerData = followerlist[index];
                  return followerInf(followerData:followerData);
              },
              childCount: followerlist.length,
            ),
          ),
        ],
      ), 
    ); 
  }
}

class followerInf extends StatefulWidget {
  const followerInf({
    super.key,
    required this.followerData,
  });

  final Follow followerData;

  @override
  State<followerInf> createState() => _followerInfState();
}

class _followerInfState extends State<followerInf>{

  bool isLoading = true;

  @override
    void initState() {
      super.initState();
      _initialize().then((_) {
        setState(() {
          isLoading = false;
        });
      });
    }

  late User_inf user_data_json;

  Future<void> _initialize() async {
    try {
      // getUserdataも呼び出してuser_data_jsonを所得
      user_data_json = await User_data().getUserdata(widget.followerData.follower_id);

      setState(() {
      });
    } catch (e) {
      // エラーハンドリング
      print('Error loading follow list: $e');
    }
  }

  @override
  Widget build(BuildContext context) {

    if (isLoading) {
      return Center(child: CircularProgressIndicator()); // ローディング中のインジケーター
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, //アイコンを上に揃える
        children: [
          InkWell(
            onTap: () {
              //user_iconボタンを押した時の処理
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return UserpostPage(user_data_json:user_data_json,);
                  },
                ),
              );            
            },
            child: CircleAvatar(
              backgroundImage: NetworkImage(user_data_json.userImageUrl),
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      user_data_json.user_name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}