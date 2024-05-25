import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class Sigma extends StatefulWidget {
  @override
  _SigmaState createState() => _SigmaState();
}

class _SigmaState extends State<Sigma> {
  List<String> players = [];
  List<String> marks = ["숫자1", "숫자2", "숫자3", "속박1", "속박2", "속박3"];
  List<int> dynamisStacks = [];
  List<String?> selectedMarks = [];
  List<String?> previousMarks = [];
  int helloWorldMeleeIndex = -1;
  int helloWorldRangedIndex = -1;
  late Stopwatch _stopwatch;
  Timer? _timer;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    players = List.generate(8, (index) => '플레이어 ${index + 1}');
    assignDynamisStacks();
    assignHelloWorldDebuffs();
    selectedMarks = List.filled(8, null);
    previousMarks = List.filled(8, null);
    _stopwatch = Stopwatch();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _stopwatch.start();
        _timer = Timer.periodic(Duration(seconds: 1), (timer) {
          setState(() {
            _elapsedSeconds = _stopwatch.elapsed.inSeconds;
          });
        });

      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void assignDynamisStacks() {
    dynamisStacks = List.filled(8, 0);
    List<int> indices = List.generate(8, (index) => index);
    indices.shuffle();
    for (int i = 0; i < 6; i++) {
      dynamisStacks[indices[i]] = 1;
    }
  }

  void assignHelloWorldDebuffs() {
    List<int> indices = List.generate(8, (index) => index);
    indices.shuffle();
    helloWorldMeleeIndex = indices.removeLast();
    helloWorldRangedIndex = indices.removeLast();
  }

  bool validateMarks() {
    // 모든 표식이 정확히 한 번씩 할당되었는지 확인
    for (String mark in marks) {
      if (selectedMarks.where((m) => m == mark).length != 1) {
        return false;
      }
    }

    // 헬로 월드 디버프를 받은 플레이어가 표식을 받았는지 확인
    if (selectedMarks[helloWorldMeleeIndex] != null || selectedMarks[helloWorldRangedIndex] != null) {
      return false;
    }

    return true;
  }

  void startTimer() {
    _stopwatch.start();
  }

  void stopTimer() {
    _stopwatch.stop();
  }

  void resetTimer() {
    _stopwatch.reset();
    _elapsedSeconds = 0;
  }

  void submitMarks() {
    stopTimer();
    if (validateMarks()) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("성공"),
          content: Text("표식이 성공적으로 할당되었습니다!\n경과 시간: $_elapsedSeconds 초"),
          actions: [
            TextButton(
              onPressed: () {
                resetTimer();
                Navigator.pop(context);
              },
              child: Text("확인"),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("오류"),
          content: Text("각 표식은 정확히 한 번씩 할당되어야 하며, 헬로 월드 디버프를 받은 플레이어는 표식을 받을 수 없습니다."),
          actions: [
            TextButton(
              onPressed: () {
                resetTimer();
                Navigator.pop(context);
              },
              child: Text("확인"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('시그마 시뮬레이터'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '플레이어 할당',
                style: TextStyle(fontSize: 24),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '경과 시간: $_elapsedSeconds 초',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ...List.generate(players.length, (index) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${players[index]}',
                      style: TextStyle(fontSize: 18),
                    ),
                    if (dynamisStacks[index] > 0)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Image.asset('assets/dynamis_stack_${dynamisStacks[index]}.png', width: 70, height: 70),
                      ),
                    if (index == helloWorldMeleeIndex)
                      Image.asset('assets/helloworld_melee.png', width: 70, height: 70),
                    if (index == helloWorldRangedIndex)
                      Image.asset('assets/helloworld_ranged.png', width: 70, height: 70),
                    SizedBox(width: 20),
                    ...marks.map((mark) {
                      return IconButton(
                        onPressed: () {
                          setState(() {
                            if (selectedMarks[index] != mark) {
                              previousMarks[index] = selectedMarks[index];
                              selectedMarks[index] = mark;
                            } else {
                              selectedMarks[index] = null; // 토글되도록 선택을 취소합니다.
                            }
                          });
                        },
                        icon: mark.startsWith("숫자") ? ImageIcon(
                          AssetImage('number_${mark.substring(2)}.png'),
                          size: 70,
                          color: selectedMarks[index] == mark ? Colors.black : null, // 선택되었을 때 아이콘 색상을 변경합니다.
                        ) : mark.startsWith("속박") ? ImageIcon(
                          AssetImage('lock_${mark.substring(2)}.png'),
                          size: 70,
                          color: selectedMarks[index] == mark ? Colors.black : null, // 선택되었을 때 아이콘 색상을 변경합니다.
                        ) : Icon(Icons.clear), // 기본적으로 아무 것도 표시하지 않는 아이콘을 사용합니다.
                        color: selectedMarks[index] == mark ? Colors.grey : null, // 선택되었을 때 배경 색상을 변경합니다.
                      );


                    }),
                  ],
                );
              }),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  startTimer();
                  submitMarks();
                },
                child: Text('표식 할당하기'),
              ),
              ElevatedButton(
                onPressed: () {
                  assignDynamisStacks();
                  assignHelloWorldDebuffs();
                  selectedMarks = List.filled(8, null);
                  setState(() {});
                },
                child: Text('표식 재할당하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
