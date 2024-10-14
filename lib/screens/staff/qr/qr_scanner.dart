import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:wellbee/screens/staff/qr/scandata_widget.dart';
import 'package:wellbee/ui_parts/color.dart';

class ScannerWidget extends StatefulWidget {
  const ScannerWidget({super.key});

  @override
  State<ScannerWidget> createState() => _ScannerWidgetState();
}

class _ScannerWidgetState extends State<ScannerWidget>
    with SingleTickerProviderStateMixin {
  MobileScannerController controller = MobileScannerController();
  bool isStarted = true;
  double zoomFactor = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   backgroundColor: kColorPrimary,
        //   title: const Text('Scan QR code'),
        // ),
        backgroundColor: Colors.black,
        body: Builder(builder: (context) {
          return SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                    height: MediaQuery.of(context).size.width * 4 / 3,
                    child: MobileScanner(
                        controller: controller,
                        fit: BoxFit.contain,
                        onDetect: (scandata) {
                          setState(() {
                            controller.stop();
                            Navigator.of(context)
                                .pushReplacement(MaterialPageRoute(
                              builder: (context) {
                                return ScanDataWidget(scandata: scandata);
                              },
                            ));
                          });
                        })),
                Slider(
                    value: zoomFactor,
                    onChanged: (sliderValue) {
                      setState(() {
                        zoomFactor = sliderValue;
                        controller.setZoomScale(sliderValue);
                      });
                    }),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // IconButton(
                      // // アイコンの表示はオン／オフによって変わる
                      // icon: ValueListenableBuilder(
                      //   valueListenable: controller,
                      //   builder: (context, state, child) {

                      //     switch (state) {
                      //       // オフしている場合、オンにする
                      //       case TorchState.off:
                      //         return const Icon(
                      //           Icons.flash_off,
                      //           color: Colors.grey,
                      //         );
                      //       // オンしている場合、オフにする
                      //       case TorchState.on:
                      //         return const Icon(
                      //           Icons.flash_on,
                      //           color: Color(0xFFFFDDBB),
                      //         );
                      //     }
                      //   },
                      // ),
                      // iconSize: 50,
                      // // ボタンが押されたら切り替えを実行する
                      // onPressed: () => controller.toggleTorch()),
                      // カメラのオン／オフのボタン
                      IconButton(
                        color: const Color(0xFFBBDDFF),
                        // オン／オフの状態によって表示するアイコンが変わる
                        icon: isStarted
                            ? const Icon(Icons.stop) // ストップのアイコン
                            : const Icon(Icons.play_arrow), // プレイのアイコン
                        iconSize: 50.h,
                        // ボタンが押されたらオン／オフを実行する
                        onPressed: () => setState(() {
                          isStarted ? controller.stop() : controller.start();
                          isStarted = !isStarted;
                        }),
                      ),
                      // アイコン前のカメラと裏のカメラを切り替えるボタン
                      // IconButton(
                      //   color: const Color(0xFFBBDDFF),
                      //   icon: ValueListenableBuilder<CameraFacing>(
                      //     // アイコンの表示は使っているカメラによって変わる
                      //     valueListenable: controller.cameraFacing,
                      //     builder: (context, state, child) {
                      //       switch (state) {
                      //         // 前のカメラの場合
                      //         case CameraFacing.front:
                      //           return const Icon(Icons.camera_front);
                      //         // 後ろのカメラの場合
                      //         case CameraFacing.back:
                      //           return const Icon(Icons.camera_rear);
                      //       }
                      //     },
                      //   ),
                      //   iconSize: 50,
                      //   onPressed: () {
                      //     if (isStarted) {
                      //       controller.switchCamera();
                      //     }
                      //   },
                      // ),
                    ])
              ],
            ),
          );
        }));
  }
}
