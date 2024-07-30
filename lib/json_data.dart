import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
//import 'package:intl/intl.dart';
import 'post.dart';

class PostDataButton {

  Future<void> postData(String _text, XFile? image) async {
    final url = Uri.parse('http://192.168.0.200:3000/save');
    final headers = {"Content-Type": "application/json"};

    final user = FirebaseAuth.instance.currentUser!;
    final posterId = user.uid; // ログイン中のユーザーのIDがとれます
    final posterName = user.displayName!; // Googleアカウントの名前がとれます
    final posterImageUrl = user.photoURL!; // Googleアカウントのアイコンデータがとれます
    final createdAt = Timestamp.now();
    final time = createdAt.seconds;
    String imageName = "null";

    if (image != null) {
      String imagename = image.name; // 画像のファイル名を取得
      imageName = "${time}_${imagename}";
    }

    final body = json.encode({
      "createdAt": time,
      "posterName": posterName,
      "posterImageUrl": posterImageUrl,
      "posterId": posterId,
      "text": _text,
      "imageName": imageName
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        print('Data saved successfully');
      } else {
        print('Failed to save data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> upload(XFile? image) async {
    String uploadUrl = 'http://192.168.0.200:3000/upload'; // ここにサーバーのアップロードURLを設定します
    
    if (image == null) {
      print("image is null");
      return;
    }

    var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
    request.files.add(await http.MultipartFile.fromPath('picture', image.path));

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        print('Image uploaded successfully');
      } else {
        print('Image upload failed with status: ${response.statusCode}');
        }
    } catch (e) {
      print('Error uploading image: $e');
    }
  }
}

class UPDATE {

   Future<void> update(String newText, int postId) async {
    final url = Uri.parse('http://192.168.0.200:3000/update');
    final headers = {"Content-Type": "application/json"};

    final createdAt = Timestamp.now();
    final time = createdAt.seconds;

    final body = json.encode({
      "createdAt": time,
      "newText": newText,
      "postId": postId,
    });

    print('Sending update request: $body to $url');

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        print('Data update successfully');
      } else {
        print('Failed to update data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}

class DELETE {

   Future<void> delete(int postId) async {
    final url = Uri.parse('http://192.168.0.200:3000/delete');
    final headers = {"Content-Type": "application/json"};

    final body = json.encode({
      "postId": postId,
    });
    print('Sending delete request: $body to $url');

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        print('Data update successfully');
      } else {
        print('Failed to update data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}

class PostService {
  Future<List<Post>> fetchPosts() async {
    final url = Uri.parse('http://192.168.0.200:3000/data'); // 適切なエンドポイントに変更
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Post.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load posts');
    }
  }
}