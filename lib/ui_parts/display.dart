import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wellbee/screens/attendee/attendee.dart';
import 'package:wellbee/screens/reservation/membership.dart';
import 'package:wellbee/ui_function/convert.dart';
import 'package:wellbee/ui_parts/color.dart';
import 'package:wellbee/ui_parts/box_decoration.dart';
import 'dart:ui';

class UserDisplay extends StatelessWidget {
  String attendeeName;
  String gender;
  String dateOfBirth;

  UserDisplay({
    required this.attendeeName,
    required this.gender,
    required this.dateOfBirth,
  });

  @override
  bool isLoading = false;
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
            border: Border(bottom: const BorderSide(width: 0.05))),
        height: 70,
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            const CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey,
                child: Icon(
                  Icons.person,
                  size: 30,
                )),
            Container(
              width: 290,
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    attendeeName,
                  ),
                  SizedBox(height: 10),
                  Text(dateOfBirth),
                ],
              ),
            ),
          ],
        ));
  }
}

class ReservationMaterials extends StatelessWidget {
  const ReservationMaterials(
      {Key? key, required this.title, required this.statusValue})
      : super(key: key);
  final String title;
  final String statusValue;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Padding(
        padding: const EdgeInsets.all(5),
        child: Text(title,
            style: TextStyle(
              fontWeight: FontWeight.w900,
            )),
      ),
      Text(statusValue, style: TextStyle(fontSize: 26)),
    ]);
  }
}

class ReservationSummaryCard extends StatefulWidget {
  late Map<String, dynamic> selectedCourseSlot;
  late Map<String, dynamic> membershipList;

  ReservationSummaryCard(
      {Key? key,
      required this.selectedCourseSlot,
      required this.membershipList})
      : super(key: key);

  @override
  State<ReservationSummaryCard> createState() => _ReservationSummaryCardState();
}

class _ReservationSummaryCardState extends State<ReservationSummaryCard> {
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
              height: 220,
              child: Column(
                children: [
                  Column(
                    children: [
                      // 一番上のあおい部分、作成日のContainerの色など
                      Container(
                        decoration: const BoxDecoration(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(10)),
                          // boxShadow: [
                          //   BoxShadow(
                          //     color: Color.fromARGB(255, 78, 78, 78),
                          //     blurRadius: 2.0,
                          //   ),
                          // ],
                        ),
                        // 作成日の表示場所指定
                        alignment: Alignment.centerLeft,
                        width: double.infinity,
                        // 作成日の具体的な数字を入れる部分
                        child: Padding(
                          padding: const EdgeInsets.all(7.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Date',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                  )),
                              Text('${widget.selectedCourseSlot['date']}',
                                  style: const TextStyle(
                                    fontSize: 26,
                                    // fontWeight: FontWeight.bold
                                  )),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 1,
                    child: Divider(
                      thickness: 1.0,
                    ),
                  ),
                  ReservationMaterials(
                      title: 'Time',
                      statusValue:
                          '${widget.selectedCourseSlot['start_time']}-${widget.selectedCourseSlot['end_time']}'),
                  SizedBox(
                    height: 10,
                    child: Divider(
                      thickness: 1.0,
                    ),
                  ),
                  ReservationMaterials(
                      title: 'Course',
                      statusValue:
                          widget.selectedCourseSlot['slot_course_name']),
                  SizedBox(
                    height: 10,
                    child: Divider(
                      thickness: 1.0,
                    ),
                  ),
                  // ここだけTimestampをDateTime型にしたい、dateはDateTime型をTimestamp型にした
                  ReservationMaterials(
                    title: 'Name',
                    statusValue: widget.membershipList['attendee_name'],
                  ),
                ],
              )),
        ),
      ),
    ]);
  }
}

class QrReservationSummaryCard extends StatefulWidget {
  late Map<String, dynamic> reservationList;

  QrReservationSummaryCard({
    Key? key,
    required this.reservationList,
  }) : super(key: key);

  @override
  State<QrReservationSummaryCard> createState() =>
      _QrReservationSummaryCardState();
}

