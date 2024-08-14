import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'mypost.dart';
import 'json_data.dart';
import 'post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'user_post.dart';
import 'dart:async';
import 'likeusersPage.dart';

//ポストの見た目
class PostWidget extends StatefulWidget {
  const PostWidget({
    Key? key,
    required this.post,
    required this.created,
    required this.likelist,
  });

  final Timestamp created;
  final Post post;
  final List<Like> likelist;

  @override
  _PostWidgetState createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> with AutomaticKeepAliveClientMixin {
  bool isLiked = false;
  //Timer? timer;
  late List<Like> likeusers;
  int likeCount = 0;
  bool isLoading =true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    //初期状態の「いいね」を取得
    _initialize().then((_) {
      if (mounted) { // mounted をチェック
        setState(() {
          isLoading = false;
        });
      }
    });
  }

   @override
  void dispose() {
    //timer?.cancel();
    super.dispose();
  }

  Future<void> _initialize() async {
    isLiked = widget.likelist.any((like) => like.postId == widget.post.postId);

      try {
        likeusers = await LIKE().getLikenum(widget.post.postId);
        likeCount = likeusers.length;
        if (mounted) { // mounted をチェック
          setState(() {});
        }
      } catch (e) {
        // エラーハンドリング
        print('Error loading like list: $e');
      }
    }

  void toggleLike() async {
    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId != null) {
        setState(() {
          isLiked = !isLiked;
        });

        if (isLiked) {
          await LIKE().like(userId, widget.post.postId);
        } else {
          await LIKE().unlike(userId, widget.post.postId);
        }
        print("User: $userId, Post: ${widget.post.postId}, Liked: $isLiked");

        // いいね数の再取得を追加
        final updatedLikeUsers = await LIKE().getLikenum(widget.post.postId);
        setState(() {
          likeCount = updatedLikeUsers.length;
        });
      } else {
        print("User not logged in.");
      }
    } catch (e) {
      print("Error liking post: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    if (isLoading) {
      return Center(child: CircularProgressIndicator()); // ローディング中のインジケーター
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, //アイコンを上に揃える
        children: [

          InkWell(
            onTap: () async {
              //user_iconボタンを押した時の処理
              String user_id = widget.post.posterId;
              String my_id = FirebaseAuth.instance.currentUser!.uid;

              // user_data_jsonを取得
              User_inf user_data_json = await User_data().getUserdata(user_id);

              //user_pageに遷移する
              if (user_id == my_id) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return MypostPage();
                    },
                  ),
                );
              } else {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return UserpostPage(user_data_json:user_data_json,);
                    },
                  ),
                );
              }
            },
            child: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(widget.post.posterImageUrl),
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
                      widget.post.posterName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      // toDate() で Timestamp から DateTime に変換できます。
                      DateFormat('MM/dd HH:mm').format(widget.created.toDate()),
                      style: const TextStyle(fontSize: 10),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.post.text.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: FirebaseAuth.instance.currentUser!.uid == widget.post.posterId
                                    ? Colors.amber[100]
                                    : Colors.blue[100],
                              ),
                              child: Text(
                                widget.post.text,
                                softWrap: true,
                              ),
                            ),
                          //画像を表示
                          if (widget.post.imageName != "null")
                            CachedNetworkImage(
                              imageUrl: '${Url}/images/${widget.post.imageName}',
                            ),
                          // いいねボタンを追加
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.thumb_up,
                                  color: isLiked ? Colors.blue : Colors.grey,
                                ),
                                onPressed: toggleLike,
                              ),
                              Text(
                                'いいね ${likeCount}', // 実際のいいね数を表示するためのロジックを追加してください
                                style: TextStyle(color: Colors.black),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    //自分のpost
                    //編集
                    if (FirebaseAuth.instance.currentUser!.uid == widget.post.posterId)
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  content: TextFormField(
                                    initialValue: widget.post.text,
                                    autofocus: true,
                                    onFieldSubmitted: (newText) {
                                      //post.text　post.postidを用いて編集する
                                      UPDATE().update(newText, widget.post.postId);
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                );
                              },
                            );
                          } else if (value == 'delete') {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Delete'),
                                  content: const Text('このポストを削除しますか？'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        //post.postidを用いて削除する関数を入れる
                                        DELETE().delete(widget.post.postId);
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                );
                              },
                            );
                          } else if (value == 'いいね') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LikeUsersPage(likeusers: likeusers),
                              ),
                            );
                          }
                        },
                        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(
                            value: 'edit',
                            child: Text('Edit'),
                          ),
                          const PopupMenuItem<String>(
                            value: 'delete',
                            child: Text('Delete'),
                          ),
                          const PopupMenuItem<String>(
                            value: 'いいね',
                            child: Text('いいね'),
                          ),
                        ],
                      ),
                    //他人のpost
                    if (FirebaseAuth.instance.currentUser!.uid != widget.post.posterId)
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'no action') {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('No action'),
                                  content: const Text('何もしない'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('何もしない'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('何もしない'),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        },
                        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(
                            value: 'no action',
                            child: Text('no action'),
                          ),
                        ],
                      ),
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
