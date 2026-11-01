from rest_framework.permissions import BasePermission


class IsStaffMember(BasePermission):
    """スタッフのみ許可する。

    wellbee/permissions.py の IsStaffUser は is_authenticated しか見ておらず、
    一般ユーザーも通ってしまう。メッセージ作成は全会員への配信を伴うため、
    ここでは is_staff を明示的に確認する独自のクラスを使う。
    （IsStaffUser 自体の修正は他エンドポイントへの影響があるため別タスク）
    """

    def has_permission(self, request, view):
        user = request.user
        return bool(user and user.is_authenticated and user.is_staff)
