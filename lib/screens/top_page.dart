import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:wellbee/assets/inet.dart';
import 'package:wellbee/screens/attendee/attendee.dart';
import 'package:wellbee/screens/qr/qr_user.dart';
import 'package:wellbee/screens/reservation/membership.dart';
import 'package:wellbee/screens/questionnaire/ex_survey.dart';
import 'package:wellbee/screens/questionnaire/questinnaire_attendee.dart';
import 'package:wellbee/screens/questionnaire/questionnaire_base.dart';
import 'package:wellbee/screens/questionnaire/survey.dart';
import 'package:wellbee/ui_function/shared_prefs.dart';
import 'package:wellbee/ui_parts/display.dart';
import 'home.dart';
import 'qr/qr_reservation.dart';
import 'result.dart';
import 'package:http/http.dart' as http;

class TopPage extends StatefulWidget {
  // final model.User newUser;
  final int firstNum;
  const TopPage(
    // this.newUser,
    this.firstNum, {
    Key? key,
  }) : super(key: key);

  @override
  _TopPageState createState() => _TopPageState();
}

class _TopPageState extends State<TopPage> {
  int _selectedIndex = 0;
  List<Widget> _pages = [];

  @override
  void initState() {
    _selectedIndex = widget.firstNum;
    _pages = [
      HomePage(),
      UserQrCodePage(),
      // PrivacyPage(),
    ];
    super.initState();
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
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        animationDuration: const Duration(milliseconds: 200),
        index: _selectedIndex,
        onTap: _onItemTapped,
        items: const <Widget>[
          Icon(Icons.home, color: Color.fromARGB(255, 97, 198, 187), size: 30),
          Icon(Icons.qr_code_rounded,
              color: Color.fromARGB(255, 97, 198, 187), size: 30),
          // Icon(Icons.privacy_tip,
          //     color: Color.fromARGB(255, 97, 198, 187), size: 30),
        ],
        // type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
