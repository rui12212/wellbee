from rest_framework.permissions import BasePermission, SAFE_METHODS

class IsStaffUser(BasePermission):
    def has_permission(self, request, view):
     return bool(request.user.is_authenticated)

class BaseUserPermission(BasePermission):
    def has_permission(self, request, view):
        # リスト表示はスタッフのみ
        if view.action == 'list':
            return request.user and request.user.is_staff
        #  詳細表示、作成、部分更新は認証されたユーザー
        if view.action in ['retrieve', 'create', 'partial_update',]:
            return request.user and request.user.is_authenticated
         # 更新と削除はスタッフのみ
        if view.action in ['update', 'destroy']:
            return request.user and request.user.is_staff
        # デフォルトではアクセスを拒否
        return False

class MembershipPermission(BasePermission):
    def has_permission(self, request, view):
        # リスト表示はスタッフのみ
        if view.action in ['list', 'retrieve']:
            return (request.user and request.user.is_authenticated) or request.user.is_staff==1
        # アクションがmy_reservationだった場合
        if view.action  == 'fetch_available_membership' or view.action == 'fetch_my_all_membership' or view.action == 'fetch_membership_by_staff' or view.action == 'fetch_closest_membership' or view.action == 'fetch_course_membership' or view.action == 'fetch_all_available_membership' or view.action == 'fetch_all_dm_attendee':
            return (request.user and request.user.is_authenticated) or request.user.is_staff==1
        if view.action in ['create','partial_update','update', 'destroy',]:
            return (request.user and request.user.is_authenticated) or request.user.is_staff==1
        # デフォルトではアクセスを拒否
        return False
    
class AttendeePermission(BasePermission):
    def has_permission(self, request, view):
        # リスト表示はスタッフのみ
        if view.action in ['list', 'retrieve']:
            return request.user and request.user.is_staff ==1
        if view.action == 'fetch_first_page_attendee':
            return True
        # 自分で作ったアクションを実行する許可を下記
        if view.action  == 'fetch_attendee_by_staff' or view.action == 'fetch_my_attendee' or view.action == 'fetch_first_attendee' or view.action=='fetch_attendee_health_survey':
            return (request.user and request.user.is_authenticated) or request.user.is_staff==1
         # 更新と削除はスタッフのみ
        # if view.action == 'destroy':
        #     return request.user and request.user.is_staff
        if view.action in ['create','partial_update','update', 'destroy',]:
            return (request.user and request.user.is_authenticated) or request.user.is_staff==1

        # デフォルトではアクセスを拒否
        return False

class InterviewPermission(BasePermission):
    def has_permission(self, request, view):
        # リスト表示はスタッフのみ
        if view.action in ['list', 'retrieve']:
            return request.user and request.user.is_staff ==1
        # if view.action == 'fetch_first_page_attendee':
        #     return True
        # 自分で作ったアクションを実行する許可を下記
        if view.action  == 'fetch_interview_by_staff':
            return (request.user and request.user.is_authenticated) or request.user.is_staff==1
         # 更新と削除はスタッフのみ
        # if view.action == 'destroy':
        #     return request.user and request.user.is_staff
        if view.action in ['create','partial_update','update', 'destroy',]:
            return (request.user and request.user.is_authenticated) or request.user.is_staff==1

        # デフォルトではアクセスを拒否
        return False
    
class ReservationPermission(BasePermission):
    def has_permission(self, request, view):
        # リスト表示はスタッフのみ
        if view.action in ['list', 'retrieve']:
            return (request.user and request.user.is_authenticated) or request.user.is_staff==1
        # アクションがmy_reservationだった場合
        if view.action  == 'fetch_my_reservations' or view.action  == 'fetch_my_available_slots' or view.action =='fetch_slots_for_staff' or view.action == 'fetch_qr_reservation' or view.action == 'fetch_my_all_reservation':
            return (request.user and request.user.is_authenticated) or request.user.is_staff ==1
         # 更新と削除はスタッフのみ
        # if view.action == 'destroy':
        #     return request.user and request.user.is_staff
        # if view.action == 'fetch_qr_reservation':
        #     return request.user.is_staff
        if view.action in ['create','partial_update','update', 'destroy',]:
            return (request.user and request.user.is_authenticated)

        # デフォルトではアクセスを拒否
        return False

