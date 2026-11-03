from django.contrib.auth import get_user_model
from django.utils import timezone

from .models import UserNotification

User = get_user_model()


def resolve_recipients(
    target_type, membership_status, target_course_id=None, staff_only=False
):
    """宛先条件から対象ユーザーの QuerySet を返す。

    期限切れの判定には Membership.is_expired を使わない。あのフィールドを
    True に更新する処理がコード上に存在せず、常に False のままだからである。
    代わりに expire_day と当日の日付を比較する。

    - 有効（active）  : expire_day >= 今日 のメンバーシップを1件でも持つ
    - 期限切れ(expired): メンバーシップ履歴はあるが、有効なものが1件もない

    staff_only が True のときは他の条件を一切見ず、スタッフ全員を返す。
    """
    today = timezone.localdate()
    # 退会済みだけを除く。スタッフも会員として通っている可能性があるため、
    # 配信対象から外さない。
    base = User.objects.filter(is_active=True)

    if staff_only:
        # テスト送信用。コースやメンバーシップ状態を無視してスタッフ全員に送る
        return base.filter(is_staff=True)

    if target_type == 'all':
        if membership_status == 'all':
            return base
        if membership_status == 'active':
            return base.filter(membership__expire_day__gte=today).distinct()
        if membership_status == 'expired':
            return base.filter(
                membership__isnull=False
            ).exclude(
                membership__expire_day__gte=today
            ).distinct()
        if membership_status == 'none':
            return base.filter(membership__isnull=True)
        return User.objects.none()

    if target_type == 'course' and target_course_id:
        if membership_status == 'all':
            return base.filter(
                membership__course_id=target_course_id
            ).distinct()
        if membership_status == 'active':
            return base.filter(
                membership__course_id=target_course_id,
                membership__expire_day__gte=today,
            ).distinct()
        if membership_status == 'expired':
            # exclude に2条件をまとめて書くと「その2つを同時に満たす
            # メンバーシップを持つ人」が除外される。つまり当該コースの
            # 有効なメンバーシップを持つ人だけが抜ける。
            return base.filter(
                membership__course_id=target_course_id
            ).exclude(
                membership__course_id=target_course_id,
                membership__expire_day__gte=today,
            ).distinct()
        # course + none は無効な組み合わせ（シリアライザーでも拒否している）
        return User.objects.none()

    return User.objects.none()


def count_recipients(
    target_type, membership_status, target_course_id=None, staff_only=False
):
    """送信前に「何人に届くか」を数える。レコードは作らない。"""
    return resolve_recipients(
        target_type, membership_status, target_course_id, staff_only
    ).count()


def deliver(notification):
    """対象ユーザーぶんの UserNotification を一括作成し、対象ユーザーを返す。

    post_save シグナルではなくビューの perform_create から明示的に呼ぶ。
    シグナルにすると管理画面やシェルからの保存でも配信が走ってしまう。
    """
    users = list(
        resolve_recipients(
            notification.target_type,
            notification.membership_status,
            notification.target_course_id,
            notification.staff_only,
        )
    )
    if not users:
        return users

    UserNotification.objects.bulk_create(
        [
            UserNotification(notification=notification, user=user)
            for user in users
        ],
        # 万一この関数が二重に呼ばれても、unique_together に当たった行は
        # 静かに捨てて処理を続ける（二重配信を防ぐ）
        ignore_conflicts=True,
    )
    return users
