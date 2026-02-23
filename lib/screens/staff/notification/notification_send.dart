import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wellbee/assets/inet.dart';
import 'package:wellbee/ui_function/shared_prefs.dart';
import 'package:wellbee/ui_parts/color.dart';
import 'package:http/http.dart' as http;

class NotificationSendPage extends StatefulWidget {
  const NotificationSendPage({Key? key}) : super(key: key);

  @override
  _NotificationSendPageState createState() => _NotificationSendPageState();
}

class _NotificationSendPageState extends State<NotificationSendPage> {
  List<dynamic> _settings = [];
  Map<String, dynamic>? _selectedSetting;
  List<dynamic> _targetUsers = [];
  int _targetCount = 0;
  bool _isLoadingSettings = true;
  bool _isLoadingPreview = false;
  bool _isSending = false;
  bool _previewLoaded = false;

  @override
  void initState() {
    super.initState();
    _fetchSettings();
  }

  Future<void> _fetchSettings() async {
    try {
      final token = await SharedPrefs.fetchStaffAccessToken();
      var url =
          Uri.parse('${baseUri}attendances/notification-settings/?token=$token');
      var response = await Future.any([
        http.get(url, headers: {
          "Authorization": 'JWT $token',
          "Content-Type": "application/json"
        }),
        Future.delayed(const Duration(seconds: 15),
            () => throw TimeoutException("Request timeout"))
      ]);
      if (response.statusCode == 200) {
        setState(() {
          _settings = jsonDecode(response.body) as List<dynamic>;
          _isLoadingSettings = false;
        });
      }
    } catch (e) {
      setState(() => _isLoadingSettings = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _fetchTargetUsers() async {
    if (_selectedSetting == null) return;
    setState(() {
      _isLoadingPreview = true;
      _previewLoaded = false;
    });

    try {
      final token = await SharedPrefs.fetchStaffAccessToken();
      final settingId = _selectedSetting!['id'];
      var url = Uri.parse(
          '${baseUri}attendances/notification-settings/$settingId/target-users/?token=$token');
      var response = await Future.any([
        http.get(url, headers: {
          "Authorization": 'JWT $token',
          "Content-Type": "application/json"
        }),
        Future.delayed(const Duration(seconds: 15),
            () => throw TimeoutException("Request timeout"))
      ]);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _targetUsers = data['target_users'] ?? [];
          _targetCount = data['total_count'] ?? 0;
          _isLoadingPreview = false;
          _previewLoaded = true;
        });
      }
    } catch (e) {
      setState(() => _isLoadingPreview = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _sendMessage() async {
    if (_selectedSetting == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Message'),
        content: Text(
            'Send message to $_targetCount users?\n\nThis will also send push notifications.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Send')),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isSending = true);
    try {
      final token = await SharedPrefs.fetchStaffAccessToken();
      final settingId = _selectedSetting!['id'];
      var url = Uri.parse(
          '${baseUri}attendances/notification-settings/$settingId/send/?token=$token');
      var response = await http.post(url, headers: {
        "Authorization": 'JWT $token',
        "Content-Type": "application/json"
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(data['message'] ?? 'Sent!')));
        setState(() {
          _previewLoaded = false;
          _targetUsers = [];
          _targetCount = 0;
        });
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Send failed.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Send Message',
            style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        backgroundColor: kColorPrimary,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: _isLoadingSettings
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step 1: Select setting
                  Text('1. Select Days Setting',
                      style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87)),
                  SizedBox(height: 12.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        isExpanded: true,
                        hint: const Text('Select a setting'),
                        value: _selectedSetting?['id'],
                        items: _settings.map<DropdownMenuItem<int>>((s) {
                          return DropdownMenuItem<int>(
                            value: s['id'],
                            child: Text(
                                '${s['days_before_expire']} days before'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedSetting = _settings
                                .firstWhere((s) => s['id'] == value);
                            _previewLoaded = false;
                            _targetUsers = [];
                            _targetCount = 0;
                          });
                        },
                      ),
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Step 2: Preview
                  Text('2. Preview Target Users',
                      style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87)),
                  SizedBox(height: 12.h),
                  SizedBox(
                    width: double.infinity,
                    height: 44.h,
                    child: ElevatedButton(
                      onPressed: _selectedSetting == null || _isLoadingPreview
                          ? null
                          : _fetchTargetUsers,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kColorPrimaryThin,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r)),
                      ),
                      child: _isLoadingPreview
                          ? SizedBox(
                              width: 20.w,
                              height: 20.w,
                              child: const CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : Text('Check Target Users',
                              style: TextStyle(
                                  fontSize: 16.sp, color: Colors.white)),
                    ),
                  ),

                  if (_previewLoaded) ...[
                    SizedBox(height: 16.h),
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Target: $_targetCount users',
                              style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: kColorPrimary)),
                          if (_targetUsers.isNotEmpty) ...[
                            SizedBox(height: 12.h),
                            ..._targetUsers.map((u) => Padding(
                                  padding: EdgeInsets.only(bottom: 8.h),
                                  child: Row(
                                    children: [
                                      Icon(Icons.person_outline,
                                          size: 18.sp,
                                          color: Colors.grey[600]),
                                      SizedBox(width: 8.w),
                                      Expanded(
                                        child: Text(
                                          '${u['attendee_name']} - ${u['course_name']} (${u['expire_day']})',
                                          style: TextStyle(
                                              fontSize: 14.sp,
                                              color: Colors.black87),
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                          ],
                          if (_targetUsers.isEmpty)
                            Padding(
                              padding: EdgeInsets.only(top: 8.h),
                              child: Text('No target users found.',
                                  style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.grey[600])),
                            ),
                        ],
                      ),
                    ),
                  ],

                  SizedBox(height: 24.h),

                  // Step 3: Message preview
                  if (_selectedSetting != null) ...[
                    Text('3. Message Preview',
                        style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                    SizedBox(height: 12.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Color(0xFFF0FAF7),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: kColorPrimary.withOpacity(0.3)),
                      ),
                      child: Text(
                        _selectedSetting!['message'] ?? '',
                        style: TextStyle(fontSize: 15.sp, height: 1.5),
                      ),
                    ),
                  ],

                  SizedBox(height: 32.h),

                  // Step 4: Send
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed:
                          (_previewLoaded && _targetCount > 0 && !_isSending)
                              ? _sendMessage
                              : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kColorPrimary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r)),
                      ),
                      child: _isSending
                          ? const CircularProgressIndicator(
                              color: Colors.white)
                          : Text('Send to $_targetCount users',
                              style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
