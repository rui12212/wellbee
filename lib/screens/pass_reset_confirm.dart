import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:wellbee/ui_parts/color.dart';
import 'package:wellbee/ui_parts/textstyle.dart';
import '../assets/inet.dart';
import '../ui_parts/show_dialogue.dart';

class PassResetConfirmPage extends StatefulWidget {
  final String resetToken;

  const PassResetConfirmPage({
    super.key,
    required this.resetToken,
  });

  @override
  State<PassResetConfirmPage> createState() => _PassResetConfirmPageState();
}

class _PassResetConfirmPageState extends State<PassResetConfirmPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (password.isEmpty || confirmPassword.isEmpty) {
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
        const SnackBar(content: Text('Password must be at least 8 characters.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    await DialogGenerator.showLoadingDialog(context: context);

    try {
      final url = Uri.parse('${baseUri}accounts/password-reset/confirm/');
      final response = await Future.any([
        http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'reset_token': widget.resetToken,
            'new_password': password,
            'confirm_password': confirmPassword,
          }),
        ),
        Future.delayed(
          const Duration(seconds: 15),
          () => throw TimeoutException('Request timeout'),
        ),
      ]);

      if (!mounted) return;
      Navigator.pop(context);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset successfully.')),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        final body = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(body['error'] as String? ?? 'Failed to reset password.')),
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
                style: TextButton.styleFrom(backgroundColor: Colors.transparent),
                onPressed: () => Navigator.of(context).pop(),
                child: const Icon(Icons.chevron_left),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Set New Password',
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Enter your new password below.',
                      style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 32.h),
                    PasswordCustomTextBox(
                      label: 'New Password',
                      hintText: 'Enter new password',
                      controller: _passwordController,
                      isPassword: true,
                      inputType: TextInputType.text,
                    ),
                    SizedBox(height: 16.h),
                    PasswordCustomTextBox(
                      label: 'Confirm Password',
                      hintText: 'Re-enter new password',
                      controller: _confirmPasswordController,
                      isPassword: true,
                      inputType: TextInputType.text,
                    ),
                    SizedBox(height: 32.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _resetPassword,
                        child: Text(
                          'Reset Password',
                          style: TextStyle(
                            color: kColorPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
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
}
