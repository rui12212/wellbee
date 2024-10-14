import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:wellbee/assets/inet.dart';
import 'package:wellbee/screens/staff/auth/staff_top_page.dart';
import 'package:wellbee/ui_function/shared_prefs.dart';
import 'package:wellbee/ui_parts/color.dart';
import 'package:wellbee/ui_parts/show_dialogue.dart';
import 'package:wellbee/ui_parts/textstyle.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
  await initializeDateFormatting('en', null);
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const StaffSignInPage(),
    );
  }
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

class StaffSignInPage extends StatefulWidget {
  const StaffSignInPage({
    super.key,
  });

  @override
  State<StaffSignInPage> createState() => _StaffSignInPageState();
}

int mobileNumber = 0;

class _StaffSignInPageState extends State<StaffSignInPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? token = '';

  Future<void> fetchToken() async {
    token = await SharedPrefs.fetchAccessToken();
  }

  @override
  void initState() {
    super.initState();
    fetchToken();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    try {
      if (_phoneController.text.isEmpty || _passwordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please fill in all fields.')));
        return;
      }

      // ダイアログを呼び出す
      await DialogGenerator.showLoadingDialog(context: context);

      var url = Uri.parse('${baseUri}accounts/api/staff/token/');
      var response = await Future.any([
        http.post(url, body: {
          'phone_number': _phoneController.text,
          'password': _passwordController.text,
        }),
        Future.delayed(const Duration(seconds: 15),
            () => throw TimeoutException("Request timeout"))
      ]);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final staffAccessToken = data['access'];
        await SharedPrefs.setStaffAccessToken(staffAccessToken);
        print(staffAccessToken);

        Navigator.pop(context);
        await Future.delayed(Duration(milliseconds: 200));

        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Login success!')));
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const StaffTopPage(0)),
        );
      } else if (response.statusCode > 500) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Error occurred. Mobile number or password maybe wrong.')));
      } else {
        Navigator.pop(context);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed. Try again later.')));
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
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Center(
            child: Column(children: [
              Align(alignment: Alignment.topLeft, child: _HeaderBackButton()),
              SizedBox(
                height: 270.h,
                child: Image.asset('lib/assets/wellbee_cover.png'),
              ),
              Text('Staff Sign In',
                  style: TextStyle(
                    fontSize: 40.sp,
                    fontWeight: FontWeight.w300,
                  )),
              SizedBox(
                height: 20.h,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                    child: CustomTextBox(
                  label: 'Mobile Number',
                  hintText: '10 digits number',
                  controller: _phoneController,
                ).phoneFieldDecoration()),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Container(
                    child: CustomTextBox(
                  label: 'Password',
                  hintText: 'Your password here',
                  controller: _passwordController,
                ).textFieldDecoration()),
              ),
              SizedBox(
                height: 10.h,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: _login,
                  child: Text('Sign In',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, color: kColorPrimary)),
                ),
              ),
              // _Footer(),
            ]),
          ),
        ),
      ),
    );
  }
}
