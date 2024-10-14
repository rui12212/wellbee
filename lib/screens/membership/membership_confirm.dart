import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:wellbee/assets/inet.dart';
import 'package:wellbee/ui_parts/color.dart';
import 'package:wellbee/ui_function/shared_prefs.dart';
import 'package:http/http.dart' as http;

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: TextButton(
        style: TextButton.styleFrom(
            backgroundColor: Colors.transparent,
            shape: const CircleBorder(
                side: BorderSide(
                    color: Color.fromARGB(255, 216, 214, 214), width: 5))),
        child: const Icon(Icons.chevron_left,
            color: Color.fromARGB(255, 155, 152, 152)),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

class _Question extends StatelessWidget {
  String question;
  String name;

  _Question({required this.question, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 100,
        child: Column(
          children: [
            Text(question,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w300)),
            Text(name,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600))
          ],
        ));
  }
}

class MembershipConfirmPage extends StatefulWidget {
  Map<dynamic, dynamic> attendeeList;
  Map<dynamic, dynamic> membershipMap;

  MembershipConfirmPage({
    Key? key,
    required this.attendeeList,
    required this.membershipMap,
  }) : super(key: key);

  @override
  _MembershipConfirmPageState createState() => _MembershipConfirmPageState();
}

class _MembershipConfirmPageState extends State<MembershipConfirmPage> {
  String? token = '';

  Future<List<dynamic>?> _fetchAvailableCourse() async {
    try {
      token = await SharedPrefs.fetchAccessToken();
      final String formattedDate = '';
      // print('for = $formattedDate');
      var url = Uri.parse(
          '${baseUri}reservations/reservation/available_slots?date=2024-08-7');
      var response = await Future.any([
        http.get(url, headers: {"Authorization": 'JWT $token'}),
        Future.delayed(const Duration(seconds: 15),
            () => throw TimeoutException("Request timeout"))
      ]);
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          print(data);
          return data;
        }
      } else if (response.statusCode >= 400) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Internet Error occurred.')));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Container(
          height: 595,
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(children: [
            _Header(),
            _Question(
              question: 'Confirm Membership for',
              name: widget.attendeeList['name'],
            ),
            Container(
              padding: EdgeInsets.all(30),
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: FractionalOffset.topLeft,
                      end: FractionalOffset.bottomRight,
                      colors: [
                        kColorPrimary,
                        Color.fromARGB(255, 188, 250, 216),
                      ],
                      stops: const [
                        0.0,
                        1.0
                      ]),
                  borderRadius: BorderRadius.all(Radius.circular(70))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DetailRow(
                    title: 'Course Name:',
                    value: widget.membershipMap['course'],
                  ),
                  _DetailRow(
                    title: 'Month:',
                    value: '${widget.membershipMap['duration']} month',
                  ),
                  _DetailRow(
                    title: 'Times Per Week:',
                    value: '${widget.membershipMap['times_per_week']} time',
                  ),
                  _DetailRow(
                    title: 'Max Join Times:',
                    value: '',
                  ),
                  _DetailRow(
                    title: 'Total Amount:',
                    value: '\$150',
                  ),
                ],
              ),
            )
          ])),
    ));
  }
}

class _DetailRow extends StatelessWidget {
  final String title;
  final String value;

  _DetailRow({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w300,
            ),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}
