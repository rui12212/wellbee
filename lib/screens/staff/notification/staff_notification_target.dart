import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:wellbee/assets/inet.dart';
import 'package:wellbee/screens/staff/notification/notification_draft.dart';
import 'package:wellbee/screens/staff/notification/staff_notification_compose.dart';
import 'package:wellbee/ui_function/shared_prefs.dart';
import 'package:wellbee/ui_parts/color.dart';

class StaffNotificationTargetPage extends StatefulWidget {
  const StaffNotificationTargetPage({super.key});

  @override
  State<StaffNotificationTargetPage> createState() =>
      _StaffNotificationTargetPageState();
}

class _StaffNotificationTargetPageState
    extends State<StaffNotificationTargetPage> {
  final NotificationDraft _draft = NotificationDraft();

  List<Map<String, dynamic>> _courses = [];
  bool _isLoadingCourses = true;
  bool _isCounting = false;
  String? _countError;

  @override
  void initState() {
    super.initState();
    _fetchCourses();
    _fetchRecipientCount();
  }

  Future<void> _fetchCourses() async {
    try {
      final token = await SharedPrefs.fetchAccessToken();
      final url = Uri.parse('${baseUri}attendances/course/?token=$token');
      final response = await Future.any([
        http.get(url, headers: {
          "Authorization": 'JWT $token',
          "Content-Type": "application/json",
        }),
        Future.delayed(const Duration(seconds: 15),
            () => throw TimeoutException("Request Timeout")),
      ]);
      if (!mounted) return;
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          _courses = data.cast<Map<String, dynamic>>();
          _isLoadingCourses = false;
        });
      } else {
        setState(() => _isLoadingCourses = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingCourses = false);
    }
  }

  /// 現在の宛先条件で何人に届くかをサーバーに数えてもらう。
  /// レコードは作られない。
  Future<void> _fetchRecipientCount() async {
    if (!_draft.isTargetValid) {
      setState(() {
        _draft.recipientCount = 0;
        _countError = null;
      });
      return;
    }

    setState(() {
      _isCounting = true;
      _countError = null;
    });

    try {
      final token = await SharedPrefs.fetchAccessToken();
      final url = Uri.parse(
          '${baseUri}notifications/notification/recipient_count/?token=$token');
      final response = await Future.any([
        http.post(
          url,
          headers: {
            "Authorization": 'JWT $token',
            "Content-Type": "application/json",
          },
          body: jsonEncode({
            'target_type': _draft.targetType,
            'membership_status': _draft.membershipStatus,
            if (_draft.targetCourseId != null)
              'target_course': _draft.targetCourseId,
          }),
        ),
        Future.delayed(const Duration(seconds: 15),
            () => throw TimeoutException("Request Timeout")),
      ]);

      if (!mounted) return;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _draft.recipientCount = data['recipient_count'] ?? 0;
          _isCounting = false;
        });
      } else {
        setState(() {
          _isCounting = false;
          _countError = 'Could not count recipients';
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isCounting = false;
        _countError = 'Could not count recipients';
      });
    }
  }

  void _selectTargetType(String value) {
    setState(() {
      _draft.targetType = value;
      if (value == 'all') {
        _draft.targetCourseId = null;
        _draft.targetCourseName = null;
      } else if (_draft.membershipStatus == 'none') {
        // コース指定と「メンバーシップなし」は両立しないので既定値に戻す
        _draft.membershipStatus = 'active';
      }
    });
    _fetchRecipientCount();
  }

  void _selectStatus(String value) {
    setState(() => _draft.membershipStatus = value);
    _fetchRecipientCount();
  }

  void _selectCourse(Map<String, dynamic> course) {
    setState(() {
      _draft.targetCourseId = course['id'];
      _draft.targetCourseName = course['course_name'];
    });
    _fetchRecipientCount();
  }

  Future<void> _goNext() async {
    final sent = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => StaffNotificationComposePage(draft: _draft),
      ),
    );
    // 送信が完了したら、この画面も閉じて一覧まで戻す
    if (sent == true && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canProceed =
        _draft.isTargetValid && !_isCounting && _draft.recipientCount > 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F2),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 22.h, 20.w, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 14.h),
              _buildStepBar(1),
              SizedBox(height: 20.h),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionLabel('WHO RECEIVES THIS'),
                      SizedBox(height: 10.h),
                      _buildTargetOption(
                        value: 'all',
                        title: 'All members',
                        description: 'Everyone registered in the app',
                      ),
                      SizedBox(height: 8.h),
                      _buildTargetOption(
                        value: 'course',
                        title: 'One course',
                        description: 'Only people tied to the course you pick',
                      ),
                      if (_draft.targetType == 'course') ...[
                        SizedBox(height: 12.h),
                        _buildCoursePicker(),
                      ],
                      SizedBox(height: 22.h),
                      _buildSectionLabel('NARROW BY MEMBERSHIP'),
                      SizedBox(height: 10.h),
                      _buildStatusChips(),
                      if (_draft.targetType == 'course') ...[
                        SizedBox(height: 12.h),
                        _buildHint(
                            '"No membership" cannot be combined with a single course.'),
                      ],
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
              _buildCountCard(),
              SizedBox(height: 12.h),
              _buildNextButton(canProceed),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(19.r),
            child: Container(
              width: 38.w,
              height: 38.w,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE4DFD8)),
              ),
              child: Icon(Icons.close, size: 16.sp, color: kColorTextDarkGrey),
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'New Message',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF212121),
              ),
            ),
            Text(
              'Step 1 of 3 · Recipients',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStepBar(int current) {
    return Row(
      children: List.generate(3, (i) {
        return Expanded(
          child: Container(
            height: 3.h,
            margin: EdgeInsets.only(right: i < 2 ? 5.w : 0),
            decoration: BoxDecoration(
              color: i < current ? kColorPrimary : const Color(0xFFE4DFD8),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF212121),
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildTargetOption({
    required String value,
    required String title,
    required String description,
  }) {
    final selected = _draft.targetType == value;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: () => _selectTargetType(value),
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: selected ? kColorPrimary : const Color(0xFFE4DFD8),
              width: selected ? 2 : 1,
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 13.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                size: 20.sp,
                color: selected ? kColorPrimary : Colors.grey,
              ),
              SizedBox(width: 11.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF212121),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: kColorTextDarkGrey,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoursePicker() {
    if (_isLoadingCourses) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          children: [
            SizedBox(
              width: 16.w,
              height: 16.w,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: kColorPrimary),
            ),
            SizedBox(width: 10.w),
            Text('Loading courses…',
                style: TextStyle(fontSize: 13.sp, color: kColorTextDarkGrey)),
          ],
        ),
      );
    }
    if (_courses.isEmpty) {
      return _buildHint('No courses available.');
    }
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: _courses.map((course) {
        final selected = _draft.targetCourseId == course['id'];
        return _buildChip(
          label: course['course_name'] ?? '',
          selected: selected,
          onTap: () => _selectCourse(course),
        );
      }).toList(),
    );
  }

  Widget _buildStatusChips() {
    // コース指定のときは「メンバーシップなし」を選べない
    final noneDisabled = _draft.targetType == 'course';
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: [
        _buildChip(
          label: 'Any status',
          selected: _draft.membershipStatus == 'all',
          onTap: () => _selectStatus('all'),
        ),
        _buildChip(
          label: 'Active',
          selected: _draft.membershipStatus == 'active',
          onTap: () => _selectStatus('active'),
        ),
        _buildChip(
          label: 'Expired',
          selected: _draft.membershipStatus == 'expired',
          onTap: () => _selectStatus('expired'),
        ),
        _buildChip(
          label: 'No membership',
          selected: _draft.membershipStatus == 'none',
          onTap: noneDisabled ? null : () => _selectStatus('none'),
          disabled: noneDisabled,
        ),
      ],
    );
  }

  Widget _buildChip({
    required String label,
    required bool selected,
    VoidCallback? onTap,
    bool disabled = false,
  }) {
    final Color bg = disabled
        ? const Color(0xFFF0ECE6)
        : (selected ? kColorPrimary : Colors.white);
    final Color border = disabled
        ? const Color(0xFFE4DFD8)
        : (selected ? kColorPrimary : const Color(0xFFE4DFD8));
    final Color fg = disabled
        ? Colors.grey.shade400
        : (selected ? Colors.white : kColorTextDarkGrey);

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(999.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999.r),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999.r),
            border: Border.all(color: border),
          ),
          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: fg,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline, size: 14.sp, color: Colors.grey),
        SizedBox(width: 7.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 12.sp, color: Colors.grey, height: 1.6),
          ),
        ),
      ],
    );
  }

  Widget _buildCountCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE4DFD8)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
      child: Row(
        children: [
          Icon(Icons.group_outlined, size: 18.sp, color: kColorPrimary),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              _countError ?? 'Reaches about',
              style: TextStyle(fontSize: 13.sp, color: kColorTextDarkGrey),
            ),
          ),
          if (_isCounting)
            SizedBox(
              width: 16.w,
              height: 16.w,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: kColorPrimary),
            )
          else if (_countError == null) ...[
            Text(
              '${_draft.recipientCount}',
              style: TextStyle(
                fontSize: 19.sp,
                fontWeight: FontWeight.w700,
                color: kColorPrimary,
              ),
            ),
            SizedBox(width: 5.w),
            Text('people',
                style: TextStyle(fontSize: 13.sp, color: kColorTextDarkGrey)),
          ],
        ],
      ),
    );
  }

  Widget _buildNextButton(bool enabled) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: enabled ? _goNext : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: kColorPrimary,
          disabledBackgroundColor: const Color(0xFFCFD8D4),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(vertical: 15.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Next',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(width: 8.w),
            Icon(Icons.arrow_forward_ios, size: 14.sp),
          ],
        ),
      ),
    );
  }
}
