import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:wellbee/ui_parts/color.dart';
import 'package:wellbee/ui_parts/textstyle.dart';
import '../../../assets/inet.dart';
import '../../../ui_function/shared_prefs.dart';
import '../../../ui_parts/show_dialogue.dart';

class AddStaffUserPage extends StatefulWidget {
  const AddStaffUserPage({super.key});

  @override
  State<AddStaffUserPage> createState() => _AddStaffUserPageState();
}

class _AddStaffUserPageState extends State<AddStaffUserPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  String _fullPhoneNumber = '';
  bool _isLoading = false;
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadToken() async {
    _token = await SharedPrefs.fetchStaffAccessToken();
  }

  Future<void> _createStaffUser() async {
    final phoneNumber = _fullPhoneNumber;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (phoneNumber.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match.')),
      );
      return;
    }

    if (password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Password must be at least 8 characters.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    await DialogGenerator.showLoadingDialog(context: context);

    try {
      final url = Uri.parse(
          '${baseUri}accounts/staff/create/?token=$_token');
      final response = await Future.any([
        http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'JWT $_token',
          },
          body: jsonEncode({
            'phone_number': phoneNumber,
            'password': password,
            'is_staff': true,
            'is_active': true,
          }),
        ),
        Future.delayed(
          const Duration(seconds: 15),
          () => throw TimeoutException('Request timeout'),
        ),
      ]);

      if (!mounted) return;
      Navigator.pop(context);

      if (response.statusCode == 201) {
        _phoneController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();
        setState(() => _fullPhoneNumber = '');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Staff user created successfully.')),
        );
      } else {
        final body = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  body['error'] as String? ?? 'Failed to create staff user.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton(
                style:
                    TextButton.styleFrom(backgroundColor: Colors.transparent),
                onPressed: () => Navigator.of(context).pop(),
                child: const Icon(Icons.chevron_left),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add Staff User',
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Creates a new staff account with full access.',
                      style:
                          TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 32.h),
                    CustomTextBox(
                      label: 'Phone Number',
                      hintText: '7501234567',
                      controller: _phoneController,
                    ).phoneFieldDecoration(
                      onPhoneChanged: (number) =>
                          setState(() => _fullPhoneNumber = number),
                    ),
                    SizedBox(height: 16.h),
                    PasswordCustomTextBox(
                      label: 'Password',
                      hintText: 'Enter password',
                      controller: _passwordController,
                      isPassword: true,
                      inputType: TextInputType.text,
                    ),
                    SizedBox(height: 16.h),
                    PasswordCustomTextBox(
                      label: 'Confirm Password',
                      hintText: 'Re-enter password',
                      controller: _confirmPasswordController,
                      isPassword: true,
                      inputType: TextInputType.text,
                    ),
                    SizedBox(height: 32.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _createStaffUser,
                        child: Text(
                          'Create Staff User',
                          style: TextStyle(
                            color: kColorPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 32.h),
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
