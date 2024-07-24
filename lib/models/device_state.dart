import 'anc_mode.dart';
import 'device_info.dart';

class DeviceState {
  final bool isConnected;
  final DeviceInfo? deviceInfo;
  final AncMode ancMode;
  final bool lowLatencyMode;
  final String? connectionError;

  const DeviceState({
    this.isConnected = false,
    this.deviceInfo,
    this.ancMode = AncMode.off,
    this.lowLatencyMode = false,
    this.connectionError,
  });
}
