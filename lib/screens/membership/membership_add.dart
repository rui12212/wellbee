// // import 'package:booking_calendar/booking_calendar.dart';
// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/painting.dart';
// import 'package:flutter/rendering.dart';
// import 'package:flutter/widgets.dart';
// import 'package:flutter_calendar_week/flutter_calendar_week.dart';
// import 'package:flutter/material.dart';
// import 'package:wellbee/assets/inet.dart';
// import 'package:wellbee/screens/membership/membership_attendee.dart';
// import 'package:wellbee/screens/membership/membership_confirm.dart';
// import 'package:wellbee/ui_parts/color.dart';
// import 'package:wellbee/ui_function/convert.dart';
// import 'package:wellbee/ui_function/shared_prefs.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'package:wellbee/ui_parts/textstyle.dart';
// import 'package:wellbee/ui_parts/ticket.dart';

// class _Header extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Align(
//       alignment: Alignment.topLeft,
//       child: TextButton(
//         style: TextButton.styleFrom(
//             backgroundColor: Colors.transparent,
//             shape: const CircleBorder(
//                 side: BorderSide(
//                     color: Color.fromARGB(255, 216, 214, 214), width: 5))),
//         child: const Icon(Icons.chevron_left,
//             color: Color.fromARGB(255, 155, 152, 152)),
//         onPressed: () {
//           Navigator.of(context).pop();
//         },
//       ),
//     );
//   }
// }

// class _Question extends StatelessWidget {
//   String question;
//   String name;

//   _Question({required this.question, required this.name});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//         height: 100,
//         child: Column(
//           children: [
//             Text(question,
//                 style: TextStyle(fontSize: 28, fontWeight: FontWeight.w300)),
//             Text(name,
//                 style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600))
//           ],
//         ));
//   }
// }

// class MembershipAddPage extends StatefulWidget {
//   late Map<dynamic, dynamic> attendeeList;

//   MembershipAddPage({
//     Key? key,
//     required this.attendeeList,
//   }) : super(key: key);

//   @override
//   _MembershipAddPageState createState() => _MembershipAddPageState();
// }

// class _MembershipAddPageState extends State<MembershipAddPage> {
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _reasonController = TextEditingController();
//   final TextEditingController _goalController = TextEditingController();
//   final TextEditingController _commentController = TextEditingController();

//   String? token = '';
//   String isSelectedValue = 'Yoga';
//   int isSelectedIntValue = 1;
//   int isSelectedMonthValue = 1;
//   late DateTime newDate = DateTime(2000);
//   String? courseName = '';

//   @override
//   showSnackBar(color, text) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(backgroundColor: color, content: Text(text)),
//     );
//   }

//   @override
//   void initState() {
//     super.initState();
//     // _fetchMyAllMembershipAdd();
//   }