class _QrReservationSummaryCardState extends State<QrReservationSummaryCard> {
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
              height: 220,
              child: Column(
                children: [
                  Column(
                    children: [
                      // 一番上のあおい部分、作成日のContainerの色など
                      Container(
                        decoration: const BoxDecoration(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(10)),
                          // boxShadow: [
                          //   BoxShadow(
                          //     color: Color.fromARGB(255, 78, 78, 78),
                          //     blurRadius: 2.0,
                          //   ),
                          // ],
                        ),
                        // 作成日の表示場所指定
                        alignment: Alignment.centerLeft,
                        width: double.infinity,
                        // 作成日の具体的な数字を入れる部分
                        child: Padding(
                          padding: const EdgeInsets.all(7.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Date',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                  )),
                              Text('${widget.reservationList['date']}',
                                  style: const TextStyle(
                                    fontSize: 26,
                                    // fontWeight: FontWeight.bold
                                  )),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 1,
                    child: Divider(
                      thickness: 1.0,
                    ),
                  ),
                  ReservationMaterials(
                      title: 'Time',
                      statusValue:
                          '${widget.reservationList['slot_start_time']}-${widget.reservationList['slot_end_time']}'),
                  SizedBox(
                    height: 10,
                    child: Divider(
                      thickness: 1.0,
                    ),
                  ),
                  ReservationMaterials(
                      title: 'Course',
                      statusValue: widget.reservationList['slot_course_name']),
                  SizedBox(
                    height: 10,
                    child: Divider(
                      thickness: 1.0,
                    ),
                  ),
                  // ここだけTimestampをDateTime型にしたい、dateはDateTime型をTimestamp型にした
                  ReservationMaterials(
                    title: 'Name',
                    statusValue: widget.reservationList['attendee_name'],
                  ),
                ],
              )),
        ),
      ),
    ]);
  }
}

class HomeCard extends StatelessWidget {
  String image;
  String text;
  Widget pass;

  HomeCard({required this.image, required this.text, required this.pass});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2.62 / 3,
      child: InkWell(
          child: Container(
            margin: EdgeInsets.only(right: 15.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image:
                  DecorationImage(fit: BoxFit.cover, image: AssetImage(image)),
            ),
            child: Container(
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(
                    text,
                    style: TextStyle(color: Colors.white, fontSize: 18.r),
                  ),
                ),
              ),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                      begin: Alignment.bottomRight,
                      stops: [
                        0.1,
                        0.9
                      ],
                      colors: [
                        Colors.black.withOpacity(.9),
                        Colors.black.withOpacity(.1)
                      ])),
            ),
          ),
          onTap: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => pass));
          }),
    );
  }
}

class AttendeeDisplay extends StatelessWidget {
  String attendeeName;
  String gender;
  String dateOfBirth;
  String goal;
  // bool isWithinOneMonth;

  AttendeeDisplay({
    required this.attendeeName,
    required this.gender,
    required this.dateOfBirth,
    required this.goal,
    // required this.isWithinOneMonth
  });

  @override
  Widget build(BuildContext context) {
    // if(isWithinOneMonth == true){

    // } else{

    // }
    return Container(
      height: 150.r,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 110.w,
            decoration: BoxDecoration(
                image: DecorationImage(
                  image: gender == 'male'
                      ? AssetImage('lib/assets/attendee_pic/male_fitness.png')
                      : AssetImage(
                          'lib/assets/attendee_pic/female_fitness.png'),
                ),
                color: Colors.white,
                boxShadow: shadowList,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.r),
                    bottomLeft: Radius.circular(20.r))),
            height: 150.r,
          ),
          Expanded(
              child: Container(
                  height: 150.r,
                  padding: EdgeInsets.all(16).r,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      // boxShadow: shadowList,
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(20.r),
                          bottomRight: Radius.circular(20.r))),
                  child: Column(
                    children: [
                      Align(
                          alignment: Alignment.topLeft,
                          child: Text(attendeeName,
                              style: TextStyle(
                                  overflow: TextOverflow.ellipsis,
                                  color: kColorTextDarkGrey,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold))),
                      Row(
                        children: [
                          Text('Birthday: ',
                              style:
                                  TextStyle(fontSize: 16.w, color: kColorText)),
                          Text(dateOfBirth,
                              style:
                                  TextStyle(fontSize: 16.w, color: kColorText))
                        ],
                      ),
                      Row(
                        children: [
                          Text('Gender: ',
                              style:
                                  TextStyle(fontSize: 17.r, color: kColorText)),
                          Text(gender,
                              style:
                                  TextStyle(fontSize: 17.r, color: kColorText))
                        ],
                      ),
                      // SizedBox(height: 10.r),
                      Align(
                          alignment: Alignment.topLeft,
                          child: goal == ''
                              ? Text('No goal is set',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 17.r,
                                      color: kColorTextDarkGrey))
                              : DefaultTextStyle(
                                  style: TextStyle(
                                      fontSize: 17.r,
                                      color: kColorTextDarkGrey),
                                  child: Text(
                                    goal,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
                    ],
                  )))
        ],
      ),
    );
  }
}

