import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:wellbee/ui_parts/color.dart';

class ThemeColors {
  static const letterColor = Color.fromARGB(255, 76, 77, 78);
  static const kAccentColor = Color.fromARGB(255, 255, 232, 190);
}

// class ShowSnackBar extends StatelessWidget {
//   final String text;
//   final dynamic color;

//   ShowSnackBar({required this.text, required this.color});

//   @override
//   Widget build(BuildContext context){
//     void showSnackBar(color, text) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           backgroundColor: color,
//           content: Text(text),
//         ),
//       );
//     }
//   }
// }`

class CustomTextBox<Widget> {
  final String label;
  final String hintText;
  final TextEditingController? controller;
  final Function? function;
  final TextInputType? inputType;
  // dynamic inputValue;

  CustomTextBox({
    required this.label,
    required this.hintText,
    this.controller,
    this.function,
    this.inputType,
    // this.inputValue,
  });

  // CustomTextBox(label: 'Mobile Number', hintText: '11 digits number')

  textFieldDecoration() {
    // return がないと、何も表示されない
    return TextField(
      keyboardType: inputType,
      textAlign: TextAlign.center,
      controller: controller,
      style: const TextStyle(color: ThemeColors.letterColor, fontSize: 15),
      decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: ThemeColors.letterColor),
          hintText: hintText,
          hintStyle: const TextStyle(color: ThemeColors.letterColor),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: kColorPrimary)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: ThemeColors.letterColor),
          )),
      obscureText: false,
    );
  }

  phoneFieldDecoration() {
    return IntlPhoneField(
      controller: controller,
      decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: ThemeColors.letterColor),
          hintText: hintText,
          hintStyle: const TextStyle(color: ThemeColors.letterColor),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: kColorPrimary)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: ThemeColors.letterColor),
          )),
      initialCountryCode: 'IQ',
      onChanged: (phone) {
        // print(phone.completeNumber);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return textFieldDecoration();
  }
}

class LeftCustomTextBox<Widget> {
  final String label;
  final String hintText;
  final TextEditingController? controller;
  final Function? function;
  final TextInputType? inputType;
  // dynamic inputValue;

  LeftCustomTextBox({
    required this.label,
    required this.hintText,
    this.controller,
    this.function,
    this.inputType,
    // this.inputValue,
  });

  // CustomTextBox(label: 'Mobile Number', hintText: '11 digits number')

  textFieldDecoration() {
    // return がないと、何も表示されない
    return TextField(
      keyboardType: inputType,
      textAlign: TextAlign.left,
      controller: controller,
      style: TextStyle(color: ThemeColors.letterColor, fontSize: 22.h),
      decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: ThemeColors.letterColor),
          hintText: hintText,
          hintStyle: const TextStyle(color: ThemeColors.letterColor),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: kColorPrimary)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: ThemeColors.letterColor),
          )),
      obscureText: false,
    );
  }

  phoneFieldDecoration() {
    return IntlPhoneField(
      controller: controller,
      decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: ThemeColors.letterColor),
          hintText: hintText,
          hintStyle: const TextStyle(color: ThemeColors.letterColor),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: kColorPrimary)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: ThemeColors.letterColor),
          )),
      initialCountryCode: 'IQ',
      onChanged: (phone) {
        // print(phone.completeNumber);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return textFieldDecoration();
  }
}

class LongCustomTextBox<Widget> {
  final String label;
  final String hintText;
  final TextEditingController? controller;
  final Function? function;
  final TextInputType? inputType;
  // dynamic inputValue;

  LongCustomTextBox({
    required this.label,
    required this.hintText,
    this.controller,
    this.function,
    this.inputType,
    // this.inputValue,
  });

  // CustomTextBox(label: 'Mobile Number', hintText: '11 digits number')

  textFieldDecoration() {
    // return がないと、何も表示されない
    return SizedBox(
      height: 150,
      child: TextField(
        maxLength: 150,
        minLines: null, // 最小1行
        maxLines: null,
        expands: true,
        keyboardType: inputType,
        textAlign: TextAlign.center,
        controller: controller,
        style: const TextStyle(color: ThemeColors.letterColor, fontSize: 15),
        decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: ThemeColors.letterColor),
            hintText: hintText,
            hintStyle: const TextStyle(color: ThemeColors.letterColor),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: kColorPrimary)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: ThemeColors.letterColor),
            )),
        obscureText: false,
      ),
    );
  }

  phoneFieldDecoration() {
    return IntlPhoneField(
      controller: controller,
      decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: ThemeColors.letterColor),
          hintText: hintText,
          hintStyle: const TextStyle(color: ThemeColors.letterColor),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: kColorPrimary)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: ThemeColors.letterColor),
          )),
      initialCountryCode: 'IQ',
      onChanged: (phone) {
        // print(phone.completeNumber);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return textFieldDecoration();
  }
}

class InterviewCustomTextBox<Widget> {
  final String label;
  final String hintText;
  final TextEditingController? controller;
  final Function? function;
  final TextInputType? inputType;
  // dynamic inputValue;