class SlotPermission(BasePermission):
    def has_permission(self, request, view):
        # リスト表示はスタッフのみ
        if view.action in ['list', 'retrieve']:
            return request.user.is_staff ==1
        # アクションがmy_reservationだった場合
        if view.action  == 'fetch_course_slots' or view.action == 'fetch_slots_for_staff' or view.action == 'fetch_course_slots_for_staff' or view.action == 'fetch_slots_for_calendar' or view.action =='update_slot' or view.action =='fetch_each_course_slots' or view.action =='fetch_all_slots':
            return  (request.user and request.user.is_authenticated) or request.user.is_staff == 1
        if view.action in ['create','partial_update','update', 'destroy',]:
            return request.user.is_staff==1
        # デフォルトではアクセスを拒否
        return False

class BaseBodySurveyPermission(BasePermission):
    def has_permission(self, request, view):
        # リスト表示はスタッフのみ
        if view.action in ['list', 'retrieve']:
            return (request.user and request.user.is_staff)
        # 自分で作ったアクションを実行する許可を下記
        if view.action  == 'fetch_my_bmi' or view.action == 'fetch_staff_bmi':
            return (request.user or request.user.is_authenticated) or request.user.is_staff == 1
         # 更新と削除はスタッフのみ
        # if view.action == 'destroy':
        #     return request.user and request.user.is_staff
        if view.action in ['create','partial_update','update', 'destroy',]:
            return (request.user and request.user.is_authenticated)

        # デフォルトではアクセスを拒否
        return False

class SurveyResponsePermission(BasePermission):
    def has_permission(self, request, view):
        # リスト表示はスタッフのみ
        if view.action in ['list', 'retrieve']:
            return (request.user and request.user.is_authenticated) or request.user.is_staff==1
        # 自分で作ったアクションを実行する許可を下記
        if view.action  == 'fetch_my_survey' or view.action == 'fetch_staff_survey':
            return (request.user and request.user.is_authenticated) or request.user.is_staff==1
         # 更新と削除はスタッフのみ
        # if view.action == 'destroy':
        #     return request.user and request.user.is_staff
        if view.action in ['create','partial_update','update', 'destroy',]:
            return (request.user and request.user.is_authenticated) or request.user.is_staff == 1

        # デフォルトではアクセスを拒否
        return False

class UserPermission(BasePermission):
    def has_permission(self, request, view):
        # リスト表示はスタッフのみ
        if view.action in ['list', 'retrieve']:
            return (request.user and request.user.is_authenticated) or request.user.is_staff==1
        # 自分で作ったアクションを実行する許可を下記
        if view.action  == 'fetch_my_id' or view.action == 'fetch_my_points' or view.action=='increase_points'or view.action=='delete_user':
            return (request.user and request.user.is_authenticated) or request.user.is_staff==1
         # 更新と削除はスタッフのみ
        # if view.action == 'destroy':
        #     return request.user and request.user.is_staff
        if view.action in ['partial_update','update',]:
            return (request.user and request.user.is_authenticated) or request.user.is_staff==1
        # デフォルトではアクセスを拒否
        return False

class CheckInPermission(BasePermission):
    def has_permission(self, request, view):
        # リスト表示はスタッフのみ
        if view.action in ['list', 'retrieve']:
            return request.user.is_staff
        # 自分で作ったアクションを実行する許可を下記
        if view.action  == 'fetch_staff_checkin':
            return (request.user and request.user.is_authenticated) or request.user.is_staff
         # 更新と削除はスタッフのみ
        if view.action == 'destroy':
            return request.user.is_staff
        if view.action in ['create','partial_update','update']:
            return (request.user and request.user.is_authenticated) or request.user.is_staff

        # デフォルトではアクセスを拒否
        return False

class VersionPermission(BasePermission):
    def has_permission(self, request, view):
        # リスト表示はスタッフのみ
        if view.action in ['list', 'retrieve']:
            return request.user.is_staff
        # 自分で作ったアクションを実行する許可を下記
        if view.action  == 'fetch_latest_version':
            return (request.user and request.user.is_authenticated) or request.user.is_staff
         # 更新と削除はスタッフのみ
        if view.action == 'destroy':
            return request.user.is_staff
        if view.action in ['create','partial_update','update']:
            return (request.user and request.user.is_authenticated) or request.user.is_staff

        # デフォルトではアクセスを拒否
        return False