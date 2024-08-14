import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:login_upload/post.dart';
import 'main.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'json_data.dart';
import 'package:image_picker/image_picker.dart';

class settingPage extends StatefulWidget {
  const settingPage({super.key});

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<settingPage> {
  final _usernameController = TextEditingController();
  late User_inf user_data_json;
  bool isLoading = true;
  XFile? _image = null;
  final imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initialize().then((_) {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      // user_data_jsonを取得
      user_data_json = await User_data().getUserdata(user.uid);
      setState(() {
      });
    } catch (e) {
      // エラーハンドリング
      print('Error loading follow list: $e');
    }
  }

  Future<void> _updateUsername(String newName) async {
    User_inf changedata = User_inf(
      user_id: user_data_json.user_id,
      user_name: newName,
      userImageUrl: user_data_json.userImageUrl,
      createdAt: user_data_json.createdAt,
    );

    try {
      User_data().edituserdata(changedata);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ユーザー名が更新されました')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ユーザー名の更新に失敗しました: $e')),
      );
    }
  }

  // ギャラリーから写真を取得するメソッド
  Future getImageFromGallery() async {
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = XFile(pickedFile.path);
      }
    });
  }

  Future<void> _updateUserImageUrl() async {
    User_inf changedata = User_inf(
      user_id: user_data_json.user_id,
      user_name: user_data_json.user_name,
      userImageUrl: user_data_json.userImageUrl,
      createdAt: user_data_json.createdAt,
    );

    try {
      User_data().edituserdata(changedata);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ユーザーアイコンが更新されました')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ユーザーアイコンの更新に失敗しました: $e')),
      );
    }
  }

  void _showUsernameDialog() {
    _usernameController.text = user_data_json.user_name;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ユーザー名を変更'),
          content: TextFormField(
            controller: _usernameController,
            decoration: const InputDecoration(
              labelText: '新しいユーザー名',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ダイアログを閉じる
              },
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () {
                final newName = _usernameController.text; // 入力された新しいユーザー名を取得
                _updateUsername(newName);
                Navigator.of(context).pop(); // ダイアログを閉じる
              },
              child: const Text('変更'),
            ),
          ],
        );
      },
    );
  }

  void _showUserIconDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('準備中'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ダイアログを閉じる
              },
              child: const Text('戻る'),
            ),
          ],
        );
      },
    );
  }

  void _showSignoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('サインアウトしますか？'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ダイアログを閉じる
              },
              child: const Text('いいえ'),
            ),
            TextButton(
              onPressed: ()async {
                // Google からサインアウト
                await GoogleSignIn().signOut();
                // Firebase からサインアウト
                await FirebaseAuth.instance.signOut();
                // SignInPage に遷移
                // このページには戻れないようにします。
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) {
                    return LoginPage();
                  }),
                  (route) => false,
                );
              },
              child: const Text('はい'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()), // ローディングインジケーター
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            // ユーザーアイコン画像
            CircleAvatar(
              backgroundImage: NetworkImage(user_data_json.userImageUrl),
              radius: 40,
            ),
            // ユーザー名
            Text(
              user_data_json.user_name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 16),

            // 部分的に左寄せにしたい場合の書き方
            Align(
              alignment: Alignment.centerLeft,
              // ユーザー ID
              child: Text('ユーザーID：${user_data_json.user_id}'),
            ),
            Align(
              alignment: Alignment.centerLeft,
              // 登録日
              child: Text('登録日：${FirebaseAuth.instance.currentUser!.metadata.creationTime!}'),
            ),
            const SizedBox(height: 16),

            // ユーザー名変更部分
            ElevatedButton(
              onPressed: _showUsernameDialog,
              child: const Text('ユーザー名変更'),
            ),

            //アイコン変更
            ElevatedButton(
              onPressed: _showUserIconDialog,
              child: const Text('アイコン変更'),
            ),

            //サイアウト
            ElevatedButton(
              onPressed: _showSignoutDialog,
              child: const Text('サインアウト'),
            ),
          ],
        ),
      ),
    );
  }
}
