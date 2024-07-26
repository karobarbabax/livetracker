import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:livetracker/timer.dart';
import 'package:livetracker/util.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Live Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Live Tracker'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  int _start = 100;
  void startTimer() {
    const oneSec = Duration(seconds: 1);
    Timer timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(LifecycleEventHandler(
      resumeCallBack: () async {
        print("what happened");
        if (mounted) {
          setState(() {
            closeKeyboard();
          });
        }
      },
      suspendingCallBack: () async {
        print('app send to background');
        startTimer();

        if (mounted) {
          setState(() {
            closeKeyboard();
          });
        }
      },
    ));
  }

  void closeKeyboard() {
    FocusScope.of(context).unfocus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  TextEditingController phonenumberController = TextEditingController();
  var messageFocus = FocusNode();
  String _phoneNumber = "";
  bool _trackingStarted = false;

  int countdownSeconds = 20; //total timer limit in seconds
  late CountdownTimer countdownTimer;
  bool isTimerRunning = false;

  void initTimerOperation() {
    //timer callbacks
    countdownTimer = CountdownTimer(
      seconds: countdownSeconds,
      onTick: (seconds) {
        print("tracking ...");
        isTimerRunning = true;
        setState(() {
          countdownSeconds = seconds; //this will return the timer values
        });
      },
      onFinished: () {
        stopTimer();
        // Handle countdown finished
      },
    );

    //native app life cycle
    SystemChannels.lifecycle.setMessageHandler((msg) {
      // On AppLifecycleState: paused
      if (msg == AppLifecycleState.paused.toString()) {
        if (isTimerRunning) {
          countdownTimer.pause(countdownSeconds); //setting end time on pause
        }
      }

      // On AppLifecycleState: resumed
      if (msg == AppLifecycleState.resumed.toString()) {
        if (isTimerRunning) {
          countdownTimer.resume();
        }
      }
      return Future(() => null);
    });

    //starting timer
    isTimerRunning = true;
    countdownTimer.start();
  }

  void stopTimer() {
    isTimerRunning = false;
    countdownTimer.stop();
  }

  void resetTimer() {
    stopTimer();
    setState(() {
      countdownSeconds = 20;
    });
  }

  TextStyle primaryTextStyle({int? size, Color? color, FontWeight? weight}) {
    return TextStyle(
      fontSize: size != null ? size.toDouble() : 16.00,
      color: color ?? const Color(0xFF2E3033),
      fontWeight: weight ?? FontWeight.normal,
    );
  }

  TextStyle secondaryTextStyle() {
    return const TextStyle(
      fontSize: 14.00,
      color: Color.fromARGB(255, 18, 18, 18),
      decoration: TextDecoration.none,
      fontWeight: FontWeight.normal,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _phoneNumber.isEmpty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: phonenumberController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintStyle: TextStyle(fontSize: 17),
                            hintText: 'Enter someone phone number',
                            border: InputBorder.none,
                            // contentPadding: EdgeInsets.all(20),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _phoneNumber = phonenumberController.value.text;
                            });
                          },
                          child: Container(
                            height: 45,
                            decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                                color: Color.fromARGB(255, 64, 64, 64)),
                            child: const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: Text(
                                "Save phone number",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Your select this phone number for saving your live:",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              color: Color.fromARGB(255, 0, 0, 0)),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const Text(
                          "Pay Attention if your phone will not unlock in next 2 minutes i call this phone number",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              fontWeight: FontWeight.w200,
                              color: Color.fromARGB(255, 0, 0, 0)),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _phoneNumber = "";
                                  });
                                },
                                child: Container(
                                  child: const Icon(
                                      color: Colors.red,
                                      Icons.highlight_remove_sharp),
                                )),
                            const SizedBox(
                              width: 20,
                            ),
                            Text(
                              _phoneNumber,
                              textAlign: TextAlign.start,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 0, 0, 0)),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 80,
                        ),
                        _trackingStarted
                            ? const Text(
                                style: TextStyle(color: Colors.black),
                                "Timer start")
                            : const SizedBox(),
                        const SizedBox(
                          height: 70,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            MaterialButton(
                              color: Colors.tealAccent,
                              onPressed: () {
                                initTimerOperation();
                              },
                              child: const Text("Start Timer"),
                            ),
                            MaterialButton(
                              color: Colors.orangeAccent,
                              onPressed: () {
                                stopTimer();
                              },
                              child: const Text("Stop Timer"),
                            ),
                            MaterialButton(
                              color: Colors.redAccent,
                              onPressed: () {
                                resetTimer();
                              },
                              child: const Text("Reset Timer"),
                            )
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              // if (_trackingStarted) {
                              //   initTimerOperation();
                              // }
                              _trackingStarted = !_trackingStarted;
                            });
                          },
                          child: Container(
                            height: 45,
                            decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(8)),
                              color: _trackingStarted
                                  ? const Color.fromARGB(255, 225, 116, 99)
                                  : const Color.fromARGB(255, 99, 225, 147),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                _trackingStarted
                                    ? "Stop Tracking, I can handel it"
                                    : "Start Tracking my live ...",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: Color.fromARGB(255, 45, 45, 45)),
                              ),
                            ),
                          ),
                        ),
                        Text("$countdownSeconds")
                      ],
                    )
            ],
          ),
        ),
      ),
    );
  }
}
