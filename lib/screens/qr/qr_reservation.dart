import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:wellbee/assets/inet.dart';
import 'package:wellbee/screens/home.dart';
import 'package:wellbee/screens/qr/qr_code.dart';
import 'package:wellbee/screens/top_page.dart';
import 'package:wellbee/ui_function/shared_prefs.dart';
import 'package:http/http.dart' as http;
import 'package:wellbee/ui_parts/dialogue_awesome.dart';
import 'package:wellbee/ui_parts/display.dart';

import '../../ui_parts/color.dart';

class _Header extends StatelessWidget {
  String title;
  // String subtitle;

  _Header({
    required this.title,
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
          // Align(
          //   alignment: Alignment.topLeft,
          //   child: Text(
          //     subtitle,
          //     style: TextStyle(
          //         fontSize: 22,
          //         fontWeight: FontWeight.w300,
          //         color: kColorTextDarkGrey),
          //   ),
          // )
        ],
      ),
    );
  }
}

class QrReservationPage extends StatefulWidget {
  const QrReservationPage({Key? key}) : super(key: key);

  @override
  _QrReservationPageState createState() => _QrReservationPageState();
}

class _QrReservationPageState extends State<QrReservationPage> {
  String? token = '';

  // Future<void> _fetchToken() async {
  //   token = await SharedPrefs.fetchAccessToken();
  // }

