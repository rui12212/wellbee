import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:wellbee/ui_parts/color.dart';

class _ReservationCardShapeBorder extends ShapeBorder {
  final double? width;
  final double? radius;

  _ReservationCardShapeBorder({
    required this.width,
    required this.radius,
  });

  @override
  EdgeInsetsGeometry get dimensions {
    return EdgeInsets.all(width!);
  }

  @override
  ShapeBorder scale(double t) {
    return _ReservationCardShapeBorder(
      width: width! * t,
      radius: radius! * t,
    );
  }

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    if (a is _ReservationCardShapeBorder)
      return _ReservationCardShapeBorder(
        width: lerpDouble(a.width, width, t),
        radius: lerpDouble(a.radius, radius, t),
      );
    return super.lerpFrom(a, t);
  }

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) {
    if (b is _ReservationCardShapeBorder)
      return _ReservationCardShapeBorder(
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

class _ReservationCard extends StatelessWidget {
  late String date;
  late String start_time;
  late String end_time;
  late int course_name;
  late String attendee_name;

  _ReservationCard({
    Key? key,
    required this.attendee_name,
    required this.course_name,
    required this.date,
    required this.start_time,
    required this.end_time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 128,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: _ReservationCardShapeBorder(width: 1, radius: 16.0),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Table(
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
                          SizedBox(height: 4),
                          Text(
                            date,
                            style: TextStyle(
                              fontSize: 18,
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
                            style: TextStyle(color: kColorText),
                          ),
                          SizedBox(height: 4),
                          Text(
                            start_time,
                            style: TextStyle(
                              color: kColorTextDark,
                              fontSize: 18,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      SizedBox(height: 8),
                      SizedBox(height: 8),
                    ],
                  ),
                  TableRow(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Valid until',
                            style: TextStyle(color: kColorText),
                          ),
                          SizedBox(height: 4),
                          Text(
                            end_time,
                            style: TextStyle(
                              color: kColorTextDark,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Times to join',
                            style: TextStyle(color: kColorText),
                          ),
                          SizedBox(height: 4),
                          Text(
                            attendee_name,
                            style: TextStyle(
                              color: kColorTextDark,
                              fontSize: 18,
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

class ReservationCardList extends StatelessWidget {
  late Map<dynamic, dynamic> membershipList;

  ReservationCardList({
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
    return _ReservationCard(
      course_name: membershipList['course_name'],
      attendee_name: membershipList['attendee_name'],
      date: membershipList['expire_day'],
      start_time: membershipList['times_per_week'],
      end_time: membershipList['max_join_times'],
    );
  }
}
