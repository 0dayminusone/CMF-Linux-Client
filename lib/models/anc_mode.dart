// ANC modes, maps to the byte values found packet sniffing BL values, see in the bl dart file for exact byte values
enum AncMode { high, mid, low, adaptive, transparency, off }

extension AncModeExtension on AncMode {
  int get value {
    switch (this) {
      case AncMode.adaptive:
        return 4;
      case AncMode.high:
        return 1;
      case AncMode.mid:
        return 2;
      case AncMode.low:
        return 3;
      case AncMode.transparency:
        return 7;
      case AncMode.off:
        return 5;
    }
  }

  String get displayName {
    switch (this) {
      case AncMode.high:
        return 'High';
      case AncMode.mid:
        return 'Mid';
      case AncMode.low:
        return 'Low';
      case AncMode.adaptive:
        return 'Adaptive';
      case AncMode.transparency:
        return 'Transparency';
      case AncMode.off:
        return 'Off';
    }
  }

  String get description {
    switch (this) {
      case AncMode.high:
        return 'Maximum noise cancellation';
      case AncMode.mid:
        return 'Balanced noise cancellation';
      case AncMode.low:
        return 'Light noise cancellation';
      case AncMode.adaptive:
        return 'Auto-adjusting cancellation';
      case AncMode.transparency:
        return 'Transparent (different from 0 ANC)';
      case AncMode.off:
        return 'No cancellation';
    }
  }
}
