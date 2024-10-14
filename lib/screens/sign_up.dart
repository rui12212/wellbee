// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:wellbee/screens/first_attendee_add.dart';
import 'package:wellbee/ui_function/shared_prefs.dart';
import 'package:wellbee/ui_parts/color.dart';
import '../ui_parts/show_dialogue.dart';
import '../ui_parts/textstyle.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../assets/inet.dart';

import 'top_page.dart';
// import 'package:http_mock_adapter/http_mock_adapter.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});
  // This widget is the root of your application.

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _HeaderBackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      // 具体的なstylenの指定
      style: TextButton.styleFrom(
          // TextButtonのTextの色を指定
          // ボタンの色を透明にして、
          backgroundColor: Colors.transparent,
          // CircleBorderクラスで、円形の境界線を作成することで、中身を抜いた円形のみ示すことができる
          shape: const CircleBorder(
              // ボタンの境界線の色を kButtonColorPrimary で指定
              )),
      child: const Icon(Icons.chevron_left),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeaderBackButton(),
            ],
          ),
          Text('Sign Up',
              style: TextStyle(
                fontSize: 40.sp,
                fontWeight: FontWeight.w300,
              )),
        ],
      ),
    );
  }
}

class _SignUpForm extends StatefulWidget {
  const _SignUpForm();
  @override
  State<_SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<_SignUpForm> {
  // final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _rephoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repasswordController = TextEditingController();
  // final TextEditingController _otpController = TextEditingController();
  // String _verificationId = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _repasswordController.dispose();
    super.dispose();
  }

  Future<void> _registerUser() async {
    if (_passwordController.text == _repasswordController.text &&
        _phoneController.text == _rephoneController.text) {
      try {
        if (_phoneController.text.isEmpty ||
            _rephoneController.text.isEmpty ||
            _passwordController.text.isEmpty ||
            _repasswordController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please fill in all fields.')));
          return;
        }
        // ロードの開始
        setState(() {
          _isLoading = true;
        });
        // ダイアログを呼び出す
        await DialogGenerator.showLoadingDialog(context: context);

        // アカウントの作成
        var url = Uri.parse('${baseUri}accounts/create/');
        var response = await http.post(url, body: {
          'phone_number': _phoneController.text,
          'password': _passwordController.text,
        });

        if (response.statusCode == 201) {
          // 作成成功したら、Token作成
          var url = Uri.parse('${baseUri}authen/jwt/create/');
          var response = await http.post(url, body: {
            'phone_number': _phoneController.text,
            'password': _passwordController.text,
          });
          // 作成したTokenを取得し、SharedPrefsに保存
          final data = jsonDecode(response.body);
          final accessToken = data['access'];
          final refreshToken = data['refresh'];
          await SharedPrefs.setAccessToken(accessToken);

          Navigator.pop(context);
          await Future.delayed(Duration(milliseconds: 250));
          // setState(() {
          //   Navigator.pop(context);
          // });

          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('User created successfully!')));
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //       builder: (context) => const FirstAttendeeAddPage()),
          // );
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const FirstAttendeeAddPage()),
          );
        } else if (response.statusCode == 400) {
          // ロードの終了
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                  'Error occurred. The same mobile number is already registered or format is wrong.')));
        } else {
          // ロードの終了
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Failed to create user. Try again later.')));
        }
        // エラー処理
      } catch (e) {
        // ロードの終了
        Navigator.pop(context);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
        // ここは最後に必ず実行される
      } finally {
        // ロードの終了
        // Navigator.pop(context);
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Phone number or Password does not match.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 680.h,
      padding: EdgeInsets.symmetric(horizontal: 15).h,
      child: Form(
        // key: _formKey,
        child: Column(children: [
          SizedBox(
            height: 200.h,
            width: 380.w,
            child: Image.asset('lib/assets/sign_up.png'),
          ),
          SizedBox(
            height: 30.h,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
                child: CustomTextBox(
              label: 'Phone number',
              hintText: 'Your phone number',
              controller: _phoneController,
            ).phoneFieldDecoration()),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
                child: CustomTextBox(
              label: 'Confirm Phone number',
              hintText: 'Re-confirm Your phone number',
              controller: _rephoneController,
            ).phoneFieldDecoration()),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0).w,
            child: Container(
              child: PasswordCustomTextBox(
                label: 'Password',
                hintText: 'Enter your password',
                controller: _passwordController,
                isPassword: true,
                inputType: TextInputType.text,
                // function: (value) {
                //   _passwordController = value;
                //   // パスワード入力時の処理
                //   // print('Password: $value');
                // },
              ),
              //     CustomTextBox(
              //   label: 'Password',
              //   hintText: 'Your password',
              //   controller: _passwordController,
              // ).textFieldDecoration()
            ),
          ),
          SizedBox(
            height: 20.h,
          ),
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                child: PasswordCustomTextBox(
                  label: 'Password',
                  hintText: 'Enter your password',
                  controller: _repasswordController,
                  isPassword: true,
                  inputType: TextInputType.text,
                  // function: (value) {
                  //   _passwordController = value;
                  //   // パスワード入力時の処理
                  //   // print('Password: $value');
                  // },
                ),
                //     CustomTextBox(
                //   label: 'Confirm Password',
                //   hintText: 'Confirm your password',
                //   controller: _repasswordController,
                // ).textFieldDecoration(
              )),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _registerUser,
              child: Text('Sign Up',
                  style: TextStyle(
                      color: kColorPrimary, fontWeight: FontWeight.w700)),
            ),
          ),
        ]),
      ),
    );
  }
}

class _SignUpPageState extends State<SignUpPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // backgroundColor: ,
      body: SingleChildScrollView(
        child: Column(children: [
          _Header(),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 32).h,
            child: _SignUpForm(),
          ),
          // Padding(
          //   padding: EdgeInsets.symmetric(vertical: 32).h,
          // )
        ]),
      ),
    );
  }
}
