import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wellbee/assets/inet.dart';
import 'package:wellbee/screens/staff/calendar/calendar.dart';
import 'package:wellbee/screens/staff/course/course.dart';
import 'package:wellbee/screens/staff/qr_after_point/point_select.dart';
import 'package:wellbee/ui_function/shared_prefs.dart';
import 'package:wellbee/ui_parts/color.dart';
import 'package:wellbee/ui_parts/dialogue_awesome.dart';
import 'package:wellbee/ui_parts/textstyle.dart';
import 'package:http/http.dart' as http;

class _Header extends StatelessWidget {
  String title;
  String pk;

  _Header({
    required this.title,
    required this.pk,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.h,
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
                              color: Color.fromARGB(255, 206, 204, 204),
                              width: 5))),
                  child: const Icon(Icons.chevron_left,
                      color: Color.fromARGB(255, 155, 152, 152)),
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
                      builder: (context) {
                        return PointSelectPage(pk: pk);
                      },
                    ), ((route) => false));
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

class PointIncreasePage extends StatefulWidget {
  String pk;
  int point;
  PointIncreasePage(
      // this.newUser,
      {Key? key,
      required this.pk,
      required this.point})
      : super(key: key);

  @override
  _PointIncreasePageState createState() => _PointIncreasePageState();
}

class _PointIncreasePageState extends State<PointIncreasePage> {
  String? token = '';
  final TextEditingController _pointController = TextEditingController();

  @override
  showSnackBar(color, text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: color, content: Text(text)),
    );
  }

  Future<void> increasePoints() async {
    if (_pointController.text.trim().isEmpty) {
      showSnackBar(Colors.red, 'The field is empty');
    } else {
      try {
        final int increasedPoints = int.tryParse(_pointController.text) ?? 0;
        final int finalPoint = widget.point + increasedPoints;
        token = await SharedPrefs.fetchStaffAccessToken();
        var url =
            Uri.parse('${baseUri}accounts/users/${widget.pk}/?token=$token');

        final response = await Future.any([
          http.patch(url,
              headers: {
                "Authorization": 'JWT $token',
                "Content-Type": "application/json"
              },
              body: jsonEncode({'points': finalPoint})),
          Future.delayed(const Duration(seconds: 15),
              () => throw TimeoutException("Request timeout"))
        ]);

        if (response.statusCode == 200) {
          showSnackBar(kColorPrimary, 'Point increment success!');

          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
            builder: (context) {
              return PointSelectPage(pk: widget.pk);
            },
          ), ((route) => false));
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Failed to add points')));
        }
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e :Failed to add points')));
      }
    }
  }

  @override
  void initState() {
    super.initState();
  }

  void showAwesomeDialog(
      // int id,
      ) {
    CustomAwesomeDialogueForCancelReservation(
      titleText: 'Give Point',
      desc: 'Did you make sure the detail?',
      callback: () async {
        // await _cancelReservation(id);
      },
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 20.w,
            ),
            child: SingleChildScrollView(
              child: Container(
                  child: Column(
                children: [
                  _Header(title: 'Give Point to user', pk: widget.pk),
                  Container(
                    height: 500.h,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Current Point',
                            style: TextStyle(
                                fontWeight: FontWeight.w300, fontSize: 20.sp)),
                        Text('${widget.point}pt',
                            style: TextStyle(
                                fontSize: 50.sp, fontWeight: FontWeight.bold)),
                        SizedBox(
                          height: 26.h,
                        ),
                        Align(
                            alignment: Alignment.topCenter,
                            child: Text('How much point member get?',
                                style: TextStyle(
                                    color: kColorTextDarkGrey,
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.w500))),
                        CustomTextBox(
                          label: '',
                          hintText: '',
                          inputType: TextInputType.number,
                          controller: _pointController,
                        ).textFieldDecoration(),
                        SizedBox(
                          height: 40.h,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            final increasePoint = _pointController.text.trim();
                            int? intIncreasePoint = int.tryParse(increasePoint);
                            if (intIncreasePoint == null) {
                              showSnackBar(Colors.red, 'Point must be numbers');
                            } else
                              increasePoints();
                          },
                          child: Text('Give Point',
                              style: TextStyle(
                                  color: kColorPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 22.sp)),
                        ),
                      ],
                    ),
                  )
                ],
              )),
            ),
          ),
        ));
  }
}
