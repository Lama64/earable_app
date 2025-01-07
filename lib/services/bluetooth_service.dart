import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

// Provides the data of the earable.
// Methods taken from https://github.com/teco-kit/cosinuss-flutter-new.
// Methods are adapted for use with a provider and to include error handling.
class BluetoothService extends ChangeNotifier {
  String _connectionStatus = "Disconnected";
  String _heartRate = "- bpm";

  String _accX = "-";
  String _accY = "-";
  String _accZ = "-";

  bool _isConnected = false;

  bool earConnectFound = false;

  String get connectionStatus => _connectionStatus;
  String get heartRate => _heartRate;
  String get accX => _accX;
  String get accY => _accY;
  String get accZ => _accZ;
  bool get isConnected => _isConnected;

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

    var bpmLabel = "- bpm";
    if (bpm != 0) {
      bpmLabel = "$bpm bpm";
    }
    _heartRate = bpmLabel;
    notifyListeners();
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

    _accX = "$accX (unknown unit)";
    _accY = "$accY (unknown unit)";
    _accZ = "$accZ (unknown unit)";
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

    if (permissionStatus.isPermanentlyDenied) {
      throw Exception('Location permissions denied.');
    }
    try {
      // start scanning
      FlutterBluePlus.startScan();

      // listen to scan results
      FlutterBluePlus.scanResults.listen((results) async {
        // do something with scan results
        for (ScanResult r in results) {
          if (r.device.platformName == "earconnect" && !earConnectFound) {
            earConnectFound =
                true; // avoid multiple connects attempts to same device

            await FlutterBluePlus.stopScan();

            r.device.connectionState.listen((state) {
              // listen for connection state changes
              _isConnected = state == BluetoothConnectionState.connected;
              _connectionStatus = (_isConnected) ? "Connected" : "Disconnected";

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
      if (!earConnectFound) {
        throw Exception('No earable found.');
      }
    } catch (exception) {
      throw Exception('Failed to connect to earable: $exception');
    }
  }
}
