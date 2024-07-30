import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
//import 'package:http/http.dart' as http;
import 'json_data.dart';
//import 'package:firebase_core/firebase_core.dart';

class ChatPage extends StatefulWidget {
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  XFile? _image = null;
  final imagePicker = ImagePicker();
  final TextEditingController _controller = TextEditingController();
  String _text = "";
  // ギャラリーから写真を取得するメソッド
  Future getImageFromGallery() async {
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = XFile(pickedFile.path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 120,
        leading: TextButton(
          child: Text(
            'キャンセル',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
              ), // 文字色を設定

          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 8),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: TextFormField(
                controller: _controller,
                maxLines: null,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.amber),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Colors.amber,
                      width: 2,
                    ),
                  ),
                  fillColor: Colors.amber[50],
                  filled: true,
                ),
                onChanged: (text) {
                  setState(() {
                    _text = text;
                  });
                },
              ),
            ),
          ),
          SizedBox(height: 8),
          Center(
            // 取得した写真を表示(ない場合はメッセージ)
            child: _image == null
                ? Text(
                    '写真を選択してください',
                    style: Theme.of(context).textTheme.headlineMedium,
                  )
                : Image.file(File(_image!.path)),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // uploadするボタン
          FloatingActionButton(
            onPressed: () {
              if ((_image != null) && (_text != "")) {
                // ここでPostDataButtonをインスタンス化し、画像を渡す
                PostDataButton().postData(_text,_image);
                PostDataButton().upload(_image!);
              }
              if ((_image == null) && (_text != "")) {
                PostDataButton().postData(_text,_image);
                PostDataButton().upload(_image);
              }
              if ((_image != null) && (_text == "")) {
                PostDataButton().postData(_text,_image);
                PostDataButton().upload(_image!);
              }
              if ((_image == null) && (_text == "")) {
                print("image is null");
              }

              _controller.clear();

              setState(() {
                _image = null;
                _text = "";
              });
            },
            child: Text('Upload'),
          ),
          // ギャラリーから取得するボタン
          FloatingActionButton(
            onPressed: getImageFromGallery,
            child: const Icon(Icons.photo_album),
          ),
        ],
      ),
    );
  }
}
