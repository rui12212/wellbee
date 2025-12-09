import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wellbee/assets/inet.dart';
import 'package:wellbee/screens/staff/course_add/all_courses.dart';
import 'package:wellbee/ui_function/provider.dart';
import 'package:http/http.dart' as http;
import 'package:wellbee/ui_function/shared_prefs.dart';
import 'package:wellbee/ui_parts/botton.dart';
import 'package:wellbee/ui_parts/color.dart';
import 'package:wellbee/ui_parts/textstyle.dart';

class _Header extends StatelessWidget {
  String title;

  _Header({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.h,
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 30.sp, fontWeight: FontWeight.bold),
          ),
          TextButton(
            style: TextButton.styleFrom(
                backgroundColor: Colors.transparent,
                shape: const CircleBorder(
                    side: BorderSide(
                        color: Color.fromARGB(255, 206, 204, 204), width: 5))),
            child: const Icon(Icons.chevron_left,
                color: Color.fromARGB(255, 155, 152, 152)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
      ),
    );
  }
}

class CourseEditPage extends ConsumerStatefulWidget {
  CourseEditPage({
    Key? key,
  }) : super(key: key);

  @override
  _CourseEditPageState createState() => _CourseEditPageState();
}

class _CourseEditPageState extends ConsumerState<CourseEditPage> {
  final TextEditingController _courseNameController = TextEditingController();

  String? token = '';

  @override
  showSnackBar(color, text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: color, content: Text(text)),
    );
  }

  @override
  void initState() {
    super.initState();
    // fetchedSlotData = _fetchAvailableCourse() as Future<List<dynamic>?>;
  }

  void addNewCourse(
      StateProvider<bool> isOpen, StateProvider<bool> isPrivate) async {
    try {
      token = await SharedPrefs.fetchStaffAccessToken();
      var url = Uri.parse('${baseUri}course/?token=$token');
      var response = await Future.any([
        http.post(url,
            body: jsonEncode({
              'course_name': _courseNameController,
              'is_open': isOpen,
              'is_private': isPrivate,
            }),
            headers: {
              "Authorization": 'JWT $token',
              "Content-Type": 'application/json',
            }),
        Future.delayed(const Duration(seconds: 15),
            () => throw TimeoutException("Request timeout"))
      ]);
      if (response.statusCode == 201) {
        // List<dynamic> data = jsonDecode(response.body);
        // if (data.isNotEmpty) {
        showSnackBar(kColorPrimary, 'Purchase Membership success!');
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
          builder: (context) {
            return CoursesPage();
          },
        ), ((route) => false));
      } else if (response.statusCode >= 400) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Internet Error occurred. Try again later')));
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
    final isOpenSelected = ref.watch(isOpenSelectedProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(15),
          child: Column(
            children: [
              _Header(title: 'All Course'),
              Container(
                height: 500.h,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 26.h,
                    ),
                    Align(
                        alignment: Alignment.topCenter,
                        child: Text('How much point member get?',
                            style: TextStyle(
                                color: kColorTextDarkGrey,
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w500))),
                    CustomTextBox(
                      label: '',
                      hintText: 'Put new course name',
                      inputType: TextInputType.text,
                      controller: _courseNameController,
                    ).textFieldDecoration(),
                    SizedBox(
                      height: 20.h,
                    ),
                    Row(
                      children: [
                        Text('Is this course open?'),
                        CustomFilledButton(
                            labelText: 'Yes',
                            boolByProvider: isOpenSelected,
                            newBoolByProvider: ref
                                .read(isExpireDaySelectedProvider.notifier)
                                .state = true)
                      ],
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    Text('Is this course private?'),
                    SizedBox(
                      height: 40.h,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        final courseName = _courseNameController.text.trim();
                        if (courseName == null || courseName == '') {
                          showSnackBar(Colors.red, 'Put the course name');
                        } else
                          addNewCourse(isOpenSelectedProvider,
                              isPrivateSelectedProvider);
                      },
                      child: Text('Add new course',
                          style: TextStyle(
                              color: kColorPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 22.sp)),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.large(
        backgroundColor: Color.fromARGB(255, 65, 174, 147),
        // label: Text('+', style: TextStyle(fontSize: 40)),
        child: Icon(Icons.add, size: 40.h, color: Colors.white),
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => CourseEditPage()));
        },
      ),
    );
  }

  Widget _buildGridItem({
    required Widget image,
    required String title,
  }) {
    return Container(
      decoration: BoxDecoration(
        // gradient: LinearGradient(
        //     begin: FractionalOffset.bottomRight,
        //     end: FractionalOffset.topLeft,
        //     colors: [
        //       // kColorPrimary,
        //       // Color.fromARGB(255, 188, 250, 216),
        //     ],
        //     stops: const [
        //       0.7,
        //       1.0
        //     ]),
        boxShadow: [
          // BoxShadow(
          //   color: Colors.black.withOpacity(0.8), // 影の色（半透明）
          //   spreadRadius: 1, // 影の広がり
          //   blurRadius: 10, // ぼかし具合
          //   offset: Offset(2, 4), // 影の位置（X方向、Y方向）
          // ),
        ],
        color: Color.fromARGB(255, 77, 156, 125),
        borderRadius: BorderRadius.circular(12.0),
      ),
      padding: const EdgeInsets.all(4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 8.0.h),
          Container(
            child: image,
            height: 80.h,
            width: double.infinity.w,
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: title.length >= 13 ? 13.w : 18.w,
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 20,
                ),
              ],
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4.0.h),
          Spacer(),
        ],
      ),
    );
  }
}
