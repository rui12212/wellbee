import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wellbee/ui_parts/color.dart';

/// 送信済みメッセージの詳細。一覧から受け取ったレコードを表示するだけで、
/// 追加の通信は行わない。送信済みは編集・削除できない仕様なので操作もない。
class StaffNotificationDetailPage extends StatelessWidget {
  final Map<String, dynamic> message;

  const StaffNotificationDetailPage({super.key, required this.message});

  String _formatDateTime(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    final dt = DateTime.tryParse(raw);
    if (dt == null) return '';
    final local = dt.toLocal();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final hh = local.hour.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');
    return '${months[local.month - 1]} ${local.day}, ${local.year}  $hh:$mm';
  }

  String _statusLabel(String? status) {
    switch (status) {
      case 'active':
        return 'Active membership';
      case 'expired':
        return 'Expired membership';
      case 'none':
        return 'No membership';
      default:
        return 'Any status';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool staffOnly = message['staff_only'] == true;
    final bool isCourse = message['target_type'] == 'course';
    final String? imageUrl = message['image_url'] as String?;
    final int delivered = (message['delivered_count'] as num?)?.toInt() ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F2),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 22.h, 20.w, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(19.r),
                      child: Container(
                        width: 38.w,
                        height: 38.w,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFE4DFD8)),
                        ),
                        child: Icon(Icons.arrow_back_ios_new,
                            size: 14.sp, color: kColorTextDarkGrey),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    'Sent message',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF212121),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDeliveryCard(staffOnly, isCourse, delivered),
                      SizedBox(height: 14.h),
                      _buildContentCard(imageUrl),
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 誰に何人へ届いたかを先に出す。送信済みの記録として最も重要な情報。
  Widget _buildDeliveryCard(bool staffOnly, bool isCourse, int delivered) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: staffOnly ? const Color(0xFFFFF8D6) : Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
            color: staffOnly ? kColorSecondary : const Color(0xFFE4DFD8)),
      ),
      padding: EdgeInsets.fromLTRB(16.w, 15.h, 16.w, 15.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DELIVERY',
            style: TextStyle(
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w700,
              color: staffOnly ? const Color(0xFF9E8B45) : Colors.grey,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$delivered',
                style: TextStyle(
                  fontSize: 34.sp,
                  fontWeight: FontWeight.w700,
                  color: staffOnly ? const Color(0xFF7A6A2E) : kColorPrimary,
                  height: 1.1,
                ),
              ),
              SizedBox(width: 7.w),
              Text(
                'people',
                style: TextStyle(fontSize: 15.sp, color: kColorTextDarkGrey),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Divider(
            height: 1.h,
            color: staffOnly ? kColorSecondary : const Color(0xFFE4DFD8),
          ),
          SizedBox(height: 12.h),
          if (staffOnly)
            _buildRow('Recipients', 'Staff only (test)', emphasise: true)
          else ...[
            _buildRow(
              'Recipients',
              isCourse ? (message['course_name'] ?? 'Course') : 'All members',
            ),
            SizedBox(height: 7.h),
            _buildRow('Membership', _statusLabel(message['membership_status'])),
          ],
          SizedBox(height: 7.h),
          _buildRow('Sent at', _formatDateTime(message['created_at'])),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool emphasise = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90.w,
          child: Text(
            label,
            style: TextStyle(fontSize: 12.5.sp, color: Colors.grey),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13.5.sp,
              fontWeight: emphasise ? FontWeight.w700 : FontWeight.w500,
              color: emphasise
                  ? const Color(0xFF7A6A2E)
                  : const Color(0xFF212121),
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContentCard(String? imageUrl) {
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE4DFD8)),
      ),
      padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 18.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WHAT MEMBERS SEE',
            style: TextStyle(
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w700,
              color: Colors.grey,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            message['title'] ?? '',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF212121),
              height: 1.45,
            ),
          ),
          if (hasImage) ...[
            SizedBox(height: 16.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    height: 180.h,
                    color: const Color(0xFFF0ECE6),
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(
                      color: kColorPrimary,
                      value: progress.expectedTotalBytes != null
                          ? progress.cumulativeBytesLoaded /
                              progress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                // 画像が開けなくても本文は読めるようにする
                errorBuilder: (context, error, stack) => Container(
                  height: 120.h,
                  color: const Color(0xFFF0ECE6),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image_outlined,
                          size: 28.sp, color: Colors.grey),
                      SizedBox(height: 8.h),
                      Text(
                        'Image could not be loaded',
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          SizedBox(height: 18.h),
          Text(
            message['body'] ?? '',
            style: TextStyle(
              fontSize: 15.sp,
              color: const Color(0xFF212121),
              height: 1.85,
            ),
          ),
          SizedBox(height: 18.h),
          Divider(height: 1.h, color: const Color(0xFFE4DFD8)),
          SizedBox(height: 11.h),
          Row(
            children: [
              Icon(Icons.lock_outline, size: 13.sp, color: Colors.grey),
              SizedBox(width: 7.w),
              Expanded(
                child: Text(
                  'A sent message cannot be edited or deleted.',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
