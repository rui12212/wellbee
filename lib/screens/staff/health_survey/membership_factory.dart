// class Membership {
//   final int id;
//   final String userId;
//   final int course;
//   final DateTime expireDay;
//   final DateTime startDay;
//   final int minus;
//   final int times;
//   final int maxJoinTimes;
//   final int alreadyJoinTimes;
//   final DateTime lastCheckIn;
//   final int requestedJoinTimes;
//   final int duration;
//   final DateTime requestTime;
//   final bool isApproved;
//   final double totalPrice;
//   final String attendeeName;
//   final String attendeeGender;
//   final DateTime attendeeBirthday;
//   final String courseName;
//   final int numPerson;
//   final double discountedTotalPrice;
//   final int attendee;
//   final DateTime lastSurveyDate;

//   Membership({
//     required this.id,
//     required this.userId,
//     required this.course,
//     required this.expireDay,
//     required this.startDay,
//     required this.minus,
//     required this.times,
//     required this.maxJoinTimes,
//     required this.alreadyJoinTimes,
//     required this.lastCheckIn,
//     required this.requestedJoinTimes,
//     required this.duration,
//     required this.requestTime,
//     required this.isApproved,
//     required this.totalPrice,
//     required this.attendeeName,
//     required this.attendeeGender,
//     required this.attendeeBirthday,
//     required this.courseName,
//     required this.numPerson,
//     required this.discountedTotalPrice,
//     required this.attendee,
//     required this.lastSurveyDate,
//   });

//   factory Membership.fromJson(Map<String, dynamic> json) {
//     return Membership(
//       id: json['id'],
//       userId: json['user_id'],
//       course: json['course'],
//       expireDay: DateTime.parse(json['expire_day']),
//       startDay: DateTime.parse(json['start_day']),
//       minus: json['minus'],
//       times: json['times'],
//       maxJoinTimes: json['max_join_times'],
//       alreadyJoinTimes: json['already_join_times'],
//       lastCheckIn: DateTime.parse(json['last_check_in']),
//       requestedJoinTimes: json['requested_join_times'],
//       duration: json['duration'],
//       requestTime: DateTime.parse(json['request_time']),
//       isApproved: json['is_approved'],
//       totalPrice: json['total_price'].toDouble(),
//       attendeeName: json['attendee_name'],
//       attendeeGender: json['attendee_gender'],
//       attendeeBirthday: DateTime.parse(json['attendee_birthday']),
//       courseName: json['course_name'],
//       numPerson: json['num_person'],
//       discountedTotalPrice: json['discounted_total_price'].toDouble(),
//       attendee: json['attendee'],
//       lastSurveyDate: DateTime.parse(json['last_survey_date']),
//     );
//   }
// }
