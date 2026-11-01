import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wellbee/screens/staff/notification/notification_draft.dart';
import 'package:wellbee/screens/staff/notification/staff_notification_confirm.dart';
import 'package:wellbee/ui_parts/color.dart';

/// 画像の上限。これを超えるとR2へのアップロードと会員側の読み込みが重くなる。
const int _maxImageBytes = 5 * 1024 * 1024;

class StaffNotificationComposePage extends StatefulWidget {
  final NotificationDraft draft;

  const StaffNotificationComposePage({super.key, required this.draft});

  @override
  State<StaffNotificationComposePage> createState() =>
      _StaffNotificationComposePageState();
}

class _StaffNotificationComposePageState
    extends State<StaffNotificationComposePage> {
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  int? _imageBytes;
  String? _imageError;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.draft.title);
    _bodyController = TextEditingController(text: widget.draft.body);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        // 送信前に縮小しておく。会員の通信量を抑えるため
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (picked == null) return;

      final length = await picked.length();
      if (!mounted) return;
      if (length > _maxImageBytes) {
        setState(() {
          _imageError = 'This image is too large. Please choose one under 5 MB.';
        });
        return;
      }
      setState(() {
        widget.draft.image = picked;
        _imageBytes = length;
        _imageError = null;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _imageError = 'Could not open the image.');
      }
    }
  }

  void _removeImage() {
    setState(() {
      widget.draft.image = null;
      _imageBytes = null;
      _imageError = null;
    });
  }

  Future<void> _goNext() async {
    widget.draft.title = _titleController.text;
    widget.draft.body = _bodyController.text;

    final sent = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => StaffNotificationConfirmPage(draft: widget.draft),
      ),
    );
    if (sent == true && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).round()} KB';
    return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final draft = widget.draft;
    final canProceed = _titleController.text.trim().isNotEmpty &&
        _bodyController.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F2),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 22.h, 20.w, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 14.h),
              _buildStepBar(2),
              SizedBox(height: 16.h),
              _buildTargetChip(draft),
              SizedBox(height: 20.h),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('TITLE'),
                      SizedBox(height: 8.h),
                      TextField(
                        controller: _titleController,
                        maxLength: 100,
                        onChanged: (_) => setState(() {}),
                        decoration: _inputDecoration('e.g. Studio closed on Nov 5'),
                        style: TextStyle(fontSize: 15.sp),
                      ),
                      SizedBox(height: 6.h),
                      _buildLabel('MESSAGE'),
                      SizedBox(height: 8.h),
                      TextField(
                        controller: _bodyController,
                        maxLines: 8,
                        minLines: 6,
                        onChanged: (_) => setState(() {}),
                        decoration: _inputDecoration('Write the message here'),
                        style: TextStyle(fontSize: 15.sp, height: 1.7),
                      ),
                      SizedBox(height: 16.h),
                      _buildLabel('IMAGE'),
                      SizedBox(height: 8.h),
                      if (draft.image == null)
                        _buildAddImageButton()
                      else
                        _buildImageRow(draft),
                      if (_imageError != null) ...[
                        SizedBox(height: 7.h),
                        Text(
                          _imageError!,
                          style: TextStyle(
                              fontSize: 12.sp, color: const Color(0xFFD94040)),
                        ),
                      ] else ...[
                        SizedBox(height: 7.h),
                        Text(
                          'One image, up to 5 MB. Videos are not supported yet.',
                          style: TextStyle(fontSize: 11.5.sp, color: Colors.grey),
                        ),
                      ],
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: canProceed ? _goNext : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kColorPrimary,
                    disabledBackgroundColor: const Color(0xFFCFD8D4),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 15.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Review before sending',
                        style: TextStyle(
                            fontSize: 16.sp, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(width: 8.w),
                      Icon(Icons.arrow_forward_ios, size: 14.sp),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey.shade400),
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 12.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: const BorderSide(color: Color(0xFFE4DFD8)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: const BorderSide(color: Color(0xFFE4DFD8)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(color: kColorPrimary, width: 2),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'New Message',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF212121),
              ),
            ),
            Text(
              'Step 2 of 3 · Content',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStepBar(int current) {
    return Row(
      children: List.generate(3, (i) {
        return Expanded(
          child: Container(
            height: 3.h,
            margin: EdgeInsets.only(right: i < 2 ? 5.w : 0),
            decoration: BoxDecoration(
              color: i < current ? kColorPrimary : const Color(0xFFE4DFD8),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
        );
      }),
    );
  }

  /// 書いている間も宛先が見えるようにしておく。送信先を見失わないため。
  Widget _buildTargetChip(NotificationDraft draft) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5F0),
        borderRadius: BorderRadius.circular(8.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 7.h),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.group_outlined, size: 13.sp, color: kColorPrimary),
          SizedBox(width: 7.w),
          Flexible(
            child: Text(
              '${draft.targetLabel} · ${draft.recipientCount} people',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0D6650),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF212121),
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildAddImageButton() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: _pickImage,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: const Color(0xFFE4DFD8)),
          ),
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_photo_alternate_outlined,
                  size: 18.sp, color: kColorPrimary),
              SizedBox(width: 8.w),
              Text(
                'Add an image',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: kColorPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageRow(NotificationDraft draft) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE4DFD8)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: Image.file(
              File(draft.image!.path),
              width: 54.w,
              height: 54.w,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 54.w,
                height: 54.w,
                color: const Color(0xFFF0ECE6),
                alignment: Alignment.center,
                child: Icon(Icons.image_outlined,
                    size: 20.sp, color: Colors.grey),
              ),
            ),
          ),
          SizedBox(width: 11.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  draft.image!.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF212121),
                  ),
                ),
                if (_imageBytes != null) ...[
                  SizedBox(height: 2.h),
                  Text(
                    _formatBytes(_imageBytes!),
                    style: TextStyle(fontSize: 11.5.sp, color: Colors.grey),
                  ),
                ],
              ],
            ),
          ),
          Material(
            color: const Color(0xFFF7F5F2),
            borderRadius: BorderRadius.circular(17.r),
            child: InkWell(
              onTap: _removeImage,
              borderRadius: BorderRadius.circular(17.r),
              child: Container(
                width: 34.w,
                height: 34.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE4DFD8)),
                ),
                child: Icon(Icons.close,
                    size: 14.sp, color: const Color(0xFFD94040)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
