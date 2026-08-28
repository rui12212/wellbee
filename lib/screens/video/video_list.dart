import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:wellbee/assets/inet.dart';
import 'package:wellbee/ui_function/shared_prefs.dart';
import 'package:wellbee/ui_parts/color.dart';
import 'package:wellbee/screens/video/video_player_page.dart';

class VideoListPage extends StatefulWidget {
  final int courseId;
  final String courseName;

  const VideoListPage({
    Key? key,
    required this.courseId,
    required this.courseName,
  }) : super(key: key);

  @override
  _VideoListPageState createState() => _VideoListPageState();
}

class _VideoListPageState extends State<VideoListPage> {
  Future<List<dynamic>?> _fetchVideos() async {
    try {
      final token = await SharedPrefs.fetchAccessToken();
      var url = Uri.parse(
          '${baseUri}attendances/video/?course_id=${widget.courseId}&token=$token');
      var response = await Future.any([
        http.get(url, headers: {
          "Authorization": 'JWT $token',
          "Content-Type": "application/json",
        }),
        Future.delayed(
          const Duration(seconds: 15),
          () => throw TimeoutException("Request timeout"),
        ),
      ]);
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.only(top: 8.h, bottom: 16.h),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.courseName,
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
              ),
              SizedBox(height: 10.h),
              Expanded(
                child: FutureBuilder(
                  future: _fetchVideos(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Text(
                          'No videos available',
                          style: TextStyle(
                            fontSize: 18.sp,
                            color: kColorTextDarkGrey,
                          ),
                        ),
                      );
                    }
                    final videos = snapshot.data!;
                    return _buildVideoList(videos);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoList(List<dynamic> videos) {
    return ListView.builder(
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final video = videos[index];
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => VideoPlayerPage(
                  videoId: video['id'],
                  videoUrl: video['video_url'],
                  title: video['title'],
                ),
              ),
            );
          },
          child: Container(
            margin: EdgeInsets.only(bottom: 16.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildThumbnail(video),
                _buildVideoInfo(video),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildThumbnail(Map<String, dynamic> video) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(14.r),
            topRight: Radius.circular(14.r),
          ),
          child: video['thumbnail_url'] != null
              ? Image.network(
                  video['thumbnail_url'],
                  width: double.infinity,
                  height: 150.h,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 150.h,
                    color: Colors.grey.shade200,
                    child: Icon(Icons.videocam,
                        size: 48.sp, color: Colors.grey),
                  ),
                )
              : Container(
                  width: double.infinity,
                  height: 150.h,
                  color: Colors.grey.shade200,
                  child:
                      Icon(Icons.videocam, size: 48.sp, color: Colors.grey),
                ),
        ),
        Positioned(
          top: 10,
          left: 10,
          child: Container(
            width: 28.w,
            height: 28.w,
            decoration: BoxDecoration(
              color: kColorPrimary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${video['order']}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Center(
            child: Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 28.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoInfo(Map<String, dynamic> video) {
    return Padding(
      padding: EdgeInsets.all(12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            video['title'] ?? '',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (video['description'] != null &&
              video['description'].toString().isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 4.h),
              child: Text(
                video['description'],
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: kColorTextDarkGrey,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
