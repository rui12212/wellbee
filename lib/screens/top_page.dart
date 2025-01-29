import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wellbee/assets/inet.dart';
import 'package:wellbee/version/version_info.dart';
import 'package:wellbee/screens/setting/setting_page.dart';
import 'package:wellbee/screens/user_calendar.dart';
import 'package:wellbee/ui_function/shared_prefs.dart';
import 'package:wellbee/ui_parts/color.dart';
import 'package:wellbee/ui_parts/dialogue_awesome.dart';
import 'home.dart';
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
      UserCalendarPage(),
      SettingPage(),
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
        backgroundColor: kColorPrimary,
        index: _selectedIndex,
        onTap: _onItemTapped,
        items: const <Widget>[
          Icon(Icons.home, color: Color.fromARGB(255, 97, 198, 187), size: 30),
          Icon(Icons.calendar_month_outlined,
              color: Color.fromARGB(255, 97, 198, 187), size: 30),
          Icon(Icons.settings_accessibility_outlined,
              color: Color.fromARGB(255, 97, 198, 187), size: 30),
        ],
        // type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
