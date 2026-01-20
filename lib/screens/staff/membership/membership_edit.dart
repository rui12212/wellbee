import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:wellbee/assets/inet.dart';
import 'package:wellbee/ui_parts/color.dart';
import 'package:wellbee/ui_function/shared_prefs.dart';
import 'package:http/http.dart' as http;

class _Header extends StatelessWidget {
  final String title;
  final String subtitle;

  const _Header({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90.h,
      child: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style:
                        TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shape: const CircleBorder(
                          side: BorderSide(
                              color: Color.fromARGB(255, 206, 204, 204),
                              width: 5))),
                  child: const Icon(Icons.chevron_left,
                      color: Color.fromARGB(255, 155, 152, 152)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              subtitle,
              style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w300,
                  color: kColorTextDarkGrey),
            ),
          )
        ],
      ),
    );
  }
}

class MembershipEditPage extends StatefulWidget {
  final Map<String, dynamic> membership;

  const MembershipEditPage({Key? key, required this.membership})
      : super(key: key);

  @override
  _MembershipEditPageState createState() => _MembershipEditPageState();
}

class _MembershipEditPageState extends State<MembershipEditPage> {
  String? token = '';
  bool isLoading = false;
  List<Map<String, dynamic>> courseList = [];

  // Editable fields
  int? selectedCourseId;
  int? selectedDuration;
  int? maxJoinTimes;
  int? requestedJoinTimes;
  int? alreadyJoinTimes;
  DateTime? startDay;
  DateTime? expireDay;
  bool isExpired = false;
  DateTime? lastCheckIn;

  // Duration options
  final List<Map<String, dynamic>> durationOptions = [
    {'value': 1, 'label': '1 month'},
    {'value': 2, 'label': '2 months'},
    {'value': 3, 'label': '3 months'},
    {'value': 6, 'label': '6 months'},
    {'value': 12, 'label': '1 year'},
  ];

  @override
  void initState() {
    super.initState();
    _initializeFields();
    _fetchCourses();
  }

  void _initializeFields() {
    final m = widget.membership;
    selectedCourseId = m['course'];
    selectedDuration = m['duration'];
    maxJoinTimes = m['max_join_times'];
    requestedJoinTimes = m['requested_join_times'];
    alreadyJoinTimes = m['already_join_times'];
    isExpired = m['is_expired'] ?? false;

    if (m['start_day'] != null) {
      startDay = DateTime.parse(m['start_day']);
    }
    if (m['expire_day'] != null) {
      expireDay = DateTime.parse(m['expire_day']);
    }
    if (m['last_check_in'] != null) {
      lastCheckIn = DateTime.parse(m['last_check_in']);
    }
  }

