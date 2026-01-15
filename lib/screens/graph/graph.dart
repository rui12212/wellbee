import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:wellbee/assets/inet.dart';
import 'package:wellbee/screens/graph/radar.dart';
import 'package:wellbee/screens/questionnaire/questionnaire_base.dart';
import 'package:wellbee/ui_function/shared_prefs.dart';
import 'package:wellbee/ui_parts/color.dart';
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

class GraphPage extends StatefulWidget {
  late Map<String, dynamic> attendeeList;

  GraphPage({
    super.key,
    required this.attendeeList,
  });

  @override
  State<GraphPage> createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  String? token = '';
  String attendee_name = '';

  Future<List<dynamic>?> _fetchSurveyResult(String attendeeName) async {
    try {
      token = await SharedPrefs.fetchAccessToken();
      var url = Uri.parse(
          '${baseUri}questionnaires/survey_response/my_survey?attendee_name=$attendeeName&token=$token');
      var response = await Future.any([
        http.get(url, headers: {"Authorization": 'JWT $token'}),
        Future.delayed(const Duration(seconds: 15),
            () => throw TimeoutException("Request Timeout"))
      ]);
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty && data != null) {
          return data;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Error occurred. You may not have taken survey')));
        }
      } else if (response.statusCode >= 400) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Internet Error occurred')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Something went wrong. Try again later')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Other Error: $e')));
    }
  }

  Future<List<dynamic>?> _fetchBodyResult(String attendeeName) async {
    try {
      token = await SharedPrefs.fetchAccessToken();
      var url = Uri.parse(
          '${baseUri}questionnaires/base_body_survey/my_bmi?attendee_name=${attendeeName}&token=$token');
      var response = await Future.any([
        http.get(url, headers: {
          "Authorization": 'JWT $token',
          "Content-Type": "application/json"
        }),
        Future.delayed(const Duration(seconds: 15),
            () => throw TimeoutException("Request Timeout"))
      ]);
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty && data != null) {
          return data;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Error occurred. You may not have taken survey')));
        }
      } else if (response.statusCode >= 400) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Internet Error occurred')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Something went wrong. Try again later')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Other Error: $e')));
    }
  }

  @override
  void initState() {
    super.initState();
    // _fetchSurveyResult();
  }

  Widget bottomTitleWidgets(
      double value, TitleMeta meta, double chartWidth, String date) {
    final style = TextStyle(
        fontWeight: FontWeight.bold,
        color: kColorTextDarkGrey,
        fontFamily: 'Digital',
        fontSize: 15.sp);
    DateTime parsedDateTime = DateTime.parse(date);
    String fotmattedDate = DateFormat('yy-MM').format(parsedDateTime);

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(fotmattedDate, style: style),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const _Header(
                  title: 'Your Health Chart',
                  subtitle: 'Track your mental and physical health',
                ),
                // below GHQ
                SizedBox(
                  height: 20.h,
                ),
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mental Health/ساخلەمیا دەرونی',
                        style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black),
                      ),
                      SizedBox(
                        height: 5.h,
                      ),
                      FutureBuilder(
                          future:
                              _fetchSurveyResult(widget.attendeeList['name']),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (snapshot.hasError) {
                              return Center(
                                  child: Text('Error: ${snapshot.error}'));
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return Center(
                                  child: Column(
                                children: [
                                  SizedBox(height: 40.h),
                                  Text('No survey can be shown.'),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  QuestionnairePage(
                                                      attendeeList: widget
                                                          .attendeeList)));
                                    },
                                    child: Text('Take a 5 min Survey',
                                        style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 4, 141, 151),
                                            fontSize: 15.sp)),
                                  ),
                                  SizedBox(height: 40.h),
                                ],
                              ));
                            } else {
                              final mySurveyList = snapshot.data;
                              List<int> spotShowingList = [];
                              Map<dynamic, dynamic> dataSet = {};
                              for (int i = 0; i < mySurveyList!.length; i++) {
                                spotShowingList.add(i);
                                dataSet[i] = mySurveyList[i]['total_score'];
                              }
                              // dataSetの型変換
                              List<FlSpot> spotsData =
                                  dataSet.entries.map((entry) {
                                return FlSpot(entry.key.toDouble(),
                                    entry.value.toDouble());
                              }).toList();

                              final lineBarsDataMentalHealth = [
                                LineChartBarData(
                                    spots: spotsData, // your data here
                                    isCurved: true,
                                    barWidth: 3,
                                    color: kHealthColor, // グラフの色
                                    dotData: FlDotData(
                                      show: true,
                                      getDotPainter:
                                          (spot, percent, barData, index) =>
                                              FlDotCirclePainter(
                                        // ドットの大きさ
                                        radius: 7.h,
                                        color: kHealthColor,
                                        strokeWidth: 0.5,
                                      ),
                                    )),
                              ];

                              final lineBarsData = [
                                LineChartBarData(
                                  // spotのどこを表示させるか？
                                  showingIndicators: spotShowingList,
                                  spots: spotsData,

                                  isCurved: true,
                                  barWidth: 3,
                                  dotData: const FlDotData(show: true),
                                ),
                              ];
                              final tooltipsOnBar = lineBarsData[0];

                              // 動的にmaxXを変更
                              double convertedMaxXForGHQ = 6;
                              double convertMaxXForGHQ() {
                                int maxX = mySurveyList.length;
                                if (maxX < 7) {
                                  maxX = 6;
                                  return maxX.toDouble();
                                } else {
                                  return maxX.toDouble();
                                }
                              }

                              convertedMaxXForGHQ = convertMaxXForGHQ();

                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Container(
                                  width: MediaQuery.of(context).size.width *
                                      (convertedMaxXForGHQ / 6),
                                  height:
                                      MediaQuery.of(context).size.width * 0.8,
                                  color: Colors.white,
                                  child: LayoutBuilder(
                                      builder: (context, constraints) {
                                    return LineChart(
                                      LineChartData(
                                        lineBarsData: lineBarsDataMentalHealth,
                                        showingTooltipIndicators:
                                            spotShowingList.map((index) {
                                          return ShowingTooltipIndicators([
                                            LineBarSpot(
                                              // どんなバーを表示するか？
                                              tooltipsOnBar,
                                              // 選んだバーの何個目を表示するか？
                                              lineBarsData
                                                  .indexOf(tooltipsOnBar),
                                              // スポットはどんなやつ？
                                              tooltipsOnBar.spots[index],
                                            ),
                                          ]);
                                        }).toList(),
                                        lineTouchData: LineTouchData(
                                          enabled: true,
                                          handleBuiltInTouches: false,
                                          touchCallback: (FlTouchEvent event,
                                              LineTouchResponse? response) {
                                            if (response == null ||
                                                response.lineBarSpots == null) {
                                              return;
                                            }
                                            if (event is FlTapUpEvent) {
                                              final spotIndex = response
                                                  .lineBarSpots!
                                                  .first
                                                  .spotIndex;
                                              // print(mySurveyList[spotIndex]);
                                              Navigator.of(context)
                                                  .push(MaterialPageRoute(
                                                builder: (context) {
                                                  return RadarChartPage(
                                                      surveyData: mySurveyList[
                                                          spotIndex]);
                                                },
                                              ));
                                            }
                                          },
                                          mouseCursorResolver:
                                              (FlTouchEvent event,
                                                  LineTouchResponse? response) {
                                            if (response == null ||
                                                response.lineBarSpots == null) {
                                              return SystemMouseCursors.basic;
                                            }
                                            return SystemMouseCursors.click;
                                          },
                                          getTouchedSpotIndicator:
                                              (LineChartBarData barData,
                                                  List<int> spotIndexes) {
                                            return spotIndexes.map((index) {
                                              return const TouchedSpotIndicatorData(
                                                // spotまでの下からの線
                                                FlLine(
                                                  color: Colors.transparent,
                                                ),
                                                FlDotData(
                                                  show: true,
                                                  // getDotPainter: (spot, percent,
                                                  //         barData, index) =>
                                                  //     FlDotCirclePainter(
                                                  //   // ドットの大きさ
                                                  //   radius: 12,
                                                  //   color: Colors.black,
                                                  //   strokeWidth: 0.5,
                                                  // ),
                                                ),
                                              );
                                            }).toList();
                                          },
                                          touchTooltipData:
                                              LineTouchTooltipData(
                                            // ドットにデータの中の数字をどう表示するか？
                                            getTooltipColor: (touchedSpot) =>
                                                kHealthColor,
                                            tooltipRoundedRadius: 30,
                                            getTooltipItems: (List<LineBarSpot>
                                                lineBarsSpot) {
                                              return lineBarsSpot
                                                  .map((lineBarSpot) {
                                                return LineTooltipItem(
                                                  lineBarSpot.y.toString(),
                                                  TextStyle(
                                                    fontSize: 14.sp,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                );
                                              }).toList();
                                            },
                                          ),
                                        ),
                                        // セングラフのデータ自体何を表示するか？
                                        // Y軸の最低ポイントは？
                                        minY: 0,
                                        maxY: 25, // Y軸の最大値を30に設定
                                        minX: 0,
                                        maxX: 6, // X軸の最大値を6に設定
                                        // グラフのY軸のタイトル
                                        titlesData: FlTitlesData(
                                          leftTitles: AxisTitles(
                                            axisNameWidget: Text(
                                              'Mental Health',
                                              style: TextStyle(
                                                fontSize: 18.sp,
                                                color: kHealthColor,
                                                fontWeight: FontWeight.w600,
                                                decoration: TextDecoration.none,
                                              ),
                                            ),
                                            axisNameSize: 22.sp,
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              reservedSize: 20.sp, // 余白を調整
                                              getTitlesWidget: (value, meta) {
                                                return Text('');
                                              },
                                            ),
                                          ),
                                          bottomTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              interval: 1,
                                              getTitlesWidget: (value, meta) {
                                                if (value >=
                                                    mySurveyList.length) {
                                                  return const SizedBox
                                                      .shrink(); // 範囲外のラベルを隠す
                                                }
                                                return bottomTitleWidgets(
                                                    value,
                                                    meta,
                                                    constraints.maxWidth,
                                                    mySurveyList[value.toInt()]
                                                        ['created_at']);
                                              },
                                              reservedSize: 30.sp,
                                            ),
                                          ),
                                          topTitles: const AxisTitles(
                                            axisNameWidget: Text(
                                              '',
                                              textAlign: TextAlign.left,
                                            ),
                                            axisNameSize: 24,
                                            sideTitles: SideTitles(
                                              showTitles: false,
                                              reservedSize: 0,
                                            ),
                                          ),
                                        ),
                                        // Gridボーダーの表示非表示
                                        gridData: const FlGridData(show: false),
                                        borderData: FlBorderData(
                                          // Gridボーダーの表示非表示
                                          show: true,
                                          border: const Border(
                                            left: BorderSide(
                                                color: Colors.grey,
                                                width: 0.5), // y=0の線
                                            bottom: BorderSide(
                                                color: Colors.grey,
                                                width: 0.5), // x=0の線
                                            right:
                                                BorderSide.none, // 右側のボーダーを非表示
                                            top: BorderSide.none,
                                          ),
                                        ),
                                        extraLinesData: ExtraLinesData(
                                          horizontalLines: [
                                            HorizontalLine(
                                              y: 10,
                                              color: kHealthColor,
                                              strokeWidth: 2,
                                              dashArray: [5, 5],
                                            ),
                                            HorizontalLine(
                                              label: HorizontalLineLabel(),
                                              y: 0,
                                              color: kHealthColor,
                                              strokeWidth: 2,
                                              dashArray: [5, 5],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              );
                            }
                          }),
                      Text('*Your somatic,anxiety,body condition level',
                          style: TextStyle(fontSize: 14.h)),
                      Text(
                          '*Healthy score is between 0 - 10\nخالا ساخلەمیێ دنیڤێ دایە 0-10',
                          style: TextStyle(
                              fontSize: 14.h,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 4, 141, 151)))
                    ],
                  ),
                ),
                // below Weight
                SizedBox(
                  height: 15.h,
                ),
                Divider(
                  height: 20.h,
                  thickness: 2,
                  // indent: 20,
                  // endIndent: 0,
                  // color:,
                ),
                SizedBox(
                  height: 20.h,
                ),
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Weight/کێش',
                        style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black),
                      ),
                      SizedBox(
                        height: 5.h,
                      ),
                      FutureBuilder(
                          future: _fetchBodyResult(widget.attendeeList['name']),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (snapshot.hasError) {
                              return Center(
                                  child: Text('Error: ${snapshot.error}'));
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return Center(
                                  child: Column(
                                children: [
                                  SizedBox(height: 40.h),
                                  Text('No survey can be shown.'),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  QuestionnairePage(
                                                      attendeeList: widget
                                                          .attendeeList)));
                                    },
                                    child: Text('Take a 5 min Survey',
                                        style: TextStyle(
                                            color: kColorPrimary,
                                            fontSize: 15.sp)),
                                  ),
                                  SizedBox(height: 40.h),
                                ],
                              ));
                            } else {
                              final myBodyList = snapshot.data;
                              List<int> spotShowingList = [];
                              Map<dynamic, dynamic> dataSet = {};
                              for (int i = 0; i < myBodyList!.length; i++) {
                                spotShowingList.add(i);
                                dataSet[i] = myBodyList[i]['weight'];
                              }
                              // dataSetの型変換
                              List<FlSpot> spotsData =
                                  dataSet.entries.map((entry) {
                                return FlSpot(
                                    // 取得したデータは{String, int}となっていた。int
                                    entry.key.toDouble(),
                                    double.parse(entry.value));
                              }).toList();

                              // どのspotを表示させるか
                              final lineBarsData = [
                                LineChartBarData(
                                  // spotのどこを表示させるか？
                                  showingIndicators: spotShowingList,
                                  spots: spotsData,
                                  isCurved: true,
                                  barWidth: 3,
                                  dotData: const FlDotData(show: true),
                                  color: kColorPrimary,
                                ),
                              ];
                              final tooltipsOnBar = lineBarsData[0];

                              // maxXをデータの長さに基づいて動的に設定
                              double convertedMaxXForBMI = 6;
                              double convertMaxX() {
                                int maxX = myBodyList.length;
                                if (maxX < 7) {
                                  maxX = 6;
                                  return maxX.toDouble();
                                } else {
                                  return maxX.toDouble();
                                }
                              }

                              convertedMaxXForBMI = convertMaxX();

                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Container(
                                  width: MediaQuery.of(context).size.width *
                                      (convertedMaxXForBMI / 6),
                                  height:
                                      MediaQuery.of(context).size.width * 0.8,
                                  color: Colors.white,
                                  child: LayoutBuilder(
                                      builder: (context, constraints) {
                                    return LineChart(
                                      LineChartData(
                                        showingTooltipIndicators:
                                            spotShowingList.map((index) {
                                          return ShowingTooltipIndicators([
                                            LineBarSpot(
                                              // どんなバーを表示するか？
                                              tooltipsOnBar,
                                              // 選んだバーの何個目を表示するか？
                                              lineBarsData
                                                  .indexOf(tooltipsOnBar),
                                              // スポットはどんなやつ？
                                              tooltipsOnBar.spots[index],
                                            ),
                                          ]);
                                        }).toList(),
                                        lineTouchData: LineTouchData(
                                          enabled: false,
                                          handleBuiltInTouches: false,
                                          touchCallback: (FlTouchEvent event,
                                              LineTouchResponse? response) {
                                            if (response == null ||
                                                response.lineBarSpots == null) {
                                              return;
                                            }
                                            if (event is FlTapUpEvent) {
                                              final spotIndex = response
                                                  .lineBarSpots!
                                                  .first
                                                  .spotIndex;
                                            }
                                          },
                                          mouseCursorResolver:
                                              (FlTouchEvent event,
                                                  LineTouchResponse? response) {
                                            if (response == null ||
                                                response.lineBarSpots == null) {
                                              return SystemMouseCursors.basic;
                                            }
                                            return SystemMouseCursors.click;
                                          },
                                          getTouchedSpotIndicator:
                                              (LineChartBarData barData,
                                                  List<int> spotIndexes) {
                                            return spotIndexes.map((index) {
                                              return TouchedSpotIndicatorData(
                                                // spotまでの下からの線
                                                FlLine(
                                                  color: Colors.transparent,
                                                ),
                                                FlDotData(
                                                  show: true,
                                                  getDotPainter: (spot, percent,
                                                          barData, index) =>
                                                      FlDotCirclePainter(
                                                    // ドットの大きさ
                                                    radius: 6.h,
                                                    color: kColorPrimary,
                                                    strokeWidth: 0.5,
                                                  ),
                                                ),
                                              );
                                            }).toList();
                                          },
                                          touchTooltipData:
                                              LineTouchTooltipData(
                                            // ドットにデータの中の数字をどう表示するか？
                                            getTooltipColor: (touchedSpot) =>
                                                kColorPrimary,
                                            tooltipRoundedRadius: 30,
                                            getTooltipItems: (List<LineBarSpot>
                                                lineBarsSpot) {
                                              return lineBarsSpot
                                                  .map((lineBarSpot) {
                                                return LineTooltipItem(
                                                  lineBarSpot.y.toString(),
                                                  TextStyle(
                                                    fontSize: 14.sp,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                );
                                              }).toList();
                                            },
                                          ),
                                        ),
                                        // セングラフのデータ自体何を表示するか？
                                        lineBarsData: lineBarsData,
                                        // Y軸の最低ポイントは？
                                        minY: 0,
                                        maxY: 150, // Y軸の最大値を30に設定
                                        minX: 0,
                                        maxX:
                                            convertedMaxXForBMI, // X軸の最大値を6に設定
                                        // グラフのY軸のタイトル
                                        titlesData: FlTitlesData(
                                          leftTitles: AxisTitles(
                                            axisNameWidget: Text(
                                              'Weight',
                                              style: TextStyle(
                                                fontSize: 18.sp,
                                                fontWeight: FontWeight.w600,
                                                color: kColorPrimary,
                                                decoration: TextDecoration.none,
                                              ),
                                            ),
                                            axisNameSize: 22.sp,
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              reservedSize: 20.sp, // 余白を調整
                                              getTitlesWidget: (value, meta) {
                                                return Text('');
                                              },
                                            ),
                                          ),
                                          bottomTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              interval: 1,
                                              getTitlesWidget: (value, meta) {
                                                if (value >=
                                                    myBodyList.length) {
                                                  return const SizedBox
                                                      .shrink(); // 範囲外のラベルを隠す
                                                }
                                                return bottomTitleWidgets(
                                                    value,
                                                    meta,
                                                    constraints.maxWidth,
                                                    myBodyList[value.toInt()]
                                                        ['created_at']);
                                              },
                                              reservedSize: 30.sp,
                                            ),
                                          ),
                                          topTitles: const AxisTitles(
                                            axisNameWidget: Text(
                                              '',
                                              textAlign: TextAlign.left,
                                            ),
                                            axisNameSize: 24,
                                            sideTitles: SideTitles(
                                              showTitles: false,
                                              reservedSize: 0,
                                            ),
                                          ),
                                        ),
                                        // Gridボーダーの表示非表示
                                        gridData: const FlGridData(show: false),
                                        borderData: FlBorderData(
                                          // Gridボーダーの表示非表示
                                          show: true,
                                          border: const Border(
                                            left: BorderSide(
                                                color: Colors.grey,
                                                width: 0.5), // y=0の線
                                            bottom: BorderSide(
                                                color: Colors.grey,
                                                width: 0.5), // x=0の線
                                            right:
                                                BorderSide.none, // 右側のボーダーを非表示
                                            top: BorderSide.none,
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              );
                            }
                          }),
                      SizedBox(height: 20.h)
                    ],
                  ),
                ),
                // below BMI
                Divider(
                  height: 20.h,
                  thickness: 2,
                  // indent: 20,
                  // endIndent: 0,
                  // color:,
                ),
                SizedBox(height: 10.h),
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BMI/خالا نموونەیی یا کێشا لەشێ تە',
                        style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black),
                      ),
                      SizedBox(
                        height: 5.h,
                      ),
                      FutureBuilder(
                          future: _fetchBodyResult(widget.attendeeList['name']),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (snapshot.hasError) {
                              return Center(
                                  child: Text('Error: ${snapshot.error}'));
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return Center(
                                  child: Column(
                                children: [
                                  SizedBox(height: 40.h),
                                  Text('No survey can be shown.'),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  QuestionnairePage(
                                                      attendeeList: widget
                                                          .attendeeList)));
                                    },
                                    child: Text('Take a 5 min Survey',
                                        style: TextStyle(
                                            color: kColorPrimary,
                                            fontSize: 15.sp)),
                                  ),
                                  SizedBox(height: 40.h),
                                ],
                              ));
                            } else {
                              final myBMIList = snapshot.data;
                              List<int> spotShowingList = [];
                              Map<dynamic, dynamic> dataSet = {};
                              for (int i = 0; i < myBMIList!.length; i++) {
                                spotShowingList.add(i);
                                dataSet[i] = myBMIList[i]['BMI'];
                              }
                              // dataSetの型変換
                              List<FlSpot> spotsData =
                                  dataSet.entries.map((entry) {
                                return FlSpot(
                                    // 取得したデータは{String, int}となっていた。int
                                    entry.key.toDouble(),
                                    double.parse(entry.value));
                              }).toList();

                              // どのspotを表示させるか
                              final lineBarsData = [
                                LineChartBarData(
                                  // spotのどこを表示させるか？
                                  showingIndicators: spotShowingList,
                                  spots: spotsData,
                                  isCurved: true,
                                  barWidth: 3,
                                  dotData: const FlDotData(show: true),
                                  color: kColorPrimary,
                                ),
                              ];
                              final tooltipsOnBar = lineBarsData[0];

                              // maxXをデータの長さに基づいて動的に設定
                              double convertedMaxXForBMI = 6;
                              double convertMaxX() {
                                int maxX = myBMIList.length;
                                if (maxX < 7) {
                                  maxX = 6;
                                  return maxX.toDouble();
                                } else {
                                  return maxX.toDouble();
                                }
                              }

                              convertedMaxXForBMI = convertMaxX();

                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Container(
                                  width: MediaQuery.of(context).size.width *
                                      (convertedMaxXForBMI / 6),
                                  height:
                                      MediaQuery.of(context).size.width * 0.8,
                                  color: Colors.white,
                                  child: LayoutBuilder(
                                      builder: (context, constraints) {
                                    return LineChart(
                                      LineChartData(
                                        showingTooltipIndicators:
                                            spotShowingList.map((index) {
                                          return ShowingTooltipIndicators([
                                            LineBarSpot(
                                              // どんなバーを表示するか？
                                              tooltipsOnBar,
                                              // 選んだバーの何個目を表示するか？
                                              lineBarsData
                                                  .indexOf(tooltipsOnBar),
                                              // スポットはどんなやつ？
                                              tooltipsOnBar.spots[index],
                                            ),
                                          ]);
                                        }).toList(),
                                        lineTouchData: LineTouchData(
                                          enabled: false,
                                          handleBuiltInTouches: false,
                                          touchCallback: (FlTouchEvent event,
                                              LineTouchResponse? response) {
                                            if (response == null ||
                                                response.lineBarSpots == null) {
                                              return;
                                            }
                                            if (event is FlTapUpEvent) {
                                              final spotIndex = response
                                                  .lineBarSpots!
                                                  .first
                                                  .spotIndex;
                                              // setState(() {
                                              //   // ボタンを押したらspotIndexのデータを表示する
                                              //   if (showingTooltipOnSpots.contains(spotIndex)) {
                                              //     // すでにshowingしているものをタッチしたら、spotが消えます
                                              //     showingTooltipOnSpots.remove(spotIndex);
                                              //   } else {
                                              //     // showingされているものではなかったら、showするリスト押下したspotを入れます。（表示させます）
                                              //     showingTooltipOnSpots.add(spotIndex);
                                              //   }
                                              // });
                                            }
                                          },
                                          mouseCursorResolver:
                                              (FlTouchEvent event,
                                                  LineTouchResponse? response) {
                                            if (response == null ||
                                                response.lineBarSpots == null) {
                                              return SystemMouseCursors.basic;
                                            }
                                            return SystemMouseCursors.click;
                                          },
                                          getTouchedSpotIndicator:
                                              (LineChartBarData barData,
                                                  List<int> spotIndexes) {
                                            return spotIndexes.map((index) {
                                              return TouchedSpotIndicatorData(
                                                // spotまでの下からの線
                                                FlLine(
                                                  color: Colors.transparent,
                                                ),
                                                FlDotData(
                                                  show: true,
                                                  getDotPainter: (spot, percent,
                                                          barData, index) =>
                                                      FlDotCirclePainter(
                                                    // ドットの大きさ
                                                    radius: 6.h,
                                                    color: kColorPrimary,
                                                    strokeWidth: 0.5,
                                                  ),
                                                ),
                                              );
                                            }).toList();
                                          },
                                          touchTooltipData:
                                              LineTouchTooltipData(
                                            // ドットにデータの中の数字をどう表示するか？
                                            getTooltipColor: (touchedSpot) =>
                                                kColorPrimary,
                                            tooltipRoundedRadius: 30,
                                            getTooltipItems: (List<LineBarSpot>
                                                lineBarsSpot) {
                                              return lineBarsSpot
                                                  .map((lineBarSpot) {
                                                return LineTooltipItem(
                                                  lineBarSpot.y.toString(),
                                                  TextStyle(
                                                    fontSize: 14.sp,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                );
                                              }).toList();
                                            },
                                          ),
                                        ),
                                        // セングラフのデータ自体何を表示するか？
                                        lineBarsData: lineBarsData,
                                        // Y軸の最低ポイントは？
                                        minY: 0,
                                        maxY: 30, // Y軸の最大値を30に設定
                                        minX: 0,
                                        maxX:
                                            convertedMaxXForBMI, // X軸の最大値を6に設定
                                        // グラフのY軸のタイトル
                                        titlesData: FlTitlesData(
                                          leftTitles: AxisTitles(
                                            axisNameWidget: Text(
                                              'BMI',
                                              style: TextStyle(
                                                fontSize: 18.sp,
                                                fontWeight: FontWeight.w600,
                                                color: kColorPrimary,
                                                decoration: TextDecoration.none,
                                              ),
                                            ),
                                            axisNameSize: 22.sp,
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              reservedSize: 20.sp, // 余白を調整
                                              getTitlesWidget: (value, meta) {
                                                return Text('');
                                              },
                                            ),
                                          ),
                                          bottomTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              interval: 1,
                                              getTitlesWidget: (value, meta) {
                                                if (value >= myBMIList.length) {
                                                  return const SizedBox
                                                      .shrink(); // 範囲外のラベルを隠す
                                                }
                                                return bottomTitleWidgets(
                                                    value,
                                                    meta,
                                                    constraints.maxWidth,
                                                    myBMIList[value.toInt()]
                                                        ['created_at']);
                                              },
                                              reservedSize: 30.sp,
                                            ),
                                          ),
                                          // rightTitles: AxisTitles(
                                          //   axisNameWidget: Text('BMI',
                                          //       style: TextStyle(
                                          //         fontSize: 20,
                                          //         color: kColorPrimary,
                                          //         decoration: TextDecoration.none,
                                          //       )),
                                          //   axisNameSize: 20,
                                          //   sideTitles: SideTitles(
                                          //     showTitles: true,
                                          //     reservedSize: 0,
                                          //   ),
                                          // ),
                                          topTitles: const AxisTitles(
                                            axisNameWidget: Text(
                                              '',
                                              textAlign: TextAlign.left,
                                            ),
                                            axisNameSize: 24,
                                            sideTitles: SideTitles(
                                              showTitles: false,
                                              reservedSize: 0,
                                            ),
                                          ),
                                        ),
                                        // Gridボーダーの表示非表示
                                        gridData: const FlGridData(show: false),
                                        borderData: FlBorderData(
                                          // Gridボーダーの表示非表示
                                          show: true,
                                          border: const Border(
                                            left: BorderSide(
                                                color: Colors.grey,
                                                width: 0.5), // y=0の線
                                            bottom: BorderSide(
                                                color: Colors.grey,
                                                width: 0.5), // x=0の線
                                            right:
                                                BorderSide.none, // 右側のボーダーを非表示
                                            top: BorderSide.none,
                                          ),
                                        ),
                                        // betweenBarsData: [
                                        //   BetweenBarsData(
                                        //     fromIndex: 0,
                                        //     toIndex: 1,
                                        //     color: kColorPrimary
                                        //         .withOpacity(0.3), // 塗る色を指定
                                        //   ),
                                        // ],
                                        extraLinesData: ExtraLinesData(
                                          horizontalLines: [
                                            HorizontalLine(
                                              y: 18,
                                              color: kColorPrimary,
                                              strokeWidth: 2,
                                              dashArray: [5, 5],
                                            ),
                                            HorizontalLine(
                                              label: HorizontalLineLabel(),
                                              y: 24,
                                              color: kColorPrimary,
                                              strokeWidth: 2,
                                              dashArray: [5, 5],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              );
                            }
                          }),
                      Text('BMI: Body Mass Index',
                          style: TextStyle(fontSize: 14.h)),
                      Text('*It shows ideal body weight',
                          style: TextStyle(fontSize: 14.h)),
                      Text(
                          '*Healthy score is between 18 - 24\nخالا ساخلەمیێ دنیڤێ دایە 18-24',
                          style: TextStyle(
                              fontSize: 14.h,
                              fontWeight: FontWeight.bold,
                              color: kColorPrimary)),
                      SizedBox(height: 50.h)
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
