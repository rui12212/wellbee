import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wellbee/ui_parts/color.dart';

class _TicketShapeBorder extends ShapeBorder {
  final double? width;
  final double? radius;

  _TicketShapeBorder({
    required this.width,
    required this.radius,
  });

  @override
  EdgeInsetsGeometry get dimensions {
    return EdgeInsets.all(width!);
  }

  @override
  ShapeBorder scale(double t) {
    return _TicketShapeBorder(
      width: width! * t,
      radius: radius! * t,
    );
  }

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    if (a is _TicketShapeBorder)
      return _TicketShapeBorder(
        width: lerpDouble(a.width, width, t),
        radius: lerpDouble(a.radius, radius, t),
      );
    return super.lerpFrom(a, t);
  }

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) {
    if (b is _TicketShapeBorder)
      return _TicketShapeBorder(
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

class _Ticket extends StatelessWidget {
  final Widget image;
  late String attendee_name;
  late String course_name;
  late String expire_day;
  late int times;
  late int max_join_times;
  late int already_join_times;

  _Ticket({
    Key? key,
    required this.image,
    required this.attendee_name,
    required this.course_name,
    required this.already_join_times,
    required this.max_join_times,
    required this.expire_day,
    required this.times,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 128.h,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: _TicketShapeBorder(width: 1, radius: 16.0),
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
            height: double.infinity,
            margin: EdgeInsets.symmetric(vertical: 8.0.h),
            color: kColorTicketBorder,
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Table(
                children: [
                  TableRow(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Course',
                            style: TextStyle(color: kColorText, fontSize: 18.h),
                          ),
                          // SizedBox(height: 4.h),
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
                                  ? 14.h
                                  : course_name == 'Private Yoga@Studio' ||
                                          course_name == 'Private Yoga@Home' ||
                                          course_name ==
                                              'Private Pilates@Studio' ||
                                          course_name == 'Private Pilates@Home'
                                      ? 12.h
                                      : 17.h,
                              color: kColorPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Name',
                            style: TextStyle(color: kColorText, fontSize: 18.h),
                          ),
                          // SizedBox(height: 4.h),
                          Text(
                            attendee_name,
                            style: TextStyle(
                              color: kColorTextDark,
                              fontSize: 17.h,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      SizedBox(
                        height: 8.h,
                        // width: 20.w,
                      ),
                      SizedBox(
                        height: 8.h,
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Expire At',
                            style: TextStyle(color: kColorText, fontSize: 16.h),
                          ),
                          // SizedBox(height: 4.h),
                          Text(
                            expire_day,
                            style: TextStyle(
                              color: kColorTextDark,
                              fontSize: 16.h,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Join Times',
                            style: TextStyle(color: kColorText, fontSize: 16.h),
                          ),
                          // SizedBox(height: 4.h),
                          Text(
                            '$already_join_times/$max_join_times',
                            style: TextStyle(
                              color: kColorTextDark,
                              fontSize: 18.h,
                            ),
                          ),
                        ],
                      ),
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

class TicketList extends StatelessWidget {
  late Map<dynamic, dynamic> membershipList;

  TicketList({
    Key? key,
    required this.membershipList,
  });

  // late String attendee_name;
  // late String course_name;
  // late String expire_day;
  // late int times_per_week;
  // late int max_join_times;
  // late int already_join_times;

  @override
  Widget build(BuildContext context) {
    return _Ticket(
        course_name: membershipList['course_name'],
        attendee_name: membershipList['attendee_name'],
        expire_day: membershipList['expire_day'],
        times: membershipList['times'],
        max_join_times: membershipList['max_join_times'],
        already_join_times: membershipList['already_join_times'],
        image: membershipList['course_name'] == 'Yoga' ||
                membershipList['course_name'] == 'Kids Yoga(A)' ||
                membershipList['course_name'] == 'Kids Yoga(B)' ||
                membershipList['course_name'] == 'Kids Yoga KG'
            ? Image.asset('lib/assets/invi_course_pic/invi_yoga.png')
            : membershipList['course_name'] == 'Dance' ||
                    membershipList['course_name'] == 'Kids Zumba' ||
                    membershipList['course_name'] == 'Zumba'
                ? Image.asset('lib/assets/invi_course_pic/invi_dance.png')
                : membershipList['course_name'] == 'Karate' ||
                        membershipList['course_name'] == 'Kids Karate'
                    ? Image.asset('lib/assets/invi_course_pic/invi_karate.png')
                    : membershipList['course_name'] == 'Music' ||
                            membershipList['course_name'] == 'Kids Music'
                        ? Image.asset(
                            'lib/assets/invi_course_pic/invi_music.png')
                        : membershipList['course_name'] == 'Kids Gym(A)' ||
                                membershipList['course_name'] == 'Kids Gym(B)'
                            ? Image.asset(
                                'lib/assets/invi_course_pic/male_fitness.png')
                            : membershipList['course_name'] == 'Pilates'
                                ? Image.asset(
                                    'lib/assets/invi_course_pic/invi_pilates.png')
                                : membershipList['course_name'] ==
                                        'Family Pilates'
                                    ? Image.asset(
                                        'lib/assets/invi_course_pic/invi_family_pilates.png')
                                    : membershipList['course_name'] ==
                                            'Family Yoga'
                                        ? Image.asset(
                                            'lib/assets/invi_course_pic/invi_family_yoga.png')
                                        : membershipList['course_name'] ==
                                                    'Private Yoga@Studio' ||
                                                membershipList['course_name'] ==
                                                    'Private Yoga@Home'
                                            ? Image.asset(
                                                'lib/assets/invi_course_pic/private_yoga.png')
                                            : membershipList['course_name'] ==
                                                        'Private Pilates@Studio' ||
                                                    membershipList[
                                                            'course_name'] ==
                                                        'Private Pilates@Home'
                                                ? Image.asset(
                                                    'lib/assets/invi_course_pic/private_pilates.png')
                                                : Image.asset(
                                                    'lib/assets/invi_course_pic/female_fitness.png'));
  }
}
