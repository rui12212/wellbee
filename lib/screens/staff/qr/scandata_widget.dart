import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:wellbee/assets/inet.dart';
import 'package:wellbee/screens/staff/qr/qr_scanner.dart';
import 'package:wellbee/screens/staff/qr_after/check_in.dart';
import 'package:wellbee/screens/staff/qr_after/user_home.dart';
import 'package:wellbee/screens/staff/qr_after_point/point_select.dart';

class ScanDataWidget extends StatefulWidget {
  final BarcodeCapture? scandata;

  const ScanDataWidget({
    super.key,
    this.scandata,
  });

  @override
  State<ScanDataWidget> createState() => _ScanDataWidgetState();
}

class _ScanDataWidgetState extends State<ScanDataWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleScannedData();
    });
  }

  void _handleScannedData() {
    if (widget.scandata == null || widget.scandata!.barcodes.isEmpty) {
      _showError('scan data is invalid');
      return;
    }

    String codeValue = widget.scandata!.barcodes.first.rawValue ?? '';
    BarcodeType? codeType = widget.scandata!.barcodes.first.type;

    if (codeValue.isEmpty) {
      _showError('The data is empty');
      return;
    }

    // URLがユーザー情報の場合
    if (codeValue.contains("${baseUri}accounts/users")) {
      String pk = codeValue.split("/").last;
      if (pk.isNotEmpty) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) {
            return UserHomePage(pk: pk);
          },
        ));
        return;
      }
    }

    if (codeValue.contains("${baseUri}accounts/users/points")) {
      String pk = codeValue.split("/").last;
      if (pk.isNotEmpty) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) {
            return PointSelectPage(pk: pk);
          },
        ));
        return;
      }
    }

    // URLが予約情報の場合
    if (codeValue.contains(
        '${baseUri}reservations/reservation/qr_reservation?reservation_id=')) {
      String id = codeValue.split('reservation_id=').last;
      if (id.isNotEmpty) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) {
            return CheckInPage(id: id);
          },
        ));
        return;
      }
    }

    // 条件に一致しない場合
    _showError('Cannot scan data properly');
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error happened'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // ダイアログを閉じる
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => const ScannerWidget(),
              ));
            },
            child: const Text('Try again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 一時的にローディングインジケーターを表示
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanning...'),
      ),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}


// class ScanDataWidget extends StatelessWidget {
//   final BarcodeCapture? scandata;
//   const ScanDataWidget({
//     super.key,
//     this.scandata,
//   });

//   @override
//   Widget build(BuildContext context) {
//     String codeValue = scandata?.barcodes.first.rawValue ?? 'null';
//     BarcodeType? codeType = scandata?.barcodes.first.type;

//     // もしもURLがmembership購入だったらー＞UserHomeに飛ばす

//     // URLがcheckinだったら->checkin画面に飛ばす
//     if (codeValue.contains("${baseUri}accounts/users/")) {
//       String pk = codeValue.split("/").last;
//       Navigator.of(context).pushReplacement(MaterialPageRoute(
//         builder: (context) {
//           return UserHomePage(pk: pk);
//         },
//       ));
//     }
//     if (codeValue.contains(
//         '${baseUri}reservations/reservation/qr_reservation?reservation_id=')) {
//       String id = codeValue.split('reservation_id=').last;
//       Navigator.of(context).pushReplacement(MaterialPageRoute(
//         builder: (context) {
//           return CheckInPage(id: id);
//         },
//       ));
//     }
//     return Container(child: Text('No scanned data'));
//   }
// }
