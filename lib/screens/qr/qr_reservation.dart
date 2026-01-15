import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
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
              color: kColorTextDarkGrey,
              height: 1.4,
            ),
          ),
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
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('You may not have reservation')));
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

  Future<List<dynamic>?> _deletePastReservation(int reservationId) async {
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
        showSnackBar(kColorPrimary, 'Past reservation automatically deleted');
        setState(() {});
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
              const _Header(
                title: 'My Reservation',
                subtitle: 'Tap to show QR code / Swipe left to cancel',
              ),
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
                    final today = DateTime.now();
                    final String formattedDate =
                        DateFormat('yyyy-MM-dd').format(today);
                    final dateOfToday = DateTime.parse(formattedDate);
                    // final deleteList = [];
                    fetchedReservationList.forEach(
                      (e) async {
                        final DateTime reservationDate =
                            DateTime.parse(e['date']);
                        final bool isAttended = e['attended'];
                        final bool is_cancelled = e['slot_is_cancelled'];
                        // print(dateOfToday);
                        // print(e['date']);
                        // 過去の予約で、参加していないものは消す
                        if ((reservationDate.isBefore(dateOfToday) &&
                                isAttended == false) ||
                            // 過去の予約で、Slotがキャンセルされたものを削除する
                            (reservationDate.isBefore(dateOfToday) &&
                                is_cancelled == true &&
                                isAttended == false)) {
                          // deleteList.add(e['id']);
                          await _deletePastReservation(e['id']);
                        } else {
                          return;
                        }
                      },
                    );
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
                            // setState(() {});
                            return Column(
                              children: [
                                isAttended == true && is_before
                                    // is_cancelled == false
                                    ? Opacity(
                                        opacity: 0.4,
                                        child: PastReservationTicketList(
                                            reservationList:
                                                fetchedReservationList[index]),
                                      )
                                    : is_cancelled == true && is_before == false
                                        ?
                                        // Slotがキャンセルの場合は、Opacity
                                        Stack(
                                            children: [
                                              Container(
                                                height: 120.h,
                                                alignment: Alignment.center,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                        'Reservation Cancelled',
                                                        style: TextStyle(
                                                            color:
                                                                kColorTextDark,
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
                                        : Slidable(
                                            endActionPane: ActionPane(
                                              motion: ScrollMotion(),
                                              children: [
                                                SlidableAction(
                                                  flex: 1,
                                                  onPressed: (context) async {
                                                    showAwesomeDialog(
                                                        fetchedReservationList[
                                                            index]['id']);
                                                  },
                                                  backgroundColor: Colors.amber,
                                                  foregroundColor: Colors.white,
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
