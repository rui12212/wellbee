// import 'package:wellbee/screens/staff/health_survey/membership_factory.dart';

// class Attendee {
//   final int id;
//   final String user;
//   final String name;
//   final String gender;
//   final DateTime dateOfBirth;
//   final String anyComment;
//   final DateTime createdDate;
//   final String reason;
//   final String goal;
//   final DateTime lastSurveyDate;
//   final String userId;
//   final String userPhone;
//   final int points;
//   final List<Membership> membership;

//   Attendee({
//     required this.id,
//     required this.user,
//     required this.name,
//     required this.gender,
//     required this.dateOfBirth,
//     required this.anyComment,
//     required this.createdDate,
//     required this.reason,
//     required this.goal,
//     required this.lastSurveyDate,
//     required this.userId,
//     required this.userPhone,
//     required this.points,
//     required this.membership,
//   });

//   factory Attendee.fromJson(Map<String, dynamic> json) {
//     var membershipJson = json['membership'] as List;
//     List<Membership> membershipList = membershipJson
//         .map((membershipItem) => Membership.fromJson(membershipItem))
//         .toList();

//     return Attendee(
//       id: json['id'],
//       user: json['user'],
//       name: json['name'],
//       gender: json['gender'],
//       dateOfBirth: DateTime.parse(json['date_of_birth']),
//       anyComment: json['any_comment'],
//       createdDate: DateTime.parse(json['created_date']),
//       reason: json['reason'],
//       goal: json['goal'],
//       lastSurveyDate: DateTime.parse(json['last_survey_date']),
//       userId: json['user_id'],
//       userPhone: json['user_phone'],
//       points: json['points'],
//       membership: membershipList,
//     );
//   }
// }