  Future<void> _fetchCourses() async {
    try {
      token = await SharedPrefs.fetchStaffAccessToken();
      var url = Uri.parse('${baseUri}attendances/course/all_course');
      var response = await http.get(url, headers: {
        "Authorization": 'JWT $token',
        "Content-Type": "application/json"
      });
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          courseList = data.cast<Map<String, dynamic>>();
        });
      }
    } catch (e) {
      debugPrint('Error fetching courses: $e');
    }
  }

  Future<void> _updateMembership() async {
    setState(() {
      isLoading = true;
    });

    try {
      token = await SharedPrefs.fetchStaffAccessToken();
      final membershipId = widget.membership['id'];
      var url = Uri.parse('${baseUri}attendances/membership/$membershipId/edit/');

      Map<String, dynamic> data = {
        'course': selectedCourseId,
        'duration': selectedDuration,
        'max_join_times': maxJoinTimes,
        'requested_join_times': requestedJoinTimes,
        'already_join_times': alreadyJoinTimes,
        'is_expired': isExpired,
      };

      if (startDay != null) {
        data['start_day'] = DateFormat('yyyy-MM-dd').format(startDay!);
      }
      if (expireDay != null) {
        data['expire_day'] = DateFormat('yyyy-MM-dd').format(expireDay!);
      }
      if (lastCheckIn != null) {
        data['last_check_in'] = DateFormat('yyyy-MM-dd').format(lastCheckIn!);
      }

      var response = await Future.any([
        http.patch(
          url,
          headers: {
            "Authorization": 'JWT $token',
            "Content-Type": "application/json"
          },
          body: jsonEncode(data),
        ),
        Future.delayed(const Duration(seconds: 15),
            () => throw TimeoutException("Request timeout"))
      ]);

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Membership updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update: ${response.body}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _selectDate(
      BuildContext context, DateTime? initialDate, Function(DateTime) onSelect) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      onSelect(picked);
    }
  }

  void _showConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Changes'),
        content: const Text('Are you sure you want to save these changes?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _updateMembership();
            },
            style: ElevatedButton.styleFrom(backgroundColor: kColorPrimary),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.membership;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: _Header(
                title: m['attendee_name'] ?? 'Unknown',
                subtitle: m['course_name'] ?? '',
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Read-only Section
                    _buildSectionHeader('Read-only Information'),
                    _buildReadOnlyCard(m),
                    SizedBox(height: 20.h),

                    // Editable Section
                    _buildSectionHeader('Editable Fields'),
                    _buildEditableCard(),
                    SizedBox(height: 30.h),
                  ],
                ),
              ),
            ),
            // Save Button
            Container(
              padding: EdgeInsets.all(20.w),
              child: SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _showConfirmDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kColorPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: kColorPrimary,
        ),
      ),
    );
  }

  Widget _buildReadOnlyCard(Map<String, dynamic> m) {
    return Card(
      elevation: 1,
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            _buildReadOnlyRow('Membership ID', m['id']?.toString() ?? 'N/A'),
            _buildReadOnlyRow('User Phone', m['user_phone'] ?? 'N/A'),
            _buildReadOnlyRow('Times/Week', m['times']?.toString() ?? 'N/A'),
            _buildReadOnlyRow('Num Person', m['num_person']?.toString() ?? 'N/A'),
            _buildReadOnlyRow('Is Approved', m['is_approved'] == true ? 'Yes' : 'No'),
            _buildReadOnlyRow('Total Price', m['total_price']?.toString() ?? 'N/A'),
            _buildReadOnlyRow('Discount Rate', '${((1 - (m['discount_rate'] ?? 1)) * 100).toInt()}% OFF'),
            _buildReadOnlyRow('Offer', m['offer']?.toString() ?? '0'),
            _buildReadOnlyRow('Minus (Points)', m['minus']?.toString() ?? '0'),
            _buildReadOnlyRow('Discounted Price', m['discounted_total_price']?.toString() ?? 'N/A'),
            _buildReadOnlyRow('Request Time', m['request_time']?.toString().substring(0, 10) ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course dropdown
            _buildLabel('Course'),
            DropdownButtonFormField<int>(
              value: selectedCourseId,
              decoration: _inputDecoration(),
              items: courseList.map((course) {
                return DropdownMenuItem<int>(
                  value: course['id'],
                  child: Text(course['course_name'] ?? ''),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCourseId = value;
                });
              },
            ),
            SizedBox(height: 16.h),

            // Duration dropdown
            _buildLabel('Duration'),
            DropdownButtonFormField<int>(
              value: selectedDuration,
              decoration: _inputDecoration(),
              items: durationOptions.map((option) {
                return DropdownMenuItem<int>(
                  value: option['value'],
                  child: Text(option['label']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedDuration = value;
                });
              },
            ),
            SizedBox(height: 16.h),

            // Max Join Times
            _buildLabel('Max Join Times'),
            TextFormField(
              initialValue: maxJoinTimes?.toString() ?? '',
              decoration: _inputDecoration(),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                maxJoinTimes = int.tryParse(value);
              },
            ),
            SizedBox(height: 16.h),

            // Requested Join Times
            _buildLabel('Requested Join Times'),
            TextFormField(
              initialValue: requestedJoinTimes?.toString() ?? '',
              decoration: _inputDecoration(),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                requestedJoinTimes = int.tryParse(value);
              },
            ),
            SizedBox(height: 16.h),

            // Already Join Times
            _buildLabel('Already Join Times'),
            TextFormField(
              initialValue: alreadyJoinTimes?.toString() ?? '',
              decoration: _inputDecoration(),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                alreadyJoinTimes = int.tryParse(value);
              },
            ),
            SizedBox(height: 16.h),

            // Start Day
            _buildLabel('Start Day'),
            _buildDatePicker(
              startDay,
              (date) => setState(() => startDay = date),
            ),
            SizedBox(height: 16.h),

            // Expire Day
            _buildLabel('Expire Day'),
            _buildDatePicker(
              expireDay,
              (date) => setState(() => expireDay = date),
            ),
            SizedBox(height: 16.h),

            // Last Check In
            _buildLabel('Last Check In'),
            _buildDatePicker(
              lastCheckIn,
              (date) => setState(() => lastCheckIn = date),
            ),
            SizedBox(height: 16.h),

            // Is Expired Switch
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Is Expired',
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
                ),
                Switch(
                  value: isExpired,
                  activeColor: kColorPrimary,
                  onChanged: (value) {
                    setState(() {
                      isExpired = value;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        text,
        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
    );
  }

  Widget _buildDatePicker(DateTime? date, Function(DateTime) onSelect) {
    return InkWell(
      onTap: () => _selectDate(context, date, onSelect),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date != null
                  ? DateFormat('yyyy-MM-dd').format(date)
                  : 'Select date',
              style: TextStyle(
                fontSize: 14.sp,
                color: date != null ? Colors.black : Colors.grey,
              ),
            ),
            Icon(Icons.calendar_today, size: 20.sp, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
