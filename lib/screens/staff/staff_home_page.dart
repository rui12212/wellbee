import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wellbee/screens/staff/calendar/calendar.dart';
import 'package:wellbee/screens/staff/course/course.dart';
import 'package:wellbee/ui_parts/color.dart';

class StaffHomePage extends StatefulWidget {
  const StaffHomePage(
      // this.newUser,
      {
    Key? key,
  }) : super(key: key);

  @override
  _StaffHomePageState createState() => _StaffHomePageState();
}

class _StaffHomePageState extends State<StaffHomePage> {
  int _selectedIndex = 0;
  List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text('Staff Home',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 28.h,
                    fontWeight: FontWeight.bold)),
            backgroundColor: kColorPrimary),
        body: SafeArea(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 20.w,
            ),
            child: Column(
              children: [
                InkWell(
                    child: Container(
                        height: 100.h,
                        width: 390.w,
                        decoration: BoxDecoration(
                            border: Border.symmetric(
                                horizontal: BorderSide(width: 0.2))),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_month_outlined,
                                color: Color.fromARGB(255, 97, 198, 187),
                                size: 30),
                            SizedBox(
                              width: 10.w,
                            ),
                            Text('Calendar', style: TextStyle(fontSize: 26.sp))
                          ],
                        )),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => CalendarPage()));
                    }),
                SizedBox(
                  height: 5.h,
                ),
                InkWell(
                    child: Container(
                        height: 100.h,
                        width: 390.w,
                        decoration: BoxDecoration(
                            border: Border.symmetric(
                                horizontal: BorderSide(width: 0.2))),
                        child: Row(
                          children: [
                            Icon(Icons.school_outlined,
                                color: Color.fromARGB(255, 97, 198, 187),
                                size: 30),
                            SizedBox(
                              width: 10.w,
                            ),
                            Text('Course', style: TextStyle(fontSize: 26.sp))
                          ],
                        )),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => AllCoursePage()));
                    }),
              ],
            ),
          ),
        ));
  }
}
