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

Widget buildCheckAllMembership({
  required List<dynamic> fetchedDataList,
}) {
  final ScrollController scrollControllerOne = ScrollController();
  final ScrollController scrollControllerTwo = ScrollController();
  final ScrollController scrollControllerThree = ScrollController();
  final ScrollController scrollControllerFour = ScrollController();

  List withInOneWeek = [];
  List withInTwoWeeks = [];
  List withInFourWeeks = [];
  List withInMoreThanOneMonth = [];
  DateTime today = DateTime.now();
  fetchedDataList.forEach((e) {
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
  fetchedDataList.forEach((e) {
    DateTime lastCheckIn = DateTime.parse(e['last_check_in']);
    final differenceByToday = today.difference(lastCheckIn);
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
  return SingleChildScrollView(
    child: Container(
      child: Column(
        children: [
          Container(
              height: 550.h,
              child:
                  // print(membershipList);
                  SingleChildScrollView(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                    buildExpireCategorySection(
                        'In 1 Week', withInOneWeek, scrollControllerOne),
                    buildExpireCategorySection(
                        'In 2 weeks', withInTwoWeeks, scrollControllerTwo),
                    buildExpireCategorySection(
                        'In 4 weeks', withInFourWeeks, scrollControllerThree),
                    buildExpireCategorySection('In more than 1 month',
                        withInMoreThanOneMonth, scrollControllerFour)
                  ])))
        ],
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
  double itemHeight = 120.h;
  double listHeight = membershipList.length * itemHeight;
  double maxListHeight = 360.h;
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
