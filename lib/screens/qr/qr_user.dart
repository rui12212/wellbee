import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wellbee/assets/inet.dart';
import 'package:wellbee/screens/home.dart';
import 'package:wellbee/screens/top_page.dart';
import 'package:wellbee/ui_function/shared_prefs.dart';
import 'package:http/http.dart' as http;
import 'package:wellbee/ui_parts/display.dart';

import '../../ui_parts/color.dart';
import 'package:qr_flutter/qr_flutter.dart';

class _Header extends StatelessWidget {
  String title;

  _Header({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100.h,
      child: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Row(
              children: [
                Text(
                  title,
                  style:
                      TextStyle(fontSize: 30.sp, fontWeight: FontWeight.bold),
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
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) {
                        return TopPage(0);
                      },
                    ));
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// class _Question extends StatelessWidget {
//   String question;

//   _Question({
//     required this.question,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//         height: 80.h,
//         child: Column(
//           children: [
//             Text(question,
//                 style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w300))
//           ],
//         ));
//   }
// }

class UserQrCodePage extends StatefulWidget {
  UserQrCodePage({
    Key? key,
  }) : super(key: key);

  @override
  _UserQrCodePageState createState() => _UserQrCodePageState();
}

class _UserQrCodePageState extends State<UserQrCodePage> {
  String? token = '';
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

  @override
  void initState() {
    super.initState();
  }

  @override
  showSnackBar(color, text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: color, content: Text(text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: [
                _Header(title: 'QR for Staff'),
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
                        return Container(
                          height: 400.h,
                          alignment: Alignment.center,
                          child: QrImageView(
                            data:
                                '${baseUri}accounts/users/${fetchedUserData?[0]['user_id']}',
                            version: QrVersions.auto,
                            size: 200.0.h,
                          ),
                        );
                      }
                    }),
              ],
            ),
          ),
        ));
  }
}
      // body: SafeArea(//)