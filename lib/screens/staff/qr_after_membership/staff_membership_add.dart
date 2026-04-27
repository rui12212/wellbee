import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wellbee/assets/inet.dart';
import 'package:wellbee/screens/staff/qr_after_membership/staff_membership_confirm.dart';
import 'package:wellbee/screens/staff/qr_after_membership/staff_private_membership_confirm.dart';
import 'package:wellbee/ui_parts/color.dart';
import 'package:wellbee/ui_function/shared_prefs.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class _Header extends StatelessWidget {
  final String title;
  final String subtitle;

  const _Header({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 8.h, bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 30.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(24.r),
                  child: Container(
                    width: 48.w,
                    height: 48.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      size: 20.sp,
                      color: kColorTextDarkGrey,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              color: kColorText,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class StaffMembershipAddPage extends StatefulWidget {
  final Map<dynamic, dynamic> attendeeList;
  final String userId;

  const StaffMembershipAddPage({
    Key? key,
    required this.attendeeList,
    required this.userId,
  }) : super(key: key);

  @override
  _StaffMembershipAddPageState createState() => _StaffMembershipAddPageState();
}

class _StaffMembershipAddPageState extends State<StaffMembershipAddPage> {
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();

  String? token = '';
  String? selectedCourse;
  int selectedTimes = 1;
  int selectedDuration = 1;
  String selectedCurrency = 'USD';
  double selectedDiscountRate = 1.0;
  DateTime newDate = DateTime.now();
  List<DropdownMenuItem<String>> courseDropDownItems = [];
  bool isPrivate = false;
  bool _isLoadingCourses = true;

  // ---------- Course classification ----------

  static const Set<String> privateCourseSet = {
    'Private Yoga@Studio',
    'Private Pilates@Studio',
    'Private Yoga@Home',
    'Private Pilates@Home',
  };

  // ---------- Pre-built dropdown items ----------

  final List<DropdownMenuItem<int>> monthItems = const [1, 3, 6, 12]
      .map(
        (m) => DropdownMenuItem<int>(
          value: m,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Text('$m month'),
          ),
        ),
      )
      .toList();

  final List<DropdownMenuItem<int>> privateMonthItems = const [1, 2, 3]
      .map(
        (m) => DropdownMenuItem<int>(
          value: m,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Text('$m month'),
          ),
        ),
      )
      .toList();

  final List<DropdownMenuItem<int>> privateTimesItems =
      List.generate(10, (index) => index + 1)
          .map(
            (n) => DropdownMenuItem<int>(
              value: n,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Text('$n time'),
              ),
            ),
          )
          .toList();

  final List<DropdownMenuItem<String>> currencyItems = const ['USD', 'IQD']
      .map(
        (c) => DropdownMenuItem<String>(
          value: c,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Text(c),
          ),
        ),
      )
      .toList();

  final List<DropdownMenuItem<double>> discountRateItems = const [
    1.0,
    0.95,
    0.9,
    0.85,
    0.8,
    0.75,
    0.7,
    0.65,
    0.6,
    0.55,
    0.5,
    0.45,
    0.4
  ]
      .map(
        (rate) => DropdownMenuItem<double>(
          value: rate,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Text('${(100 - rate * 100).toStringAsFixed(1)}%'),
          ),
        ),
      )
      .toList();

  // ---------- Lifecycle ----------

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  @override
  void dispose() {
    _priceController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  void _showSnackBar(Color color, String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: color, content: Text(text)),
    );
  }

  // ---------- Networking ----------

  Future<List<String>?> _fetchOpenCourses() async {
    try {
      token = await SharedPrefs.fetchStaffAccessToken();
      final url = Uri.parse('${baseUri}attendances/course/?token=$token');
      final response = await Future.any([
        http.get(url, headers: {
          'Authorization': 'JWT $token',
          'Content-Type': 'application/json',
        }),
        Future.delayed(const Duration(seconds: 15),
            () => throw TimeoutException('Request timeout')),
      ]);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map<String?>((e) => e['course_name'] as String?)
            .whereType<String>()
            .toList();
      }
      _showSnackBar(
          Colors.red, 'Failed to fetch courses (${response.statusCode})');
      return null;
    } catch (e) {
      _showSnackBar(Colors.red, 'Error: $e');
      return null;
    }
  }

  Future<void> _loadCourses() async {
    final courses = await _fetchOpenCourses();
    if (!mounted) return;
    if (courses == null || courses.isEmpty) {
      setState(() => _isLoadingCourses = false);
      return;
    }
    final initialCourse = courses.first;
    setState(() {
      courseDropDownItems = courses
          .map((c) => DropdownMenuItem<String>(
                value: c,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(c),
                ),
              ))
          .toList();
      selectedCourse = initialCourse;
      _isLoadingCourses = false;
      _onCourseChanged();
    });
  }

  // ---------- Course-based form constraints ----------

  void _onCourseChanged() {
    final course = selectedCourse;
    if (course == null) return;
    isPrivate = privateCourseSet.contains(course);
    if (isPrivate && ![1, 2, 3].contains(selectedDuration)) {
      selectedDuration = 1;
    } else if (!isPrivate && ![1, 3, 6, 12].contains(selectedDuration)) {
      selectedDuration = 1;
    }
  }

  // ---------- Submit ----------

  void _onSubmit() {
    if (selectedCourse == null) {
      _showSnackBar(Colors.red, 'Course is required');
      return;
    }

    final priceText = _priceController.text.trim();
    final priceValue = int.tryParse(priceText);
    if (priceValue == null || priceValue <= 0) {
      _showSnackBar(Colors.red, 'Enter a valid price');
      return;
    }

    final discountAmount = _discountController.text.trim();
    final intDiscountAmount = int.tryParse(discountAmount) ?? 0;
    final formattedDate = DateFormat('yyyy-MM-dd').format(newDate);

    if (!isPrivate) {
      final membershipMap = <dynamic, dynamic>{
        'course': selectedCourse,
        'duration': selectedDuration,
        'total_price': priceValue,
        'currency': selectedCurrency,
        'minus': intDiscountAmount,
        'discount_rate': selectedDiscountRate,
        'start_day': formattedDate,
      };
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => StaffMembershipConfirmPage(
                attendeeList: widget.attendeeList,
                membershipMap: membershipMap,
                userId: widget.userId,
              )));
    } else {
      final membershipMap = <dynamic, dynamic>{
        'course': selectedCourse,
        'duration': selectedDuration,
        'times': selectedTimes,
        'total_price': priceValue,
        'currency': selectedCurrency,
        'minus': intDiscountAmount,
        'discount_rate': selectedDiscountRate,
        'start_day': formattedDate,
      };
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => StaffPrivateMembershipConfirmPage(
                attendeeList: widget.attendeeList,
                membershipMap: membershipMap,
                userId: widget.userId,
              )));
    }
  }

  // ---------- Modern UI helpers ----------

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: kColorTextDarkGrey,
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _wrapField({required String label, required Widget child}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 7.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(label),
          SizedBox(height: 5.h),
          child,
        ],
      ),
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime date,
    required ValueChanged<DateTime> onChanged,
  }) {
    return _wrapField(
      label: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: date,
            firstDate: DateTime(2024),
            lastDate: DateTime(2030),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(
                    primary: kColorPrimary,
                    onPrimary: Colors.white,
                    onSurface: kColorTextDarkGrey,
                  ),
                  textButtonTheme: TextButtonThemeData(
                    style:
                        TextButton.styleFrom(foregroundColor: kColorPrimary),
                  ),
                ),
                child: child!,
              );
            },
          );
          if (picked != null) {
            setState(() => onChanged(picked));
          }
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 17.h, horizontal: 15.w),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey[300]!, width: 1),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today_outlined,
                  size: 22.sp, color: kColorPrimary),
              SizedBox(width: 10.w),
              Text(
                DateFormat('yyyy/MM/dd').format(date),
                style: TextStyle(
                  fontSize: 18.sp,
                  color: kColorTextDarkGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return _wrapField(
      label: label,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey[300]!, width: 1),
        ),
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: value,
            isExpanded: true,
            icon: Icon(Icons.keyboard_arrow_down_rounded,
                color: Colors.grey[600], size: 28.sp),
            style: TextStyle(fontSize: 18.sp, color: Colors.black),
            borderRadius: BorderRadius.circular(14),
            items: items,
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    TextInputType? inputType,
  }) {
    return _wrapField(
      label: label,
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        style: TextStyle(fontSize: 18.sp),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[400]),
          contentPadding:
              EdgeInsets.symmetric(vertical: 15.h, horizontal: 15.w),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: kColorTextDarkGrey, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: kColorPrimary, width: 2),
          ),
        ),
      ),
    );
  }

  // ---------- Build ----------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(
                title: 'Buy Membership',
                subtitle: 'For ${widget.attendeeList['name']}',
              ),
              Expanded(
                child: _isLoadingCourses
                    ? const Center(child: CircularProgressIndicator())
                    : courseDropDownItems.isEmpty
                        ? Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.w),
                              child: Text(
                                'No open course available.\nAdd a course first.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  color: kColorTextDarkGrey,
                                ),
                              ),
                            ),
                          )
                        : SingleChildScrollView(
                            padding: EdgeInsets.only(bottom: 24.h),
                            child: _buildForm(),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        _buildDatePicker(
          label: 'Start Day',
          date: newDate,
          onChanged: (d) => newDate = d,
        ),
        _buildDropdown<String>(
          label: 'Course',
          value: selectedCourse,
          items: courseDropDownItems,
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              selectedCourse = value;
              _onCourseChanged();
            });
          },
        ),
        _buildDropdown<int>(
          label: 'Months',
          value: selectedDuration,
          items: isPrivate ? privateMonthItems : monthItems,
          onChanged: (value) {
            if (value == null) return;
            setState(() => selectedDuration = value);
          },
        ),
        if (isPrivate)
          _buildDropdown<int>(
            label: 'Times',
            value: selectedTimes,
            items: privateTimesItems,
            onChanged: (value) {
              if (value == null) return;
              setState(() => selectedTimes = value);
            },
          ),
        _buildTextField(
          label: 'Price',
          hintText: 'e.g. 60',
          controller: _priceController,
          inputType: TextInputType.number,
        ),
        _buildDropdown<String>(
          label: 'Currency',
          value: selectedCurrency,
          items: currencyItems,
          onChanged: (value) {
            if (value == null) return;
            setState(() => selectedCurrency = value);
          },
        ),
        _buildTextField(
          label: 'Discount (\$)',
          hintText: '0',
          controller: _discountController,
          inputType: TextInputType.number,
        ),
        _buildDropdown<double>(
          label: 'Discount (%)',
          value: selectedDiscountRate,
          items: discountRateItems,
          onChanged: (value) {
            if (value == null) return;
            setState(() => selectedDiscountRate = value);
          },
        ),
        SizedBox(height: 32.h),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: Icon(Icons.shopping_cart_outlined,
                color: Colors.white, size: 24.sp),
            label: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.h),
              child: Text(
                'Check Out',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: kColorPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              minimumSize: Size(double.infinity, 60.h),
              elevation: 2,
            ),
            onPressed: _onSubmit,
          ),
        ),
        SizedBox(height: 20.h),
      ],
    );
  }
}
