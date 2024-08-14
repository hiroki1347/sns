import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
//import 'package:intl/intl.dart';
import 'post.dart';

class PostDataButton {
  //user_dataから送れるように変更する
  Future<void> postData(String _text, XFile? image) async {
    final url = Uri.parse('${Url}/save');
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
    String uploadUrl = '${Url}/upload'; // ここにサーバーのアップロードURLを設定します
    
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
    final url = Uri.parse('${Url}/update');
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
    final url = Uri.parse('${Url}/delete');
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

class LIKE {

  Future<void> like(String user_id, int postId) async {
    final url = Uri.parse('${Url}/like');
    final likedAt = Timestamp.now();
    final time = likedAt.seconds;
    final headers = {"Content-Type": "application/json"};
    final body = json.encode({
      "user_id": user_id,
      "postId": postId,
      "likedAt": time,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        print('like successfully');
      } else {
        print('Failed to like: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> unlike(String user_id, int postId) async {
    final url = Uri.parse('${Url}/unlike');

    final headers = {"Content-Type": "application/json"};
    final body = json.encode({
      "user_id": user_id,
      "postId": postId,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        print('unlike successfully');
      } else {
        print('Failed to unlike: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<List<Like>> fetchLikedPosts(String user_id) async {
    final response = await http.get(Uri.parse('${Url}/user_likes?user_id=$user_id'));

    if (response.statusCode == 200) {
      List<dynamic> likedPostIds = jsonDecode(response.body);
      List<Like> likelist = likedPostIds.map((json) => Like.fromJson(json)).toList();
      return likelist;
    } else {
      throw Exception('Failed to load liked posts');
    }
  }

  Future<List<Like>> getLikenum(int postId) async {
    final response = await http.get(Uri.parse('${Url}/get_like_num?postId=$postId'));

    if (response.statusCode == 200) {
      List<dynamic> likenum = jsonDecode(response.body);
      List<Like> likeusers = likenum.map((json) => Like.fromJson(json)).toList();
      return likeusers;
    } else {
      throw Exception('Failed to load liked posts');
    }
  }
}

class FOLLOW {

  Future<void> follow(String follower_id, String followee_id) async {
    final url = Uri.parse('${Url}/follow');
    final followedAt = Timestamp.now();
    final time = followedAt.seconds;
    final headers = {"Content-Type": "application/json"};
    final body = json.encode({
      "follower_id": follower_id,
      "followee_id": followee_id,
      "followedAt": time,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        print('follow successfully');
      } else {
        print('Failed to follow: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> unfollow(String follower_id, String followee_id) async {
    final url = Uri.parse('${Url}/unfollow');

    final headers = {"Content-Type": "application/json"};
    final body = json.encode({
      "follower_id": follower_id,
      "followee_id": followee_id,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        print('unfollow successfully');
      } else {
        print('Failed to unfollow: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<List<Follow>> followUser(String user_id) async {
    final response = await http.get(Uri.parse('${Url}/user_follow?user_id=$user_id'));

    if (response.statusCode == 200) {
      List<dynamic> follow_users = jsonDecode(response.body);
      List<Follow> followlist = follow_users.map((json) => Follow.fromJson(json)).toList();
      return followlist;
    } else {
      throw Exception('Failed to load follows');
    }
  }

  Future<List<Follow>> getFollower(String followee_id) async {
    final response = await http.get(Uri.parse('${Url}/get_follower?followee_id=$followee_id'));

    

    if (response.statusCode == 200) {
      List<dynamic> followers = jsonDecode(response.body);
      List<Follow> followerlist = followers.map((json) => Follow.fromJson(json)).toList();

      return followerlist;
    } else {
      throw Exception('Failed to load follows');
    }
  }
}

class User_data {
  Future<void> edituserdata(User_inf changedata) async {

    final url = Uri.parse('${Url}/user_inf');
    final user_id = changedata.user_id;
    final user_name = changedata.user_name;
    final userImageUrl = changedata.userImageUrl;
    final createdAt = Timestamp.now();
    final time = createdAt.seconds;
    final headers = {"Content-Type": "application/json"};
    final body = json.encode({
      "user_id": user_id,
      "user_name": user_name,
      "userImageUrl": userImageUrl,
      "createdAt": time,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        print('user_inf successfully');
      } else {
        print('Failed to user_inf: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> firstuserdata() async {

    final url = Uri.parse('${Url}/first_inf');
    final user = FirebaseAuth.instance.currentUser!;
    final user_id = user.uid;
    final user_name = user.displayName;
    final userImageUrl = user.photoURL;
    final createdAt = Timestamp.now();
    final time = createdAt.seconds;
    
    final headers = {"Content-Type": "application/json"};
    final body = json.encode({
      "user_id": user_id,
      "user_name": user_name,
      "userImageUrl": userImageUrl,
      "createdAt": time,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        print('first_inf successfully');
      } else {
        print('Failed to fisrt_inf: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<User_inf> getUserdata(String user_id) async {
    final response = await http.get(Uri.parse('${Url}/get_user_inf?user_id=$user_id'));

    //print(response.body);

    if (response.statusCode == 200) {
      dynamic user_data = jsonDecode(response.body);
      User_inf user_data_json = User_inf.fromJson(user_data);
      return user_data_json;
    } else {
      throw Exception('Failed to load follows');
    }
  }

  // サーバーに登録済みかどうかを確認する関数
  Future<bool> checkUserExists(String uid) async {
    final response = await http.get(
      Uri.parse('${Url}/check_user?uid=$uid'),
    );

    if (response.statusCode == 200) {
      // サーバーがユーザーの存在を確認できた場合
      final check = json.decode(response.body);
      return check['exists'];  // サーバーがユーザーの存在を真偽値で返すと仮定
    } else {
      throw Exception('Failed to check user existence');
    }
  }
}