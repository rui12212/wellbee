import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wellbee/screens/graph/radar_extends.dart';
import 'package:wellbee/ui_parts/color.dart';

class _Header extends StatelessWidget {
  String title;
  String subtitle;

  _Header({required this.title, required this.subtitle});

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
                    Navigator.of(context).pop();
                  },
                )
              ],
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              subtitle,
              style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w300,
                  color: kColorTextDarkGrey),
            ),
          )
        ],
      ),
    );
  }
}

class StaffRadarChartPage extends StatefulWidget {
  // 前のページから渡されるアンケートデータ（Map<String, int>）
  final Map<String, dynamic> surveyData;

  StaffRadarChartPage({super.key, required this.surveyData});
  // : assert(surveyData.length == 20,
  //       'surveyData must contain exactly 20 elements.');

  // 色の定義
  final Color gridColor = Color.fromARGB(57, 158, 158, 158);
  final Color titleColor = Colors.black;
  final Color baselineColor = Colors.grey.withOpacity(0.3); // 基準値の色
  final Color userColor = Colors.blue.withOpacity(0.5); // ユーザーデータの色

  @override
  State<StaffRadarChartPage> createState() => _StaffRadarChartPageState();
}

class _StaffRadarChartPageState extends State<StaffRadarChartPage> {
  // 選択されたデータセットのインデックス（未使用だが保持）
  int selectedDataSetIndex = -1;
  double bodyScore = 0;
  double sleepScore = 0;
  double stressScore = 0;
  double activityScore = 0;
  double relationScore = 0;

  // 各カテゴリの集計値（Body, Sleep, Stress, Activity, Overall）
  List<double> categoryValues = [0, 0, 0, 0, 0];

  @override
  void initState() {
    super.initState();
    processSurveyData();
  }

