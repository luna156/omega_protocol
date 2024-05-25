import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class Omega extends StatefulWidget {
  @override
  _OmegaState createState() => _OmegaState();
}

class _OmegaState extends State<Omega> {
  List<String> players = List.generate(8, (index) => '플레이어 ${index + 1}');
  List<String> marks = ["숫자1", "숫자2", "속박1", "속박2"];
  List<int> dynamisStacks = List.filled(8, 0);
  List<int> helloWorldMeleeIndexes = List.filled(2, -1);
  List<int> helloWorldRangedIndexes = List.filled(2, -1);
  List<String?> selectedMarks = List.filled(8, null);
  List<String?> previousMarks = List.filled(8, null);
  late Stopwatch _stopwatch;
  Timer? _timer;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    assignDynamisStacks();
    assignHelloWorldDebuffs();
    _stopwatch = Stopwatch();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds = _stopwatch.elapsed.inSeconds;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void assignDynamisStacks() {
    List<int> indices = List.generate(8, (index) => index);
    indices.shuffle();
    for (int i = 0; i < 4; i++) {
      dynamisStacks[indices[i]] = 2;
    }
    for (int i = 4; i < 8; i++) {
      dynamisStacks[indices[i]] = 1;
    }
  }

  void assignHelloWorldDebuffs() {
    List<int> indices = List.generate(8, (index) => index);
    indices.shuffle();
    helloWorldMeleeIndexes[0] = indices.removeLast();
    helloWorldMeleeIndexes[1] = indices.removeLast();
    helloWorldRangedIndexes[0] = indices.removeLast();
    helloWorldRangedIndexes[1] = indices.removeLast();
  }

  String? validateMarks() {
    // 모든 플레이어에 대해 속박 및 숫자 표식이 정확히 1개씩 할당되었는지 확인합니다.
    int markedCount = selectedMarks.where((mark) => mark != null).length;
    if (markedCount != 4) {
      return "표식이 정확히 4개 할당되지 않았습니다.";
    }

    // 첫 번째 헬로월드 대상자에게 표식이 찍히지 않았는지 확인합니다.
    if (selectedMarks[helloWorldMeleeIndexes[0]] != null || selectedMarks[helloWorldRangedIndexes[0]] != null) {
      return "첫 번째 헬로월드 대상자에게 표식이 찍혔습니다.";
    }

    // 속박징 2개가 올바르게 할당되었는지 확인합니다.
    int shacklesCount = 0;
    for (int i = 0; i < selectedMarks.length; i++) {
      String? mark = selectedMarks[i];
      if (mark != null && mark.startsWith('속박')) {
        shacklesCount++;
        if (dynamisStacks[i] != 2 || (helloWorldMeleeIndexes[1] != i && helloWorldRangedIndexes[1] != i)) {
          if (!(helloWorldMeleeIndexes[1] == i && dynamisStacks[i] == 2) &&
              !(helloWorldRangedIndexes[1] == i && dynamisStacks[i] == 2)) {
            return "속박징이 잘못 할당되었습니다.";
          }
        }
      }
    }
    if (shacklesCount != 2) {
      return "속박징이 2개 할당되지 않았습니다.";
    }

    // 숫자징 2개가 올바르게 할당되었는지 확인합니다.
    int numbersCount = 0;
    for (int i = 0; i < selectedMarks.length; i++) {
      String? mark = selectedMarks[i];
      if (mark != null && mark.startsWith('숫자')) {
        numbersCount++;
        if (dynamisStacks[i] == 2 || helloWorldMeleeIndexes.contains(i) || helloWorldRangedIndexes.contains(i)) {
          return "숫자징이 잘못 할당되었습니다.";
        }
      }
    }
    if (numbersCount != 2) {
      return "숫자징이 2개 할당되지 않았습니다.";
    }

    return null;
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
    String? validationResult = validateMarks();
    if (validationResult == null) {
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
          content: Text(validationResult),
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
        title: Text('오메가 시뮬레이터'),
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
                    if (helloWorldMeleeIndexes.contains(index))
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Image.asset('assets/helloworld_melee.png', width: 70, height: 70),
                      ),
                    if (helloWorldRangedIndexes.contains(index))
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Image.asset('assets/helloworld_ranged.png', width: 70, height: 70),
                      ),
                    if (index == helloWorldMeleeIndexes[0])
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Image.asset('assets/first.png', width: 70, height: 70),
                      ),
                    if (index == helloWorldMeleeIndexes[1])
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Image.asset('assets/second.png', width: 70, height: 70),
                      ),
                    if (index == helloWorldRangedIndexes[0])
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Image.asset('assets/first.png', width: 70, height: 70),
                      ),
                    if (index == helloWorldRangedIndexes[1])
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Image.asset('assets/second.png', width: 70, height: 70),
                      ),
                    SizedBox(width: 20),
                    ...marks.map((mark) {
                      return Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: selectedMarks[index] == mark ? Colors.blue : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: IconButton(
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
                          icon: mark.startsWith("숫자")
                              ? Image.asset('assets/number_${mark.substring(2)}.png', width: 70, height: 70)
                              : mark.startsWith("속박")
                              ? Image.asset('assets/lock_${mark.substring(2)}.png', width: 70, height: 70)
                              : Icon(Icons.clear), // 기본적으로 아무 것도 표시하지 않는 아이콘을 사용합니다.
                          color: selectedMarks[index] == mark ? Colors.grey : null, // 선택되었을 때 배경 색상을 변경합니다.
                        ),
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
