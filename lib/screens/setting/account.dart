import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wellbee/assets/inet.dart';
import 'package:wellbee/main.dart';
import 'package:wellbee/screens/setting/setting_page.dart';
import 'dart:convert';

import 'package:wellbee/screens/top_page.dart';
import 'package:wellbee/ui_function/shared_prefs.dart';
import 'package:wellbee/ui_parts/color.dart';
import 'package:wellbee/ui_parts/dialogue_awesome.dart';

class _Header extends StatelessWidget {
  String title;

  _Header({required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Row(
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 30.sp, fontWeight: FontWeight.bold),
              ),
              TextButton(
                style: TextButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shape: const CircleBorder(
                        side: BorderSide(
                            color: Color.fromARGB(255, 216, 214, 214),
                            width: 5))),
                child: const Icon(Icons.chevron_left,
                    color: Color.fromARGB(255, 155, 152, 152)),
                onPressed: () {
                  Navigator.of(context).pop();
                  // Navigator.of(context).pushReplacement(MaterialPageRoute(
                  //   builder: (context) {
                  //     return TopPage(1);
                  //   },
                  // ));
                },
              )
            ],
          ),
        ),
      ],
    );
  }
}

class AccountPage extends StatefulWidget {
  String userId;

  AccountPage({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  String? token = '';
  bool isChecked = false;

  @override
  showSnackBar(color, text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: color, content: Text(text)),
    );
  }

  Future<List<dynamic>?> _fetchAttendee() async {
    try {
      token = await SharedPrefs.fetchAccessToken();
      var url =
          Uri.parse('${baseUri}attendances/attendee/my_attendee/?token=$token');
      var response = await Future.any([
        http.get(url, headers: {
          "Authorization": 'JWT $token',
          "Content-Type": "application/json"
        }),
        Future.delayed(const Duration(seconds: 15),
            () => throw TimeoutException("Request timeout"))
      ]);
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          return data;
        }
      } else if (response.statusCode >= 400) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Internet Error occurred.')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Something went wrong. Try again later')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<List<dynamic>?> _deleteUser() async {
    // print(widget.userId);
    try {
      token = await SharedPrefs.fetchAccessToken();
      // print(token);
      var url = Uri.parse(
          '${baseUri}accounts/users/${widget.userId}/delete_user/?token=$token');
      var response = await Future.any([
        http.post(url, headers: {
          "Authorization": 'JWT $token',
          "Content-Type": "application/json"
        }),
        Future.delayed(const Duration(seconds: 15),
            () => throw TimeoutException("Request timeout"))
      ]);
      if (response.statusCode == 200) {
        await SharedPrefs.clearAuthInfo();
        // List<dynamic> data = jsonDecode(response.body);
        showSnackBar(kColorPrimary, 'User inactivated');
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => SignInPage()));
      } else if (response.statusCode >= 400) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Internet Error occurred')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Something went wrong. Try again later')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void showAwesomeDialog() {
    CustomAwesomeDialogueForCancelReservation(
      titleText: 'Delete account',
      desc: 'Are you sure to delete?\nAll data will be deleted...',
      callback: () async {
        _deleteUser();
        // await SharedPrefs.clearAuthInfo();
        // await Navigator.of(context)
        //     .pushReplacement(MaterialPageRoute(builder: ((context) {
        //   return SignInPage();
        // })));
      },
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Container(
            padding: EdgeInsets.all(12.h),
            child: SingleChildScrollView(
              child: Column(
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(
                    title: 'Account',
                  ),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Delete your account?',
                            style: TextStyle(
                                fontSize: 20.h, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'Deleting your account removes all your account information, including credit and reward points. You won\'t be able to get your data back.',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(
                            height: 5.h,
                          ),
                          Center(
                            child: Container(
                              height: 250.h,
                              width: 250.h,
                              decoration: BoxDecoration(
                                // borderRadius:
                                //     BorderRadius.all(Radius.circular(70)),
                                image: DecorationImage(
                                    fit: BoxFit.fill,
                                    image: AssetImage(
                                        'lib/assets/delete_account.png')),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 5.h,
                          ),
                          Row(
                            children: [
                              Checkbox(
                                  value: isChecked,
                                  onChanged: (value) {
                                    setState(() {
                                      isChecked = value!;
                                    });
                                  }),
                              Expanded(
                                  child: Text(
                                'I understand that this will remove my wellbee points or reservations',
                                style: TextStyle(fontSize: 16.h),
                              ))
                            ],
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                          Center(
                            child: Column(children: [
                              OutlinedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  // Navigator.of(context)
                                  //     .pushReplacement(MaterialPageRoute(
                                  //   builder: (context) {
                                  //     return SettingPage();
                                  //   },
                                  // ));
                                },
                                child: Text(
                                  'Keep account',
                                  style: TextStyle(
                                      fontSize: 18, color: kColorPrimary),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: kColorPrimary),
                                ),
                              ),
                              TextButton(
                                  onPressed: isChecked
                                      ? () {
                                          showAwesomeDialog();
                                        }
                                      : null,
                                  child: Text(
                                    'Delete account',
                                    style: TextStyle(
                                        fontSize: 18.h, color: kColorPrimary),
                                  ))
                            ]),
                          )
                        ]),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
