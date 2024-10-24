import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:wellbee/screens/first_attendee_add.dart';
import 'package:wellbee/screens/staff/auth/staff_signin.dart';
import 'package:wellbee/screens/staff/auth/staff_top_page.dart';
import 'package:wellbee/ui_parts/color.dart';
import 'package:wellbee/ui_parts/textstyle.dart';
import 'assets/inet.dart';
import 'screens/sign_up.dart';
import 'screens/top_page.dart';
import 'ui_parts/show_dialogue.dart';
import 'ui_function/shared_prefs.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

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
    return ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, child) {
          return MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              fontFamily: 'Playfair',
            ),
            home: const SignInPage(),
          );
        });
  }
}

class _Footer extends StatelessWidget {
  // ここ、Function()にしないと、Widgetが読み込まれたタイミングでurlLauncherが起動しちゃう
  final Future<void> Function() callback;

  _Footer({required this.callback});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        //   const Text(
        //       // \をいれることで、文字列として使いたい「'」と文字の中で使いたい「'」を分けられる
        //       'Forgot password?',
        //       style: TextStyle(
        //         fontSize: 16,
        //       )),
        //   const SizedBox(
        //     width: 4,
        //   ),

        //   // TextにもInkWellで機能を付与することが可能
        //   InkWell(
        //     onTap: () {
        //       Navigator.of(context).push(MaterialPageRoute(
        //         builder: (context) {
        //           return const SignUpPage();
        //         },
        //       ));
        //     },
        //     child: const Text('Reset password',
        //         style: TextStyle(
        //           color: Colors.black38,
        //           fontSize: 16,
        //         )),
        //   )
        // ]),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(
              // \をいれることで、文字列として使いたい「'」と文字の中で使いたい「'」を分けられる
              'Don\'t have Account?',
              style: TextStyle(
                fontSize: 16.sp,
              )),
          SizedBox(
            width: 4.w,
          ),

          // TextにもInkWellで機能を付与することが可能
          InkWell(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) {
                  return const SignUpPage();
                },
              ));
            },
            child: Text('Sign up',
                style: TextStyle(
                  color: Colors.black38,
                  fontSize: 18.sp,
                )),
          )
        ]),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(
              // \をいれることで、文字列として使いたい「'」と文字の中で使いたい「'」を分けられる
              'For Staff',
              style: TextStyle(
                fontSize: 16.sp,
              )),
          SizedBox(
            width: 4.w,
          ),

          // TextにもInkWellで機能を付与することが可能
          InkWell(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) {
                  return const StaffSignInPage();
                },
              ));
            },
            child: Text('Sign In',
                style: TextStyle(
                  color: Colors.black38,
                  fontSize: 18.sp,
                )),
          )
        ]),
        SizedBox(
          height: 18.h,
        ),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(
              // \をいれることで、文字列として使いたい「'」と文字の中で使いたい「'」を分けられる
              'Privacy Policy',
              style: TextStyle(
                fontSize: 15.sp,
              )),
          // SizedBox(
          //   width: 4.w,
          // ),
          IconButton(
              icon: Icon(
                Icons.privacy_tip_outlined,
              ),
              onPressed: () async {
                await callback();
                // Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
                //   builder: (context) {
                //     return LaunchUrlContainer();
                //   },
                // ), ((route) => false));
              })
        ]),
      ],
    );
  }
}

class SignInPage extends StatefulWidget {
  const SignInPage({
    super.key,
  });

  @override
  State<SignInPage> createState() => _SignInPageState();
}

