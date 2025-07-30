import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';

class BatteryView extends StatefulWidget {
  const BatteryView({super.key});

  @override
  State<BatteryView> createState() => _BatteryViewState();
}

class _BatteryViewState extends State<BatteryView> {
  // MethodChannel 할당
  final MethodChannel platform = MethodChannel('samples.flutter.dev/battery');

  // Rive 애니메이션 컨트롤러
  StateMachineController? _controller;

  // 배터리 레벨 변수
  String _batteryLevel = '0 %';

  Future<void> _getBatteryLevel() async {
    String batteryLevel;
    int? result;

    try {
      // 네이티브 함수 이름
      result = await platform.invokeMethod<int>('getBatteryLevel');

      batteryLevel = '$result %';
    } on PlatformException catch (e) {
      batteryLevel = "Failed to get battery level: '${e.message}'";
    }

    _batteryLevel = batteryLevel;

    // Rive 애니메이션 input값 업데이트
    if (_controller != null) {
      // input 변수 이름으로 불러오기
      final SMIInput? input = _controller!.getNumberInput('charge_rate');

      log("${input != null}");
      if (input != null) {
        // 업데이트
        input.change(result!.toDouble());
      }
    }

    // rebuild
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _getBatteryLevel();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 20,
          children: [
            Text(_batteryLevel, style: TextStyle(fontSize: 30)),
            SizedBox(
              height: 200,
              child: RiveAnimation.asset(
                "assets/battery.riv",
                artboard: "Artboard", // Rive에서 설정한 Artboard 이름
                stateMachines: [
                  "State Machine 1",
                ], // Rive에서 설정한 State Machine 이름
                onInit: (p0) {
                  _controller = StateMachineController.fromArtboard(
                    p0,
                    "State Machine 1",
                  );

                  p0.addController(_controller!);
                },
              ),
            ),
            FilledButton.tonal(
              onPressed: _getBatteryLevel,
              child: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
}