  void processSurveyData() {
    double body = 0;
    double sleep = 0;
    double stress = 0;
    double activity = 0;
    double relation = 0;

    for (int i = 0; i < 20; i++) {
      String scoreKey = 'score$i';
      int score = widget.surveyData[scoreKey] ?? 0;

      if (i >= 0 && i <= 3) {
        body += score;
      } else if (i >= 4 && i <= 7) {
        sleep += score;
      } else if (i >= 8 && i <= 11) {
        stress += score;
      } else if (i >= 12 && i <= 15) {
        activity += score;
      } else if (i >= 16 && i <= 19) {
        relation += score;
      }
    }
    setState(() {
      categoryValues = [body, sleep, stress, activity, relation];
      bodyScore = 4 - categoryValues[0];
      sleepScore = 4 - categoryValues[1];
      stressScore = 4 - categoryValues[2];
      activityScore = 4 - categoryValues[3];
      relationScore = 4 - categoryValues[4];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(
                    title: 'Survey Detail',
                    subtitle: 'Your Physical & Mental status'),
                // カテゴリのリスト表示（色付きのインジケーター付き）
                // GestureDetector(
                //   onTap: () {
                //     setState(() {
                //       selectedDataSetIndex = -1;
                //     });
                //   },
                //   child: Text(
                //     'Survey Detail',
                //     style: TextStyle(
                //       fontSize: 32.h,
                //       fontWeight: FontWeight.w300,
                //     ),
                //   ),
                // ),
                // Radar Chartとラベルを重ねて表示
                SizedBox(
                  height: 20.h,
                ),
                Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 1.3,
                      child: RadarChart(
                        RadarChartDataFixMinMax(
                          max: RadarEntry(value: 4),
                          min: RadarEntry(value: 1),
                          tickCount: 3, // スケールの目盛り数を固定
                          dataSets: showingDataSets(),
                          radarBackgroundColor: Colors.transparent,
                          borderData: FlBorderData(show: false),
                          radarBorderData:
                              const BorderSide(color: Colors.transparent),

                          ticksTextStyle: TextStyle(
                              color: Colors.transparent, fontSize: 2.h),
                          tickBorderData:
                              const BorderSide(color: Colors.transparent),
                          gridBorderData:
                              BorderSide(color: widget.gridColor, width: 2.w),
                          // スケールの固定（minYとmaxYが使用できないため、データを制限）
                          // タッチイベントの設定
                          radarTouchData: RadarTouchData(
                            touchCallback: (FlTouchEvent event,
                                RadarTouchResponse? response) {
                              if (response == null ||
                                  response.touchedSpot == null) {
                                setState(() {
                                  selectedDataSetIndex = -1;
                                });
                                return;
                              }
                              if (event is FlTapUpEvent) {
                                setState(() {
                                  selectedDataSetIndex =
                                      response.touchedSpot!.touchedDataSetIndex;
                                  // 必要に応じて他のアクションを追加
                                });
                              }
                            },
                          ),
                        ),
                        // RadarChartData(
                        //   // データセットの定義（基準値とユーザーデータ）
                        //   dataSets: showingDataSets(),
                        //   radarBackgroundColor: Colors.transparent,
                        //   borderData: FlBorderData(show: false),
                        //   radarBorderData:
                        //       const BorderSide(color: Colors.transparent),
                        //   tickCount: 4, // スケールの目盛り数を固定
                        //   ticksTextStyle: const TextStyle(
                        //       color: Colors.transparent, fontSize: 2),
                        //   tickBorderData:
                        //       const BorderSide(color: Colors.transparent),
                        //   gridBorderData:
                        //       BorderSide(color: widget.gridColor, width: 2),
                        //   // スケールの固定（minYとmaxYが使用できないため、データを制限）
                        //   // タッチイベントの設定
                        //   radarTouchData: RadarTouchData(
                        //     touchCallback: (FlTouchEvent event,
                        //         RadarTouchResponse? response) {
                        //       if (response == null ||
                        //           response.touchedSpot == null) {
                        //         setState(() {
                        //           selectedDataSetIndex = -1;
                        //         });
                        //         return;
                        //       }
                        //       if (event is FlTapUpEvent) {
                        //         setState(() {
                        //           selectedDataSetIndex =
                        //               response.touchedSpot!.touchedDataSetIndex;
                        //           // 必要に応じて他のアクションを追加
                        //         });
                        //       }
                        //     },
                        //   ),
                        // ),
                        swapAnimationDuration:
                            const Duration(milliseconds: 400),
                      ),
                    ),
                    // レーダーチャート上に水平なラベルをオーバーレイ表示
                    Positioned.fill(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          double radius =
                              min(constraints.maxWidth, constraints.maxHeight) /
                                  2.4.h;
                          double centerX = constraints.maxWidth / 2;
                          double centerY = constraints.maxHeight / 2;

                          List<String> labels = [
                            'Physic/لەش',
                            'Sleep\nنڤستن',
                            'Stress\n(فشار(سترێس',
                            'Exercise\nکرنا راهێنانان',
                            'Diet\nخوارن',
                          ];

                          return Stack(
                            children: List.generate(labels.length, (index) {
                              double angle = (360 / labels.length) * index - 90;
                              double radians = angle * pi / 180;
                              double labelX =
                                  centerX + (radius + 20.w) * cos(radians);
                              double labelY =
                                  centerY + (radius + 20.w) * sin(radians);

                              return Positioned(
                                left: labelX - 70.w, // テキストの幅に応じて調整
                                top: labelY - 12.w, // テキストの高さに応じて調整
                                child: Container(
                                  // テキストの入るボックス
                                  width: 150.w,
                                  alignment: Alignment.center,
                                  child: Text(
                                    labels[index],
                                    style: TextStyle(
                                      color: widget.titleColor,
                                      fontSize: 15.h,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            }),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20.h,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: getRawDataSets()
                      .asMap()
                      .map((index, value) {
                        final isSelected = index == selectedDataSetIndex;
                        return MapEntry(
                          index,
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedDataSetIndex = index;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: EdgeInsets.symmetric(vertical: 0.1.h),
                              height: 30.h,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Color.fromARGB(190, 206, 207, 210)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(46),
                              ),
                              padding: EdgeInsets.symmetric(
                                vertical: 4.h,
                                horizontal: 6.w,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 400),
                                    curve: Curves.easeInToLinear,
                                    padding:
                                        EdgeInsets.all(isSelected ? 8.h : 6.h),
                                    decoration: BoxDecoration(
                                      color: value.color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: 10.w),
                                  AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInToLinear,
                                    style: TextStyle(
                                      color: isSelected
                                          ? value.color
                                          : Colors.black,
                                    ),
                                    child: Text(value.title,
                                        style: TextStyle(fontSize: 16.h)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      })
                      .values
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // データセットの定義（基準値とユーザーデータ）
  List<RadarDataSet> showingDataSets() {
    List<RadarDataSet> dataSets = [];

    // 1. グラフ枠（最大値4）
    dataSets.add(RadarDataSet(
      fillColor: Colors.transparent,
      borderColor: widget.baselineColor,
      entryRadius: 0,
      dataEntries: List.generate(5, (_) => RadarEntry(value: 4)),
      borderWidth: 2,
    ));

    dataSets.add(RadarDataSet(
      fillColor: Color.fromARGB(71, 1, 141, 55),
      borderColor: Color.fromARGB(87, 1, 141, 55),
      entryRadius: 3.w,
      dataEntries: [
        RadarEntry(value: bodyScore),
        RadarEntry(value: sleepScore),
        RadarEntry(value: stressScore),
        RadarEntry(value: activityScore),
        RadarEntry(value: relationScore),
      ],
      borderWidth: 2,
    ));

    return dataSets;
  }

  // カテゴリごとのタイトルと色のリストを取得（レジェンド用）
  List<RawDataSet> getRawDataSets() {
    return [
      RawDataSet(
        title: 'Physics : Body condition: $bodyScore',
        color: Color.fromARGB(255, 53, 121, 50),
        values: [categoryValues[0]],
      ),
      RawDataSet(
        title: 'Sleep : The quality of the sleep: $sleepScore',
        color: Colors.pink,
        values: [categoryValues[1]],
      ),
      RawDataSet(
        title: 'Stress : Daily stress level: $stressScore',
        color: Colors.brown,
        values: [categoryValues[2]],
      ),
      RawDataSet(
        title: 'Exercise: Habit of exercise: $activityScore',
        color: Colors.purple,
        values: [categoryValues[3]],
      ),
      RawDataSet(
        title: 'Diet : Healthy diet habit : $relationScore',
        color: Colors.blueGrey,
        values: [categoryValues[4]],
      ),
    ];
  }
}

// カテゴリごとのデータセットを表すクラス（レジェンド用）
class RawDataSet {
  RawDataSet({
    required this.title,
    required this.color,
    required this.values,
  });

  final String title;
  final Color color;
  final List<double> values;
}
