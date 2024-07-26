import 'dart:async';
import 'package:flutter/services.dart';
import 'package:bluez/bluez.dart';
import '../models/anc_mode.dart';

// bluez plugin for linux rfcomm connection TODO: Make platform agnostic with flutter ffi
class BluetoothService {
  static const String _devicePrefix =
      '2C:BE:EB'; // all cmf nothing device start with mac prefix
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
}
