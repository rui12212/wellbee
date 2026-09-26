import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wellbee/assets/inet.dart';
import 'package:wellbee/screens/staff/qr_after_point/point_select.dart';
import 'package:wellbee/ui_function/shared_prefs.dart';
import 'package:wellbee/ui_parts/color.dart';
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
                Flexible(
                  child: Text(
                    title,
                    style:
                        TextStyle(fontSize: 30.sp, fontWeight: FontWeight.bold),
                  ),
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

class StampIncreasePage extends StatefulWidget {
  String pk;
  int stamp;
  int point;
  StampIncreasePage({
    Key? key,
    required this.pk,
    required this.stamp,
    required this.point
  }) : super(key: key);

  @override
  _StampIncreasePageState createState() => _StampIncreasePageState();
}

class _StampIncreasePageState extends State<StampIncreasePage> {
  String? token = '';
  final TextEditingController _stampController = TextEditingController();

  @override
  showSnackBar(color, text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: color, content: Text(text)),
    );
  }

  Future<void> increaseStamps() async {
    if (_stampController.text.trim().isEmpty) {
      showSnackBar(Colors.red, 'The field is empty');
    } else {
      try {
        final int increasedStamps = int.tryParse(_stampController.text) ?? 0;
        final int finalStamp = widget.stamp + increasedStamps;
        final int currentPoint = widget.point;
        final int finalPoint = currentPoint + (widget.stamp%5+increasedStamps) ~/ 5;
        token = await SharedPrefs.fetchStaffAccessToken();
        var url =
            Uri.parse('${baseUri}accounts/users/${widget.pk}/?token=$token');

        final response = await Future.any([
          http.patch(url,
              headers: {
                "Authorization": 'JWT $token',
                "Content-Type": "application/json"
              },
              body: jsonEncode({'stamps': finalStamp, 'points': finalPoint})),
          Future.delayed(const Duration(seconds: 15),
              () => throw TimeoutException("Request timeout"))
        ]);

        if (response.statusCode == 200) {
          showSnackBar(kColorPrimary, 'Stamp increment success!');

          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
            builder: (context) {
              return PointSelectPage(pk: widget.pk);
            },
          ), ((route) => false));
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Failed to add stamps')));
        }
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e :Failed to add stamps')));
      }
    }
  }

  @override
  void initState() {
    super.initState();
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
                  _Header(title: 'Add Stamp', pk: widget.pk),
                  Container(
                    height: 500.h,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Current Stamp',
                            style: TextStyle(
                                fontWeight: FontWeight.w300, fontSize: 20.sp)),
                        Text('${widget.stamp}',
                            style: TextStyle(
                                fontSize: 50.sp, fontWeight: FontWeight.bold)),
                        SizedBox(
                          height: 26.h,
                        ),
                        Align(
                            alignment: Alignment.topCenter,
                            child: Text('How many stamps does member get?',
                                style: TextStyle(
                                    color: kColorTextDarkGrey,
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.w500))),
                        CustomTextBox(
                          label: '',
                          hintText: '',
                          inputType: TextInputType.number,
                          controller: _stampController,
                        ).textFieldDecoration(),
                        SizedBox(
                          height: 40.h,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            final increaseStamp = _stampController.text.trim();
                            int? intIncreaseStamp = int.tryParse(increaseStamp);
                            if (intIncreaseStamp == null) {
                              showSnackBar(Colors.red, 'Stamp must be numbers');
                            } else if (intIncreaseStamp <= 0) {
                              showSnackBar(
                                  Colors.red, 'Enter a number greater than 0');
                            } else {
                              increaseStamps();
                            }
                          },
                          child: Text('Add Stamp',
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