class _ReservationTicketShapeBorder extends ShapeBorder {
  final double? width;
  final double? radius;

  _ReservationTicketShapeBorder({
    required this.width,
    required this.radius,
  });

  @override
  EdgeInsetsGeometry get dimensions {
    return EdgeInsets.all(width!);
  }

  @override
  ShapeBorder scale(double t) {
    return _ReservationTicketShapeBorder(
      width: width! * t,
      radius: radius! * t,
    );
  }

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    if (a is _ReservationTicketShapeBorder)
      return _ReservationTicketShapeBorder(
        width: lerpDouble(a.width, width, t),
        radius: lerpDouble(a.radius, radius, t),
      );
    return super.lerpFrom(a, t);
  }

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) {
    if (b is _ReservationTicketShapeBorder)
      return _ReservationTicketShapeBorder(
        width: lerpDouble(width, b.width, t),
        radius: lerpDouble(radius, b.radius, t),
      );
    return super.lerpTo(b, t);
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return getOuterPath(
      rect.deflate(width!),
      textDirection: textDirection,
    );
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final r = radius!;
    final rs = radius! / 2; // 区切り部分の半径
    final w = rect.size.width; // 全体の横幅
    final h = rect.size.height; // 全体の縦幅
    final wl = w / 3; // ロゴ部分の横幅
    return Path()
      ..addPath(
        Path()
          ..moveTo(r, 0)
          ..lineTo(wl - rs, 0) // →
          ..arcToPoint(
            Offset(wl + rs, 0),
            radius: Radius.circular(rs),
            clockwise: false,
          )
          ..lineTo(w - r, 0) // →
          ..arcToPoint(Offset(w, r), radius: Radius.circular(r))
          ..lineTo(w, h - rs) // ↓
          ..arcToPoint(Offset(w - r, h), radius: Radius.circular(r))
          ..lineTo(wl + rs, h) // ←
          ..arcToPoint(
            Offset(wl - rs, h),
            radius: Radius.circular(rs),
            clockwise: false,
          )
          ..lineTo(r, h) // ←
          ..arcToPoint(Offset(0, h - r), radius: Radius.circular(r))
          ..lineTo(0, r) // ↑
          ..arcToPoint(Offset(r, 0), radius: Radius.circular(r)),
        Offset(rect.left, rect.top),
      );
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width!
      ..color = kColorTicketBorder;
    canvas.drawPath(
      getOuterPath(
        rect.deflate(width! / 2.0),
        textDirection: textDirection,
      ),
      paint,
    );
  }
}

class _ReservationTicket extends StatelessWidget {
  final Widget image;
  late String attendee_name;
  late String course_name;
  late String date;
  late String start_time;
  late String end_time;

