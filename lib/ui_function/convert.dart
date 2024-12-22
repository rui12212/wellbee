import 'package:intl/intl.dart';

class IntConverter {
  static convertNumToDate(int date) {
    switch (date) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
    }
  }

  // static convertNumToCourse(int num) {
  //   switch (num) {
  //     case 1:
  //       return 'Yoga';
  //     case 2:
  //       return 'Kids Yoga(A)';
  //     case 3:
  //       return 'Zumba';
  //     case 4:
  //       return 'Dance';
  //     case 5:
  //       return 'Kids Dance';
  //     case 6:
  //       return 'Karate';
  //     case 7:
  //       return 'Kids Karate';
  //     case 8:
  //       return 'Kids Taiso(A)';
  //     case 9:
  //       return 'Music';
  //     case 10:
  //       return 'Kids Music';
  //     case 11:
  //       return 'Pilates';
  //     case 12:
  //       return 'Family Pilates';
  //     case 13:
  //       return 'Family Yoga';
  //     case 14:
  //       return 'Kids Taiso(B)';
  //     case 15:
  //       return 'Kids Yoga(B)';
  //     case 16:
  //       return 'Kids Yoga KG';
  //   }
  // }

  // static convertCourseToNum(String course) {
  //   switch (course) {
  //     case 'Yoga':
  //       return 1;
  //     case 'Kids Yoga(A)':
  //       return 2;
  //     case 'Zumba':
  //       return 3;
  //     case 'Dance':
  //       return 4;
  //     case 'Kids Dance':
  //       return 5;
  //     case 'Karate':
  //       return 6;
  //     case "Kids Karate":
  //       return 7;
  //     case 'Kids Taiso(A)':
  //       return 8;
  //     case 'Music':
  //       return 9;
  //     case 'Kids Music':
  //       return 10;
  //     case 'Pilates':
  //       return 11;
  //     case 'Family Pilates':
  //       return 12;
  //     case 'Family Yoga':
  //       return 13;
  //     case 'Kids Taiso(B)':
  //       return 14;
  //     case 'Kids Yoga(B)':
  //       return 15;
  //     case 'Kids Yoga KG':
  //       return 16;
  //   }
  // }

  static String formatTime(dynamic time) {
    if (time is String) {
      DateTime timeObj = DateFormat('HH:mm:ss').parse(time);
      // DateTime parsedTime = DateFormat.jm().parse(time);
      return DateFormat.Hm().format(timeObj); // 例: 8:00
    } else if (time is int) {
      String timeStr = time.toString().padLeft(6, '0'); // 例: 800 -> "080000"
      // DateTime timeObj = DateFormat('HHmmss').parse(timeStr);
      DateTime timeObj = DateFormat.jm().parse(timeStr);
      return DateFormat('h:mm').format(timeObj); // 例: 8:00
    } else {
      throw FormatException("Unsupported time format");
    }
  }
}

class QuestionConverter {
  // static convertStringToNum(String str) {
  //   switch (str) {
  //     case 'Better than usual':
  //       return 0;
  //     case 'Same as usual':
  //       return 1;
  //     case 'Worse than usual':
  //       return 2;
  //     case 'Much worse than usual':
  //       return 3;
  //   }
  // }
  static convertDoubleToNum(double) {
    switch (double) {
      case 0.0:
        return 0;
      case 1.0:
        return 1;
      case 2.0:
        return 2;
      case 3.0:
        return 3;
    }
  }

  // static createResponseMap(List responseIntList) {
  //   Map<dynamic, dynamic> map = {};
  //   for (int i = 1; i < 3; i++) {
  //     map = <dynamic, dynamic>{
  //       'question$i': i,
  //       'response$i': responseIntList[i],
  //       'score$i': i
  //     };
  //   }
  //   return map;
  // }

  static createResponseMap(List responseList) {
    Map<dynamic, dynamic> map = {};
    Map<dynamic, dynamic> completedMap = {};
    for (int i = 0; i < 28; i++) {
      map = <dynamic, dynamic>{'response$i': responseList[i], 'score$i': i};
      completedMap.addAll(map);
    }
    return completedMap;
  }
}

class MembershipConverter {
  static discountRateGenerator(String month) {}

  static culcTotalExpence(
    int month,
    int times,
  ) {}
}
