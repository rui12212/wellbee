import 'package:flutter_riverpod/flutter_riverpod.dart';

final startTimeProvider = StateProvider((ref) {
  return '11:00';
});

final endTimeProvider = StateProvider((ref) {
  return '12:00';
});

final slotListProvider = StateProvider<List<dynamic>>((ref) => []);

final maxCapacityProvider = StateProvider<int>((ref) {
  return 20;
});

final isNearlyExpired = StateProvider<bool>((ref) {
  return false;
});

final isWithInOneWeek = StateProvider<bool>((ref) {
  return false;
});

final isExpireDaySelectedProvider = StateProvider<bool>(
  (ref) {
    return true;
  },
);

final isExpireWithin2WeekProvider = StateProvider<bool>((ref) {
  return false;
});

final isLastCheckInOver2WeekProvider = StateProvider<bool>((ref) {
  return false;
});

final isUpdateNeededProvider = StateProvider<bool>((ref) {
  return false;
});

final isCanTakeSurveyProvider = StateProvider<bool>((ref) {
  return false;
});
