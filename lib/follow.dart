import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:firebase_core/firebase_core.dart';
//import 'firebase_options.dart';
import 'post.dart';
import 'dart:async';
import 'json_data.dart';
import 'user_post.dart';


class FollowingPage extends StatefulWidget {
  const FollowingPage({
    super.key,
  });

  @override
  State<FollowingPage> createState() => _FollowingPagePageState();
}

class _FollowingPagePageState extends State<FollowingPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Follow> followlist = [];
  String follower_id = FirebaseAuth.instance.currentUser!.uid;
  bool isfollowed = false;
  int followingCount = 0;

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
      // followUser 関数を呼び出して followlist を取得
      followlist = await FOLLOW().followUser(FirebaseAuth.instance.currentUser!.uid);
      // isfollow を更新
      followingCount = followlist.length;
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
            floating: true,
            pinned: false,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true, // タイトルを中央に配置
              title: Text(
                'フォロー中 ${followingCount}人',
                style: TextStyle(fontSize: 20.0), // フォントサイズを調整
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                Follow followData = followlist[index];    
                  return UserInf(followData:followData);
              },
              childCount: followlist.length,
            ),
          ),
        ],
      ), 
    ); 
  }
}

class UserInf extends StatefulWidget {
  const UserInf({
    super.key,
    required this.followData,
  });

  final Follow followData;
  @override
  State<UserInf> createState() => _UserInfState();
}

class _UserInfState extends State<UserInf>{

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
      user_data_json = await User_data().getUserdata(widget.followData.followee_id);

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
