import 'package:image_picker/image_picker.dart';

/// 宛先選択 → 本文入力 → 確認 の3画面で持ち回す下書き。
///
/// 送信するまでサーバーには何も作らないので、入力途中の状態はこのオブジェクトが
/// 唯一の保管場所になる。
class NotificationDraft {
  /// 'all'（全会員） または 'course'（コース指定）
  String targetType;

  /// 'all' / 'active' / 'expired' / 'none'
  String membershipStatus;

  int? targetCourseId;
  String? targetCourseName;

  String title;
  String body;
  XFile? image;

  /// recipient_count で取得した「何人に届くか」
  int recipientCount;

  NotificationDraft({
    this.targetType = 'all',
    this.membershipStatus = 'active',
    this.targetCourseId,
    this.targetCourseName,
    this.title = '',
    this.body = '',
    this.image,
    this.recipientCount = 0,
  });

  /// 宛先の組み合わせが成立しているか。
  ///
  /// コース指定なのにコースが選ばれていない場合と、コース指定＋
  /// 「メンバーシップなし」の組み合わせはサーバー側でも拒否される。
  bool get isTargetValid {
    if (targetType == 'course') {
      if (targetCourseId == null) return false;
      if (membershipStatus == 'none') return false;
    }
    return true;
  }

  bool get isContentValid => title.trim().isNotEmpty && body.trim().isNotEmpty;

  /// 確認画面やカードに出す宛先の説明文
  String get targetLabel {
    final scope = targetType == 'course'
        ? (targetCourseName ?? 'Course')
        : 'All members';
    switch (membershipStatus) {
      case 'active':
        return '$scope · Active';
      case 'expired':
        return '$scope · Expired';
      case 'none':
        return '$scope · No membership';
      default:
        return '$scope · Any status';
    }
  }
}
