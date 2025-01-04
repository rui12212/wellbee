// import 'dart:async';
// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// import 'package:flutter_calendar_week/flutter_calendar_week.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_slidable/flutter_slidable.dart';
// import 'package:intl/intl.dart';
// import 'package:wellbee/assets/inet.dart';
// import 'package:wellbee/screens/staff/calendar/attendee_detail_page.dart';
// import 'package:wellbee/screens/staff/course/course.dart';
// import 'package:wellbee/screens/staff/course/slot_add.dart';
// import 'package:wellbee/ui_function/convert.dart';
// import 'package:wellbee/ui_function/shared_prefs.dart';
// import 'package:http/http.dart' as http;
// import 'package:wellbee/ui_parts/color.dart';
// import 'package:wellbee/ui_parts/dialogue_awesome.dart';

// class _Header extends StatelessWidget {
//   String title;

//   _Header({
//     required this.title,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 50.h,
//       child: Row(
//         children: [
//           Text(
//             title,
//             style: title.length > 12
//                 ? TextStyle(fontSize: 21.sp, fontWeight: FontWeight.bold)
//                 : TextStyle(fontSize: 30.sp, fontWeight: FontWeight.bold),
//           ),
//           TextButton(
//             style: TextButton.styleFrom(
//                 backgroundColor: Colors.transparent,
//                 shape: const CircleBorder(
//                     side: BorderSide(
//                         color: Color.fromARGB(255, 206, 204, 204), width: 5))),
//             child: const Icon(Icons.chevron_left,
//                 color: Color.fromARGB(255, 155, 152, 152)),
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//           )
//         ],
//       ),
//     );
//   }
// }

// class SlotPage extends StatefulWidget {
//   Map<String, dynamic> courseList;

//   SlotPage({Key? key, required this.courseList}) : super(key: key);

//   @override
//   _SlotPageState createState() => _SlotPageState();
// }

// class _SlotPageState extends State<SlotPage> {
//   final CalendarWeekController _controller = CalendarWeekController();
//   String? token = '';
//   DateTime selectedDate = DateTime.now();

//   @override
//   showSnackBar(color, text) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(backgroundColor: color, content: Text(text)),
//     );
//   }

//   @override
//   void initState() {
//     super.initState();
//     // fetchedSlotData = _fetchAvailableCourse() as Future<List<dynamic>?>;
//   }

//   Future<List<dynamic>?> _fetchCourseSlots() async {
//     try {
//       final String formattedDate =
//           DateFormat('yyyy-MM-dd').format(selectedDate);
//       token = await SharedPrefs.fetchStaffAccessToken();
//       var url = Uri.parse('${baseUri}reservations/slot/course_slots_for_staff/')
//           .replace(queryParameters: {
//         'token': token,
//         'course_name': widget.courseList['course_name'],
//         'date': formattedDate,
//       });
//       // print(widget.courseList['course_name']);
//       var response = await Future.any([
//         http.get(url, headers: {
//           "Authorization": 'JWT $token',
//           "Content-Type": "application/json"
//         }),
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

//   Future<List<dynamic>?> _deleteSlot(int slotId) async {
//     try {
//       token = await SharedPrefs.fetchStaffAccessToken();
//       var url = Uri.parse(
//           '${baseUri}reservations/slot/${slotId}/update_slot/?token=$token');

//       var response = await Future.any([
//         http.patch(url, headers: {
//           "Authorization": 'JWT $token',
//           "Content-Type": "application/json"
//         }),
//         Future.delayed(const Duration(seconds: 15),
//             () => throw TimeoutException("Request timeout"))
//       ]);

//       if (response.statusCode == 200) {
//         showSnackBar(kColorPrimary, 'Slot has been cancelled');
//         // Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
//         //   builder: (context) {
//         //     return AllCoursePage();
//         //   },
//         // ), ((route) => false));
//       }
//       // else if (response.statusCode == 204) {
//       //   showSnackBar(kColorPrimary, 'Slot has been deleted');
//       //   Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
//       //     builder: (context) {
//       //       return AllCoursePage();
//       //     },
//       //   ), ((route) => false));
//       // }
//       else if (response.statusCode >= 400) {
//         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//             content: Text('Internet Error. You may not have slots')));
//       }
//       // else {
//       //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//       //       content: Text('Something went wrong. Try again later')));
//       // }
//     } catch (e) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('Error: $e')));
//     }
//   }