//   // Future<List<dynamic>?> _fetchMyAllMembershipAdd() async {
//   //   try {
//   //     token = await SharedPrefs.fetchAccessToken();
//   //     var url =
//   //         Uri.parse('${baseUri}attendances/MembershipAdd/my_all_MembershipAdd/');
//   //     var response = await Future.any([
//   //       http.get(url, headers: {"Authorization": 'JWT $token'}),
//   //       Future.delayed(const Duration(seconds: 15),
//   //           () => throw TimeoutException("Request timeout"))
//   //     ]);
//   //     if (response.statusCode == 200) {
//   //       List<dynamic> data = jsonDecode(response.body);
//   //       if (data.isNotEmpty) {
//   //         return data;
//   //       } else if (data.isEmpty) {
//   //         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//   //             content: Text('There is no available MembershipAdd.')));
//   //       } else {
//   //         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//   //             content: Text('Some Error occurred.Try again later')));
//   //       }
//   //     } else if (response.statusCode >= 400) {
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //           const SnackBar(content: Text('Internet Error occurred.')));
//   //     } else {
//   //       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//   //           content: Text('Something went wrong. Try again later')));
//   //     }
//   //   } catch (e) {
//   //     ScaffoldMessenger.of(context)
//   //         .showSnackBar(SnackBar(content: Text('Error: $e')));
//   //   }
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Container(
//           padding: EdgeInsets.symmetric(horizontal: 20),
//           child: Column(
//             children: [
//               _Header(),
//               _Question(
//                 question: 'Apply Membership for',
//                 name: widget.attendeeList['name'],
//               ),
//               Container(
//                 height: 580,
//                 child: SingleChildScrollView(
//                   child: Column(
//                     children: [
//                       SizedBox(
//                         height: 36,
//                       ),
//                       Column(
//                         children: [
//                           Align(
//                               alignment: Alignment.topLeft,
//                               child: Text('Course',
//                                   style: TextStyle(
//                                       color: kColorTextDarkGrey,
//                                       fontSize: 20,
//                                       fontWeight: FontWeight.w500))),
//                           Container(
//                             decoration: BoxDecoration(
//                                 borderRadius:
//                                     BorderRadius.all(Radius.circular(10)),
//                                 border: Border.all(color: kColorTextDarkGrey)),
//                             child: DropdownButton(
//                               itemHeight: 75,
//                               isExpanded: true,
//                               style:
//                                   TextStyle(fontSize: 22, color: Colors.black),
//                               items: [
//                                 DropdownMenuItem(
//                                   value: 'Yoga',
//                                   child: Padding(
//                                     padding: const EdgeInsets.all(10.0),
//                                     child: Text('Yoga'),
//                                   ),
//                                 ),
//                                 DropdownMenuItem(
//                                   value: 'Kids Yoga',
//                                   child: Padding(
//                                     padding: const EdgeInsets.all(10.0),
//                                     child: Text('Kids Yoga'),
//                                   ),
//                                 ),
//                                 DropdownMenuItem(
//                                   value: 'Dance',
//                                   child: Padding(
//                                     padding: const EdgeInsets.all(10.0),
//                                     child: Text('Dance'),
//                                   ),
//                                 ),
//                                 DropdownMenuItem(
//                                   value: 'Kids Dance',
//                                   child: Padding(
//                                     padding: const EdgeInsets.all(10.0),
//                                     child: Text('Kids Dance'),
//                                   ),
//                                 ),
//                                 DropdownMenuItem(
//                                   value: 'Karate',
//                                   child: Padding(
//                                     padding: const EdgeInsets.all(10.0),
//                                     child: Text('Karate'),
//                                   ),
//                                 ),
//                                 DropdownMenuItem(
//                                   value: 'Kids Karate',
//                                   child: Padding(
//                                     padding: const EdgeInsets.all(10.0),
//                                     child: Text('Kids Karate'),
//                                   ),
//                                 ),
//                                 DropdownMenuItem(
//                                   value: 'Music',
//                                   child: Padding(
//                                     padding: const EdgeInsets.all(10.0),
//                                     child: Text('Music'),
//                                   ),
//                                 ),
//                                 DropdownMenuItem(
//                                   value: 'Kids Music',
//                                   child: Padding(
//                                     padding: const EdgeInsets.all(10.0),
//                                     child: Text('Kids Music'),
//                                   ),
//                                 ),
//                                 DropdownMenuItem(
//                                   value: 'Kids Taiso',
//                                   child: Padding(
//                                     padding: const EdgeInsets.all(10.0),
//                                     child: Text('Kids Taiso'),
//                                   ),
//                                 ),
//                               ],
//                               value: isSelectedValue,
//                               onChanged: (String? value) {
//                                 setState(() {
//                                   isSelectedValue = value!;
//                                 });
//                               },
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(
//                         height: 15,
//                       ),
//                       Column(
//                         children: [
//                           Align(
//                               alignment: Alignment.topLeft,
//                               child: Text('Months',
//                                   style: TextStyle(
//                                       color: kColorTextDarkGrey,
//                                       fontSize: 20,
//                                       fontWeight: FontWeight.w500))),
//                           Container(
//                             decoration: BoxDecoration(
//                                 borderRadius:
//                                     BorderRadius.all(Radius.circular(10)),
//                                 border: Border.all(color: kColorTextDarkGrey)),
//                             child: DropdownButton(
//                               itemHeight: 75,
//                               isExpanded: true,
//                               style:
//                                   TextStyle(fontSize: 22, color: Colors.black),
//                               items: [
//                                 DropdownMenuItem(
//                                   value: 1,
//                                   child: Padding(
//                                     padding: const EdgeInsets.all(10.0),
//                                     child: Text('1 month'),
//                                   ),
//                                 ),
//                                 DropdownMenuItem(
//                                   value: 3,
//                                   child: Padding(
//                                     padding: const EdgeInsets.all(10.0),
//                                     child: Text('3 months'),
//                                   ),
//                                 ),
//                                 DropdownMenuItem(
//                                   value: 6,
//                                   child: Padding(
//                                     padding: const EdgeInsets.all(10.0),
//                                     child: Text('6 months'),
//                                   ),
//                                 ),
//                                 DropdownMenuItem(
//                                   value: 12,
//                                   child: Padding(
//                                     padding: const EdgeInsets.all(10.0),
//                                     child: Text('1 year'),
//                                   ),
//                                 ),
//                               ],
//                               value: isSelectedMonthValue,
//                               onChanged: (value) {
//                                 setState(() {
//                                   isSelectedMonthValue = value as int;
//                                 });
//                               },
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(
//                         height: 15,
//                       ),
//                       Column(
//                         children: [
//                           Align(
//                               alignment: Alignment.topLeft,
//                               child: Text('Times per a week',
//                                   style: TextStyle(
//                                       color: kColorTextDarkGrey,
//                                       fontSize: 20,
//                                       fontWeight: FontWeight.w500))),
//                           Container(
//                             decoration: BoxDecoration(
//                                 borderRadius:
//                                     BorderRadius.all(Radius.circular(10)),
//                                 border: Border.all(color: kColorTextDarkGrey)),
//                             child: DropdownButton(
//                               itemHeight: 75,
//                               isExpanded: true,
//                               style:
//                                   TextStyle(fontSize: 22, color: Colors.black),
//                               items: [
//                                 DropdownMenuItem(
//                                   value: 1,
//                                   child: Padding(
//                                     padding: const EdgeInsets.all(10.0),
//                                     child: Text('1 time in a week'),
//                                   ),
//                                 ),
//                                 DropdownMenuItem(
//                                   value: 2,
//                                   child: Padding(
//                                     padding: const EdgeInsets.all(10.0),
//                                     child: Text('2 times in a week'),
//                                   ),
//                                 ),
//                               ],
//                               value: isSelectedIntValue,
//                               onChanged: (value) {
//                                 setState(() {
//                                   isSelectedIntValue = value as int;
//                                 });
//                               },
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(
//                         height: 52,
//                       ),
//                       FilledButton.icon(
//                         onPressed: () {
//                           Map<dynamic, dynamic> membershipMap = {
//                             'course': isSelectedValue,
//                             'times_per_week': isSelectedIntValue,
//                             'duration': isSelectedMonthValue,
//                           };
//                           Navigator.of(context).push(MaterialPageRoute(
//                               builder: (context) => MembershipConfirmPage(
//                                   attendeeList: widget.attendeeList,
//                                   membershipMap: membershipMap)));
//                         },
//                         label: const Text('Check Out',
//                             style: TextStyle(fontSize: 20)),
//                         style: ButtonStyle(
//                           minimumSize: MaterialStateProperty.all<Size>(
//                               Size(300, 80)), // ボタンの幅と高さを設定
//                         ),
//                       ),
//                       SizedBox(
//                         height: 15,
//                       ),
//                       SizedBox(
//                         height: 52,
//                       ),
//                     ],
//                   ),
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
