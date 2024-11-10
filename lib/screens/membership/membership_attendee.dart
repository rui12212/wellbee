// import 'dart:async';
// import 'dart:convert';

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/painting.dart';
// import 'package:flutter/rendering.dart';
// import 'package:intl/intl.dart';
// import 'package:wellbee/assets/inet.dart';
// import 'package:wellbee/screens/attendee/attendee_add.dart';
// import 'package:wellbee/screens/membership/membership_add.dart';
// import 'package:wellbee/ui_function/shared_prefs.dart';
// import 'package:http/http.dart' as http;
// import 'package:wellbee/ui_parts/display.dart';

// import '../../ui_parts/color.dart';

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

//   _Question({
//     required this.question,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//         height: 80,
//         child: Column(
//           children: [
//             Text(question,
//                 style: TextStyle(fontSize: 28, fontWeight: FontWeight.w300))
//           ],
//         ));
//   }
// }

// class MembershipAttendeePage extends StatefulWidget {
//   const MembershipAttendeePage({Key? key}) : super(key: key);

//   @override
//   _MembershipAttendeePageState createState() => _MembershipAttendeePageState();
// }

// class _MembershipAttendeePageState extends State<MembershipAttendeePage> {
//   String? token = '';

//   Future<List<dynamic>?> _fetchAttendee() async {
//     try {
//       token = await SharedPrefs.fetchAccessToken();
//       var url = Uri.parse('${baseUri}attendances/attendee/my_attendee/');
//       var response = await Future.any([
//         http.get(url, headers: {"Authorization": 'JWT $token'}),
//         Future.delayed(const Duration(seconds: 15),
//             () => throw TimeoutException("Request timeout"))
//       ]);
//       if (response.statusCode == 200) {
//         List<dynamic> data = jsonDecode(response.body);
//         if (data.isNotEmpty) {
//           return data;
//         }
//       } else if (response.statusCode >= 400) {
//         ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Internet Error occurred.')));
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//             content: Text('Something went wrong. Try again later')));
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('Error: $e')));
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   showSnackBar(color, text) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(backgroundColor: color, content: Text(text)),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Container(
//           padding: EdgeInsets.symmetric(horizontal: 20),
//           child: Column(
//             children: [
//               _Header(),
//               _Question(question: 'For Which Attendee?'),
//               Container(
//                 height: 610,
//                 child: FutureBuilder(
//                   future: _fetchAttendee(),
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return Center(
//                         child: CircularProgressIndicator(),
//                       );
//                     } else if (snapshot.hasError) {
//                       return Center(child: Text('Error: ${snapshot.error}'));
//                     } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                       return Center(child: Text('No attendee registered.'));
//                     } else {
//                       final attendeeList = snapshot.data!;
//                       return ListView.builder(
//                         itemCount: attendeeList.length,
//                         itemBuilder: (context, index) {
//                           if (attendeeList[index]['goal'] == null) {
//                             attendeeList[index]['goal'] = '';
//                           }
//                           if (attendeeList[index]['reason'] == null) {
//                             attendeeList[index]['reason'] = '';
//                           }
//                           return InkWell(
//                               child: AttendeeDisplay(
//                                   attendeeName: attendeeList[index]['name'],
//                                   gender: attendeeList[index]['gender'],
//                                   dateOfBirth: attendeeList[index]
//                                       ['date_of_birth'],
//                                   goal: attendeeList[index]['goal']),
//                               onTap: () {
//                                 Navigator.of(context).push(MaterialPageRoute(
//                                     builder: (context) => MembershipAddPage(
//                                         attendeeList: attendeeList[index])));
//                               });
//                         },
//                       );
//                     }
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//       // floatingActionButton: FloatingActionButton.large(
//       //   // label: Text('+', style: TextStyle(fontSize: 40)),
//       //   child: Icon(Icons.add, size: 40),
//       //   onPressed: () {
//       //     Navigator.of(context)
//       //         .push(MaterialPageRoute(builder: (context) => AttendeeAddPage()));
//       //   },
//       // ),
//     );
//   }
// }
