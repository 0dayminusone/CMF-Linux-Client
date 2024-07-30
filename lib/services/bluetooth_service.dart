import 'dart:async';
import 'package:flutter/services.dart';
import 'package:bluez/bluez.dart';
import '../models/anc_mode.dart';

// bluez plugin for linux rfcomm connection TODO: Make platform agnostic with flutter ffi
class BluetoothService {
  static const String _devicePrefix =
      '2C:BE:EB'; // all cmf nothing device start with mac prefix
  static const int _rfcommChannelNum = 15; // rfcomm channel

  BlueZClient? _client;
  BlueZDevice? _connectedDevice;
  int? _socketId;

  static const MethodChannel _rfcommChannel = MethodChannel('rfcomm');

  // hardcoded packets

  static const List<int> _lowLatencyOn = [
    0x55,
    0x60,
    0x01,
    0x40,
    0xf0,
    0x02,
    0x00,
    0x27,
    0x01,
    0x00,
    0x97,
    0xf7,
  ];
  static const List<int> _lowLatencyOff = [
    0x55,
    0x60,
    0x01,
    0x40,
    0xf0,
    0x02,
    0x00,
    0x28,
    0x02,
    0x00,
    0xa7,
    0x04,
  ];

  static const List<int> _ancBase = [
    0x55,
    0x60,
    0x01,
    0x0f,
    0xf0,
    0x03,
    0x00,
    0xcd,
    0x01,
    0x00,
    0x00,
    0xc4,
    0x47,
  ];

  // states
  AncMode _currentAncMode = AncMode.off;
  bool _lowLatencyMode = false;

  bool get isConnected => _connectedDevice != null && _socketId != null;
  String? get deviceAddress => _connectedDevice?.address;
  AncMode get currentAncMode => _currentAncMode;
  bool get lowLatencyMode => _lowLatencyMode;

  Future<bool> connect() async {
    try {
      // init bluez client
      _client = BlueZClient();
      await _client!.connect();

      final device = await _findNothingDevice();
      if (device == null) {
        await _client?.close();
        return false;
      }

      for (int attempt = 1; attempt <= 3; attempt++) {
        try {
          await Future.delayed(Duration(milliseconds: attempt * 500));
          _socketId = await _connectRfcommSocket(
            device.address,
            _rfcommChannelNum,
          );
          _connectedDevice = device;

          return true;
        } catch (e) {
          if (attempt == 3) rethrow;
        }
      }

      return false;
    } catch (e) {
      await _client?.close();
      return false;
    }
  }

  Future<BlueZDevice?> _findNothingDevice() async {
    try {
      // check known devices
      for (final device in _client!.devices) {
        if (device.address.toUpperCase().startsWith(_devicePrefix)) {
          return device;
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  // connect rfcomm socket using methd
  Future<int> _connectRfcommSocket(String address, int channel) async {
    try {
      final result = await _rfcommChannel.invokeMethod('connect', {
        'address': address,
        'channel': channel,
      });

      if (result is int && result > 0) {
        return result;
      } else {
        throw Exception('invalid socket id returned');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> disconnect() async {
    try {
      // close sock
      if (_socketId != null) {
        await _rfcommChannel.invokeMethod('close', {'socket_id': _socketId});
        _socketId = null;
      }

      _connectedDevice = null;

      await _client?.close();
      _client = null;
    } catch (e) {}
  }

  Future<String> getBluetoothAddress() async {
    return _connectedDevice?.address ?? 'unknown';
  }

  // base send pkt func
  Future<void> _sendPacket(List<int> packet) async {
    if (_socketId == null) throw Exception('socket not connected');

    try {
      await _rfcommChannel.invokeMethod('send', {
        'socket_id': _socketId,
        'data': packet,
      });
    } catch (e) {
      rethrow;
    }
  }

  // anc pkt
  Future<void> setAncMode(AncMode mode) async {
    if (!isConnected) throw Exception('not connected');

    try {
      final packet = List<int>.from(_ancBase);
      packet[9] = mode.value;

      await _sendPacket(packet);
      _currentAncMode = mode;
    } catch (e) {
      rethrow;
    }
  }

  // low latency pkt
  Future<void> setLowLatencyMode(bool enabled) async {
    if (!isConnected) throw Exception('not connected');

    try {
      final packet = enabled ? _lowLatencyOn : _lowLatencyOff;
      await _sendPacket(packet);

      _lowLatencyMode = enabled;
    } catch (e) {
      rethrow;
    }
  }

  // check if bt mac matches pattern
  static bool isNothingDevice(String address) {
    return address.toUpperCase().startsWith(_devicePrefix);
  }
}
