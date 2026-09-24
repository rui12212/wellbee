import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wellbee/assets/inet.dart';
import 'package:wellbee/screens/staff/qr_after/user_home.dart';
import 'package:wellbee/screens/staff/qr_after_point/point_decrease.dart';
import 'package:wellbee/screens/staff/qr_after_point/point_increase.dart';
import 'package:wellbee/screens/staff/qr_after_point/stamp_increase.dart';
import 'package:wellbee/screens/staff/qr_after_point/stamp_decrease.dart';
import 'package:wellbee/ui_function/shared_prefs.dart';
import 'package:wellbee/ui_parts/color.dart';
import 'package:http/http.dart' as http;

class _Header extends StatelessWidget {
  final String pk;

  const _Header({required this.pk});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Point & Stamp',
            style: TextStyle(fontSize: 30.sp, fontWeight: FontWeight.w600),
          ),
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
                builder: (context) => UserHomePage(pk: pk),
              ), ((route) => false));
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
    );
  }
}

class PointSelectPage extends StatefulWidget {
  final String pk;
  const PointSelectPage({
    Key? key,
    required this.pk,
  }) : super(key: key);

  @override
  _PointSelectPageState createState() => _PointSelectPageState();
}

class _PointSelectPageState extends State<PointSelectPage> {
  String? token = '';

  Future<Map<String, dynamic>?> _fetchPoint() async {
    try {
      token = await SharedPrefs.fetchStaffAccessToken();
      var url =
          Uri.parse('${baseUri}accounts/users/${widget.pk}/?token=$token');
      var response = await Future.any([
        http.get(url, headers: {
          "Authorization": 'JWT $token',
          "Content-Type": "application/json"
        }),
        Future.delayed(const Duration(seconds: 15),
            () => throw TimeoutException("Request Timeout"))
      ]);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
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
    return null;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F2),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(pk: widget.pk),
              SizedBox(height: 24.h),
              FutureBuilder(
                future: _fetchPoint(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox(
                      height: 400.h,
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data == null) {
                    return SizedBox(
                      height: 400.h,
                      child: const Center(child: Text('No User can be found')),
                    );
                  } else {
                    final fetchedUser = snapshot.data!;
                    final int currentPoint = fetchedUser['points'] ?? 0;
                    final int currentStamp = fetchedUser['stamps'] ?? 0;
                    return Column(
                      children: [
                        _buildValuePanel(
                          label: 'POINT',
                          value: currentPoint,
                          unit: 'pt',
                          gradientColors: const [
                            Color(0xFF93D6C7),
                            Color(0xFF74C2B1)
                          ],
                          buttonColor: const Color(0xFF74C2B1),
                          textColor: const Color(0xFF10473D),
                          plusLabel: 'Give Point',
                          minusLabel: 'Use Point',
                          onPlusTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => PointIncreasePage(
                                      pk: widget.pk, point: currentPoint))),
                          onMinusTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => PointDecreasePage(
                                      pk: widget.pk, point: currentPoint))),
                        ),
                        SizedBox(height: 16.h),
                        _buildValuePanel(
                          label: 'STAMP',
                          value: currentStamp,
                          unit: '✦',
                          gradientColors: [
                            kColorPrimary,
                            const Color(0xFF0F6B55)
                          ],
                          buttonColor: const Color(0xFF0F6B55),
                          textColor: Colors.white,
                          plusLabel: 'Add Stamp',
                          minusLabel: 'Remove Stamp',
                          onPlusTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => StampIncreasePage(
                                      pk: widget.pk, stamp: currentStamp, point: currentPoint))),
                          onMinusTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => StampDecreasePage(
                                      pk: widget.pk, stamp: currentStamp))),
                        ),
                        SizedBox(height: 16.h),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildValuePanel({
    required String label,
    required int value,
    required String unit,
    required List<Color> gradientColors,
    required Color buttonColor,
    required Color textColor,
    required String plusLabel,
    required String minusLabel,
    required VoidCallback onPlusTap,
    required VoidCallback onMinusTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 16.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    color: textColor.withValues(alpha: 0.75),
                  ),
                ),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '$value',
                        style: TextStyle(
                          fontSize: 36.sp,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                      TextSpan(
                        text: ' $unit',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          color: textColor.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: onPlusTap,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    color: buttonColor,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('+',
                            style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                                color: textColor)),
                        SizedBox(width: 6.w),
                        Text(plusLabel,
                            style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: textColor)),
                      ],
                    ),
                  ),
                ),
              ),
              Container(width: 1, height: 48.h, color: Colors.white24),
              Expanded(
                child: InkWell(
                  onTap: onMinusTap,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    color: buttonColor,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('−',
                            style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                                color: textColor.withValues(alpha: 0.85))),
                        SizedBox(width: 6.w),
                        Text(minusLabel,
                            style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: textColor.withValues(alpha: 0.85))),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
