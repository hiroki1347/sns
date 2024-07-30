import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class PostDataButton extends StatelessWidget {
  //PostDataButton({required this.text});
  //  final String text;

  Future<void> postData() async {
    final url = Uri.parse('http://192.168.0.200:3000/save');
    final headers = {"Content-Type": "application/json"};
    
    final user = FirebaseAuth.instance.currentUser!;
    final posterId = user.uid; // ログイン中のユーザーのIDがとれます
    final posterName = user.displayName!; // Googleアカウントの名前がとれます
    final posterImageUrl = user.photoURL!; // Googleアカウントのアイコンデータがとれます
    
    final createdAt = Timestamp.now(),
    time = DateFormat('yyyy/MM/dd HH:mm:ss').format(createdAt.toDate());

    final body = json.encode({
      "createdAt": time,
      "posterName": posterName,
      "posterImageUrl": posterImageUrl,
      "posterId": posterId,
      "text": "abc"
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

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: postData,
      child: Text('Send Data'),
    );
  }
}
