import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:wellbee/assets/inet.dart';
import 'package:wellbee/ui_function/shared_prefs.dart';
import 'package:wellbee/ui_parts/images.dart';
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
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}

class DeletedCoursesPage extends StatefulWidget {
  const DeletedCoursesPage({Key? key}) : super(key: key);

  @override
  State<DeletedCoursesPage> createState() => _DeletedCoursesPageState();
}

class _DeletedCoursesPageState extends State<DeletedCoursesPage> {
  String? _token;
  bool _isLoading = false;
  List<dynamic> _deletedCourses = [];

  @override
  void initState() {
    super.initState();
    _loadDeletedCourses();
  }

  void _showSnackBar(Color color, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: color, content: Text(text)),
    );
  }

  Future<void> _ensureToken() async {
    _token ??= await SharedPrefs.fetchStaffAccessToken();
  }

  Future<void> _loadDeletedCourses() async {
    setState(() => _isLoading = true);
    try {
      await _ensureToken();
      final url = Uri.parse(
          '${baseUri}attendances/course/deleted_courses/?token=$_token');
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
        setState(() => _deletedCourses = data);
      } else {
        _showSnackBar(Colors.red,
            'Failed to fetch deleted courses (${response.statusCode})');
      }
    } catch (e) {
      _showSnackBar(Colors.red, 'Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _restoreCourse(int courseId) async {
    try {
      await _ensureToken();
      final url = Uri.parse(
          '${baseUri}attendances/course/$courseId/restore/?token=$_token');
      final response = await Future.any([
        http.patch(
          url,
          headers: {
            'Authorization': 'JWT $_token',
            'Content-Type': 'application/json',
          },
        ),
        Future.delayed(const Duration(seconds: 15),
            () => throw TimeoutException('Request timeout')),
      ]);
      if (response.statusCode == 200) {
        _showSnackBar(Colors.green, 'Course restored successfully');
        _loadDeletedCourses();
      } else {
        _showSnackBar(
            Colors.red, 'Failed to restore course (${response.statusCode})');
      }
    } catch (e) {
      _showSnackBar(Colors.red, 'Error: $e');
    }
  }

  Future<void> _hardDeleteCourse(int courseId) async {
    try {
      await _ensureToken();
      final url = Uri.parse(
          '${baseUri}attendances/course/$courseId/hard_delete/?token=$_token');
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
        _showSnackBar(Colors.green, 'Course permanently deleted');
        _loadDeletedCourses();
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
                    Chip(
                      label: Text(isPrivate ? 'Private' : 'Public'),
                      backgroundColor: isPrivate
                          ? Colors.orange.withOpacity(0.15)
                          : Colors.blue.withOpacity(0.15),
                    ),
                    SizedBox(height: 8.h),
                  ],
                ),
              ),
            ]),
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () async {
                      final result = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Confirm Restore'),
                          content: const Text(
                              'Are you sure you want to restore this course?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              style: TextButton.styleFrom(
                                  foregroundColor: Colors.green),
                              child: const Text('Restore'),
                            ),
                          ],
                        ),
                      );
                      if (result == true) {
                        _restoreCourse(courseId);
                      }
                    },
                    icon: const Icon(Icons.restore, color: Colors.green),
                    label: const Text('Restore',
                        style: TextStyle(color: Colors.green)),
                  ),
                ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () async {
                      final result = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Confirm Permanent Delete'),
                          content: const Text(
                              'Are you sure you want to permanently delete this course? This action cannot be undone.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              style: TextButton.styleFrom(
                                  foregroundColor: Colors.red),
                              child: const Text('Delete Permanently'),
                            ),
                          ],
                        ),
                      );
                      if (result == true) {
                        _hardDeleteCourse(courseId);
                      }
                    },
                    icon: const Icon(Icons.delete_forever, color: Colors.red),
                    label: const Text('Delete Permanently',
                        style: TextStyle(color: Colors.red)),
                  ),
                ),
              ],
            )
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
              child: const _Header(title: 'Deleted Courses'),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _deletedCourses.isEmpty
                      ? const Center(child: Text('No deleted courses'))
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          itemBuilder: (context, index) {
                            final course =
                                _deletedCourses[index] as Map<String, dynamic>;
                            return _buildCourseCard(course);
                          },
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemCount: _deletedCourses.length,
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
