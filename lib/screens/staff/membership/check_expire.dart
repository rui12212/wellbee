// import 'package:booking_calendar/booking_calendar.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wellbee/assets/inet.dart';
// import 'package:wellbee/screens/reservation/reservation_create.dart';

import 'package:wellbee/ui_function/provider.dart';
import 'package:wellbee/ui_parts/color.dart';
import 'package:wellbee/ui_function/shared_prefs.dart';
import 'package:http/http.dart' as http;
import 'package:wellbee/ui_parts/ticket.dart';

class _Header extends StatelessWidget {
  String title;
  bool isLongName;

  _Header({required this.title, required this.isLongName});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.h,
      child: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Row(
              children: [
                Text(
                  title,
                  style: isLongName
                      ? TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold)
                      : TextStyle(fontSize: 30.sp, fontWeight: FontWeight.bold),
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
                    Navigator.of(context).pop();
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

class CheckMembershipPage extends ConsumerStatefulWidget {
  String courseName;
  CheckMembershipPage({
    Key? key,
    required this.courseName,
  });

  @override
  _CheckMembershipPageState createState() => _CheckMembershipPageState();
}

class _CheckMembershipPageState extends ConsumerState<CheckMembershipPage> {
  String? token = '';
  final ScrollController scrollControllerOne = ScrollController();
  final ScrollController scrollControllerTwo = ScrollController();
  final ScrollController scrollControllerThree = ScrollController();
  final ScrollController scrollControllerFour = ScrollController();

  @override
  showSnackBar(color, text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: color, content: Text(text)),
    );
  }

  @override
  void initState() {
    super.initState();
    // _fetchMyAllMembership();
  }

  Future<List<dynamic>?> _fetchAllMembership() async {
    try {
      token = await SharedPrefs.fetchStaffAccessToken();
      var url = Uri.parse(
          '${baseUri}attendances/membership/course_membership?course_name=${widget.courseName}&token=$token');
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
  Widget build(BuildContext context) {
    final isExpireDaySelected = ref.watch(isExpireDaySelectedProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 20.w,
          ),
          child: Column(
            children: [
              _Header(
                isLongName: widget.courseName.length > 12 ? true : false,
                title: '${widget.courseName}',
              ),
              Container(
                  height: 45.h,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        FilledButton(
                          onPressed: isExpireDaySelected
                              ? () {}
                              : () {
                                  ref
                                      .read(
                                          isExpireDaySelectedProvider.notifier)
                                      .state = true;
                                },
                          style: ButtonStyle(
                              backgroundColor: isExpireDaySelected
                                  ? MaterialStateProperty.all(kColorPrimary)
                                  : MaterialStateProperty.all(
                                      Color.fromARGB(255, 218, 240, 230))),
                          child: Text('Expire Day',
                              style: TextStyle(
                                color: isExpireDaySelected
                                    ? Colors.white
                                    : kColorPrimary,
                                fontSize: 15.h,
                                fontWeight: isExpireDaySelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              )),
                        ),
                        Text('/',
                            style: TextStyle(
                                fontSize: 20.h, fontWeight: FontWeight.bold)),
                        FilledButton(
                          onPressed: isExpireDaySelected
                              ? () {
                                  ref
                                      .read(
                                          isExpireDaySelectedProvider.notifier)
                                      .state = false;
                                  // Navigator.of(context).push(
                                  //     MaterialPageRoute(builder: (context) {
                                  //   return CheckLastCheckInPage(
                                  //       courseName: widget.courseName);
                                  // }));
                                }
                              : () {},
                          style: ButtonStyle(
                              backgroundColor: isExpireDaySelected
                                  ? MaterialStateProperty.all(
                                      Color.fromARGB(255, 218, 240, 230))
                                  : MaterialStateProperty.all(kColorPrimary)),
                          child: Text('Last Check',
                              style: TextStyle(
                                  fontSize: 15.h,
                                  fontWeight: isExpireDaySelected
                                      ? FontWeight.normal
                                      : FontWeight.bold,
                                  color: isExpireDaySelected
                                      ? kColorPrimary
                                      : Colors.white)),
                        ),
                      ],
                    ),
                  )),
              SingleChildScrollView(
                child: Container(
                  height: 555.h,
                  child: FutureBuilder(
                    future: _fetchAllMembership(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(
                                child: Text('No Membership',
                                    style: TextStyle(
                                      fontSize: 20.sp,
                                    ))),
                          ],
                        );
                      } else {
                        final membershipList = snapshot.data!;
                        List withInOneWeek = [];
                        List withInTwoWeeks = [];
                        List withInFourWeeks = [];
                        List withInMoreThanOneMonth = [];
                        DateTime today = DateTime.now();
                        membershipList.forEach((e) {
                          DateTime expireDay = DateTime.parse(e['expire_day']);
                          final differenceByToday = expireDay.difference(today);
                          if (differenceByToday.inDays <= 7) {
                            withInOneWeek.add(e);
                          } else if (differenceByToday.inDays <= 14) {
                            withInTwoWeeks.add(e);
                          } else if (differenceByToday.inDays <= 28) {
                            withInFourWeeks.add(e);
                          } else if (differenceByToday.inDays >= 29) {
                            withInMoreThanOneMonth.add(e);
                          }
                        });

                        List lastCheckWithInOneWeek = [];
                        List lastCheckWithInTwoWeeks = [];
                        List lastCheckWithInFourWeeks = [];
                        List lastCheckWithInMoreThanOneMonth = [];
                        membershipList.forEach((e) {
                          DateTime lastCheckIn =
                              DateTime.parse(e['last_check_in']);
                          final differenceByToday =
                              today.difference(lastCheckIn);
                          if (differenceByToday.inDays <= 7) {
                            lastCheckWithInOneWeek.add(e);
                          } else if (differenceByToday.inDays <= 14) {
                            lastCheckWithInTwoWeeks.add(e);
                          } else if (differenceByToday.inDays <= 28) {
                            lastCheckWithInFourWeeks.add(e);
                          } else if (differenceByToday.inDays >= 29) {
                            lastCheckWithInMoreThanOneMonth.add(e);
                          }
                        });
                        // print(membershipList);
                        return SingleChildScrollView(
                            child: isExpireDaySelected
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                        buildExpireCategorySection('In 1 Week',
                                            withInOneWeek, scrollControllerOne),
                                        buildExpireCategorySection(
                                            'In 2 weeks',
                                            withInTwoWeeks,
                                            scrollControllerTwo),
                                        buildExpireCategorySection(
                                            'In 4 weeks',
                                            withInFourWeeks,
                                            scrollControllerThree),
                                        buildExpireCategorySection(
                                            'In more than 1 month',
                                            withInMoreThanOneMonth,
                                            scrollControllerFour)
                                      ])
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                        buildLastCheckInCategorySection(
                                            'In more than 1 month',
                                            lastCheckWithInMoreThanOneMonth,
                                            scrollControllerOne),
                                        buildLastCheckInCategorySection(
                                            'In 4 weeks',
                                            lastCheckWithInFourWeeks,
                                            scrollControllerTwo),
                                        buildLastCheckInCategorySection(
                                            'In 2 weeks',
                                            lastCheckWithInTwoWeeks,
                                            scrollControllerThree),
                                        buildLastCheckInCategorySection(
                                            'In 1 Week',
                                            lastCheckWithInOneWeek,
                                            scrollControllerFour)
                                      ]));
                        // ListView.builder(
                        //     itemCount: membershipList.length,
                        //     itemBuilder: (context, index) {
                        //       // request_join_timesとmax_join_timesの比較
                        //       final requested_join_times =
                        //           membershipList[index]
                        //               ['requested_join_times'];
                        //       final max_join_times =
                        //           membershipList[index]['max_join_times'];
                        //       final isAlreadyMaxRequest =
                        //           requested_join_times == max_join_times;

                        //       // already_join_timesとmax_join_timesの比較
                        //       final already_join_times =
                        //           membershipList[index]['already_join_times'];
                        //       final isAlreadyMaxJoin =
                        //           already_join_times == max_join_times;

                        //       bool is_expired = false;
                        //       DateTime formattedDate = DateTime.parse(
                        //           membershipList[index]['expire_day']);

                        //       DateTime today = DateTime.now();

                        //       if (formattedDate.isBefore(today)) {
                        //         is_expired = true;
                        //       }
                        //       return Column(
                        //         children: [
                        //           // TicketList(
                        //           //     membershipList: membershipList[index]),
                        //           SizedBox(height: 10.h),
                        //         ],
                        //       );
                        //     }),
                      }
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildExpireCategorySection(
      String title, List membershipList, ScrollController scrollController) {
    if (membershipList.isEmpty) {
      return Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Divider(
              thickness: 0.5,
              color: Color.fromARGB(255, 80, 79, 79),
            ),
          ),
        ],
      );
    }
    // itemの一つの高さ。ここはこれから作るItemの大きさによる
    double itemHeight = 150.h;
    double listHeight = membershipList.length * itemHeight;
    double maxListHeight = 450.h;
    listHeight = listHeight > maxListHeight ? maxListHeight : listHeight;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        height: 40.h,
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: Divider(
                thickness: 0.5,
                color: Color.fromARGB(255, 80, 79, 79),
              ),
            ),
          ],
        ),
      ),
      SizedBox(height: 8.h),
      // メンバーシップリスト
      SizedBox(
          height: listHeight,
          child: Scrollbar(
            controller: scrollController,
            thumbVisibility: true,
            child: ListView.builder(
                // physics: NeverScrollableScrollPhysics(),
                controller: scrollController,
                itemCount: membershipList.length,
                itemBuilder: (context, index) {
                  return Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: MembershipTicketList(
                          membershipList: membershipList[index]));
                }),
          ))
    ]);
  }

  Widget buildLastCheckInCategorySection(
      String title, List membershipList, ScrollController scrollController) {
    if (membershipList.isEmpty) {
      return Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Divider(
              thickness: 0.5,
              color: Color.fromARGB(255, 80, 79, 79),
            ),
          ),
        ],
      );
    }
    // itemの一つの高さ。ここはこれから作るItemの大きさによる
    double itemHeight = 150.h;
    double listHeight = membershipList.length * itemHeight;
    double maxListHeight = 450.h;
    listHeight = listHeight > maxListHeight ? maxListHeight : listHeight;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        height: 40.h,
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: Divider(
                thickness: 0.5,
                color: Color.fromARGB(255, 80, 79, 79),
              ),
            ),
          ],
        ),
      ),
      SizedBox(height: 8.h),
      // メンバーシップリスト
      SizedBox(
          height: listHeight,
          child: Scrollbar(
            controller: scrollController,
            thumbVisibility: true,
            child: ListView.builder(
                // physics: NeverScrollableScrollPhysics(),
                controller: scrollController,
                itemCount: membershipList.length,
                itemBuilder: (context, index) {
                  return Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: MembershipTicketList(
                          membershipList: membershipList[index]));
                }),
          ))
    ]);
  }
}
