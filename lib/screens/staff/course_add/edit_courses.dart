import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:wellbee/assets/inet.dart';
import 'package:wellbee/screens/staff/auth/staff_top_page.dart';
import 'package:wellbee/screens/staff/course_add/deleted_courses.dart';
import 'package:wellbee/ui_function/shared_prefs.dart';
import 'package:wellbee/ui_parts/course_image.dart';

class _Header extends StatelessWidget {
  final String title;
  const _Header({required this.title});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50.h,
      child: Row(
        children: [
          Text(title,
              style: TextStyle(fontSize: 30.sp, fontWeight: FontWeight.bold)),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            color: Colors.grey,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const DeletedCoursesPage(),
                ),
              );
            },
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.transparent,
              shape: const CircleBorder(
                side: BorderSide(
                  color: Color.fromARGB(255, 206, 204, 204),
                  width: 5,
                ),
              ),
            ),
            child: const Icon(
              Icons.chevron_left,
              color: Color.fromARGB(255, 155, 152, 152),
            ),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => StaffTopPage(0)),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}

class EditCoursesPage extends StatefulWidget {
  const EditCoursesPage({Key? key}) : super(key: key);

  @override
  State<EditCoursesPage> createState() => _EditCoursesPageState();
}

class _EditCoursesPageState extends State<EditCoursesPage> {
  final TextEditingController _courseNameController = TextEditingController();
  bool _newIsOpen = true;
  bool _newIsPrivate = false;

  String? _token;
  bool _isLoading = false;
  List<dynamic> _courses = [];

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  void _showSnackBar(Color color, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: color, content: Text(text)),
    );
  }

  Future<void> _ensureToken() async {
    _token ??= await SharedPrefs.fetchStaffAccessToken();
  }

  Future<void> _loadCourses() async {
    setState(() => _isLoading = true);
    try {
      await _ensureToken();
      final url =
          Uri.parse('${baseUri}attendances/course/all_course/?token=$_token');
      final response = await Future.any([
        http.get(url, headers: {
          'Authorization': 'JWT $_token',
          'Content-Type': 'application/json',
        }),
        Future.delayed(const Duration(seconds: 15),
            () => throw TimeoutException('Request timeout')),
      ]);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        setState(() => _courses = data);
      } else {
        _showSnackBar(
            Colors.red, 'Failed to fetch courses (${response.statusCode})');
      }
    } catch (e) {
      _showSnackBar(Colors.red, 'Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _addCourse() async {
    final name = _courseNameController.text.trim();
    if (name.isEmpty) {
      _showSnackBar(Colors.red, 'Please enter a course name');
      return;
    }
    try {
      await _ensureToken();
      final url = Uri.parse('${baseUri}attendances/course/?token=$_token');
      final response = await Future.any([
        http.post(
          url,
          headers: {
            'Authorization': 'JWT $_token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'course_name': name,
            'is_open': _newIsOpen,
            'is_private': _newIsPrivate,
          }),
        ),
        Future.delayed(const Duration(seconds: 15),
            () => throw TimeoutException('Request timeout')),
      ]);
      if (response.statusCode == 201) {
        _courseNameController.clear();
        _showSnackBar(Colors.green, 'Course added successfully');
        _loadCourses();
      } else {
        _showSnackBar(
            Colors.red, 'Failed to add course (${response.statusCode})');
      }
    } catch (e) {
      _showSnackBar(Colors.red, 'Error: $e');
    }
  }

  Future<void> _deleteCourse(int courseId) async {
    try {
      await _ensureToken();
      final url =
          Uri.parse('${baseUri}attendances/course/$courseId/?token=$_token');
      final response = await Future.any([
        http.delete(
          url,
          headers: {
            'Authorization': 'JWT $_token',
            'Content-Type': 'application/json',
          },
        ),
        Future.delayed(const Duration(seconds: 15),
            () => throw TimeoutException('Request timeout')),
      ]);
      if (response.statusCode == 204) {
        _showSnackBar(Colors.green, 'Course deleted (hidden) successfully');
        _loadCourses();
      } else {
        _showSnackBar(
            Colors.red, 'Failed to delete course (${response.statusCode})');
      }
    } catch (e) {
      _showSnackBar(Colors.red, 'Error: $e');
    }
  }

  Widget _buildCourseCard(Map<String, dynamic> course) {
    final courseId = course['id'] as int;
    final name = course['course_name'] as String? ?? '';
    final isOpen = course['is_open'] as bool? ?? false;
    final isPrivate = course['is_private'] as bool? ?? false;
    final imageUrl = course['image_url'] as String?;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(children: [
              Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xFFEFEFEF),
                ),
                clipBehavior: Clip.antiAlias,
                child: buildCourseImage(imageUrl, name),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: TextStyle(
                            fontSize: 18.sp, fontWeight: FontWeight.bold)),
                    SizedBox(height: 6.h),
                    Wrap(
                      spacing: 8,
                      children: [
                        Chip(
                          label: Text(isOpen ? 'Open' : 'Closed'),
                          backgroundColor: isOpen
                              ? Colors.green.withOpacity(0.15)
                              : Colors.grey.withOpacity(0.2),
                        ),
                        Chip(
                          label: Text(isPrivate ? 'Private' : 'Public'),
                          backgroundColor: isPrivate
                              ? Colors.orange.withOpacity(0.15)
                              : Colors.blue.withOpacity(0.15),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                  ],
                ),
              ),
            ]),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () async {
                    final result = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Confirm Delete'),
                        content: const Text(
                            'Are you sure you want to delete this course?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: TextButton.styleFrom(
                                foregroundColor: Colors.red),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                    if (result == true) {
                      _deleteCourse(courseId);
                    }
                  },
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label:
                      const Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add New Course',
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 12.h),
            TextField(
              controller: _courseNameController,
              decoration: const InputDecoration(
                labelText: 'Course name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Open', style: TextStyle(fontSize: 18.w)),
                    value: _newIsOpen,
                    onChanged: (v) => setState(() => _newIsOpen = v),
                  ),
                ),
                Expanded(
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Private', style: TextStyle(fontSize: 16.w)),
                    value: _newIsPrivate,
                    onChanged: (v) => setState(() => _newIsPrivate = v),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _addCourse,
                icon: const Icon(Icons.add),
                label: const Text('Add Course'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15),
              child: const _Header(title: 'Course Edit'),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: [
                    SizedBox(height: 8.h),
                    _buildForm(),
                    SizedBox(height: 8.h),
                    _isLoading
                        ? const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : _courses.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Center(child: Text('No courses yet')),
                              )
                            : Column(
                                children: [
                                  ...List.generate(
                                    _courses.length,
                                    (index) {
                                      final course = _courses[index]
                                          as Map<String, dynamic>;
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8),
                                        child: _buildCourseCard(course),
                                      );
                                    },
                                  ),
                                ],
                              ),
                    SizedBox(height: 8.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
