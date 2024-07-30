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

  DeviceState copyWith({
    bool? isConnected,
    DeviceInfo? deviceInfo,
    AncMode? ancMode,
    bool? lowLatencyMode,
    String? connectionError,
  }) {
    return DeviceState(
      isConnected: isConnected ?? this.isConnected,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      ancMode: ancMode ?? this.ancMode,
      lowLatencyMode: lowLatencyMode ?? this.lowLatencyMode,
      connectionError: connectionError ?? this.connectionError,
    );
  }

  factory DeviceState.disconnected({String? error}) {
    return DeviceState(
      isConnected: false,
      deviceInfo: null,
      connectionError: error,
    );
  }

  factory DeviceState.connected(DeviceInfo deviceInfo) {
    return DeviceState(
      isConnected: true,
      deviceInfo: deviceInfo,
      connectionError: null,
    );
  }

  @override
  String toString() {
    return 'DeviceState(connected: $isConnected, anc: ${ancMode.displayName}, lowLatency: $lowLatencyMode)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeviceState &&
        other.isConnected == isConnected &&
        other.deviceInfo == deviceInfo &&
        other.ancMode == ancMode &&
        other.lowLatencyMode == lowLatencyMode &&
        other.connectionError == connectionError;
  }

  @override
  int get hashCode {
    return isConnected.hashCode ^
        deviceInfo.hashCode ^
        ancMode.hashCode ^
        lowLatencyMode.hashCode ^
        connectionError.hashCode;
  }
}