  InterviewCustomTextBox({
    required this.label,
    required this.hintText,
    this.controller,
    this.function,
    this.inputType,
    // this.inputValue,
  });

  // CustomTextBox(label: 'Mobile Number', hintText: '11 digits number')

  textFieldDecoration() {
    // return がないと、何も表示されない
    return SizedBox(
      height: 150,
      child: TextField(
        maxLength: 300,
        minLines: null, // 最小1行
        maxLines: null,
        expands: true,
        keyboardType: inputType,
        textAlign: TextAlign.center,
        controller: controller,
        style: const TextStyle(color: ThemeColors.letterColor, fontSize: 15),
        decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: ThemeColors.letterColor),
            hintText: hintText,
            hintStyle: const TextStyle(color: ThemeColors.letterColor),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: kColorPrimary)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: ThemeColors.letterColor),
            )),
        obscureText: false,
      ),
    );
  }

  phoneFieldDecoration() {
    return IntlPhoneField(
      controller: controller,
      decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: ThemeColors.letterColor),
          hintText: hintText,
          hintStyle: const TextStyle(color: ThemeColors.letterColor),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: kColorPrimary)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: ThemeColors.letterColor),
          )),
      initialCountryCode: 'IQ',
      onChanged: (phone) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return textFieldDecoration();
  }
}

// class PasswordCustomTextBox extends StatefulWidget {
//   final String label;
//   final String hintText;
//   final TextEditingController? controller;
//   final Function? function;
//   final TextInputType? inputType;
//   final bool isPassword; // パスワードフィールドかどうか

//   PasswordCustomTextBox({
//     required this.label,
//     required this.hintText,
//     this.controller,
//     this.function,
//     this.inputType,
//     this.isPassword = false, // デフォルトはパスワードフィールドではない
//   });

//   @override
//   _PasswordCustomTextBoxState createState() => _PasswordCustomTextBoxState();
// }

class PasswordCustomTextBox extends StatefulWidget {
  final String label;
  final String hintText;
  final TextEditingController? controller;
  final Function? function;
  final TextInputType? inputType;
  final bool isPassword; // パスワードフィールドかどうか

  PasswordCustomTextBox({
    required this.label,
    required this.hintText,
    this.controller,
    this.function,
    this.inputType,
    this.isPassword = false, // デフォルトはパスワードフィールドではない
  });

  @override
  _PasswordCustomTextBoxState createState() => _PasswordCustomTextBoxState();
}

class _PasswordCustomTextBoxState extends State<PasswordCustomTextBox> {
  bool _obscureText = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword; // パスワードフィールドの場合、初期状態を非表示に設定
  }

  /// パスワードのバリデーションを行う関数
  String? _validatePassword(String value) {
    if (value.isEmpty) {
      return 'Enter the password';
    }
    if (value.length < 7) {
      return 'Password should be more than 7 letters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password needs at least 1 capital letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password needs at least one number';
    }
    return null; // バリデーション成功
  }

  Widget textFieldDecoration() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          keyboardType: widget.inputType,
          textAlign: TextAlign.center,
          controller: widget.controller,
          style: const TextStyle(color: ThemeColors.letterColor, fontSize: 15),
          decoration: InputDecoration(
            labelText: widget.label,
            labelStyle: const TextStyle(color: ThemeColors.letterColor),
            hintText: widget.hintText,
            hintStyle: const TextStyle(color: ThemeColors.letterColor),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: kColorPrimary),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: ThemeColors.letterColor),
            ),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: ThemeColors.letterColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : null,
            errorText: _errorText, // エラーメッセージを表示
          ),
          obscureText: _obscureText,
          onChanged: (value) {
            if (widget.isPassword) {
              setState(() {
                _errorText = _validatePassword(value);
              });
            }
            if (widget.function != null) {
              widget.function!(value);
            }
          },
        ),
        // エラーメッセージをテキストフィールドの下に表示する場合
        // if (_errorText != null)
        //   Padding(
        //     padding: const EdgeInsets.only(top: 5.0, left: 10.0),
        //     child: Text(
        //       _errorText!,
        //       style: TextStyle(color: Colors.red, fontSize: 12),
        //     ),
        //   ),
      ],
    );
  }

  Widget phoneFieldDecoration() {
    return IntlPhoneField(
      controller: widget.controller,
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: const TextStyle(color: ThemeColors.letterColor),
        hintText: widget.hintText,
        hintStyle: const TextStyle(color: ThemeColors.letterColor),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: kColorPrimary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: ThemeColors.letterColor),
        ),
      ),
      initialCountryCode: 'IQ',
      onChanged: (phone) {
        if (widget.function != null) {
          widget.function!(phone.completeNumber);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 入力タイプが電話番号の場合は電話フィールドを表示
    if (widget.inputType == TextInputType.phone) {
      return phoneFieldDecoration();
    } else {
      return textFieldDecoration();
    }
  }
}
