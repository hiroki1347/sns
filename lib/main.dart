import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
//import 'firebase_options.dart';
import 'ViewPage.dart';
//import 'package:http/http.dart' as http;
//import 'post.dart';
import 'package:google_sign_in/google_sign_in.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
import 'json_data.dart';
void main() async{
  // 最初に表示するWidget
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(ChatApp());
}

class ChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser == null) {
      return MaterialApp(
        // アプリ名
        title: 'ChatApp',
        theme: ThemeData(
          // テーマカラー
          primarySwatch: Colors.blue,
        ),
        // ログイン画面を表示
        home: LoginPage(),
      );
    } else {
      return MaterialApp(
        theme: ThemeData(),
        home: ViewPage(),
      );
    } 
  }
}

// ログイン画面用Widget
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // メッセージ表示用
  String infoText = '';
  // 入力したメールアドレス・パスワード
  String email = '';
  String password = '';

  Future<void> signInWithGoogle() async {
    // GoogleSignIn をして得られた情報を Firebase と関連づけることをやっています。
    final googleUser = await GoogleSignIn(scopes: ['profile', 'email']).signIn();

    final googleAuth = await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    await FirebaseAuth.instance.signInWithCredential(credential);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        
        child: Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                child: ElevatedButton(
                  child: const Text('GoogleSignIn'),
                  onPressed: () async {
                    await signInWithGoogle();
                    // ログインが成功すると FirebaseAuth.instance.currentUser にログイン中のユーザーの情報が入ります
                    print(FirebaseAuth.instance.currentUser?.displayName);

                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      // ユーザーのUIDを使用してサーバーに問い合わせ
                      final bool isUserRegistered = await User_data().checkUserExists(user.uid);

                      if (!isUserRegistered) {
                        // ユーザーが未登録の場合にデータをサーバーに送信
                        await User_data().firstuserdata();
                      }

                      // ログインに成功したら ViewPage に遷移します。
                      // 前のページに戻らせないようにするにはpushAndRemoveUntilを使います。
                      if (mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) {
                            return ViewPage();
                          }),
                          (route) => false,
                        );
                      }
                    } 
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}