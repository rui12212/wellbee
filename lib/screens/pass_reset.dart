// import 'package:flutter/material.dart';
// import 'package:uni_links/uni_links.dart';
// import 'dart:async';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class PasswordResetConfirmScreen extends StatefulWidget {
//   final String uidb64;
//   final String token;

//   PasswordResetConfirmScreen({required this.uidb64, required this.token});

//   @override
//   _PasswordResetConfirmScreenState createState() =>
//       _PasswordResetConfirmScreenState();
// }

// class _PasswordResetConfirmScreenState
//     extends State<PasswordResetConfirmScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _passwordConfirmController =
//       TextEditingController();
//   bool _isLoading = false;
//   String _message = '';

//   Future<void> _resetPassword() async {
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }

//     String password = _passwordController.text.trim();
//     String passwordConfirm = _passwordConfirmController.text.trim();

//     setState(() {
//       _isLoading = true;
//       _message = '';
//     });

//     // バックエンドのエンドポイントURLに置き換えてください
//     String url =
//         'https://your-backend-domain.com/api/password-reset-confirm/${widget.uidb64}/${widget.token}/';

//     Map<String, dynamic> data = {
//       'password': password,
//       'password_confirm': passwordConfirm,
//     };

//     try {
//       final response = await http.post(
//         Uri.parse(url),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode(data),
//       );

//       if (response.statusCode == 200) {
//         setState(() {
//           _message = 'パスワードが正常に更新されました。ログインしてください。';
//         });
//       } else {
//         Map<String, dynamic> responseData = json.decode(response.body);
//         setState(() {
//           _message = responseData['message'] ?? 'エラーが発生しました。再度お試しください。';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _message = 'ネットワークエラーが発生しました。再度お試しください。';
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _passwordController.dispose();
//     _passwordConfirmController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: Text('パスワード再設定'),
//         ),
//         body: Padding(
//           padding: EdgeInsets.all(16.0),
//           child: Column(children: [
//             Form(
//               key: _formKey,
//               child: Column(
//                 children: [
//                   // 新しいパスワード入力
//                   TextFormField(
//                     controller: _passwordController,
//                     decoration: InputDecoration(
//                       labelText: '新しいパスワード',
//                     ),
//                     obscureText: true,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return '新しいパスワードを入力してください';
//                       }
//                       if (value.length < 8) {
//                         return 'パスワードは8文字以上である必要があります';
//                       }
//                       return null;
//                     },
//                   ),
//                   SizedBox(height: 16.0),
//                   // パスワード確認入力
//                   TextFormField(
//                     controller: _passwordConfirmController,
//                     decoration: InputDecoration(
//                       labelText: 'パスワード確認',
//                     ),
//                     obscureText: true,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'パスワード確認を入力してください';
//                       }
//                       if (value != _passwordController.text) {
//                         return 'パスワードが一致しません';
//                       }
//                       return null;
//                     },
//                   ),
//                   SizedBox(height: 24.0),
//                   _isLoading
//                       ? CircularProgressIndicator()
//                       : ElevatedButton(
//                           onPressed: _resetPassword,
//                           child: Text('パスワードを更新'),
//                         ),
//                 ],
//               ),
//             ),
//             SizedBox(height: 16.0),
//             Text(
//               _message,
//               style: TextStyle(color: Colors.red),
//             ),
//           ]),
//         ));
//   }
// }
