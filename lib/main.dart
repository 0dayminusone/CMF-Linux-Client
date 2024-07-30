import 'package:flutter/material.dart'; // using the default fluttr ui lib, NOTE: might migrate to microsofts fluent design lib
import 'models/anc_mode.dart';
import 'models/device_state.dart';
import 'models/device_info.dart';
import 'services/bluetooth_service.dart';

void main() {
  runApp(const CMFNixApp());
}

class CMFNixApp extends StatelessWidget {
  const CMFNixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CMF Nix', // final name; play on "CMF & Nix as in the OS family"
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF0073), // reddish pink colourscheme
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF0073),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.dark,
      home: const EarbudsControlPage(),
    );
  }
}

class EarbudsControlPage extends StatefulWidget {
  const EarbudsControlPage({super.key});

  @override
  State<EarbudsControlPage> createState() => _EarbudsControlPageState();
}

class _EarbudsControlPageState extends State<EarbudsControlPage> {
  final BluetoothService _bluetoothService = BluetoothService();
  DeviceState _deviceState = const DeviceState();
  bool _isConnecting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('CMF Nix - For the CMF Nothing Earbuds'),
        actions: [
          IconButton(
            icon: Icon(
              _deviceState.isConnected
                  ? Icons.bluetooth_connected
                  : Icons.bluetooth_disabled,
            ),
            onPressed: _deviceState.isConnected ? _disconnect : _connect,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // connection status toast thingy
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Connection Status',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          _deviceState.isConnected
                              ? Icons.check_circle
                              : Icons.error,
                          color: _deviceState.isConnected
                              ? Colors.green
                              : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _deviceState.isConnected
                              ? 'Connected'
                              : 'Disconnected',
                        ),
                      ],
                    ),
                    if (_deviceState.connectionError != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Error: ${_deviceState.connectionError}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                    if (_isConnecting) ...[
                      const SizedBox(height: 8),
                      const Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Connecting...'),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // device info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Device Information',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    if (_deviceState.isConnected &&
                        _deviceState.deviceInfo != null) ...[
                      _buildInfoRow(
                        'Bluetooth Address',
                        _deviceState.deviceInfo!.bluetoothAddress,
                      ),
                      if (_deviceState.deviceInfo!.lastConnected != null)
                        _buildInfoRow(
                          'Last Connected',
                          _deviceState.deviceInfo!.lastConnected!
                              .toLocal()
                              .toString()
                              .split('.')[0],
                        ),
                    ] else ...[
                      const Text(
                        'Connect to earbuds to view device information',
                        style: TextStyle(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // anc controls
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Active Noise Cancellation',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    Text('Current mode: ${_deviceState.ancMode.displayName}'),
                    const SizedBox(height: 8),
                    Text(
                      _deviceState.ancMode.description,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      children: AncMode.values.map((mode) {
                        final isSelected = mode == _deviceState.ancMode;
                        final isEnabled = _deviceState.isConnected;
                        return FilterChip(
                          label: Text(mode.displayName),
                          selected: isSelected,
                          onSelected: isEnabled
                              ? (selected) {
                                  if (selected && !isSelected) {
                                    _setAncMode(mode);
                                  }
                                }
                              : null,
                        );
                      }).toList(),
                    ),
                    if (!_deviceState.isConnected)
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Connect to earbuds to control ANC',
                          style: TextStyle(
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // other controls
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Settings',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Low Latency Mode'),
                      subtitle: const Text(
                        'Gaming mode for reduced audio delay',
                      ),
                      value: _deviceState.lowLatencyMode,
                      onChanged: _deviceState.isConnected
                          ? _setLowLatencyMode
                          : null,
                    ),
                    if (!_deviceState.isConnected)
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Connect to earbuds to change settings',
                          style: TextStyle(
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // handling
  Future<void> _connect() async {
    setState(() {
      _isConnecting = true;
      _deviceState = _deviceState.copyWith(connectionError: null);
    });

    try {
      final success = await _bluetoothService.connect();

      if (success) {
        // get device info
        final info = DeviceInfo(
          bluetoothAddress: await _bluetoothService.getBluetoothAddress(),
          lastConnected: DateTime.now(),
        );

        setState(() {
          _deviceState = DeviceState.connected(info).copyWith(
            ancMode: _bluetoothService.currentAncMode,
            lowLatencyMode: _bluetoothService.lowLatencyMode,
          );
        });
      } else {
        setState(() {
          _deviceState = DeviceState.disconnected(
            error: 'Failed to connect to earbuds',
          );
        });
      }
    } catch (e) {
      setState(() {
        _deviceState = DeviceState.disconnected(error: e.toString());
      });
    } finally {
      setState(() {
        _isConnecting = false;
      });
    }
  }

  Future<void> _disconnect() async {
    await _bluetoothService.disconnect();
    setState(() {
      _deviceState = DeviceState.disconnected();
    });
  }

  Future<void> _setAncMode(AncMode mode) async {
    try {
      await _bluetoothService.setAncMode(mode);
      setState(() {
        _deviceState = _deviceState.copyWith(ancMode: mode);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to set ANC mode: $e')));
      }
    }
  }

  Future<void> _setLowLatencyMode(bool enabled) async {
    try {
      await _bluetoothService.setLowLatencyMode(enabled);
      setState(() {
        _deviceState = _deviceState.copyWith(lowLatencyMode: enabled);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to set low latency mode: $e')),
        );
      }
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontFamily: 'monospace')),
          ),
        ],
      ),
    );
  }
}