  Future<List<dynamic>?> _fetchReservation() async {
    try {
      token = await SharedPrefs.fetchAccessToken();
      var url = Uri.parse(
          '${baseUri}reservations/reservation/my_all_reservation/?token=$token');
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
        if (data.isNotEmpty && data != null) {
          return data;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Error.You may not have reservation')));
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
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<List<dynamic>?> _cancelReservation(int reservationId) async {
    try {
      token = await SharedPrefs.fetchAccessToken();
      var url = Uri.parse(
          '${baseUri}reservations/reservation/$reservationId/?token=$token');
      var response = await Future.any([
        http.delete(url, headers: {
          "Authorization": 'JWT $token',
          "Content-Type": "application/json"
        }),
        Future.delayed(const Duration(seconds: 15),
            () => throw TimeoutException("Request timeout"))
      ]);
      if (response.statusCode == 204) {
        // List<dynamic> data = jsonDecode(response.body);
        showSnackBar(kColorPrimary, 'Reservation cancelled successfully');
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => TopPage(0)));
      } else if (response.statusCode >= 400) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Internet Error occurred')));
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
  void initState() {
    super.initState();
    // _fetchReservation();
  }

  @override
  showSnackBar(color, text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: color, content: Text(text)),
    );
  }

  void showAwesomeDialog(
    int id,
  ) {
    CustomAwesomeDialogueForCancelReservation(
      titleText: 'Cancel Reservation\nهەلوەشاندنا حجزکرنێ',
      desc: 'Are you sure to cancel?',
      callback: () async {
        await _cancelReservation(id);
      },
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              _Header(title: 'My Reservation'),
              FutureBuilder(
                future: _fetchReservation(),
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 50.h),
                            Container(
                              height: 300.h,
                              width: 300.h,
                              decoration: BoxDecoration(
                                // borderRadius:
                                //     BorderRadius.all(Radius.circular(70)),
                                image: DecorationImage(
                                    fit: BoxFit.fill,
                                    image: AssetImage(
                                        'lib/assets/home_pic/no_reservation.png')),
                              ),
                            ),
                            // SizedBox(height: 30),
                            Align(
                              alignment: Alignment.center,
                              child: Text('No Reservation is set...',
                                  style: TextStyle(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w300)),
                            ),
                            Text('Reserve from "Membership"',
                                style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.w300)),
                          ],
                        ),
                      ],
                    );
                  } else {
                    final fetchedReservationList = snapshot.data!;
                    // print(fetchedReservationList);
                    return Expanded(
                      child: ListView.builder(
                          itemCount: fetchedReservationList.length,
                          itemBuilder: (context, index) {
                            final bool isAttended =
                                fetchedReservationList[index]['attended'];
                            String slotDateStr =
                                fetchedReservationList[index]['slot_date'];
                            String slotEndTimeStr =
                                fetchedReservationList[index]['slot_end_time'];
                            DateTime reservationDateTime = DateTime.parse(
                                '$slotDateStr ${slotEndTimeStr}');
                            // print(reservationDateTime);
                            bool is_before =
                                reservationDateTime.isBefore(DateTime.now());
                            final bool is_cancelled =
                                fetchedReservationList[index]
                                    ['slot_is_cancelled'];
                            return Column(
                              children: [
                                isAttended == true && is_before ||
                                        isAttended == true
                                    ? Opacity(
                                        opacity: 0.4,
                                        child: PastReservationTicketList(
                                            reservationList:
                                                fetchedReservationList[index]),
                                      )
                                    : isAttended == false && is_before
                                        ? Stack(
                                            children: [
                                              Container(
                                                height: 120.h,
                                                alignment: Alignment.center,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                        'Delete Past Reservation\nژێبرنا حجزکرنا بەری نوکە',
                                                        style: TextStyle(
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    255,
                                                                    0,
                                                                    0),
                                                            fontSize: 22.sp,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w700)),
                                                  ],
                                                ),
                                              ),
                                              Opacity(
                                                opacity: 0.2,
                                                child: Slidable(
                                                    endActionPane: ActionPane(
                                                      motion: ScrollMotion(),
                                                      children: [
                                                        SlidableAction(
                                                          flex: 1,
                                                          onPressed:
                                                              (context) async {
                                                            showAwesomeDialog(
                                                                fetchedReservationList[
                                                                        index]
                                                                    ['id']);
                                                          },
                                                          backgroundColor:
                                                              Colors.amber,
                                                          foregroundColor:
                                                              Colors.white,
                                                          icon: Icons
                                                              .delete_forever_outlined,
                                                          label: 'Delete',
                                                        )
                                                      ],
                                                    ),
                                                    child: ReservationTicketList(
                                                        reservationList:
                                                            fetchedReservationList[
                                                                index])),
                                              ),
                                            ],
                                          )
                                        : is_cancelled == true
                                            ?
                                            // Slotがキャンセルの場合は、Opacity
                                            Stack(
                                                children: [
                                                  Container(
                                                    height: 120.h,
                                                    alignment: Alignment.center,
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                            'Reservation Cancelled',
                                                            style: TextStyle(
                                                                color: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        255,
                                                                        0,
                                                                        0),
                                                                fontSize: 22.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700)),
                                                        Text(
                                                            'Delete the Reservation',
                                                            style: TextStyle(
                                                                color: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        255,
                                                                        0,
                                                                        0),
                                                                fontSize: 22.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700)),
                                                      ],
                                                    ),
                                                  ),
                                                  Opacity(
                                                    opacity: 0.2,
                                                    child: Slidable(
                                                        endActionPane:
                                                            ActionPane(
                                                          motion:
                                                              ScrollMotion(),
                                                          children: [
                                                            SlidableAction(
                                                              flex: 1,
                                                              onPressed:
                                                                  (context) async {
                                                                showAwesomeDialog(
                                                                    fetchedReservationList[
                                                                            index]
                                                                        ['id']);
                                                              },
                                                              backgroundColor:
                                                                  Colors.amber,
                                                              foregroundColor:
                                                                  Colors.white,
                                                              icon: Icons
                                                                  .delete_forever_outlined,
                                                              label: 'Delete',
                                                            )
                                                          ],
                                                        ),
                                                        child: ReservationTicketList(
                                                            reservationList:
                                                                fetchedReservationList[
                                                                    index])),
                                                  ),
                                                ],
                                              )
                                            : Slidable(
                                                endActionPane: ActionPane(
                                                  motion: ScrollMotion(),
                                                  children: [
                                                    SlidableAction(
                                                      flex: 1,
                                                      onPressed:
                                                          (context) async {
                                                        showAwesomeDialog(
                                                            fetchedReservationList[
                                                                index]['id']);
                                                      },
                                                      backgroundColor:
                                                          Colors.amber,
                                                      foregroundColor:
                                                          Colors.white,
                                                      icon: Icons
                                                          .delete_forever_outlined,
                                                      label: 'Delete',
                                                    )
                                                  ],
                                                ),
                                                child: InkWell(
                                                    child: ReservationTicketList(
                                                        reservationList:
                                                            fetchedReservationList[
                                                                index]),
                                                    onTap: () {
                                                      Navigator.of(context).push(
                                                          MaterialPageRoute(
                                                              builder: (context) => QrCodePage(
                                                                  selectedReservation:
                                                                      fetchedReservationList[
                                                                          index])));
                                                    })),
                                SizedBox(height: 10.h),
                              ],
                            );
                          }),
                    );
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
