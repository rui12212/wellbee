import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:wellbee/assets/inet.dart';
import 'package:wellbee/screens/staff/qr_after/check_in.dart';
import 'package:wellbee/screens/staff/qr_after/user_home.dart';

class ScanDataWidget extends StatelessWidget {
  final BarcodeCapture? scandata;
  const ScanDataWidget({
    super.key,
    this.scandata,
  });

  @override
  Widget build(BuildContext context) {
    String codeValue = scandata?.barcodes.first.rawValue ?? 'null';
    BarcodeType? codeType = scandata?.barcodes.first.type;

    // もしもURLがmembership購入だったらー＞UserHomeに飛ばす

    // URLがcheckinだったら->checkin画面に飛ばす
    if (codeValue.contains("${baseUri}accounts/users/")) {
      String pk = codeValue.split("/").last;
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) {
          return UserHomePage(pk: pk);
        },
      ));
    }
    if (codeValue.contains(
        '${baseUri}reservations/reservation/qr_reservation?reservation_id=')) {
      String id = codeValue.split('reservation_id=').last;
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) {
          return CheckInPage(id: id);
        },
      ));
    }
    return Container(child: Text('No scanned data'));
  }
}
