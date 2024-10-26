import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide Step;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:survey_kit/survey_kit.dart';
import 'package:wellbee/assets/inet.dart';
import 'package:wellbee/screens/home.dart';
import 'package:wellbee/screens/top_page.dart';
import 'package:wellbee/ui_function/convert.dart';
import 'package:wellbee/ui_function/shared_prefs.dart';
import 'package:wellbee/ui_parts/color.dart';
import 'package:wellbee/ui_parts/dialogue_awesome.dart';
import 'package:wellbee/ui_parts/survey_question.dart';

class SurveyPage extends StatefulWidget {
  late Map<dynamic, dynamic> attendeeList;
  late Map<String, dynamic> baseBodyData;

  SurveyPage({
    Key? key,
    required this.attendeeList,
    required this.baseBodyData,
  });

  @override
  _SurveyPageState createState() => _SurveyPageState();
}

class _SurveyPageState extends State<SurveyPage> {
  String? token = '';
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    // _fetchQuestion();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> _createSurvey(List responseList) async {
    try {
      token = await SharedPrefs.fetchAccessToken();

      Map responseMap = {'attendee_id': widget.attendeeList['id']};
      // Map responseMap = {};
      for (int i = 0; i < 28; i++) {
        responseMap['response$i'] = responseList[i];
      }
      var urlSurvey = Uri.parse('${baseUri}questionnaires/survey_response/');
      var urlBase = Uri.parse('${baseUri}questionnaires/base_body_survey/');
      var response = await Future.any([
        // jsonEncodeではMap型で渡す
        http.post(urlSurvey, body: jsonEncode(responseMap), headers: {
          "Authorization": 'JWT $token',
          'Content-Type': 'application/json',
        }),
        http.post(urlBase,
            body: jsonEncode({
              'attendee_id': widget.attendeeList['id'],
              'height': widget.baseBodyData['height'],
              'weight': widget.baseBodyData['weight'],
              // 'BMI': 0,
            }),
            headers: {
              "Authorization": 'JWT $token',
              'Content-Type': 'application/json',
            }),
        Future.delayed(const Duration(seconds: 15),
            () => throw TimeoutException("Request timeout"))
      ]);
      // print(response)
      if (response.statusCode == 201) {
        showSnackBar(kColorPrimary, 'Survey submitted successfully!');

        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
          builder: (context) {
            return TopPage(0);
          },
        ), ((route) => false));
      } else if (response.statusCode >= 400) {
        Navigator.of(context).pop();
        showSnackBar(Colors.red, 'Error: Internet Error, try again');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Something went wrong. Try again later')));
      }
    } catch (e) {
      Navigator.of(context).pop();
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
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          color: Colors.white,
          child: Align(
            alignment: Alignment.center,
            child: FutureBuilder<Task>(
              future: getSurvey(),
              builder: (BuildContext context, AsyncSnapshot<Task> snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData &&
                    snapshot.data != null) {
                  final Task task = snapshot.data!;
                  return SurveyKit(
                    onResult: (SurveyResult result) async {
                      if (result.finishReason == FinishReason.COMPLETED) {
                        List intResponseList = [];
                        final jsonResult = result.toJson();
                        // print(jsonResult);

                        for (int i = 1; i < 29; i++) {
                          //  0はInstructionIndicator、1からアンケートの回答
                          final response =
                              jsonResult['results'][i]['results'][0]['result'];
                          int responseInt =
                              QuestionConverter.convertDoubleToNum(response);
                          intResponseList.add(responseInt);
                        }
                        // print(intResponseList);
                        await _createSurvey(intResponseList);

// ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
                        // for (int i = 1; i < 29; i++) {
                        //   //  0はInstructionIndicator、1からアンケートの回答
                        //   final response = jsonResult['results'][i]['results']
                        //       [0]['result']['result'];
                        //   int responseInt =
                        //       QuestionConverter.convertStringToNum(response);
                        //   intResponseList.add(responseInt);
                        // }
                        // print(intResponseList);
                        // await _createSurvey(intResponseList);

// ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
                        // Map listForModel = QuestionConverter.createResponseMap(
                        //     intResponseList);
                        // print(listForModel);
                        // print(intResponseList);
                        // print(jsonEncode(response));

                        // if (mounted) {
                        //   Navigator.of(context).pushAndRemoveUntil(
                        //       MaterialPageRoute(
                        //     builder: (context) {
                        //       return HomePage();
                        //     },
                        //   ), ((route) => false));

                        //   if (mounted) {
                        //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        //         content:
                        //             Text('Survey Submitted Successfully!')));
                        //     // CustomAwesomeDialogueForSuccess(
                        //     //   titleText: 'Success',
                        //     //   desc: 'Survey Submitted Successfully',
                        //     // ).show(context);
                        //   }
                        // }
                      } else {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => TopPage(0)));
                      }
                    },
                    task: task,
                    showProgress: true,
                    localizations: const <String, String>{
                      'cancel': 'Cancel',
                      'next': 'Next',
                    },
                    themeData: Theme.of(context).copyWith(
                      primaryColor: Colors.cyan,
                      appBarTheme: const AppBarTheme(
                        color: Colors.white,
                        iconTheme: IconThemeData(
                          color: Colors.cyan,
                        ),
                        titleTextStyle: TextStyle(
                          color: Colors.cyan,
                        ),
                      ),
                      iconTheme: const IconThemeData(
                        color: Colors.cyan,
                      ),
                      textSelectionTheme: const TextSelectionThemeData(
                        cursorColor: Colors.cyan,
                        selectionColor: Colors.cyan,
                        selectionHandleColor: Colors.cyan,
                      ),
                      cupertinoOverrideTheme: const CupertinoThemeData(
                        primaryColor: Colors.cyan,
                      ),
                      outlinedButtonTheme: OutlinedButtonThemeData(
                        style: ButtonStyle(
                          minimumSize: MaterialStateProperty.all(
                            const Size(150.0, 60.0),
                          ),
                          side: MaterialStateProperty.resolveWith(
                            (Set<MaterialState> state) {
                              if (state.contains(MaterialState.disabled)) {
                                return const BorderSide(
                                  color: Colors.grey,
                                );
                              }
                              return const BorderSide(
                                color: Colors.cyan,
                              );
                            },
                          ),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          textStyle: MaterialStateProperty.resolveWith(
                            (Set<MaterialState> state) {
                              if (state.contains(MaterialState.disabled)) {
                                return Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(
                                      color: Colors.grey,
                                    );
                              }
                              return Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(
                                    color: Colors.cyan,
                                  );
                            },
                          ),
                        ),
                      ),
                      textButtonTheme: TextButtonThemeData(
                        style: ButtonStyle(
                          textStyle: MaterialStateProperty.all(
                            Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: Colors.cyan,
                                ),
                          ),
                        ),
                      ),
                      textTheme: TextTheme(
                        displayMedium: TextStyle(
                          fontSize: 26.0.sp,
                          color: Colors.black,
                        ),
                        headlineSmall: TextStyle(
                          fontSize: 20.0.sp,
                          color: Colors.black,
                        ),
                        bodyMedium: TextStyle(
                          fontSize: 18.0.sp,
                          color: Colors.black,
                        ),
                        titleMedium: TextStyle(
                          fontSize: 18.0.sp,
                          color: Colors.black,
                        ),
                      ),
                      inputDecorationTheme: const InputDecorationTheme(
                        labelStyle: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      colorScheme: ColorScheme.fromSwatch(
                        primarySwatch: Colors.cyan,
                      )
                          .copyWith(
                            onPrimary: Colors.white,
                          )
                          .copyWith(background: Colors.white),
                    ),
                    surveyProgressbarConfiguration: SurveyProgressConfiguration(
                      backgroundColor: Colors.white,
                    ),
                  );
                }
                return const CircularProgressIndicator.adaptive();
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<Task>? getSurvey() async {
    // if (mounted) {
    // final fetchedSurveyList = await _fetchQuestion();
    final NavigableTask task = NavigableTask(
      id: TaskIdentifier(),
      steps: <Step>[
        InstructionStep(
          title: 'Welcome to the Health Survey',
          text: 'Let\'s share your current physical & psychological health!',
          buttonText: 'Let\'s go!',
        ),
        QuestionStep(
          title: 'Been feeling bad and in bad health?',
          isOptional: false,
          answerFormat: const ScaleAnswerFormat(
            step: 1,
            minimumValue: 0,
            maximumValue: 3,
            defaultValue: 0,
            minimumValueDescription: 'Better than usual',
            maximumValueDescription: 'Much worse',
          ),
        ),
        // QuestionStep(
        //   title: 'Been feeling bad and in bad health?',
        //   // text: 'We are done, do you mind to tell us more about yourself?',
        //   isOptional: false,
        //   answerFormat: const SingleChoiceAnswerFormat(
        //     textChoices: <TextChoice>[
        //       TextChoice(text: 'Better than usual', value: 'Better than usual'),
        //       TextChoice(text: 'Same as usual', value: 'Same as usual'),
        //       TextChoice(text: 'Worse than usual', value: 'Worse than usual'),
        //       TextChoice(
        //           text: 'Much worse than usual',
        //           value: 'Much worse than usual'),
        //     ],
        //   ),
        // ),
        QuestionStep(
          title: 'Been feeling in need of \na good tonic?',
          isOptional: false,
          answerFormat: const ScaleAnswerFormat(
            step: 1,
            minimumValue: 0,
            maximumValue: 3,
            defaultValue: 0,
            minimumValueDescription: 'Better than usual',
            maximumValueDescription: 'Much worse',
          ),
        ),
        // QuestionStep(
        //   title: 'Been feeling in need of \na good tonic?',
        //   // text: 'We are done, do you mind to tell us more about yourself?',
        //   isOptional: false,
        //   answerFormat: const SingleChoiceAnswerFormat(
        //     textChoices: <TextChoice>[
        //       TextChoice(text: 'Better than usual', value: 'Better than usual'),
        //       TextChoice(text: 'Same as usual', value: 'Same as usual'),
        //       TextChoice(text: 'Worse than usual', value: 'Worse than usual'),
        //       TextChoice(
        //           text: 'Much worse than usual',
        //           value: 'Much worse than usual'),
        //     ],
        //   ),
        // ),

        QuestionStep(
          title: 'Been feeling run down and \nout of sorts?',
          isOptional: false,
          answerFormat: const ScaleAnswerFormat(
            step: 1,
            minimumValue: 0,
            maximumValue: 3,
            defaultValue: 0,
            minimumValueDescription: 'Better than usual',
            maximumValueDescription: 'Much worse',
          ),
        ),
        // QuestionStep(
        //   title: 'Been feeling run down and \nout of sorts?',
        //   // text: 'We are done, do you mind to tell us more about yourself?',
        //   isOptional: false,
        //   answerFormat: const SingleChoiceAnswerFormat(
        //     textChoices: <TextChoice>[
        //       TextChoice(text: 'Better than usual', value: 'Better than usual'),
        //       TextChoice(text: 'Same as usual', value: 'Same as usual'),
        //       TextChoice(text: 'Worse than usual', value: 'Worse than usual'),
        //       TextChoice(
        //           text: 'Much worse than usual',
        //           value: 'Much worse than usual'),
        //     ],
        //   ),
        // ),
        QuestionStep(
          title: 'Been feeling that \nyou are ill?',
          isOptional: false,
          answerFormat: const ScaleAnswerFormat(
            step: 1,
            minimumValue: 0,
            maximumValue: 3,
            defaultValue: 0,
            minimumValueDescription: 'Better than usual',
            maximumValueDescription: 'Much worse',
          ),
        ),
        // QuestionStep(
        //   title: 'Been feeling that \nyou are ill?',
        //   // text: 'We are done, do you mind to tell us more about yourself?',
        //   isOptional: false,
        //   answerFormat: const SingleChoiceAnswerFormat(
        //     textChoices: <TextChoice>[
        //       TextChoice(text: 'Better than usual', value: 'Better than usual'),
        //       TextChoice(text: 'Same as usual', value: 'Same as usual'),
        //       TextChoice(text: 'Worse than usual', value: 'Worse than usual'),
        //       TextChoice(
        //           text: 'Much worse than usual',
        //           value: 'Much worse than usual'),
        //     ],
        //   ),
        // ),
        QuestionStep(
          title: 'Been getting any pains \nin your head?',
          isOptional: false,
          answerFormat: const ScaleAnswerFormat(
            step: 1,
            minimumValue: 0,
            maximumValue: 3,
            defaultValue: 0,
            minimumValueDescription: 'Better than usual',
            maximumValueDescription: 'Much worse',
          ),
        ),
        // QuestionStep(
        //   title: 'Been getting any pains \nin your head?',
        //   // text: 'We are done, do you mind to tell us more about yourself?',
        //   isOptional: false,
        //   answerFormat: const SingleChoiceAnswerFormat(
        //     textChoices: <TextChoice>[
        //       TextChoice(text: 'Better than usual', value: 'Better than usual'),
        //       TextChoice(text: 'Same as usual', value: 'Same as usual'),
        //       TextChoice(text: 'Worse than usual', value: 'Worse than usual'),
        //       TextChoice(
        //           text: 'Much worse than usual',
        //           value: 'Much worse than usual'),
        //     ],
        //   ),
        // ),
        QuestionStep(
          title:
              'Been getting a feeling of tightness or pressure \nin your head?',
          isOptional: false,
          answerFormat: const ScaleAnswerFormat(
            step: 1,
            minimumValue: 0,
            maximumValue: 3,
            defaultValue: 0,
            minimumValueDescription: 'Better than usual',
            maximumValueDescription: 'Much worse',
          ),
        ),
        // QuestionStep(
        //   title:
        //       'Been getting a feeling of tightness or pressure \nin your head?',
        //   // text: 'We are done, do you mind to tell us more about yourself?',
        //   isOptional: false,
        //   answerFormat: const SingleChoiceAnswerFormat(
        //     textChoices: <TextChoice>[
        //       TextChoice(text: 'Better than usual', value: 'Better than usual'),
        //       TextChoice(text: 'Same as usual', value: 'Same as usual'),
        //       TextChoice(text: 'Worse than usual', value: 'Worse than usual'),
        //       TextChoice(
        //           text: 'Much worse than usual',
        //           value: 'Much worse than usual'),
        //     ],
        //   ),
        // ),
        QuestionStep(
          title: 'Been having hot or cold spells?',
          isOptional: false,
          answerFormat: const ScaleAnswerFormat(
            step: 1,
            minimumValue: 0,
            maximumValue: 3,
            defaultValue: 0,
            minimumValueDescription: 'Better than usual',
            maximumValueDescription: 'Much worse',
          ),
        ),
        // QuestionStep(
        //   title: 'Been having hot or cold spells?',
        //   // text: 'We are done, do you mind to tell us more about yourself?',
        //   isOptional: false,
        //   answerFormat: const SingleChoiceAnswerFormat(
        //     textChoices: <TextChoice>[
        //       TextChoice(text: 'Better than usual', value: 'Better than usual'),
        //       TextChoice(text: 'Same as usual', value: 'Same as usual'),
        //       TextChoice(text: 'Worse than usual', value: 'Worse than usual'),
        //       TextChoice(
        //           text: 'Much worse than usual',
        //           value: 'Much worse than usual'),
        //     ],
        //   ),
        // ),
        QuestionStep(
          title: 'Been losing much sleep \nover worry?',
          isOptional: false,
          answerFormat: const ScaleAnswerFormat(
            step: 1,
            minimumValue: 0,
            maximumValue: 3,
            defaultValue: 0,
            minimumValueDescription: 'Better than usual',
            maximumValueDescription: 'Much worse',
          ),
        ),
        // QuestionStep(
        //   title: 'Been losing much sleep \nover worry?',
        //   // text: 'We are done, do you mind to tell us more about yourself?',
        //   isOptional: false,
        //   answerFormat: const SingleChoiceAnswerFormat(
        //     textChoices: <TextChoice>[
        //       TextChoice(text: 'Better than usual', value: 'Better than usual'),
        //       TextChoice(text: 'Same as usual', value: 'Same as usual'),
        //       TextChoice(text: 'Worse than usual', value: 'Worse than usual'),
        //       TextChoice(
        //           text: 'Much worse than usual',
        //           value: 'Much worse than usual'),
        //     ],
        //   ),
        // ),
        QuestionStep(
          title:
              'Been having difficulty \nin staying asleep \nonce you fall asleep?',
          isOptional: false,
          answerFormat: const ScaleAnswerFormat(
            step: 1,
            minimumValue: 0,
            maximumValue: 3,
            defaultValue: 0,
            minimumValueDescription: 'Better than usual',
            maximumValueDescription: 'Much worse',
          ),
        ),
        // QuestionStep(
        //   title:
        //       'Been having difficulty \nin staying asleep \nonce you fall asleep?',
        //   // text: 'We are done, do you mind to tell us more about yourself?',
        //   isOptional: false,
        //   answerFormat: const SingleChoiceAnswerFormat(
        //     textChoices: <TextChoice>[
        //       TextChoice(text: 'Better than usual', value: 'Better than usual'),
        //       TextChoice(text: 'Same as usual', value: 'Same as usual'),
        //       TextChoice(text: 'Worse than usual', value: 'Worse than usual'),
        //       TextChoice(
        //           text: 'Much worse than usual',
        //           value: 'Much worse than usual'),
        //     ],
        //   ),
        // ),
        QuestionStep(
          title: 'Been feeling \nconstantly under strain?',
          isOptional: false,
          answerFormat: const ScaleAnswerFormat(
            step: 1,
            minimumValue: 0,
            maximumValue: 3,
            defaultValue: 0,
            minimumValueDescription: 'Better than usual',
            maximumValueDescription: 'Much worse',
          ),
        ),
        // QuestionStep(
        //   title: 'Been feeling \nconstantly under strain?',
        //   // text: 'We are done, do you mind to tell us more about yourself?',
        //   isOptional: false,
        //   answerFormat: const SingleChoiceAnswerFormat(
        //     textChoices: <TextChoice>[
        //       TextChoice(text: 'Better than usual', value: 'Better than usual'),
        //       TextChoice(text: 'Same as usual', value: 'Same as usual'),
        //       TextChoice(text: 'Worse than usual', value: 'Worse than usual'),
        //       TextChoice(
        //           text: 'Much worse than usual',
        //           value: 'Much worse than usual'),
        //     ],
        //   ),
        // ),
        QuestionStep(
          title: 'Been getting edgy or \nbad tempered?',
          isOptional: false,
          answerFormat: const ScaleAnswerFormat(
            step: 1,
            minimumValue: 0,
            maximumValue: 3,
            defaultValue: 0,
            minimumValueDescription: 'Better than usual',
            maximumValueDescription: 'Much worse',
          ),
        ),
        // QuestionStep(
        //   title: 'Been getting edgy or \nbad tempered?',
        //   // text: 'We are done, do you mind to tell us more about yourself?',
        //   isOptional: false,
        //   answerFormat: const SingleChoiceAnswerFormat(
        //     textChoices: <TextChoice>[
        //       TextChoice(text: 'Better than usual', value: 'Better than usual'),
        //       TextChoice(text: 'Same as usual', value: 'Same as usual'),
        //       TextChoice(text: 'Worse than usual', value: 'Worse than usual'),
        //       TextChoice(
        //           text: 'Much worse than usual',
        //           value: 'Much worse than usual'),
        //     ],
        //   ),
        // ),
        QuestionStep(
          title: 'Been getting scared or \npanicky for no reason?',
          isOptional: false,
          answerFormat: const ScaleAnswerFormat(
            step: 1,
            minimumValue: 0,
            maximumValue: 3,
            defaultValue: 0,
            minimumValueDescription: 'Better than usual',
            maximumValueDescription: 'Much worse',
          ),
        ),
        // QuestionStep(
        //   title: 'Been getting scared or \npanicky for no reason?',
        //   // text: 'We are done, do you mind to tell us more about yourself?',
        //   isOptional: false,
        //   answerFormat: const SingleChoiceAnswerFormat(
        //     textChoices: <TextChoice>[
        //       TextChoice(text: 'Better than usual', value: 'Better than usual'),
        //       TextChoice(text: 'Same as usual', value: 'Same as usual'),
        //       TextChoice(text: 'Worse than usual', value: 'Worse than usual'),
        //       TextChoice(
        //           text: 'Much worse than usual',
        //           value: 'Much worse than usual'),
        //     ],
        //   ),
        // ),
        QuestionStep(
          title: 'Been feeling everything is getting on top of you?',
          isOptional: false,
          answerFormat: const ScaleAnswerFormat(
            step: 1,
            minimumValue: 0,
            maximumValue: 3,
            defaultValue: 0,
            minimumValueDescription: 'Better than usual',
            maximumValueDescription: 'Much worse',
          ),
        ),
        // QuestionStep(
        //   title: 'Been feeling everything is getting on top of you?',
        //   // text: 'We are done, do you mind to tell us more about yourself?',
        //   isOptional: false,
        //   answerFormat: const SingleChoiceAnswerFormat(
        //     textChoices: <TextChoice>[
        //       TextChoice(text: 'Better than usual', value: 'Better than usual'),
        //       TextChoice(text: 'Same as usual', value: 'Same as usual'),
        //       TextChoice(text: 'Worse than usual', value: 'Worse than usual'),
        //       TextChoice(
        //           text: 'Much worse than usual',
        //           value: 'Much worse than usual'),
        //     ],
        //   ),
        // ),
        QuestionStep(
          title: 'Been feeling nervous and strung-out all the time?',
          isOptional: false,
          answerFormat: const ScaleAnswerFormat(
            step: 1,
            minimumValue: 0,
            maximumValue: 3,
            defaultValue: 0,
            minimumValueDescription: 'Better than usual',
            maximumValueDescription: 'Much worse',
          ),
        ),
        // QuestionStep(
        //   title: 'Been feeling nervous and strung-out all the time?',
        //   // text: 'We are done, do you mind to tell us more about yourself?',
        //   isOptional: false,
        //   answerFormat: const SingleChoiceAnswerFormat(
        //     textChoices: <TextChoice>[
        //       TextChoice(text: 'Better than usual', value: 'Better than usual'),
        //       TextChoice(text: 'Same as usual', value: 'Same as usual'),
        //       TextChoice(text: 'Worse than usual', value: 'Worse than usual'),
        //       TextChoice(
        //           text: 'Much worse than usual',
        //           value: 'Much worse than usual'),
        //     ],
        //   ),
        // ),
        QuestionStep(
          title: 'Been managing to keep yourself busy and occupied?',
          isOptional: false,
          answerFormat: const ScaleAnswerFormat(
            step: 1,
            minimumValue: 0,
            maximumValue: 3,
            defaultValue: 0,
            minimumValueDescription: 'Better than usual',
            maximumValueDescription: 'Much worse',
          ),
        ),
        // QuestionStep(
        //   title: 'Been managing to keep yourself busy and occupied?',
        //   // text: 'We are done, do you mind to tell us more about yourself?',
        //   isOptional: false,
        //   answerFormat: const SingleChoiceAnswerFormat(
        //     textChoices: <TextChoice>[
        //       TextChoice(text: 'Better than usual', value: 'Better than usual'),
        //       TextChoice(text: 'Same as usual', value: 'Same as usual'),
        //       TextChoice(text: 'Worse than usual', value: 'Worse than usual'),
        //       TextChoice(
        //           text: 'Much worse than usual',
        //           value: 'Much worse than usual'),
        //     ],
        //   ),
        // ),
        QuestionStep(
          title: 'Been taking longer over the things you do?',
          isOptional: false,
          answerFormat: const ScaleAnswerFormat(
            step: 1,
            minimumValue: 0,
            maximumValue: 3,
            defaultValue: 0,
            minimumValueDescription: 'Better than usual',
            maximumValueDescription: 'Much worse',
          ),
        ),
        // QuestionStep(
        //   title: 'Been taking longer over the things you do?',
        //   // text: 'We are done, do you mind to tell us more about yourself?',
        //   isOptional: false,
        //   answerFormat: const SingleChoiceAnswerFormat(
        //     textChoices: <TextChoice>[
        //       TextChoice(text: 'Better than usual', value: 'Better than usual'),
        //       TextChoice(text: 'Same as usual', value: 'Same as usual'),
        //       TextChoice(text: 'Worse than usual', value: 'Worse than usual'),
        //       TextChoice(
        //           text: 'Much worse than usual',
        //           value: 'Much worse than usual'),
        //     ],
        //   ),
        // ),
        QuestionStep(
          title: 'Been feeling you were doing things well?',
          isOptional: false,
          answerFormat: const ScaleAnswerFormat(
            step: 1,
            minimumValue: 0,
            maximumValue: 3,
            defaultValue: 0,
            minimumValueDescription: 'Better than usual',
            maximumValueDescription: 'Much worse',
          ),
        ),
        // QuestionStep(
        //   title: 'Been feeling you were doing things well?',
        //   // text: 'We are done, do you mind to tell us more about yourself?',
        //   isOptional: false,
        //   answerFormat: const SingleChoiceAnswerFormat(
        //     textChoices: <TextChoice>[
        //       TextChoice(text: 'Better than usual', value: 'Better than usual'),
        //       TextChoice(text: 'Same as usual', value: 'Same as usual'),
        //       TextChoice(text: 'Worse than usual', value: 'Worse than usual'),
        //       TextChoice(
        //           text: 'Much worse than usual',
        //           value: 'Much worse than usual'),
        //     ],
        //   ),
        // ),
        QuestionStep(
          title: 'Been satisfied with the way you have carried out your tasks?',
          isOptional: false,
          answerFormat: const ScaleAnswerFormat(
            step: 1,
            minimumValue: 0,
            maximumValue: 3,
            defaultValue: 0,
            minimumValueDescription: 'Better than usual',
            maximumValueDescription: 'Much worse',
          ),
        ),
        // QuestionStep(
        //   title: 'Been satisfied with the way you have carried out your tasks?',
        //   // text: 'We are done, do you mind to tell us more about yourself?',
        //   isOptional: false,
        //   answerFormat: const SingleChoiceAnswerFormat(
        //     textChoices: <TextChoice>[
        //       TextChoice(text: 'Better than usual', value: 'Better than usual'),
        //       TextChoice(text: 'Same as usual', value: 'Same as usual'),
        //       TextChoice(text: 'Worse than usual', value: 'Worse than usual'),
        //       TextChoice(
        //           text: 'Much worse than usual',
        //           value: 'Much worse than usual'),
        //     ],
        //   ),
        // ),
        QuestionStep(
          title: 'Been feeling that you are playing a useful part in things?',
          isOptional: false,
          answerFormat: const ScaleAnswerFormat(
            step: 1,
            minimumValue: 0,
            maximumValue: 3,
            defaultValue: 0,
            minimumValueDescription: 'Better than usual',
            maximumValueDescription: 'Much worse',
          ),
        ),
        // QuestionStep(
        //   title: 'Been feeling that you are playing a useful part in things?',
        //   // text: 'We are done, do you mind to tell us more about yourself?',
        //   isOptional: false,
        //   answerFormat: const SingleChoiceAnswerFormat(
        //     textChoices: <TextChoice>[
        //       TextChoice(text: 'Better than usual', value: 'Better than usual'),
        //       TextChoice(text: 'Same as usual', value: 'Same as usual'),
        //       TextChoice(text: 'Worse than usual', value: 'Worse than usual'),
        //       TextChoice(
        //           text: 'Much worse than usual',
        //           value: 'Much worse than usual'),
        //     ],
        //   ),
        // ),
        QuestionStep(
          title: 'Been feeling capable of making decisions about things?',
          isOptional: false,
          answerFormat: const ScaleAnswerFormat(
            step: 1,
            minimumValue: 0,
            maximumValue: 3,
            defaultValue: 0,
            minimumValueDescription: 'Better than usual',
            maximumValueDescription: 'Much worse',
          ),
        ),
        // QuestionStep(
        //   title: 'Been feeling capable of making decisions about things?',
        //   // text: 'We are done, do you mind to tell us more about yourself?',
        //   isOptional: false,
        //   answerFormat: const SingleChoiceAnswerFormat(
        //     textChoices: <TextChoice>[
        //       TextChoice(text: 'Better than usual', value: 'Better than usual'),
        //       TextChoice(text: 'Same as usual', value: 'Same as usual'),
        //       TextChoice(text: 'Worse than usual', value: 'Worse than usual'),
        //       TextChoice(
        //           text: 'Much worse than usual',
        //           value: 'Much worse than usual'),
        //     ],
        //   ),
        // ),
        QuestionStep(
          title: 'Been able to enjoy your normal day-to-day activities?',
          isOptional: false,
          answerFormat: const ScaleAnswerFormat(
            step: 1,
            minimumValue: 0,
            maximumValue: 3,
            defaultValue: 0,
            minimumValueDescription: 'Better than usual',
            maximumValueDescription: 'Much worse',
          ),
        ),
        // QuestionStep(
        //   title: 'Been able to enjoy your normal day-to-day activities?',
        //   // text: 'We are done, do you mind to tell us more about yourself?',
        //   isOptional: false,
        //   answerFormat: const SingleChoiceAnswerFormat(
        //     textChoices: <TextChoice>[
        //       TextChoice(text: 'Better than usual', value: 'Better than usual'),
        //       TextChoice(text: 'Same as usual', value: 'Same as usual'),
        //       TextChoice(text: 'Worse than usual', value: 'Worse than usual'),
        //       TextChoice(
        //           text: 'Much worse than usual',
        //           value: 'Much worse than usual'),
        //     ],
        //   ),
        // ),
        QuestionStep(
          title: 'Been thinking of yourself as a worthless person?',
          isOptional: false,
          answerFormat: const ScaleAnswerFormat(
            step: 1,
            minimumValue: 0,
            maximumValue: 3,
            defaultValue: 0,
            minimumValueDescription: 'Better than usual',
            maximumValueDescription: 'Much worse',
          ),
        ),
        // QuestionStep(
        //   title: 'Been thinking of yourself as a worthless person?',
        //   // text: 'We are done, do you mind to tell us more about yourself?',
        //   isOptional: false,
        //   answerFormat: const SingleChoiceAnswerFormat(
        //     textChoices: <TextChoice>[
        //       TextChoice(text: 'Better than usual', value: 'Better than usual'),
        //       TextChoice(text: 'Same as usual', value: 'Same as usual'),
        //       TextChoice(text: 'Worse than usual', value: 'Worse than usual'),
        //       TextChoice(
        //           text: 'Much worse than usual',
        //           value: 'Much worse than usual'),
        //     ],
        //   ),
        // ),
        QuestionStep(
          title: 'Been feeling that \nlife is entirely hopeless?',
          isOptional: false,
          answerFormat: const ScaleAnswerFormat(
            step: 1,
            minimumValue: 0,
            maximumValue: 3,
            defaultValue: 0,
            minimumValueDescription: 'Better than usual',
            maximumValueDescription: 'Much worse',
          ),
        ),
        // QuestionStep(
        //   title: 'Been feeling that \nlife is entirely hopeless?',
        //   // text: 'We are done, do you mind to tell us more about yourself?',
        //   isOptional: false,
        //   answerFormat: const SingleChoiceAnswerFormat(
        //     textChoices: <TextChoice>[
        //       TextChoice(text: 'Better than usual', value: 'Better than usual'),
        //       TextChoice(text: 'Same as usual', value: 'Same as usual'),
        //       TextChoice(text: 'Worse than usual', value: 'Worse than usual'),
        //       TextChoice(
        //           text: 'Much worse than usual',
        //           value: 'Much worse than usual'),
        //     ],
        //   ),
        // ),
        QuestionStep(
          title: 'Been feeling that \nlife is not worth living?',
          isOptional: false,
          answerFormat: const ScaleAnswerFormat(
            step: 1,
            minimumValue: 0,
            maximumValue: 3,
            defaultValue: 0,
            minimumValueDescription: 'Better than usual',
            maximumValueDescription: 'Much worse',
          ),
        ),
        // QuestionStep(
        //   title: 'Been feeling that \nlife is not worth living?',
        //   // text: 'We are done, do you mind to tell us more about yourself?',
        //   isOptional: false,
        //   answerFormat: const SingleChoiceAnswerFormat(
        //     textChoices: <TextChoice>[
        //       TextChoice(text: 'Better than usual', value: 'Better than usual'),
        //       TextChoice(text: 'Same as usual', value: 'Same as usual'),
        //       TextChoice(text: 'Worse than usual', value: 'Worse than usual'),
        //       TextChoice(
        //           text: 'Much worse than usual',
        //           value: 'Much worse than usual'),
        //     ],
        //   ),
        // ),
        QuestionStep(
          title: 'Been having a suicidal thoughts?',
          isOptional: false,
          answerFormat: const ScaleAnswerFormat(
            step: 1,
            minimumValue: 0,
            maximumValue: 3,
            defaultValue: 0,
            minimumValueDescription: 'Better than usual',
            maximumValueDescription: 'Much worse',
          ),
        ),
        // QuestionStep(
        //   title: 'Been having a suicidal thoughts?',
        //   // text: 'We are done, do you mind to tell us more about yourself?',
        //   isOptional: false,
        //   answerFormat: const SingleChoiceAnswerFormat(
        //     textChoices: <TextChoice>[
        //       TextChoice(text: 'Better than usual', value: 'Better than usual'),
        //       TextChoice(text: 'Same as usual', value: 'Same as usual'),
        //       TextChoice(text: 'Worse than usual', value: 'Worse than usual'),
        //       TextChoice(
        //           text: 'Much worse than usual',
        //           value: 'Much worse than usual'),
        //     ],
        //   ),
        // ),
        QuestionStep(
          title:
              'Been feeling at times that you could not do anything because your nerves & anxiety were too bad?',
          isOptional: false,
          answerFormat: const ScaleAnswerFormat(
            step: 1,
            minimumValue: 0,
            maximumValue: 3,
            defaultValue: 0,
            minimumValueDescription: 'Better than usual',
            maximumValueDescription: 'Much worse',
          ),
        ),
        // QuestionStep(
        //   title:
        //       'Been feeling at times that you could not do anything because your nerves & anxiety were too bad?',
        //   // text: 'We are done, do you mind to tell us more about yourself?',
        //   isOptional: false,
        //   answerFormat: const SingleChoiceAnswerFormat(
        //     textChoices: <TextChoice>[
        //       TextChoice(text: 'Better than usual', value: 'Better than usual'),
        //       TextChoice(text: 'Same as usual', value: 'Same as usual'),
        //       TextChoice(text: 'Worse than usual', value: 'Worse than usual'),
        //       TextChoice(
        //           text: 'Much worse than usual',
        //           value: 'Much worse than usual'),
        //     ],
        //   ),
        // ),
        QuestionStep(
          title:
              'Been finding yourself wishing you were dead and away from it all?',
          answerFormat: const ScaleAnswerFormat(
            step: 1,
            minimumValue: 0,
            maximumValue: 3,
            defaultValue: 0,
            minimumValueDescription: 'Better than usual',
            maximumValueDescription: 'Much worse',
          ),
        ),
        // QuestionStep(
        //   title:
        //       'Been finding yourself wishing you were dead and away from it all?',
        //   // text: 'We are done, do you mind to tell us more about yourself?',
        //   isOptional: false,
        //   answerFormat: const SingleChoiceAnswerFormat(
        //     textChoices: <TextChoice>[
        //       TextChoice(text: 'Better than usual', value: 'Better than usual'),
        //       TextChoice(text: 'Same as usual', value: 'Same as usual'),
        //       TextChoice(text: 'Worse than usual', value: 'Worse than usual'),
        //       TextChoice(
        //           text: 'Much worse than usual',
        //           value: 'Much worse than usual'),
        //     ],
        //   ),
        QuestionStep(
          title:
              'Been finding that the idea of taking your own life keeps coming into your mind?',
          answerFormat: const ScaleAnswerFormat(
            step: 1,
            minimumValue: 0,
            maximumValue: 3,
            defaultValue: 0,
            minimumValueDescription: 'Better than usual',
            maximumValueDescription: 'Much worse',
          ),
        ),
        // ),
        // QuestionStep(
        //   title:
        //       'Been finding that the idea of taking your own life keeps coming into your mind?',
        //   // text: 'We are done, do you mind to tell us more about yourself?',
        //   isOptional: false,
        //   answerFormat: const SingleChoiceAnswerFormat(
        //     textChoices: <TextChoice>[
        //       TextChoice(text: 'Better than usual', value: 'Better than usual'),
        //       TextChoice(text: 'Same as usual', value: 'Same as usual'),
        //       TextChoice(text: 'Worse than usual', value: 'Worse than usual'),
        //       TextChoice(
        //           text: 'Much worse than usual',
        //           value: 'Much worse than usual'),
        //     ],
        //   ),
        // ),
        CompletionStep(
          isOptional: false,
          stepIdentifier: StepIdentifier(id: '321'),
          text: 'Thank! Make sure to push "NEXT" to finish',
          title: 'Done!',
          buttonText: 'Submit survey',
        ),
      ],
    );
    return Future<Task>.value(task);
    // } else {
    //   return null;
    // }
  }
}
