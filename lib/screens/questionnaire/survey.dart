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
      for (int i = 0; i < 20; i++) {
        responseMap['response$i'] = responseList[i];
      }
      var urlSurvey =
          Uri.parse('${baseUri}questionnaires/survey_response/?token=$token');
      var urlBase =
          Uri.parse('${baseUri}questionnaires/base_body_survey/?token=$token');
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

                        for (int i = 1; i < 21; i++) {
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
          title: 'Welcome to the Health Survey\nبخێر هاتی بو راپرسیا ساخلەمیێ',
          text: 'Let\'s share your current physical & psychological health!',
          buttonText: 'Let\'s go!',
        ),
        // 1
        QuestionStep(
          title:
              'Having pain in the body?(backache, headache,knees…etc)\nهەست ب هەبوونا ئێشانێ دلەشێ خودا دکەی؟(پشت ئێشان، سەرئێشان، ئێشانا چووکان…هتد',
          isOptional: false,
          answerFormat: const ScaleAnswerFormat(
            step: 1,
            minimumValue: 0,
            maximumValue: 3,
            defaultValue: 0,
            minimumValueDescription: 'Not at all\nنەخێر ب چ شێوا',
            maximumValueDescription: 'Pain Badly\nگەلەک ئێشان',
          ),
        ),
        // 2
        QuestionStep(
          title:
              'Easily get up in the morning?\nئەرێ ب ساناهی سپێدێ ژخەو رادبی؟',
          isOptional: false,
          answerFormat: const ScaleAnswerFormat(
            step: 1,
            minimumValue: 0,
            maximumValue: 3,
            defaultValue: 0,
            minimumValueDescription: 'Very easy\nگەلەک ساناهی',
            maximumValueDescription: 'Very hard\nگەلەک زەحمەت',
          ),
        ),
        // 3
        QuestionStep(
          title: 'Always feeling tired?\nهەمی دەمان هەست ب وەستیانێ دکەی؟ ',
          isOptional: false,
          answerFormat: const ScaleAnswerFormat(
            step: 1,
            minimumValue: 0,
            maximumValue: 3,
            defaultValue: 0,
            minimumValueDescription: 'Not at all\nنەخێر ب چ شێوا ',
            maximumValueDescription: 'Very much\nگەلەک',
          ),
        ),
        // 4
        QuestionStep(
          title:
              'Easily catch colds and get worse?\nزویکا پەرسیڤ دهێتە تە و یا بهێزە؟',
          isOptional: false,
          answerFormat: const ScaleAnswerFormat(
            step: 1,
            minimumValue: 0,
            maximumValue: 3,
            defaultValue: 0,
            minimumValueDescription: 'No\nنەخێر',
            maximumValueDescription: 'Yes\nبەلێ',
          ),
        ),
        // 5
        QuestionStep(
          title: 'Easy to fall asleep at night?\nب ساناهی بشەڤێ دنڤی؟',
          isOptional: false,
          answerFormat: const ScaleAnswerFormat(
            step: 1,
            minimumValue: 0,
            maximumValue: 3,
            defaultValue: 0,
            minimumValueDescription: 'Very easy\nگەلەک ساناهی',
            maximumValueDescription: 'Very hard\nگەلەک زەحمەت',
          ),
        ),
        // 6
        QuestionStep(
          title: 'Often dreams during sleep?\n گەلەک خەونان دبینی؟',
          isOptional: false,
          answerFormat: const ScaleAnswerFormat(
            step: 1,
            minimumValue: 0,
            maximumValue: 3,
            defaultValue: 0,
            minimumValueDescription: 'Not much\nنە گەلەک',
            maximumValueDescription: 'Very much\nگەلەک',
          ),
        ),
        // 7
        QuestionStep(
          title:
              'Are you feeling tired when you wake up?\n دەمێ ژخەو رادبی هەست ب وەستیانێ دکەی؟',
          isOptional: false,
          answerFormat: const ScaleAnswerFormat(
            step: 1,
            minimumValue: 0,
            maximumValue: 3,
            defaultValue: 0,
            minimumValueDescription: 'Not much\nنە گەلەک',
            maximumValueDescription: 'Very much\n گەلەک',
          ),
        ),
        // 8
        QuestionStep(
          title:
              'Having fixed time to get up or go to bed?\nچ دەمێ دیارکری بو ژخەو رابوون و نڤستنێ نینن؟ ',
          isOptional: false,
          answerFormat: const ScaleAnswerFormat(
            step: 1,
            minimumValue: 0,
            maximumValue: 3,
            defaultValue: 0,
            minimumValueDescription: 'Yes\nبەلێ ',
            maximumValueDescription: 'No\nنەخێر',
          ),
        ),
        // 9
        QuestionStep(
          title:
              'Very big life event happened lately?\nدڤان دوماهیان دا گوهورینەکا مەزن د ژیانا تەدا رویدایە؟',
          isOptional: false,
          answerFormat: const ScaleAnswerFormat(
            step: 1,
            minimumValue: 0,
            maximumValue: 3,
            defaultValue: 0,
            minimumValueDescription: 'No\n نەخێر',
            maximumValueDescription: 'Yes\nبەلێ',
          ),
        ),
        // 10
        QuestionStep(
          title: 'Easily irritated?\nب ساناهی تورە دبی؟',
          // イライラしていると感じる
          isOptional: false,
          answerFormat: const ScaleAnswerFormat(
            step: 1,
            minimumValue: 0,
            maximumValue: 3,
            defaultValue: 0,
            minimumValueDescription: 'Not much\nنە گەلەک',
            maximumValueDescription: 'Very much\nگەلەک',
          ),
        ),
        // 11
        QuestionStep(
          title: 'Defecation?\nچوونا دەستئاڤێ؟',
          isOptional: false,
          answerFormat: const ScaleAnswerFormat(
            step: 1,
            minimumValue: 0,
            maximumValue: 3,
            defaultValue: 0,
            minimumValueDescription: 'Very good\nگەلەک باشە ',
            maximumValueDescription: 'Very bad\nگەلەک نە باشە',
          ),
        ),
        // 12
        QuestionStep(
          title: 'Bedrooms are organized?\nژوورا نڤستنێ یا رێک و پێکە؟',
          isOptional: false,
          answerFormat: const ScaleAnswerFormat(
            step: 1,
            minimumValue: 0,
            maximumValue: 3,
            defaultValue: 0,
            minimumValueDescription: 'Very good\nگەلەک باشە',
            maximumValueDescription: 'Very bad\nگەلەک نە باشە',
          ),
        ),
        // 13
        QuestionStep(
          title:
              'Use a car even if it is a short distance?\nبکارئینانا ترومبێلێ خو بو رێکێن نێزیک ژی؟',
          isOptional: false,
          answerFormat: const ScaleAnswerFormat(
            step: 1,
            minimumValue: 0,
            maximumValue: 3,
            defaultValue: 0,
            minimumValueDescription: 'No\nنەخێر',
            maximumValueDescription: 'Yes, always\nبەلێ گەلەک',
          ),
        ),
        // 14
        QuestionStep(
          title: 'Easy to climb the stairs?\nب ساناهى سەر دەرەچکان دکەڤی؟',
          isOptional: false,
          answerFormat: const ScaleAnswerFormat(
            step: 1,
            minimumValue: 0,
            maximumValue: 3,
            defaultValue: 0,
            minimumValueDescription: 'Very easy\nگەلەک ساناهی',
            maximumValueDescription: 'Very hard\nگەلەک زەحمەت',
          ),
        ),
        // 15
        QuestionStep(
          title:
              'Easily put on socks while standing?\n ب ساناهى راوەستای(ژپیاڤە) گورا خو دکەیە بەر خو؟',
          isOptional: false,
          answerFormat: const ScaleAnswerFormat(
            step: 1,
            minimumValue: 0,
            maximumValue: 3,
            defaultValue: 0,
            minimumValueDescription: 'Very easy\nگەلەک ساناهی',
            maximumValueDescription: 'Very hard\nگەلەک زەحمەت',
          ),
        ),
        // 16
        QuestionStep(
          title: 'Clothes size got larger?\nقیاسێ جلکێن تە مەزنتر لێ دهێت؟',
          isOptional: false,
          answerFormat: const ScaleAnswerFormat(
            step: 1,
            minimumValue: 0,
            maximumValue: 3,
            defaultValue: 0,
            minimumValueDescription: 'Same\nوەک خویە',
            maximumValueDescription: 'Very much\nبەلێ گەلەک',
          ),
        ),
        // 17
        QuestionStep(
          title: 'Has regular mealtimes?\nدەمێن خوارنێ یێن رێک و پێک هەنە؟',
          isOptional: false,
          answerFormat: const ScaleAnswerFormat(
            step: 1,
            minimumValue: 0,
            maximumValue: 3,
            defaultValue: 0,
            minimumValueDescription: 'Yes\nبەلێ',
            maximumValueDescription: 'No\nنەخێر',
          ),
        ),
        // 18
        QuestionStep(
          title: 'Have a good appetite?\n ئارەزوویا خوارنا تە یا باشە؟ ',
          isOptional: false,
          answerFormat: const ScaleAnswerFormat(
            step: 1,
            minimumValue: 0,
            maximumValue: 3,
            defaultValue: 0,
            minimumValueDescription: 'Yes\nبەلێ',
            maximumValueDescription: 'No\nنەخێر',
          ),
        ),
        // 19
        QuestionStep(
          title:
              'Drink more than 1.5 liters of water a day?\nپتر ژ 1.5لترێن ئاڤێ د روژێدا ڤەدخویی؟ ',
          isOptional: false,
          answerFormat: const ScaleAnswerFormat(
            step: 1,
            minimumValue: 0,
            maximumValue: 3,
            defaultValue: 0,
            minimumValueDescription: 'Yes\nبەلێ',
            maximumValueDescription: 'No\nنەخێر',
          ),
        ),
        // 20
        QuestionStep(
          title:
              'Eat often salty/sweet/oily foods?\nگەلەک جاران خوارنێن سویر/شرین/ ب زەیت دخوی؟',
          isOptional: false,
          answerFormat: const ScaleAnswerFormat(
            step: 1,
            minimumValue: 0,
            maximumValue: 3,
            defaultValue: 0,
            minimumValueDescription: 'Not much\nنە گەلەک ',
            maximumValueDescription: 'Very much\n بەلێ گەلەک',
          ),
        ),
        // last
        CompletionStep(
          isOptional: false,
          stepIdentifier: StepIdentifier(id: '321'),
          text:
              'Thank! Make sure to push "NEXT" to finish\nدانە بو دوماهیک ئینانێ “Next”',
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
