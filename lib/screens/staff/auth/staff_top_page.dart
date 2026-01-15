import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:wellbee/main.dart';
import 'package:wellbee/screens/attendee/attendee.dart';
import 'package:wellbee/screens/qr/qr_user.dart';
import 'package:wellbee/screens/reservation/membership.dart';
import 'package:wellbee/screens/questionnaire/ex_survey.dart';
import 'package:wellbee/screens/questionnaire/questionnaire_base.dart';
import 'package:wellbee/screens/questionnaire/survey.dart';
import 'package:wellbee/screens/staff/qr/qr_scanner.dart';
import 'package:wellbee/screens/staff/qr_after/check_in.dart';
import 'package:wellbee/screens/staff/qr_after/user_home.dart';
import 'package:wellbee/screens/staff/staff_home_page.dart';
import 'package:wellbee/screens/top_page.dart';
import 'package:wellbee/ui_function/shared_prefs.dart';
import 'package:wellbee/ui_parts/dialogue_awesome.dart';
import 'package:wellbee/ui_parts/display.dart';

class StaffTopPage extends StatefulWidget {
  // final model.User newUser;
  final int firstNum;
  const StaffTopPage(
    // this.newUser,
    this.firstNum, {
    Key? key,
  }) : super(key: key);

  @override
  _StaffTopPageState createState() => _StaffTopPageState();
}

class _StaffTopPageState extends State<StaffTopPage> {
  int _selectedIndex = 0;
  List<Widget> _pages = [];

  @override
  void initState() {
    _selectedIndex = widget.firstNum;
    _pages = [
      StaffHomePage(),
      // UserHomePage(pk: '5de65b35f8b24ee7a03b595fde324322'),
      ScannerWidget(),
      // CheckInPage(id: '64'),
      showLogOutDialogue(),
    ];
    super.initState();
  }

  Widget showLogOutDialogue() {
    return AlertDialog(
        title: const Text(
          'Sign Out?',
        ),
        content: SizedBox(
            height: 100,
            child: Column(
              children: [
                TextButton(
                  child: const Text(
                    'Sign Out',
                  ),
                  onPressed: () async {
                    await SharedPrefs.clearStaffAuthInfo();
                    await Navigator.of(context)
                        .pushReplacement(MaterialPageRoute(builder: ((context) {
                      return SignInPage();
                    })));
                  },
                ),
              ],
            )));
  }

  void _onItemTapped(int index) {
    setState(
      () {
        _selectedIndex = index;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        animationDuration: const Duration(milliseconds: 200),
        index: _selectedIndex,
        onTap: _onItemTapped,
        items: const <Widget>[
          Icon(Icons.home, color: Color.fromARGB(255, 97, 198, 187), size: 30),
          Icon(Icons.camera_alt_outlined,
              color: Color.fromARGB(255, 97, 198, 187), size: 30),
          Icon(Icons.settings,
              color: Color.fromARGB(255, 97, 198, 187), size: 30),
        ],
        // type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
