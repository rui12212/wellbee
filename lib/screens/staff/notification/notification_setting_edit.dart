import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wellbee/assets/inet.dart';
import 'package:wellbee/ui_function/shared_prefs.dart';
import 'package:wellbee/ui_parts/color.dart';
import 'package:http/http.dart' as http;

class NotificationSettingEditPage extends StatefulWidget {
  final int? settingId;
  final int? daysBeforeExpire;
  final String? message;
  final bool? isActive;

  const NotificationSettingEditPage({
    Key? key,
    this.settingId,
    this.daysBeforeExpire,
    this.message,
    this.isActive,
  }) : super(key: key);

  @override
  _NotificationSettingEditPageState createState() =>
      _NotificationSettingEditPageState();
}

class _NotificationSettingEditPageState
    extends State<NotificationSettingEditPage> {
  final TextEditingController _daysController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  bool _isActive = true;
  bool _isLoading = false;

  bool get _isEditing => widget.settingId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _daysController.text = widget.daysBeforeExpire.toString();
      _messageController.text = widget.message ?? '';
      _isActive = widget.isActive ?? true;
    }
  }

  @override
  void dispose() {
    _daysController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_daysController.text.isEmpty || _messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all fields.')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final token = await SharedPrefs.fetchStaffAccessToken();
      final body = jsonEncode({
        'days_before_expire': int.parse(_daysController.text),
        'message': _messageController.text,
        'is_active': _isActive,
      });

      http.Response response;
      if (_isEditing) {
        var url = Uri.parse(
            '${baseUri}attendances/notification-settings/${widget.settingId}/?token=$token');
        response = await http.patch(url,
            headers: {
              "Authorization": 'JWT $token',
              "Content-Type": "application/json"
            },
            body: body);
      } else {
        var url = Uri.parse(
            '${baseUri}attendances/notification-settings/?token=$token');
        response = await http.post(url,
            headers: {
              "Authorization": 'JWT $token',
              "Content-Type": "application/json"
            },
            body: body);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Saved successfully.')));
        Navigator.of(context).pop();
      } else {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${data.toString()}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Setting'),
        content: const Text('Are you sure you want to delete this setting?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      final token = await SharedPrefs.fetchStaffAccessToken();
      var url = Uri.parse(
          '${baseUri}attendances/notification-settings/${widget.settingId}/?token=$token');
      var response = await http.delete(url, headers: {
        "Authorization": 'JWT $token',
        "Content-Type": "application/json"
      });
      if (response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Deleted successfully.')));
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Delete failed.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Setting' : 'New Setting',
            style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        backgroundColor: kColorPrimary,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: _isEditing
            ? [
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.white),
                  onPressed: _isLoading ? null : _delete,
                ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Days Before Expiry',
                style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87)),
            SizedBox(height: 8.h),
            TextField(
              controller: _daysController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'e.g. 30',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r)),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              ),
            ),
            SizedBox(height: 24.h),
            Text('Message',
                style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87)),
            SizedBox(height: 8.h),
            TextField(
              controller: _messageController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Enter the notification message',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r)),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              ),
            ),
            SizedBox(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Active',
                    style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87)),
                Switch(
                  value: _isActive,
                  activeColor: kColorPrimary,
                  onChanged: (value) => setState(() => _isActive = value),
                ),
              ],
            ),
            SizedBox(height: 32.h),
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kColorPrimary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text('Save',
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
