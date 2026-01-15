import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wellbee/assets/inet.dart';
import 'package:wellbee/screens/questionnaire/questionnaire_ghq.dart';
import 'package:wellbee/screens/questionnaire/survey.dart';
import 'package:wellbee/ui_parts/dialogue_awesome.dart';
import 'package:wellbee/ui_parts/textstyle.dart';
import 'package:wellbee/ui_parts/color.dart';
import 'package:wellbee/ui_function/shared_prefs.dart';
import 'package:http/http.dart' as http;

class _Header extends StatelessWidget {
  final String title;
  final String subtitle;

  const _Header({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 8.h, bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 30.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  borderRadius: BorderRadius.circular(24.r),
                  child: Container(
                    width: 48.w,
                    height: 48.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      size: 20.sp,
                      color: kColorTextDarkGrey,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              color: kColorText,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class QuestionnairePage extends StatefulWidget {
  late Map<dynamic, dynamic> attendeeList;

  QuestionnairePage({Key? key, required this.attendeeList}) : super(key: key);

  @override
  _QuestionnairePageState createState() => _QuestionnairePageState();
}

class _QuestionnairePageState extends State<QuestionnairePage> {
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<List<dynamic>?> _createBaseBodySurvey() async {
    try {
      var token = await SharedPrefs.fetchAccessToken();
      var url =
          Uri.parse('${baseUri}questionnaires/base_body_survey/?token=$token');
      var response = await Future.any([
        http.post(url,
            body: jsonEncode({
              'height': double.parse(_heightController.text),
              'weight': double.parse(_weightController.text),
            }),
            headers: {
              "Authorization": 'JWT $token',
              'Content-Type': 'application/json',
            }),
        Future.delayed(const Duration(seconds: 15),
            () => throw TimeoutException("Request timeout"))
      ]);
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Reservation success!')));
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
            builder: (context) {
              return QuestionnaireGhqPage();
            },
          ), ((route) => false));
        } else if (data.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('There is no available membership.')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Some Error occurred.Try again later')));
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
                const _Header(
                  title: 'Health Survey',
                  subtitle: 'First, put Height & Weight',
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 20.h),
                        CircleAvatar(
                            radius: 110,
                            backgroundColor: Colors.grey,
                            child: ClipOval(
                              child: widget.attendeeList['gender'] == 'male'
                                  ? Image.asset(
                                      'lib/assets/attendee_pic/male_fitness.png',
                                      // radius（半径）90だったら、幅はもちろんその2倍になるよね！
                                      width: 220.h,
                                      height: 220.h,
                                      fit: BoxFit.cover)
                                  : Image.asset(
                                      'lib/assets/attendee_pic/female_fitness.png',
                                      // radius（半径）90だったら、幅はもちろんその2倍になるよね！
                                      width: 220.h,
                                      height: 220.h,
                                      fit: BoxFit.cover),
                            )),
                        SizedBox(
                          height: 30.h,
                        ),
                        Container(
                            width: 250.w,
                            child: CustomTextBox(
                              inputType: TextInputType.number,
                              label: 'Height/درێژی',
                              hintText: '170cm -> 170',
                              controller: _heightController,
                            ).textFieldDecoration()),
                        SizedBox(
                          height: 15.h,
                        ),
                        Container(
                            width: 250.w,
                            child: CustomTextBox(
                              inputType: TextInputType.number,
                              label: 'Weight/کێشا',
                              hintText: '65kg -> 65',
                              controller: _weightController,
                            ).textFieldDecoration()),
                        SizedBox(
                          height: 10.h,
                        ),
                        SizedBox(
                          height: 30.h,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            String heightText = _heightController.text.trim();
                            String weightText = _weightController.text.trim();

                            // 空欄チェック
                            if (heightText.isEmpty || weightText.isEmpty) {
                              CustomAwesomeDialogueForFail(
                                titleText: 'Error',
                                desc: 'There is an empty field',
                              ).show(context);
                              return;
                            }

                            // 数字のみかチェック（tryParseで安全に変換）
                            int? heightNum = int.tryParse(heightText);
                            int? weightNum = int.tryParse(weightText);

                            if (heightNum == null || weightNum == null) {
                              CustomAwesomeDialogueForFail(
                                titleText: 'Error',
                                desc: 'Please enter numbers only',
                              ).show(context);
                              return;
                            }

                            // 最小値チェック
                            if (heightNum < 100 || weightNum < 15) {
                              CustomAwesomeDialogueForFail(
                                titleText: 'Error',
                                desc:
                                    'Minimum height is 100cm / weight is 15kg',
                              ).show(context);
                              return;
                            }

                            // 最大値チェック
                            if (heightNum > 200 || weightNum > 150) {
                              CustomAwesomeDialogueForFail(
                                titleText: 'Error',
                                desc:
                                    'Maximum height is 200cm / weight is 150kg',
                              ).show(context);
                              return;
                            }

                            // すべてのバリデーション通過
                            Map<String, dynamic> baseBodyData = {
                              'height': heightText,
                              'weight': weightText,
                            };
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => SurveyPage(
                                      attendeeList: widget.attendeeList,
                                      baseBodyData: baseBodyData,
                                    )));
                          },
                          child: Text('GO TO NEXT',
                              style: TextStyle(
                                  fontSize: 16.sp,
                                  color: kColorPrimary,
                                  fontWeight: FontWeight.w700)),
                        ),
                        SizedBox(
                          height: 30.h,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
