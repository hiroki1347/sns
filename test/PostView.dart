import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'json_data.dart';
//import 'json_upload.dart';
//import 'package:firebase_core/firebase_core.dart';
//import 'firebase_options.dart';
//import 'main.dart';
import 'post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'my_page.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';

//ポストの見た目
class PostWidget extends StatelessWidget {
  const PostWidget({
    super.key,
    required this.post,
    required this.created,
    //required this.Url,
  });
  final Timestamp created;
  final Post post;
  //final String Url;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, //アイコンを上に揃える
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(
              post.posterImageUrl,
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
                      post.posterName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                     // toDate() で Timestamp から DateTime に変換できます。
                      DateFormat('MM/dd HH:mm').format(created.toDate()),
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
                          if (post.text.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: FirebaseAuth.instance.currentUser!.uid == post.posterId
                                  ? Colors.amber[100]
                                  :Colors.blue[100],
                            ),
                            child: Text(
                              post.text,
                              softWrap: true,
                            ),
                          ),
                        //画像を表示
                        if(post.imageName != "null") 
                          CachedNetworkImage(
                            imageUrl: 'http://192.168.0.200:3000/images/${post.imageName}'
                            ),
                          // いいねボタンを追加
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.thumb_up),
                                onPressed: () async {
                                  try {
                                    // 現在のユーザーのUIDを取得
                                    String? userId = FirebaseAuth.instance.currentUser?.uid;
                                    
                                    if (userId != null) {
                                      // 「いいね」機能を呼び出す
                                      await LIKE().like(userId, post.postId);
                                      print("Liked by user: $userId for post: ${post.postId}");
                                    } else {
                                      print("User not logged in.");
                                    }
                                  } catch (e) {
                                    print("Error liking post: $e");
                                  }
                                },
                              ),
                              // 他の情報（いいねの数など）を表示するためにTextウィジェットなどを追加可能
                              Text(
                                'いいね数', //いいねの数を表示する
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    //自分のpost
                    //編集
                    if (FirebaseAuth.instance.currentUser!.uid == post.posterId)
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  content: TextFormField(
                                    initialValue: post.text,
                                    autofocus: true,
                                    onFieldSubmitted: (newText) {
                                      //post.text　post.postidを用いて編集する
                                      UPDATE().update(newText, post.postId);
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
                                        DELETE().delete(post.postId);
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                );
                              },
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
                        ],
                      ),

                    //他人のpost
                    if (FirebaseAuth.instance.currentUser!.uid != post.posterId)
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