import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:wellbee/ui_parts/color.dart';
import '../assets/inet.dart';
import '../ui_parts/show_dialogue.dart';
import 'pass_reset_confirm.dart';

class PassResetOtpPage extends StatefulWidget {
  final String phoneNumber;
  final String countryCode;

  const PassResetOtpPage({
    super.key,
    required this.phoneNumber,
    required this.countryCode,
  });

  @override
  State<PassResetOtpPage> createState() => _PassResetOtpPageState();
}

class _PassResetOtpPageState extends State<PassResetOtpPage> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  int _resendCooldown = 0;
  Timer? _timer;

  @override
  void dispose() {
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    setState(() => _resendCooldown = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_resendCooldown > 0) {
          _resendCooldown--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  Future<void> _resendOtp() async {
    if (_resendCooldown > 0) return;

    setState(() => _isLoading = true);
    await DialogGenerator.showLoadingDialog(context: context);

    try {
      final url = Uri.parse('${baseUri}accounts/password-reset/request/');
      final response = await Future.any([
        http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'phone_number': widget.phoneNumber,
            'country_code': widget.countryCode,
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
        _startCooldown();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP resent to your WhatsApp.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to resend OTP. Please try again.')),
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

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the 6-digit code.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    await DialogGenerator.showLoadingDialog(context: context);

    try {
      final url = Uri.parse('${baseUri}accounts/password-reset/verify-otp/');
      final response = await Future.any([
        http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'phone_number': widget.phoneNumber,
            'country_code': widget.countryCode,
            'otp_code': otp,
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
        final data = jsonDecode(response.body);
        final resetToken = data['reset_token'] as String;
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PassResetConfirmPage(resetToken: resetToken),
          ),
        );
      } else {
        if (!mounted) return;
        final body = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(body['error'] as String? ?? 'Invalid or expired OTP.')),
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
                      'Enter Verification Code',
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'A 6-digit code was sent to your WhatsApp.',
                      style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 32.h),
                    TextField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      textAlign: TextAlign.center,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: TextStyle(fontSize: 24.sp, letterSpacing: 8),
                      decoration: InputDecoration(
                        hintText: '------',
                        counterText: '',
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
                    ),
                    SizedBox(height: 24.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _verifyOtp,
                        child: Text(
                          'Verify',
                          style: TextStyle(
                            color: kColorPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Center(
                      child: TextButton(
                        onPressed: _resendCooldown > 0 ? null : _resendOtp,
                        child: Text(
                          _resendCooldown > 0
                              ? 'Resend OTP (${_resendCooldown}s)'
                              : 'Resend OTP',
                          style: TextStyle(
                            color: _resendCooldown > 0
                                ? Colors.grey
                                : kColorPrimary,
                            fontSize: 14.sp,
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
