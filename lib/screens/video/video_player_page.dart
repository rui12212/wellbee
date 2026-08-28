import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:wellbee/assets/inet.dart';
import 'package:wellbee/ui_function/shared_prefs.dart';

class VideoPlayerPage extends StatefulWidget {
  final int videoId;
  final String videoUrl;
  final String title;

  const VideoPlayerPage({
    Key? key,
    required this.videoId,
    required this.videoUrl,
    required this.title,
  }) : super(key: key);

  @override
  _VideoPlayerPageState createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;
  int? _recordId;
  bool _hasRecordedCompletion = false;
  bool _showSkipButtons = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
    _postViewingRecord();
  }

  Future<void> _initVideo() async {
    _videoController = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
    );
    await _videoController.initialize();
    _chewieController = ChewieController(
      videoPlayerController: _videoController,
      autoPlay: true,
      looping: false,
    );

    _videoController.addListener(_onVideoStateChanged);
    setState(() {});
  }

  void _onVideoStateChanged(){
    if(_videoController.value.isCompleted && !_hasRecordedCompletion){
      _hasRecordedCompletion = true;
      _patchViewingRecord();
    }
  }

  Future<void> _postViewingRecord() async {
    try{
      final token = await SharedPrefs.fetchAccessToken();
      var url = Uri.parse('${baseUri}attendances/viewing_record/?token=$token');
      var response = await http.post(
        url,
        headers: {
          "Authorization": 'JWT $token',
          "Content-Type": "application/json",
        },
        body: jsonEncode({"video": widget.videoId}),
      );
      if(response.statusCode == 200 || response.statusCode == 201){
        final data = jsonDecode(response.body);
        _recordId = data['id'];
      }
    }catch(e){}
  }

  Future<void> _patchViewingRecord() async {
    if(_recordId == null) return;
    try{
      final token = await SharedPrefs.fetchAccessToken();
      var url = Uri.parse(
        '${baseUri}attendances/viewing_record/$_recordId/?token=$token'
      );
      await http.patch(
        url,
        headers: {
          "Authorization": 'JWT $token',
          "Content-Type": "application/json",
        },
        body: jsonEncode({"is_completed": true}),
      );
    }catch(e){}
  }

  @override
  void dispose(){
    _videoController.removeListener(_onVideoStateChanged);
    _videoController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        toolbarHeight: isLandscape ? 36 : null,
        title: Text(
          widget.title,
          style: TextStyle(fontSize: isLandscape ? 14 : 18),
        ),
      ),
      body: _chewieController != null
          ? Center(
              child: AspectRatio(
                aspectRatio: _videoController.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Chewie(controller: _chewieController!),
                    Positioned.fill(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          setState(() { _showSkipButtons = !_showSkipButtons; });
                        },
                      ),
                    ),
                    if (_showSkipButtons)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              final current = _videoController.value.position;
                              _videoController.seekTo(
                                current - const Duration(seconds: 15),
                              );
                            },
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.replay_10,
                                  color: Colors.white70, size: 30),
                            ),
                          ),
                          const SizedBox(width: 60),
                          GestureDetector(
                            onTap: () {
                              final current = _videoController.value.position;
                              _videoController.seekTo(
                                current + const Duration(seconds: 15),
                              );
                            },
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.forward_10,
                                  color: Colors.white70, size: 30),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            )
          : const Center(child: CircularProgressIndicator(color: Colors.white)),
    );
  }

}
