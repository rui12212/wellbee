import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';

enum VersionStatus { upToDate, updateAvailable, forceUpdate }

class VersionCheckService {
  static Future<VersionStatus> check() async {
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: Duration.zero, // TODO: テスト後に Duration(hours: 1) に戻す
      ));
      await remoteConfig.setDefaults({
        'latest_version': '0.0.0',
        'minimum_required_version': '0.0.0',
      });
      await remoteConfig.fetchAndActivate();

      final latestVersion = remoteConfig.getString('latest_version');
      final minimumVersion = remoteConfig.getString('minimum_required_version');

      final info = await PackageInfo.fromPlatform();
      final currentVersion = info.version;

      if (_isOlderThan(currentVersion, minimumVersion)) {
        return VersionStatus.forceUpdate;
      } else if (_isOlderThan(currentVersion, latestVersion)) {
        return VersionStatus.updateAvailable;
      }
      return VersionStatus.upToDate;
    } catch (_) {
      return VersionStatus.upToDate;
    }
  }

  static bool _isOlderThan(String current, String target) {
    final c = current.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final t = target.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    for (var i = 0; i < 3; i++) {
      final cv = i < c.length ? c[i] : 0;
      final tv = i < t.length ? t[i] : 0;
      if (cv < tv) return true;
      if (cv > tv) return false;
    }
    return false;
  }
}