//   void showAwesomeDialog(
//     int id,
//   ) {
//     CustomAwesomeDialogueForCancelReservation(
//       titleText: 'Cancel Reservation',
//       desc: 'Are you sure to cancel?',
//       callback: () async {
//         await _deleteSlot(id);
//       },
//     ).show(context);
//   }

// // カレンダーでスロットを表示する

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Container(
//           padding: EdgeInsets.all(15),
//           child: Column(
//             children: [
//               _Header(title: '${widget.courseList['course_name']} Slot'),
//               CalendarWeek(
//                 height: 150.h,
//                 controller: _controller,
//                 pressedDateBackgroundColor: kColorPrimary,
//                 dateStyle: TextStyle(
//                   color: Color.fromARGB(255, 92, 88, 88),
//                   fontWeight: FontWeight.w600,
//                   fontSize: 18.sp,
//                 ),
//                 dayOfWeekStyle: TextStyle(
//                   fontWeight: FontWeight.w600,
//                   fontSize: 16.sp,
//                   color: Color.fromARGB(255, 92, 88, 88),
//                 ),
//                 weekendsStyle: TextStyle(
//                   fontWeight: FontWeight.w600,
//                   fontSize: 17.sp,
//                   color: Color.fromARGB(255, 92, 88, 88),
//                 ),
//                 todayDateStyle: TextStyle(
//                     color: Color.fromARGB(255, 92, 88, 88),
//                     fontWeight: FontWeight.w600,
//                     fontSize: 18.sp),
//                 todayBackgroundColor: Color.fromARGB(255, 178, 222, 217),
//                 showMonth: true,
//                 minDate: DateTime.now().add(
//                   Duration(days: 0),
//                 ),
//                 maxDate: DateTime.now().add(
//                   Duration(days: 365),
//                 ),
//                 onDatePressed: (DateTime datetime) async {
//                   // bool isAlreadyMax = fetchedSlotData['is_max'];
//                   setState(
//                     () {
//                       selectedDate = datetime;
//                     },
//                   );
//                 },
//                 onDateLongPressed: (DateTime datetime) {},
//                 onWeekChanged: () {
//                   // Do something
//                 },
//                 monthViewBuilder: (DateTime time) => Align(
//                   alignment: FractionalOffset.center,
//                   child: Container(
//                       margin: const EdgeInsets.symmetric(vertical: 14),
//                       child: Text(
//                         DateFormat.yMMMM().format(time),
//                         overflow: TextOverflow.ellipsis,
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                             color: Color.fromARGB(255, 92, 88, 88),
//                             fontSize: 18.sp),
//                       )),
//                 ),
//                 decorations: [
//                   // DecorationItem(
//                   //     decorationAlignment: FractionalOffset.bottomRight,
//                   //     date: DateTime.now(),
//                   //     decoration: Icon(
//                   //       Icons.today,
//                   //       color: Colors.blue,
//                   //     )),
//                   // DecorationItem(
//                   //     // expiredayの表示はここで行う
//                   //     date: DateTime.now().add(Duration(days: 4)),
//                   //     decoration: Text(
//                   //       'Holiday',
//                   //       style: TextStyle(
//                   //         color: Colors.brown,
//                   //         fontWeight: FontWeight.w600,
//                   //       ),
//                   //     )),
//                 ],
//               ),
//               FutureBuilder(
//                   future: _fetchCourseSlots(),
//                   builder: (context, snapshot) {
//                     // まだデータを取得しきっていない時に表示しようとするとnullが入る。nullで弾かれる
//                     // connectionStateを入れて、時間稼ぎしてあげる
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return Center(
//                         child: CircularProgressIndicator(),
//                       );
//                     } else if (snapshot.hasError) {
//                       return Center(child: Text('Error: ${snapshot.error}'));
//                     } else if (!snapshot.hasData || snapshot.data == null) {
//                       return Center(
//                           child: Text('No slot has been set on this day.'));
//                     } else {
//                       final fetchedSlotList = snapshot.data!;
//                       return Expanded(
//                         child: ListView.builder(
//                           itemCount: fetchedSlotList.length,
//                           itemBuilder: (context, index) {
//                             String formattedStartTime = IntConverter.formatTime(
//                                 fetchedSlotList[index]['start_time']);
//                             String formattedEndTime = IntConverter.formatTime(
//                                 fetchedSlotList[index]['end_time']);
//                             final bool is_cancelled =
//                                 fetchedSlotList[index]['is_cancelled'];
//                             return Container(
//                               child: is_cancelled == true
//                                   ? Stack(children: [
//                                       Container(
//                                         height: 100.h,
//                                         alignment: Alignment.center,
//                                         child: Column(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.center,
//                                           children: [
//                                             Text('Slot was cancelled',
//                                                 style: TextStyle(
//                                                     color: Color.fromARGB(
//                                                         255, 86, 82, 82),
//                                                     fontSize: 18.sp,
//                                                     fontWeight:
//                                                         FontWeight.w700)),
//                                           ],
//                                         ),
//                                       ),
//                                       Opacity(
//                                         opacity: 0.4,
//                                         child: Container(
//                                           height: 90.h,
//                                           decoration: BoxDecoration(
//                                             border: Border(
//                                               bottom: BorderSide(
//                                                 color: Colors.black, // 線の色
//                                                 width: 0.2, // 線の太さ
//                                               ),
//                                             ),
//                                           ),
//                                           child: Column(
//                                             children: [
//                                               SizedBox(
//                                                 height: 10.h,
//                                               ),
//                                               ListTile(
//                                                 title: Container(
//                                                   child: Text(
//                                                       fetchedSlotList[index]
//                                                           ['date'],
//                                                       style: TextStyle(
//                                                           fontSize: 18.sp)),
//                                                 ),
//                                                 subtitle: Row(
//                                                   children: [
//                                                     Text('Avalable Seats '),
//                                                     Text(
//                                                         '${fetchedSlotList[index]['reserved_people']}/${fetchedSlotList[index]['max_people']}'),
//                                                   ],
//                                                 ),
//                                                 trailing: Text(
//                                                     '$formattedStartTime - $formattedEndTime',
//                                                     style: TextStyle(
//                                                         fontSize: 18.sp)),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ),
//                                     ])
//                                   : Slidable(
//                                       endActionPane: ActionPane(
//                                           motion: ScrollMotion(),
//                                           children: [
//                                             SlidableAction(
//                                               flex: 1,
//                                               onPressed: (context) async {
//                                                 showAwesomeDialog(
//                                                     fetchedSlotList[index]
//                                                         ['id']);
//                                               },
//                                               backgroundColor: Colors.amber,
//                                               foregroundColor: Colors.white,
//                                               icon:
//                                                   Icons.delete_forever_outlined,
//                                               label: 'Delete',
//                                             )
//                                           ]),
//                                       child: Container(
//                                         height: 90.h,
//                                         decoration: BoxDecoration(
//                                           border: Border(
//                                             bottom: BorderSide(
//                                               color: Colors.black, // 線の色
//                                               width: 0.2, // 線の太さ
//                                             ),
//                                           ),
//                                         ),
//                                         child: Column(
//                                           children: [
//                                             SizedBox(
//                                               height: 10.h,
//                                             ),
//                                             ListTile(
//                                               title: Container(
//                                                 child: Text(
//                                                     fetchedSlotList[index]
//                                                         ['date'],
//                                                     style: TextStyle(
//                                                         fontSize: 18.sp)),
//                                               ),
//                                               subtitle: Row(
//                                                 children: [
//                                                   Text('Avalable Seats '),
//                                                   Text(
//                                                       '${fetchedSlotList[index]['reserved_people']}/${fetchedSlotList[index]['max_people']}'),
//                                                 ],
//                                               ),
//                                               trailing: Text(
//                                                   '$formattedStartTime - $formattedEndTime',
//                                                   style: TextStyle(
//                                                       fontSize: 18.sp)),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                             );
//                           },
//                         ),
//                       );
//                     }
//                   })
//             ],
//           ),
//         ),
//       ),
//       floatingActionButton: FloatingActionButton.large(
//         backgroundColor: Color.fromARGB(255, 65, 174, 147),
//         // label: Text('+', style: TextStyle(fontSize: 40)),
//         child: Icon(Icons.add, size: 40.h, color: Colors.white),
//         onPressed: () {
//           Navigator.of(context).push(MaterialPageRoute(
//               builder: (context) =>
//                   SlotAddPage(courseName: widget.courseList['course_name'])));
//         },
//       ),
//     );
//   }
// }
