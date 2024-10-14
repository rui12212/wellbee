import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wellbee/assets/inet.dart';
import 'package:wellbee/ui_function/shared_prefs.dart';
import 'package:http/http.dart' as http;

class QuestionnaireGhqPage extends StatefulWidget {
  const QuestionnaireGhqPage({Key? key}) : super(key: key);

  @override
  _QuestionnaireGhqPageState createState() => _QuestionnaireGhqPageState();
}

class _QuestionnaireGhqPageState extends State<QuestionnaireGhqPage> {
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
    return const Scaffold();
  }
}
