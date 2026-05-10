import 'package:permission_handler/permission_handler.dart' as ph;

/// 麦克风权限服务。封装 permission_handler，给 UI 层一个最小 API。
class MicPermissionService {
  /// 检查权限状态，未授予则请求。
  ///
  /// 返回 true 表示拿到了权限。
  Future<bool> ensureGranted() async {
    final status = await ph.Permission.microphone.status;
    if (status.isGranted) return true;
    if (status.isPermanentlyDenied) return false;
    final result = await ph.Permission.microphone.request();
    return result.isGranted;
  }

  Future<ph.PermissionStatus> currentStatus() =>
      ph.Permission.microphone.status;

  Future<bool> openSystemSettings() => ph.openAppSettings();
}
