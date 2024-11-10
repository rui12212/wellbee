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
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: TextButton(
        style: TextButton.styleFrom(
            backgroundColor: Colors.transparent,
            shape: const CircleBorder(
                side: BorderSide(
                    color: Color.fromARGB(255, 216, 214, 214), width: 5))),
        child: const Icon(Icons.chevron_left,
            color: Color.fromARGB(255, 155, 152, 152)),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

class _Question extends StatelessWidget {
  String question;
  String subQuestion;
  String coloredText;
  String krSub;

  _Question(
      {required this.question,
      required this.subQuestion,
      required this.coloredText,
      required this.krSub});

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 140.h,
        child: Column(
          children: [
            Align(
              alignment: Alignment.center,
              child: Text(question,
                  style:
                      TextStyle(fontSize: 26.h, fontWeight: FontWeight.w300)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(subQuestion,
                    style: TextStyle(
                        fontSize: 22.sp, fontWeight: FontWeight.w300)),
                Text(coloredText,
                    style: TextStyle(
                        fontSize: 22.h,
                        fontWeight: FontWeight.w700,
                        color: kColorPrimary)),
              ],
            ),
            Text(krSub,
                style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w300)),
          ],
        ));
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
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(
                    child: Column(
                      children: [
                        _Header(),
                        _Question(
                            question: 'Welcome to Health Survey!',
                            subQuestion: 'First, put ',
                            coloredText: 'Height & Weight',
                            krSub: 'دەستپێکێ درێژی و کێشا خو دانە'),
                        SizedBox(
                          height: 30.h,
                        ),
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
                        Text('*Do NOT put kg or cm. Put just number!',
                            style: TextStyle(
                                fontSize: 18.sp, fontWeight: FontWeight.w200)),
                        SizedBox(
                          height: 30.h,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            String heightText = _heightController.text.trim();
                            String weightText = _weightController.text.trim();
                            int heightNum = int.parse(heightText);
                            int weightNum = int.parse(weightText);

                            if (heightText.isEmpty || weightText.isEmpty) {
                              CustomAwesomeDialogueForFail(
                                titleText: 'Error',
                                desc: 'There is an empty field',
                                // callback: _createReservation,
                              ).show(context);
                              return;
                              // 最小値。heightが100より小さく、体重が15より小さければエラー
                            } else if (heightNum < 100 || weightNum < 15) {
                              CustomAwesomeDialogueForFail(
                                titleText: 'Error',
                                desc: 'Minimum height is 100cm /weight is 15kg',
                                // callback: _createReservation,
                              ).show(context);
                              return;
                              // 最小値。heightが200より大きく、体重が150より大きければエラー
                            } else if (heightNum > 200 || weightNum > 150) {
                              CustomAwesomeDialogueForFail(
                                titleText: 'Error',
                                desc: 'Minimum height is 100cm /weight is 15kg',
                                // callback: _createReservation,
                              ).show(context);
                              return;
                            } else {
                              int? height = int.tryParse(heightText);
                              int? weight = int.tryParse(weightText);

                              if (height == null || weight == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Height and Weight must be integers')),
                                );
                              } else {
                                Map<String, dynamic> baseBodyData = {
                                  'height': heightText,
                                  'weight': weightText,
                                };
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => SurveyPage(
                                          attendeeList: widget.attendeeList,
                                          baseBodyData: baseBodyData,
                                        )));
                              }
                            }
                          },
                          child: Text('GO TO NEXT',
                              style: TextStyle(
                                  fontSize: 16.sp,
                                  color: kColorPrimary,
                                  fontWeight: FontWeight.w700)),
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
