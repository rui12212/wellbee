import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:wellbee/assets/inet.dart';
import 'package:wellbee/ui_function/shared_prefs.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../ui_parts/color.dart';

class PointPage extends StatefulWidget {
  final String userId;
  final int points;
  final int stamps;

  const PointPage({
    Key? key,
    required this.userId,
    required this.points,
    required this.stamps,
  }) : super(key: key);

  @override
  _PointPageState createState() => _PointPageState();
}

class _PointPageState extends State<PointPage> {
  List<Map<String, dynamic>> _recentCheckIns = [];
  bool _isLoadingHistory = true;

  @override
  void initState(){
    super.initState();
    _fetchRecentCheckIns();
  }

  Future<void> _fetchRecentCheckIns() async {
    try{
      final token = await SharedPrefs.fetchAccessToken();
      if (token == null) return;

      final url = Uri.parse(
        '${baseUri}attendances/checkin/recent_three_checkin/?token=$token'
      );
      final response = await http.get(url, headers: {
         "Authorization": 'JWT $token',
        "Content-Type": "application/json",
      });
      if(response.statusCode == 200){
        final List<dynamic> data = jsonDecode(response.body);
        if(mounted) {
          setState((){
            _recentCheckIns = data.cast<Map<String, dynamic>>();
            _isLoadingHistory = false;
          });
        }
      } else {
        if(mounted) setState(() => _isLoadingHistory= false);
      }
    } catch(e) {
      if(mounted) setState(() => _isLoadingHistory = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F2),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              SizedBox(height: 16.h),
              _buildQrCard(),
              SizedBox(height: 16.h),
              _buildInfoRow(),
              SizedBox(height: 16.h),
              _buildStampCard(),
              SizedBox(height: 16.h),
              _buildHistorySection(),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: 'Stamp '),
                TextSpan(
                  text: '& ',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: kColorPrimary,
                  ),
                ),
                const TextSpan(text: 'Point'),
              ],
            ),
            style: TextStyle(
              fontSize: 30.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF212121),
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
    );
  }

  Widget _buildInfoRow() {
    final int cardsDone = widget.stamps ~/ 10;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Points tile — milestone gold, same yellow as the 5th/10th stamp
          Expanded(
            child: _buildInfoTile(
              label: 'POINTS',
              value: '${widget.points}',
              unit: 'pt',
              labelColor: const Color(0xB340340A),
              valueColor: const Color(0xFF40340A),
              unitColor: const Color(0x9940340A),
              background: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFEBD14E), Color(0xFFE0C13A)],
              ),
            ),
          ),
          SizedBox(width: 10.w),
          // Total stamps tile
          Expanded(
            child: _buildInfoTile(
              label: 'TOTAL STAMPS',
              value: '${widget.stamps}',
              unit: null,
            ),
          ),
          SizedBox(width: 10.w),
          // Cards done tile
          Expanded(
            child: _buildInfoTile(
              label: 'CARDS DONE',
              value: '$cardsDone',
              unit: null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required String label,
    required String value,
    String? unit,
    Color labelColor = const Color(0xFF9E9E9E),
    Color valueColor = const Color(0xFF212121),
    Color unitColor = const Color(0xFF9E9E9E),
    Gradient? background,
  }) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: background == null ? Colors.white : null,
        gradient: background,
        borderRadius: BorderRadius.circular(14.r),
        border: background == null
            ? Border.all(color: const Color(0xFFE4DFD8))
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: labelColor,
              letterSpacing: 0.4,
            ),
          ),
          SizedBox(height: 4.h),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                    color: valueColor,
                  ),
                ),
                if (unit != null)
                  TextSpan(
                    text: ' $unit',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: unitColor,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStampCard() {
    final int cardStamps = widget.stamps % 10;
    final int cardNumber =
        widget.stamps == 0 ? 1 : (widget.stamps - 1) ~/ 10 + 1;
    final int stampsInCycle = widget.stamps % 5;
    final int toNextPoint =
        (stampsInCycle == 0 && widget.stamps > 0) ? 0 : 5 - stampsInCycle;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFE4DFD8)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            height: 4.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [kColorPrimary, kColorPrimaryThin, kColorSecondary],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 24.h),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'CARD #$cardNumber',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF9E9E9E),
                        letterSpacing: 0.6,
                      ),
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '$cardStamps',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: kColorPrimary,
                            ),
                          ),
                          TextSpan(
                            text: ' / 10',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF9E9E9E),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 12.r,
                    mainAxisSpacing: 12.r,
                    childAspectRatio: 1,
                  ),
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    final bool isFilled = index < cardStamps;
                    final bool isMilestone = (index + 1) % 5 == 0;
                    return _buildStampSlot(
                      index: index,
                      isFilled: isFilled,
                      isMilestone: isMilestone,
                    );
                  },
                ),
                SizedBox(height: 20.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3.r),
                  child: LinearProgressIndicator(
                    value: cardStamps / 10,
                    minHeight: 6.h,
                    backgroundColor: const Color(0xFFE4DFD8),
                    valueColor: AlwaysStoppedAnimation<Color>(kColorPrimary),
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      toNextPoint == 0
                          ? 'Point earned!'
                          : '$toNextPoint more to next point',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF9E9E9E),
                      ),
                    ),
                    Text(
                      '+1 pt',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: kColorPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStampSlot({
    required int index,
    required bool isFilled,
    required bool isMilestone,
  }) {
    Color bgColor;
    if (isFilled && isMilestone) {
      bgColor = kColorSecondary;
    } else if (isFilled) {
      bgColor = kColorPrimary;
    } else {
      bgColor = const Color(0xFFE4DFD8);
    }

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bgColor,
        boxShadow: isFilled
            ? [
                BoxShadow(
                  color: isMilestone
                      ? kColorSecondary.withOpacity(0.4)
                      : kColorPrimary.withOpacity(0.25),
                  blurRadius: isMilestone ? 12 : 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Center(
        child: isFilled
            ? Icon(Icons.star_rounded, color: Colors.white, size: 24.r)
            : Text(
                '${index + 1}',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF9E9E9E),
                ),
              ),
      ),
    );
  }

  Widget _buildHistorySection() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE4DFD8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RECENT ACTIVITY',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF9E9E9E),
              letterSpacing: 0.4,
            ),
          ),
          SizedBox(height: 12.h),
          if (_isLoadingHistory)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                child: SizedBox(
                  width: 24.r,
                  height: 24.r,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: kColorPrimary,
                  ),
                ),
              ),
            )
          else if (_recentCheckIns.isEmpty)
            _buildHistoryItem({
              'action': 'No activity yet',
              'detail': 'Check in to earn stamps',
              'earned': '',
            })
          else
            ..._recentCheckIns.map((checkIn) => _buildHistoryItem({
                  'action': checkIn['checkin_course_name'] ?? 'Unknown Course',
                  'detail': 'Checked in',
                })),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> item) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: const Color(0xFFE4DFD8),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32.r,
            height: 32.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: kColorPrimary.withValues(alpha: 0.1),
            ),
            child: Icon(
              Icons.star_rounded,
              size: 16.r,
              color: kColorPrimary,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['action'],
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF212121),
                  ),
                ),
                Text(
                  item['detail'],
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF9E9E9E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrCard() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFE4DFD8)),
      ),
      child: Row(
        children: [
          Container(
            width: 96.r,
            height: 96.r,
            padding: EdgeInsets.all(6.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFFE4DFD8), width: 2),
            ),
            child: QrImageView(
              data: '${baseUri}accounts/users/points/${widget.userId}',
              version: QrVersions.auto,
              size: 80.r,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Page QR',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF212121),
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0ECE6),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 14.r,
                        color: const Color(0xFF5A5757),
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        'Staff will scan this code',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF5A5757),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
