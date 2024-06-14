import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'json_upload.dart';
//import 'package:firebase_core/firebase_core.dart';
//import 'firebase_options.dart';
//import 'AddPostPage.dart';
//import 'main.dart';
import 'post.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
//import 'my_page.dart';
//import 'ChatField.dart';
import 'package:intl/intl.dart';

//ポストの見た目
class PostWidget extends StatelessWidget {
  const PostWidget({
    super.key,
    required this.post,
  });

  final Post post;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
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
                      DateFormat('MM/dd HH:mm').format(post.createdAt.toDate()),
                      style: const TextStyle(fontSize: 10),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: FirebaseAuth.instance.currentUser!.uid == post.posterId ? Colors.amber[100] : Colors.blue[100],
                        ),
                        child: Text(
                          post.text,
                          softWrap: true,
                        ),
                      ),
                    ),
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
                                      post.reference.update({'text': newText});
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
                                        post.reference.delete();
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