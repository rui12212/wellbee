import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wellbee/assets/inet.dart';
import 'package:wellbee/ui_function/shared_prefs.dart';
import 'package:http/http.dart' as http;
import 'package:wellbee/ui_parts/display.dart';

import '../../ui_parts/color.dart';
import 'package:qr_flutter/qr_flutter.dart';

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

  _Question({
    required this.question,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 80.h,
        child: Column(
          children: [
            Text(question,
                style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w300))
          ],
        ));
  }
}

class QrCodePage extends StatefulWidget {
  late Map<String, dynamic> selectedReservation;

  QrCodePage({Key? key, required this.selectedReservation}) : super(key: key);

  @override
  _QrCodePageState createState() => _QrCodePageState();
}

class _QrCodePageState extends State<QrCodePage> {
  String? token = '';

  // Future<void> _fetchToken() async {
  //   token = await SharedPrefs.fetchAccessToken();
  // }

  Future<List<dynamic>?> _fetchReservation() async {
    try {
      token = await SharedPrefs.fetchAccessToken();
      var url = Uri.parse('${baseUri}reservations/reservation/my_reservations');
      var response = await Future.any([
        http.get(url, headers: {
          "Authorization": 'JWT $token',
          "Content-Type": "application/json"
        }),
        Future.delayed(const Duration(seconds: 15),
            () => throw TimeoutException("Request timeout"))
      ]);
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty && data != null) {
          print(data);
          return data;
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Error occurred.')));
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
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchReservation();
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
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              _Header(),
              _Question(question: 'Scan me for checking in!'),
              Container(
                height: 400.h,
                // width: 400.h,
                alignment: Alignment.center,
                child: QrImageView(
                  data:
                      '${baseUri}reservations/reservation/qr_reservation?reservation_id=${widget.selectedReservation['id']}',
                  version: QrVersions.auto,
                  size: 200.0.h,
                ),
              ),
            ],
          ),
        ));
  }
}
      // body: SafeArea(//)