  _ReservationTicket({
    Key? key,
    required this.image,
    required this.attendee_name,
    required this.course_name,
    required this.date,
    required this.start_time,
    required this.end_time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String formattedStartTime = IntConverter.formatTime(start_time);
    String formattedEndTime = IntConverter.formatTime(end_time);
    return Container(
      width: 390.w,
      height: 128.r,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: _ReservationTicketShapeBorder(width: 1, radius: 16.0),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              // padding: EdgeInsets.all(24),
              child: image,
            ),
          ),
          Container(
            width: 1.w,
            // height: double.infinity,
            margin: EdgeInsets.symmetric(vertical: 8.0.r),
            color: kColorTicketBorder,
          ),
          Expanded(
            flex: 3,
            child: Container(
              padding: EdgeInsets.all(8),
              child: Column(
                children: [
                  Table(
                    children: [
                      TableRow(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Course',
                                style: TextStyle(
                                  color: kColorText,
                                ),
                              ),
                              // SizedBox(height: 4),
                              Text(
                                course_name,
                                style: TextStyle(
                                  fontSize: course_name == 'Family Pilates' ||
                                          course_name == 'Family Yoga' ||
                                          course_name == 'Kids Karate' ||
                                          course_name == 'Kids Gym(A)' ||
                                          course_name == 'Kids Gym(B)' ||
                                          course_name == 'Kids Yoga(A)' ||
                                          course_name == 'Kids Yoga(B)' ||
                                          course_name == 'Kids Yoga KG' ||
                                          course_name == 'Kids Zumba'
                                      ? 14.w
                                      : course_name == 'Private Yoga@Studio' ||
                                              course_name ==
                                                  'Private Yoga@Home' ||
                                              course_name ==
                                                  'Private Pilates@Studio' ||
                                              course_name ==
                                                  'Private Pilates@Home'
                                          ? 12.w
                                          : 17.w,
                                  color: kColorTextDark,
                                  // fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Name',
                                style: TextStyle(color: kColorText),
                              ),
                              // SizedBox(height: 4),
                              Text(
                                attendee_name,
                                style: TextStyle(
                                  color: kColorTextDark,
                                  fontSize: 18.w,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          SizedBox(height: 5.r),
                          SizedBox(height: 5.r),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    width: double.infinity,
                    // color: Colors.amber,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date',
                          style: TextStyle(
                            color: kColorText,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              '$formattedStartTime-$formattedEndTime,',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: kColorPrimary,
                                fontSize: 18.w,
                              ),
                            ),
                            SizedBox(
                              width: 2.w,
                            ),
                            Text(
                              '$date',
                              style: TextStyle(
                                fontSize: 18.w,
                                fontWeight: FontWeight.bold,
                                color: kColorPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ReservationTicketList extends StatelessWidget {
  late Map<dynamic, dynamic> reservationList;

  ReservationTicketList({
    Key? key,
    required this.reservationList,
  });

  // late String attendee_name;
  // late String course_name;
  // late String expire_day;
  // late int times_per_week;
  // late int max_join_times;
  // late int already_join_times;

  @override
  Widget build(BuildContext context) {
    return _ReservationTicket(
        course_name: reservationList['slot_course_name'],
        attendee_name: reservationList['attendee_name'],
        date: reservationList['slot_date'],
        start_time: reservationList['slot_start_time'],
        end_time: reservationList['slot_end_time'],
        image: reservationList['slot_course_name'] == 'Yoga' ||
                reservationList['slot_course_name'] == 'Kids Yoga(A)' ||
                reservationList['slot_course_name'] == 'Kids Yoga(B)' ||
                reservationList['slot_course_name'] == 'Kids Yoga KG'
            ? Image.asset('lib/assets/invi_course_pic/invi_yoga.png')
            : reservationList['slot_course_name'] == 'Dance' ||
                    reservationList['slot_course_name'] == 'Kids Zumba' ||
                    reservationList['slot_course_name'] == 'Zumba'
                ? Image.asset('lib/assets/invi_course_pic/invi_dance.png')
                : reservationList['slot_course_name'] == 'Karate' ||
                        reservationList['slot_course_name'] == 'Kids Karate'
                    ? Image.asset('lib/assets/invi_course_pic/invi_karate.png')
                    : reservationList['slot_course_name'] == 'Music' ||
                            reservationList['slot_course_name'] == 'Kids Music'
                        ? Image.asset(
                            'lib/assets/invi_course_pic/invi_music.png')
                        : reservationList['slot_course_name'] == 'Kids Gym(A)' ||
                                reservationList['slot_course_name'] ==
                                    'Kids Gym(B)'
                            ? Image.asset(
                                'lib/assets/invi_course_pic/male_fitness.png')
                            : reservationList['slot_course_name'] == 'Pilates'
                                ? Image.asset(
                                    'lib/assets/invi_course_pic/invi_pilates.png')
                                : reservationList['slot_course_name'] ==
                                        'Family Pilates'
                                    ? Image.asset(
                                        'lib/assets/invi_course_pic/invi_family_pilates.png')
                                    : reservationList['slot_course_name'] ==
                                            'Family Yoga'
                                        ? Image.asset(
                                            'lib/assets/invi_course_pic/invi_family_yoga.png')
                                        : reservationList['slot_course_name'] ==
                                                    'Private Yoga@Studio' ||
                                                reservationList['slot_course_name'] ==
                                                    'Private Yoga@Home'
                                            ? Image.asset(
                                                'lib/assets/invi_course_pic/private_yoga.png')
                                            : reservationList['slot_course_name'] ==
                                                        'Private Pilates@Studio' ||
                                                    reservationList['slot_course_name'] ==
                                                        'Private Pilates@Home'
                                                ? Image.asset(
                                                    'lib/assets/invi_course_pic/private_pilates.png')
                                                : Image.asset(
                                                    'lib/assets/invi_course_pic/female_fitness.png'));
  }
}

class PastReservationTicketList extends StatelessWidget {
  late Map<dynamic, dynamic> reservationList;

  PastReservationTicketList({
    Key? key,
    required this.reservationList,
  });

  @override
  Widget build(BuildContext context) {
    return _PastReservationTicket(
        course_name: reservationList['slot_course_name'],
        attendee_name: reservationList['attendee_name'],
        date: reservationList['slot_date'],
        start_time: reservationList['slot_start_time'],
        end_time: reservationList['slot_end_time'],
        image: reservationList['slot_course_name'] == 'Yoga' ||
                reservationList['slot_course_name'] == 'Kids Yoga(A)' ||
                reservationList['slot_course_name'] == 'Kids Yoga(B)' ||
                reservationList['slot_course_name'] == 'Kids Yoga KG'
            ? Image.asset('lib/assets/invi_course_pic/invi_yoga.png')
            : reservationList['slot_course_name'] == 'Dance' ||
                    reservationList['slot_course_name'] == 'Kids Zumba' ||
                    reservationList['slot_course_name'] == 'Zumba'
                ? Image.asset('lib/assets/invi_course_pic/invi_dance.png')
                : reservationList['slot_course_name'] == 'Karate' ||
                        reservationList['slot_course_name'] == 'Kids Karate'
                    ? Image.asset('lib/assets/invi_course_pic/invi_karate.png')
                    : reservationList['slot_course_name'] == 'Music' ||
                            reservationList['slot_course_name'] == 'Kids Music'
                        ? Image.asset(
                            'lib/assets/invi_course_pic/invi_music.png')
                        : reservationList['slot_course_name'] == 'Kids Gym(A)' ||
                                reservationList['slot_course_name'] ==
                                    'Kids Gym(B)'
                            ? Image.asset(
                                'lib/assets/invi_course_pic/male_fitness.png')
                            : reservationList['slot_course_name'] == 'Pilates'
                                ? Image.asset(
                                    'lib/assets/invi_course_pic/invi_pilates.png')
                                : reservationList['slot_course_name'] ==
                                        'Family Pilates'
                                    ? Image.asset(
                                        'lib/assets/invi_course_pic/invi_family_pilates.png')
                                    : reservationList['slot_course_name'] ==
                                            'Family Yoga'
                                        ? Image.asset(
                                            'lib/assets/invi_course_pic/invi_family_yoga.png')
                                        : reservationList['slot_course_name'] ==
                                                    'Private Yoga@Studio' ||
                                                reservationList['slot_course_name'] ==
                                                    'Private Yoga@Home'
                                            ? Image.asset(
                                                'lib/assets/invi_course_pic/private_yoga.png')
                                            : reservationList['slot_course_name'] ==
                                                        'Private Pilates@Studio' ||
                                                    reservationList['slot_course_name'] ==
                                                        'Private Pilates@Home'
                                                ? Image.asset(
                                                    'lib/assets/invi_course_pic/private_pilates.png')
                                                : Image.asset(
                                                    'lib/assets/invi_course_pic/female_fitness.png'));
  }
}

class _PastReservationTicket extends StatelessWidget {
  final Widget image;
  late String attendee_name;
  late String course_name;
  late String date;
  late String start_time;
  late String end_time;

  _PastReservationTicket({
    Key? key,
    required this.image,
    required this.attendee_name,
    required this.course_name,
    required this.date,
    required this.start_time,
    required this.end_time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String formattedStartTime = IntConverter.formatTime(start_time);
    String formattedEndTime = IntConverter.formatTime(end_time);
    return Container(
      width: 390.w,
      height: 128.r,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: _ReservationTicketShapeBorder(width: 1, radius: 16.0),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              // padding: EdgeInsets.all(24),
              child: image,
            ),
          ),
          Container(
            width: 1,
            // height: double.infinity,
            margin: EdgeInsets.symmetric(vertical: 8.0.r),
            color: kColorTicketBorder,
          ),
          Expanded(
            flex: 3,
            child: Container(
              padding: EdgeInsets.all(8),
              child: Column(
                children: [
                  Table(
                    children: [
                      TableRow(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Course',
                                style: TextStyle(
                                  color: kColorText,
                                ),
                              ),
                              // SizedBox(height: 4),
                              Text(
                                course_name,
                                style: TextStyle(
                                  fontSize: course_name == 'Family Pilates' ||
                                          course_name == 'Family Yoga' ||
                                          course_name == 'Kids Karate' ||
                                          course_name == 'Kids Gym(A)' ||
                                          course_name == 'Kids Gym(B)' ||
                                          course_name == 'Kids Yoga(A)' ||
                                          course_name == 'Kids Yoga(B)' ||
                                          course_name == 'Kids Yoga KG' ||
                                          course_name == 'Kids Zumba'
                                      ? 14.w
                                      : course_name == 'Private Yoga@Studio' ||
                                              course_name ==
                                                  'Private Yoga@Home' ||
                                              course_name ==
                                                  'Private Pilates@Studio' ||
                                              course_name ==
                                                  'Private Pilates@Home'
                                          ? 12.w
                                          : 17.w,
                                  color: kColorTextDark,
                                  // fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Name',
                                style: TextStyle(color: kColorText),
                              ),
                              // SizedBox(height: 4),
                              Text(
                                attendee_name,
                                style: TextStyle(
                                  color: kColorTextDark,
                                  fontSize: 16.w,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          SizedBox(height: 2.r),
                          SizedBox(height: 2.r),
                        ],
                      ),
                      TableRow(children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Date',
                              style: TextStyle(
                                color: kColorText,
                              ),
                            ),
                            Text(
                              '$formattedStartTime-$formattedEndTime,',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: kColorPrimary,
                                fontSize: 16.w,
                              ),
                            ),
                            Text(
                              '$date',
                              style: TextStyle(
                                fontSize: 16.w,
                                fontWeight: FontWeight.bold,
                                color: kColorPrimary,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Attendance',
                              style: TextStyle(
                                color: kColorText,
                              ),
                            ),
                            Text(
                              'Completed',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: kColorPrimary,
                                fontSize: 20.w,
                              ),
                            ),
                          ],
                        ),
                      ])
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ReservationCheckList extends StatelessWidget {
  late String slot_course_name;
  late String slot_start_time;
  late String slot_end_time;
  late String slot_date;
  late String attendee_name;

  ReservationCheckList({
    Key? key,
    required this.slot_course_name,
    required this.slot_start_time,
    required this.slot_end_time,
    required this.slot_date,
    required this.attendee_name,
  });

  Widget baseContainer(
    String tytle,
    String text,
  ) {
    return Row(
      children: [
        // SizedBox(
        //   width: 30,
        // ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tytle,
                style: TextStyle(
                  fontSize: 16.r,
                  fontWeight: FontWeight.w300,
                )),
            Text(text,
                style: TextStyle(
                  color: kColorTextDarkGrey,
                  fontSize: 20.r,
                  fontWeight: FontWeight.w700,
                )),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(height: 30.r),
      baseContainer('Course Name', slot_course_name),
      SizedBox(height: 18.r),
      baseContainer('Lesson Date', slot_date),
      SizedBox(height: 18.r),
      baseContainer('Lesson Start Time', slot_start_time),
      SizedBox(height: 18.r),
      baseContainer('Lesson End Time', slot_end_time),
      SizedBox(height: 18.r),
      baseContainer(
        'Wellbee Member Name',
        attendee_name,
      ),
    ]);
  }
}

class AttendeeDetailList extends StatelessWidget {
  late String? goal;
  late String? reason;
  late String? anyComment;

  AttendeeDetailList({
    Key? key,
    this.goal,
    this.reason,
    this.anyComment,
  });

  Widget baseContainer(String? text) {
    return Container(
      width: double.infinity,
      height: 100,
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8))),
      child: text != null ? Text(text) : Text(''),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text('Goal', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      baseContainer(goal),
      SizedBox(height: 18),
      Text('Reason of joining Wellbee',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      baseContainer(reason),
      SizedBox(height: 18),
      Text('Comment',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      baseContainer(anyComment),
      SizedBox(height: 18),
    ]);
  }
}