int mobileNumber = 0;

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? token = '';
  bool? isAttendee = false;
  bool isToken = false;
  int attendeeInt = 1;

  void autoLoad() {
    if (isToken == true && isAttendee == true) {
      Navigator.push(context, MaterialPageRoute(
        builder: (context) {
          return const TopPage(0);
        },
      ));
    }
    if (isToken == true && isAttendee == false) {
      Navigator.push(context, MaterialPageRoute(
        builder: (context) {
          return const FirstAttendeeAddPage();
        },
      ));
    }
    return;
  }

  Future<void> fetchTokenAndBool() async {
    token = await SharedPrefs.fetchAccessToken();
    if (token != null) {
      bool attendeeExists = await _fetchAttendeeExist();
      setState(() {
        isToken = true;
        isAttendee = attendeeExists;
      });
      autoLoad();
    } else {
      setState(() {
        isToken = false;
      });
    }
  }

  _fetchAttendeeExist() async {
    try {
      await DialogGenerator.showLoadingDialog(context: context);
      token = await SharedPrefs.fetchAccessToken();
      if (token == null) {
        return false;
      } else {
        var url =
            Uri.parse('${baseUri}attendances/attendee/first_page_attendee/');
        var response = await Future.any([
          http.get(url, headers: {"Authorization": 'JWT $token'}),
          Future.delayed(const Duration(seconds: 5),
              () => throw TimeoutException("Request timeout"))
        ]);
        if (response.statusCode == 200) {
          List<dynamic> data = jsonDecode(response.body);
          if (data.isNotEmpty) {
            return true;
          } else
            return false;
        } else if (response.statusCode >= 400) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Internet Error occurred.')));
        } else {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Something went wrong. Try again later')));
        }
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> onLaunchUrl() async {
    final Uri url =
        Uri.parse('https://rui12212.github.io/wellbee/privacy-policy');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      // エラーハンドリング: URLを開けない場合の処理
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Try again later')));
    }
  }

// ----------------right----------- down below is for 2nd ideas

  // Future<void>? autoLoad() {
  //   if (isToken == true && isAttendee == true) {
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (context) => const TopPage(0)),
  //     );
  //   }
  //   if (isToken == true && isAttendee == false) {
  //     // Navigator.pop(context);
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (context) => const FirstAttendeeAddPage()),
  //     );
  //   }
  //   Navigator.pop(context);
  //   // return;
  // }

  // Future<void> fetchTokenAndBool() async {
  //   token = await SharedPrefs.fetchAccessToken();
  //   if (token != null) {
  //     int fetchedAttendeeInt = await _fetchAttendeeExist();
  //     setState(() {
  //       attendeeInt = fetchedAttendeeInt;
  //     });

  //     if (attendeeInt == 0) {
  //       setState(() {
  //         isToken = true;
  //         isAttendee = true;
  //       });
  //       autoLoad();
  //     } else if (attendeeInt == 1) {
  //       setState(() {
  //         isToken = true;
  //         isAttendee = false;
  //       });
  //       autoLoad();
  //     } else if (attendeeInt == 2) {
  //       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
  //           content: Text(
  //               'Error occurred. Try again later with internet connection')));
  //       // print('attendeeInt:$attendeeInt');
  //       // print('isToken:$isToken');
  //       // print('isAttendee:$isAttendee');
  //       return;
  //     }
  //   } else {
  //     setState(() {
  //       isToken = false;
  //     });
  //   }
  // }

  // _fetchAttendeeExist() async {
  //   try {
  //     await DialogGenerator.showLoadingDialog(context: context);
  //     token = await SharedPrefs.fetchAccessToken();
  //     // print(token);
  //     if (token == null) {
  //       return false;
  //     } else {
  //       var url =
  //           Uri.parse('${baseUri}attendances/attendee/first_page_attendee/');
  //       var response = await Future.any([
  //         http.get(url, headers: {"Authorization": 'JWT $token'}),
  //         Future.delayed(const Duration(seconds: 5),
  //             () => throw TimeoutException("Request timeout"))
  //       ]);
  //       if (response.statusCode == 200) {
  //         List<dynamic> data = jsonDecode(response.body);
  //         // print(data);
  //         if (data.isNotEmpty) {
  //           // ネット正常＋attendeeがいる
  //           return 0;
  //         } else
  //           // ネット正常＋attendeeがいない
  //           return 1;
  //       } else if (response.statusCode >= 400) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //             const SnackBar(content: Text('Internet Error occurred.')));
  //         Navigator.pop(context);
  //         return 2;
  //       } else {
  //         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
  //             content: Text('Something went wrong. Try again later')));
  //         Navigator.pop(context);
  //         return 2;
  //       }
  //     }
  //   } catch (e) {
  //     Navigator.pop(context);
  //     ScaffoldMessenger.of(context)
  //         .showSnackBar(SnackBar(content: Text('Error: $e')));
  //     return 2;
  //   }
  // }

  @override
  void initState() {
    super.initState();
    fetchTokenAndBool();
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

      var url = Uri.parse('${baseUri}authen/jwt/create/');
      var response = await Future.any([
        http.post(url, body: {
          'phone_number': _phoneController.text,
          'password': _passwordController.text,
        }),
        Future.delayed(const Duration(seconds: 15),
            () => throw TimeoutException("Request timeout"))
      ]);

      if (response.statusCode == 200) {
        // 作成成功したら、Token作成
        // 作成したTokenを取得し、SharedPrefsに保存
        final data = jsonDecode(response.body);
        final accessToken = data['access'];
        final refreshToken = data['refresh'];
        // print(accessToken);
        await SharedPrefs.setAccessToken(accessToken);
        bool attendeeExists = await _fetchAttendeeExist();
        setState(() {
          isAttendee = attendeeExists;
        });
        // print(accessToken);
        Navigator.pop(context);
        await Future.delayed(Duration(milliseconds: 250));

        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Login success!')));

        if (isAttendee == true) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TopPage(0)),
          );
        }
        if (isAttendee == false) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const FirstAttendeeAddPage()),
          );
        }
      } else if (response.statusCode > 350) {
        // ロードの終了

        // Navigator.pop(context);
        // await Future.delayed(Duration(milliseconds: 400));

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Error occurred. Mobile number or password maybe wrong.')));
        Navigator.pop(context);
        // Navigator.pop(context);
      } else {
        // ロードの終了
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to create user. Try again later.')));
      }
      // エラー処理
    } catch (e) {
      // ロードの終了
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
      // Navigator.pop(context);
      Navigator.pop(context);
      // ここは最後に必ず実行される
    } finally {
      // ロードの終了
      // Navigator.pop(context);
      return;
    }
  }

  // Future<void> _login() async {
  //   try {
  //     if (_phoneController.text.isEmpty || _passwordController.text.isEmpty) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text('Please fill in all fields.')));
  //       return;
  //     }
  //     // ダイアログを呼び出す
  //     await DialogGenerator.showLoadingDialog(context: context);

  //     var url = Uri.parse('${baseUri}authen/jwt/create/');
  //     var response = await Future.any([
  //       http.post(url, body: {
  //         'phone_number': _phoneController.text,
  //         'password': _passwordController.text,
  //       }),
  //       Future.delayed(const Duration(seconds: 15),
  //           () => throw TimeoutException("Request timeout"))
  //     ]);

  //     if (response.statusCode == 200) {
  //       // 作成成功したら、Token作成
  //       // 作成したTokenを取得し、SharedPrefsに保存
  //       final data = jsonDecode(response.body);
  //       final accessToken = data['access'];
  //       final refreshToken = data['refresh'];
  //       // print(accessToken);
  //       await SharedPrefs.setAccessToken(accessToken);
  //       int attendeeInt = await _fetchAttendeeExist();
  //       if (attendeeInt == 0) {
  //         setState(() {
  //           isAttendee = true;
  //         });
  //       } else if (attendeeInt == 1) {
  //         setState(() {
  //           isAttendee = false;
  //         });
  //       }
  //       Navigator.pop(context);
  //       await Future.delayed(Duration(milliseconds: 250));

  //       ScaffoldMessenger.of(context)
  //           .showSnackBar(const SnackBar(content: Text('Login success!')));

  //       if (isAttendee == true) {
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(builder: (context) => const TopPage(0)),
  //         );
  //       }
  //       if (isAttendee == false) {
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //               builder: (context) => const FirstAttendeeAddPage()),
  //         );
  //       }
  //     } else if (response.statusCode > 350) {
  //       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
  //           content: Text(
  //               'Error occurred. Mobile number or password maybe wrong.')));
  //       Navigator.pop(context);
  //       // Navigator.pop(context);
  //     } else {
  //       // ロードの終了
  //       Navigator.pop(context);
  //       ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: Text('Failed to create user. Try again later.')));
  //     }
  //     // エラー処理
  //   } catch (e) {
  //     // ロードの終了
  //     ScaffoldMessenger.of(context)
  //         .showSnackBar(SnackBar(content: Text('Error: $e')));
  //     // Navigator.pop(context);
  //     Navigator.pop(context);
  //     // ここは最後に必ず実行される
  //   } finally {
  //     // ロードの終了
  //     // Navigator.pop(context);
  //     return;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Center(
            child: Column(children: [
              SizedBox(
                height: 290.h,
                width: 390.w,
                child: Image.asset('lib/assets/wellbee_cover.png'),
              ),
              Text('Sign In',
                  style: TextStyle(
                    fontSize: 40.sp,
                    fontWeight: FontWeight.w300,
                  )),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                    child: CustomTextBox(
                  label: 'Mobile Number',
                  hintText: 'ex) 7501234567',
                  controller: _phoneController,
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
                ),
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
                          color: kColorPrimary, fontWeight: FontWeight.w700)),
                ),
              ),
              _Footer(callback: onLaunchUrl),
            ]),
          ),
        ),
      ),
    );
  }
}
