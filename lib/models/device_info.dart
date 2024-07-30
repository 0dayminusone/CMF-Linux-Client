// vars
class DeviceInfo {
  final String bluetoothAddress;
  final DateTime? lastConnected;

  const DeviceInfo({required this.bluetoothAddress, this.lastConnected});

  // json conv
  Map<String, dynamic> toJson() {
    return {
      'bluetoothAddress': bluetoothAddress,
      'lastConnected': lastConnected?.toIso8601String(),
    };
  }

  factory DeviceInfo.fromJson(Map<String, dynamic> json) {
    return DeviceInfo(
      bluetoothAddress: json['bluetoothAddress'] as String,
      lastConnected: json['lastConnected'] != null
          ? DateTime.parse(json['lastConnected'] as String)
          : null,
    );
  }

  DeviceInfo copyWith({String? bluetoothAddress, DateTime? lastConnected}) {
    return DeviceInfo(
      bluetoothAddress: bluetoothAddress ?? this.bluetoothAddress,
      lastConnected: lastConnected ?? this.lastConnected,
    );
  }

  @override
  String toString() {
    return 'DeviceInfo(address: $bluetoothAddress)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeviceInfo &&
        other.bluetoothAddress == bluetoothAddress &&
        other.lastConnected == lastConnected;
  }

  @override
  int get hashCode {
    return bluetoothAddress.hashCode ^ lastConnected.hashCode;
  }
}
