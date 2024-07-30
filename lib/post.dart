//import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final int createdAt;
  final String posterName;
  final String posterImageUrl;
  final String posterId;
  final String text;
  final String imageName;
  final int postId;

  Post({
    required this.createdAt,
    required this.posterName,
    required this.posterImageUrl,
    required this.posterId,
    required this.text,
    required this.imageName,
    required this.postId,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      createdAt: json['createdAt'] ,
      posterName: json['posterName'],
      posterImageUrl: json['posterImageUrl'],
      posterId: json['posterId'],
      text: json['text'],
      imageName: json['imageName'],
      postId: json['postId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'createdAt': createdAt,
      'posterName': posterName,
      'posterImageUrl': posterImageUrl,
      'posterId': posterId,
      'text': text,
      'imageName': imageName,
      'postId': postId,
    };
  }
}
