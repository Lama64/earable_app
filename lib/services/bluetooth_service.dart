import 'dart:math';
import 'dart:typed_data';
import 'dart:async';

import 'package:earable_app/models/session.dart';
import 'package:earable_app/services/show_error.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

// Provides the data of the earable.
// Methods taken from https://github.com/teco-kit/cosinuss-flutter-new.
// Methods are adapted for use with a provider and to include error handling.
class BluetoothService extends ChangeNotifier {
  String heartRate = "-";
  int simulatedHeartRate = 80;
  bool useSimulatedHeartRate = false;

  String accX = "-";
  String accY = "-";
  String accZ = "-";

  String connectionStatus = "Disconnected";
  bool isConnected = false;

  bool _earConnectFound = false;

  Timer? _heartRatePointsTimer;
  Timer? _simulatedHeartRateTimer;
  Timer? _movementTimer;

  int activeSessionId = -1;

  BluetoothService(this.useSimulatedHeartRate) {
    _startSimulateHeartRate();
  }

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
      heartRate = bpm.toString();
    } else {
      heartRate = "-";
    }
    notifyListeners();
  }

  /// Simulate heart rate as sensor does not seem to provide real data
  int _simulateHeartRate() {
    simulatedHeartRate = simulatedHeartRate + (Random().nextInt(5) - 2);
    if (simulatedHeartRate < 60) {
      simulatedHeartRate = 60;
    } else if (simulatedHeartRate > 120) {
      simulatedHeartRate = 120;
    }
    return simulatedHeartRate;
  }

  void _startSimulateHeartRate() {
    if (_simulatedHeartRateTimer != null &&
        _simulatedHeartRateTimer!.isActive) {
      return;
    }
    _simulatedHeartRateTimer =
        Timer.periodic(Duration(milliseconds: 500), (timer) {
      _simulateHeartRate();
      notifyListeners();
    });
  }

  void startSessionLogging(bool useSimulatedHeartRate, Session session) {
    useSimulatedHeartRate = useSimulatedHeartRate;
    activeSessionId = session.id;
    _movementTimer = Timer.periodic(Duration(milliseconds: 250), (timer) {
      session.totalMovementAmount++;
      if (calculateMagnitude() > 33) {
        session.amountOverThreshold++;
      }
    });
    _heartRatePointsTimer =
        Timer.periodic(Duration(milliseconds: 500), (timer) {
      int heartRate;
      if (useSimulatedHeartRate) {
        heartRate = simulatedHeartRate;
      } else {
        if (int.tryParse(this.heartRate) == null) {
          return;
        }
        heartRate = int.tryParse(this.heartRate) ?? 80;
      }
      session.duration = session.duration + 0.5;
      session.heartRatePoints
          .add(FlSpot(session.duration.toDouble(), heartRate.toDouble()));
      notifyListeners();
    });
  }

  void endSessionLogging() {
    activeSessionId = -1;
    _heartRatePointsTimer?.cancel();
    _movementTimer?.cancel();
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

    this.accX = accX.toString();
    this.accY = accY.toString();
    this.accZ = accZ.toString();
    notifyListeners();
  }

  double calculateMagnitude() {
    double? x = double.tryParse(accX);
    double? y = double.tryParse(accY);
    double? z = double.tryParse(accZ);
    if (x == null || y == null || z == null) {
      return 0;
    }
    return sqrt(x * x + y * y + z * z);
  }

  int twosComplimentOfNegativeMantissa(int mantissa) {
    if ((4194304 & mantissa) != 0) {
      return (((mantissa ^ -1) & 16777215) + 1) * -1;
    }

    return mantissa;
  }

  Future<void> connect(BuildContext context) async {
    var permissionStatus = await Permission.location.request();

    if (permissionStatus.isDenied) {
      if (context.mounted) {
        showError(context, 'Location permission is required to connect.');
      }
    }

    // start scanning
    FlutterBluePlus.startScan();

    try {
      // listen to scan results
      FlutterBluePlus.scanResults.listen((results) async {
        // do something with scan results
        for (ScanResult r in results) {
          if (r.device.platformName == "earconnect" && !_earConnectFound) {
            _earConnectFound =
                true; // avoid multiple connects attempts to same device

            await FlutterBluePlus.stopScan();
            _startSimulateHeartRate();

            r.device.connectionState.listen((state) {
              // listen for connection state changes
              isConnected = state == BluetoothConnectionState.connected;
              connectionStatus = (isConnected) ? "Connected" : "Disconnected";
              if (!isConnected) {
                _earConnectFound = false;
                endSessionLogging();
              }

              notifyListeners();
            });
            try {
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
            } catch (exception) {
              if (context.mounted) {
                showError(context, exception.toString());
              }
            }
          }
        }
      }, onError: (error) {
        throw error;
      });

      await Future.delayed(Duration(seconds: 5));
      FlutterBluePlus.stopScan();
      if (!isConnected && context.mounted) {
        showError(context, 'No Earable found.');
      }
    } catch (exception) {
      if (context.mounted) {
        showError(context, exception.toString());
      }
    }
  }

  @override
  void dispose() {
    _heartRatePointsTimer?.cancel();
    _simulatedHeartRateTimer?.cancel();
    _movementTimer?.cancel();
    super.dispose();
  }
}
