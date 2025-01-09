import 'dart:math';
import 'dart:typed_data';
import 'dart:async';

import 'package:earable_app/models/session.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

// Provides the data of the earable.
// Methods taken from https://github.com/teco-kit/cosinuss-flutter-new.
// Methods are adapted for use with a provider and to include error handling.
class BluetoothService extends ChangeNotifier {
  String _heartRate = "-";
  int _simulatedHeartRate = 80;
  bool _useSimulatedHeartRate = false;

  String _accX = "-";
  String _accY = "-";
  String _accZ = "-";

  String _connectionStatus = "Disconnected";
  bool _isConnected = false;

  bool _earConnectFound = false;

  Timer? _heartRateTimer;
  int _activeSessionId = -1;

  String get connectionStatus => _connectionStatus;
  String get heartRate => _heartRate;
  String get simulatedHeartRate => _simulatedHeartRate.toString();
  bool get useSimulatedHeartRate => _useSimulatedHeartRate;
  String get accX => _accX;
  String get accY => _accY;
  String get accZ => _accZ;
  bool get isConnected => _isConnected;
  int get activeSessionId => _activeSessionId;

  void updateHeartRate(rawData) {
    if (rawData.length < 2) {
      return;
    }
    Uint8List bytes = Uint8List.fromList(rawData);

    // based on GATT standard
    var bpm = bytes[1];
    if (!((bytes[0] & 0x01) == 0)) {
      bpm = (((bpm >> 8) & 0xFF) | ((bpm << 8) & 0xFF00));
    }

    if (bpm != 0) {
      _heartRate = bpm.toString();
    } else {
      _heartRate = "-";
    }
    notifyListeners();
  }

  // Simulate heart rate as sensor does not seem to provide real data
  int _simulateHeartRate() {
    _simulatedHeartRate = _simulatedHeartRate + (Random().nextInt(5) - 2);
    if (_simulatedHeartRate < 40) {
      _simulatedHeartRate = 40;
    } else if (_simulatedHeartRate > 120) {
      _simulatedHeartRate = 120;
    }
    return _simulatedHeartRate;
  }

  void updateHeartRatePoints(bool useSimulatedHeartRate, Session session) {
    _useSimulatedHeartRate = useSimulatedHeartRate;
    _activeSessionId = session.id;
    _heartRateTimer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      int heartRate;
      if (useSimulatedHeartRate) {
        heartRate = _simulateHeartRate();
      } else {
        heartRate = int.tryParse(_heartRate) ?? 40;
      }
      session.elapsedTime = session.elapsedTime + 0.5;
      session.heartRatePoints
          .add(FlSpot(session.elapsedTime.toDouble(), heartRate.toDouble()));
      notifyListeners();
    });
  }

  void stopHeartRatePoints() {
    _activeSessionId = -1;
    _heartRateTimer?.cancel();
  }

  void updateAccelerometer(rawData) {
    if (rawData.length < 19) {
      return;
    }
    Int8List bytes = Int8List.fromList(rawData);

    // description based on placing the earable into your right ear canal
    int accX = bytes[14];
    int accY = bytes[16];
    int accZ = bytes[18];

    _accX = accX.toString();
    _accY = accY.toString();
    _accZ = accZ.toString();
    notifyListeners();
  }

  int twosComplimentOfNegativeMantissa(int mantissa) {
    if ((4194304 & mantissa) != 0) {
      return (((mantissa ^ -1) & 16777215) + 1) * -1;
    }

    return mantissa;
  }

  Future<void> connect() async {
    var permissionStatus = await Permission.location.request();

    if (permissionStatus.isDenied) {
      throw Exception('Location permissions denied.');
    }

    // start scanning
    FlutterBluePlus.startScan();

    // listen to scan results
    FlutterBluePlus.scanResults.listen((results) async {
      // do something with scan results
      for (ScanResult r in results) {
        if (r.device.platformName == "earconnect" && !_earConnectFound) {
          _earConnectFound =
              true; // avoid multiple connects attempts to same device

          await FlutterBluePlus.stopScan();

          r.device.connectionState.listen((state) {
            // listen for connection state changes
            _isConnected = state == BluetoothConnectionState.connected;
            _connectionStatus = (_isConnected) ? "Connected" : "Disconnected";
            if (!_isConnected) {
              stopHeartRatePoints();
            }

            notifyListeners();
          });

          await r.device.connect();

          var services = await r.device.discoverServices();

          for (var service in services) {
            // iterate over services
            for (var characteristic in service.characteristics) {
              // iterate over characteristics

              switch (characteristic.uuid.toString()) {
                case "0000a001-1212-efde-1523-785feabcd123":
                  await characteristic.write([
                    0x32,
                    0x31,
                    0x39,
                    0x32,
                    0x37,
                    0x34,
                    0x31,
                    0x30,
                    0x35,
                    0x39,
                    0x35,
                    0x35,
                    0x30,
                    0x32,
                    0x34,
                    0x35
                  ]);
                  await Future.delayed(Duration(
                      seconds:
                          2)); // short delay before next bluetooth operation otherwise BLE crashes
                  characteristic.lastValueStream.listen((rawData) {
                    updateAccelerometer(rawData);
                  });
                  await characteristic.setNotifyValue(true);
                  await Future.delayed(Duration(seconds: 2));
                  break;

                case "00002a37-0000-1000-8000-00805f9b34fb":
                  characteristic.lastValueStream.listen((rawData) {
                    updateHeartRate(rawData);
                  });
                  await characteristic.setNotifyValue(true);
                  await Future.delayed(Duration(
                      seconds:
                          2)); // short delay before next bluetooth operation otherwise BLE crashes
                  break;

                default:
                  break;
              }
            }
          }
        }
      }
    }, onError: (error) {
      throw error;
    });

    await Future.delayed(Duration(seconds: 4));
    FlutterBluePlus.stopScan();
    if (!_earConnectFound) {
      throw Exception('No earable found.');
    }
  }

  @override
  void dispose() {
    _heartRateTimer?.cancel();
    super.dispose();
  }
}
