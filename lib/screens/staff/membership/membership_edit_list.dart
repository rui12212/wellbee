import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wellbee/assets/inet.dart';
import 'package:wellbee/screens/staff/membership/membership_edit.dart';
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
                Text(
                  title,
                  style:
                      TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold),
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

class MembershipEditListPage extends StatefulWidget {
  const MembershipEditListPage({Key? key}) : super(key: key);

  @override
  _MembershipEditListPageState createState() => _MembershipEditListPageState();
}

class _MembershipEditListPageState extends State<MembershipEditListPage> {
  String? token = '';
  List<dynamic> allMemberships = [];
  List<dynamic> filteredMemberships = [];
  bool isLoading = true;

  // Filter states
  String attendeeNameQuery = '';
  String phoneNumberQuery = '';
  String? selectedCourse;
  List<String> courseList = [];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAllMembership();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _fetchAllMembership() async {
    try {
      token = await SharedPrefs.fetchStaffAccessToken();
      var url = Uri.parse(
          '${baseUri}attendances/membership/all_available_membership?token=$token');
      var response = await Future.any([
        http.get(url, headers: {
          "Authorization": 'JWT $token',
          "Content-Type": "application/json"
        }),
        Future.delayed(const Duration(seconds: 15),
            () => throw TimeoutException("Request timeout"))
      ]);
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          allMemberships = data;
          filteredMemberships = data;
          isLoading = false;
          // Extract unique course names
          courseList = data
              .map((m) => m['course_name']?.toString() ?? '')
              .where((name) => name.isNotEmpty)
              .toSet()
              .toList();
          courseList.sort();
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to fetch memberships')));
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _applyFilters() {
    setState(() {
      filteredMemberships = allMemberships.where((m) {
        bool matchCourse = selectedCourse == null ||
            selectedCourse == 'All' ||
            m['course_name'] == selectedCourse;
        bool matchName = attendeeNameQuery.isEmpty ||
            (m['attendee_name']?.toString().toLowerCase() ?? '')
                .contains(attendeeNameQuery.toLowerCase());
        bool matchPhone = phoneNumberQuery.isEmpty ||
            (m['user_phone']?.toString() ?? '').contains(phoneNumberQuery);
        return matchCourse && matchName && matchPhone;
      }).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      attendeeNameQuery = '';
      phoneNumberQuery = '';
      selectedCourse = null;
      _nameController.clear();
      _phoneController.clear();
      filteredMemberships = allMemberships;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              _Header(
                title: 'Edit Membership',
                subtitle: 'Select membership to edit',
              ),
              // Filter Section
              _buildFilterSection(),
              SizedBox(height: 10.h),
              // Results count
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${filteredMemberships.length} memberships found',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              // Membership List
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredMemberships.isEmpty
                        ? Center(
                            child: Text(
                              'No memberships found',
                              style: TextStyle(fontSize: 18.sp),
                            ),
                          )
                        : ListView.builder(
                            itemCount: filteredMemberships.length,
                            itemBuilder: (context, index) {
                              final membership = filteredMemberships[index];
                              return _buildMembershipCard(membership);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          // Course dropdown
          DropdownButtonFormField<String>(
            value: selectedCourse,
            decoration: InputDecoration(
              labelText: 'Course',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            ),
            items: [
              const DropdownMenuItem(value: 'All', child: Text('All Courses')),
              ...courseList.map((course) => DropdownMenuItem(
                    value: course,
                    child: Text(course),
                  )),
            ],
            onChanged: (value) {
              selectedCourse = value;
              _applyFilters();
            },
          ),
          SizedBox(height: 10.h),
          // Name search
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Attendee Name',
              prefixIcon: const Icon(Icons.person_search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            ),
            onChanged: (value) {
              attendeeNameQuery = value;
              _applyFilters();
            },
          ),
          SizedBox(height: 10.h),
          // Phone search
          TextField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              prefixIcon: const Icon(Icons.phone),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            ),
            keyboardType: TextInputType.phone,
            onChanged: (value) {
              phoneNumberQuery = value;
              _applyFilters();
            },
          ),
          SizedBox(height: 10.h),
          // Clear button
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _clearFilters,
              icon: const Icon(Icons.clear, size: 18),
              label: const Text('Clear Filters'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembershipCard(Map<String, dynamic> membership) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 12.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        onTap: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => MembershipEditPage(membership: membership),
            ),
          );
          // Refresh list if edit was successful
          if (result == true) {
            _fetchAllMembership();
          }
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Attendee name and course
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      membership['attendee_name'] ?? 'Unknown',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: kColorPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      membership['course_name'] ?? '',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: kColorPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              // Phone number
              Row(
                children: [
                  Icon(Icons.phone, size: 16.sp, color: Colors.grey[600]),
                  SizedBox(width: 6.w),
                  Text(
                    membership['user_phone'] ?? 'No phone',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              // Expire day and join times
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 16.sp, color: Colors.grey[600]),
                      SizedBox(width: 6.w),
                      Text(
                        'Expires: ${membership['expire_day'] ?? 'N/A'}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${membership['already_join_times'] ?? 0}/${membership['max_join_times'] ?? 0} times',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: kColorPrimary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              // Edit indicator
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Tap to edit',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[500],
                      ),
                    ),
                    Icon(Icons.chevron_right,
                        size: 18.sp, color: Colors.grey[500]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
