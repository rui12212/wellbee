import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wellbee/assets/inet.dart';
import 'package:wellbee/main.dart';
import 'package:wellbee/screens/setting/account.dart';
import 'dart:convert';

import 'package:wellbee/screens/top_page.dart';
import 'package:wellbee/ui_function/shared_prefs.dart';
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
              // TextButton(
              //   style: TextButton.styleFrom(
              //       backgroundColor: Colors.transparent,
              //       shape: const CircleBorder(
              //           side: BorderSide(
              //               color: Color.fromARGB(255, 216, 214, 214),
              //               width: 5))),
              //   child: const Icon(Icons.chevron_left,
              //       color: Color.fromARGB(255, 155, 152, 152)),
              //   onPressed: () {
              //     Navigator.of(context).pushReplacement(MaterialPageRoute(
              //       builder: (context) {
              //         return TopPage(0);
              //       },
              //     ));
              //   },
              // )
            ],
          ),
        ),
      ],
    );
  }
}

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  String? token = '';

  void showAwesomeDialog() {
    CustomAwesomeDialogueForCancelReservation(
      titleText: 'Sign Out',
      desc: 'Are you sure to Sign out?\nYour auto login will be off!',
      callback: () async {
        await SharedPrefs.clearAuthInfo();
        await Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: ((context) {
          return SignInPage();
        })));
      },
    ).show(context);
  }
  // String my_user_id = '';

  // Future<void> _fetchToken() async {
  //   token = await SharedPrefs.fetchAccessToken();
  // }

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

  Future<void> onLaunchUrl() async {
    // print('haha');
    final Uri url =
        Uri.parse('https://rui12212.github.io/wellbee/privacy-policy');
    await launchUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          height: 620.h,
          padding: EdgeInsets.all(12.h),
          child: ListView(
            children: [
              _Header(title: 'User Info'),
              FutureBuilder(
                  future: _fetchAttendee(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                          child: Text('Error Occured.Try again later'));
                    } else {
                      final fetchedUserData = snapshot.data;
                      // print(userId);
                      return Column(
                        children: [
                          Container(
                            height: 300.h,
                            alignment: Alignment.center,
                            child: QrImageView(
                              data:
                                  '${baseUri}accounts/users/${fetchedUserData?[0]['user_id']}',
                              version: QrVersions.auto,
                              size: 180.0.h,
                            ),
                          ),
                          Divider(),
                          ListTile(
                            title: Text('Privacy Policy',
                                style: TextStyle(fontSize: 18.h)),
                            trailing: Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              onLaunchUrl();
                            },
                          ),
                          Divider(),
                          ListTile(
                            title: Text('Delete account',
                                style: TextStyle(fontSize: 18.h)),
                            trailing: Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AccountPage(
                                        userId: fetchedUserData?[0]
                                            ['user_id'])),
                              );
                            },
                          ),
                          Divider(),
                          ListTile(
                            title: Text('Sign out',
                                style: TextStyle(fontSize: 18.h)),
                            trailing: Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              showAwesomeDialog();
                            },
                          ),
                          Divider(),
                        ],
                      );
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
