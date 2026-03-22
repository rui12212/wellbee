import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:http/http.dart' as http;
import 'package:wellbee/ui_parts/color.dart';
import '../assets/inet.dart';
import '../ui_parts/show_dialogue.dart';
import 'pass_reset_otp.dart';

class PassResetRequestPage extends StatefulWidget {
  const PassResetRequestPage({super.key});

  @override
  State<PassResetRequestPage> createState() => _PassResetRequestPageState();
}

class _PassResetRequestPageState extends State<PassResetRequestPage> {
  final TextEditingController _phoneController = TextEditingController();
  String _countryCode = '+964';
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final phoneNumber = _phoneController.text.trim();
    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your phone number.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    await DialogGenerator.showLoadingDialog(context: context);

    try {
      final url = Uri.parse('${baseUri}accounts/password-reset/request/');
      final response = await Future.any([
        http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'phone_number': phoneNumber,
            'country_code': _countryCode,
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
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PassResetOtpPage(
              phoneNumber: phoneNumber,
              countryCode: _countryCode,
            ),
          ),
        );
      } else if (response.statusCode == 429) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please wait before requesting another OTP.')),
        );
      } else {
        if (!mounted) return;
        final body = jsonDecode(response.body);
        final errorMsg = (body['error'] ?? body['phone_number']?.first) as String? ??
            'Phone number not found.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg)),
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
                      'Forgot Password',
                      style: TextStyle(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Enter your phone number to receive\na verification code via WhatsApp.',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 32.h),
                    IntlPhoneField(
                      controller: _phoneController,
                      initialCountryCode: 'IQ',
                      disableLengthCheck: true,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        hintText: 'Your registered phone number',
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: kColorPrimary),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                              color: Color.fromARGB(255, 76, 77, 78)),
                        ),
                      ),
                      onChanged: (phone) {
                        _countryCode = '+${phone.countryCode}';
                      },
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'If you don\'t use WhatsApp, please contact staff.',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[500],
                      ),
                    ),
                    SizedBox(height: 24.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _sendOtp,
                        child: Text(
                          'Send OTP',
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
