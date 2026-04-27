import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:wellbee/ui_parts/color.dart';
import 'pass_reset_otp.dart';

class PassResetRequestPage extends StatefulWidget {
  const PassResetRequestPage({super.key});

  @override
  State<PassResetRequestPage> createState() => _PassResetRequestPageState();
}

class _PassResetRequestPageState extends State<PassResetRequestPage> {
  final TextEditingController _phoneController = TextEditingController();
  String _fullPhoneNumber = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (_fullPhoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your phone number.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // APNsトークンを事前取得してFirebaseがPhone Authで使えるようにする
    await FirebaseMessaging.instance.requestPermission();
    String? apnsToken;
    for (int i = 0; i < 5 && apnsToken == null; i++) {
      apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      if (apnsToken == null) await Future.delayed(const Duration(seconds: 1));
    }
    if (apnsToken == null) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Push notification setup is not complete. Please check your device settings.')),
        );
      }
      return;
    }

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: _fullPhoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) {
        // Android auto-verification (not used in this flow)
      },
      verificationFailed: (FirebaseAuthException e) {
        if (!mounted) return;
        debugPrint('verificationFailed code: ${e.code}, message: ${e.message}, details: ${e.toString()}, phone: $_fullPhoneNumber');
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${e.code}: ${e.message}')),
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PassResetOtpPage(
              phoneNumber: _fullPhoneNumber,
              verificationId: verificationId,
              resendToken: resendToken,
            ),
          ),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
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
                      'Enter your phone number to receive\na verification code via SMS.',
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
                        // E.164: completeNumberの国番号直後の先頭0を除去
                        // phone.countryCode は "+964" のように+付きで返る
                        final complete = phone.completeNumber; // 例: +96407083280250
                        final cc = phone.countryCode;          // 例: +964
                        final national = complete.substring(cc.length); // 例: 07083280250
                        _fullPhoneNumber = national.startsWith('0')
                            ? '$cc${national.substring(1)}'  // +9647083280250
                            : complete;
                      },
                    ),
                    SizedBox(height: 24.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _sendOtp,
                        child: _isLoading
                            ? SizedBox(
                                height: 20.h,
                                width: 20.w,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: kColorPrimary,
                                ),
                              )
                            : Text(
                                'Send Code',
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
