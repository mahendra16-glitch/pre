// import 'dart:async';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:record/record.dart';

// import 'platform/audio_recorder_io.dart';

// class Recorder extends StatefulWidget {
//   final void Function(String path) onStop;

//   const Recorder({key, @required this.onStop});

//   @override
//   State<Recorder> createState() => _RecorderState();
// }

// class _RecorderState extends State<Recorder> with AudioRecorderMixin {
//   int _recordDuration = 0;
//   Timer _timer;
//   AudioRecorder _audioRecorder;
//   StreamSubscription<RecordState> _recordSub;
//   RecordState _recordState = RecordState.stop;
//   StreamSubscription<Amplitude> _amplitudeSub;
//   Amplitude _amplitude;

//   @override
//   void initState() {
//     _audioRecorder = AudioRecorder();

//     _recordSub = _audioRecorder.onStateChanged().listen((recordState) {
//       _updateRecordState(recordState);
//     });

//     _amplitudeSub = _audioRecorder
//         .onAmplitudeChanged(const Duration(milliseconds: 300))
//         .listen((amp) {
//       setState(() => _amplitude = amp);
//     });

//     super.initState();
//   }

//   Future<void> _start() async {
//     try {
//       if (await _audioRecorder.hasPermission()) {
//         const encoder = AudioEncoder.aacLc;

//         if (!await _isEncoderSupported(encoder)) {
//           return;
//         }

//         final devs = await _audioRecorder.listInputDevices();
//         debugPrint(devs.toString());

//         const config = RecordConfig(encoder: encoder, numChannels: 1);

//         // Record to file
//         await recordFile(_audioRecorder, config);

//         // Record to stream
//         // await recordStream(_audioRecorder, config);

//         _recordDuration = 0;

//         _startTimer();
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print(e);
//       }
//     }
//   }

//   Future<void> _stop() async {
//     final path = await _audioRecorder.stop();

//     if (path != null) {
//       widget.onStop(path);
//     }
//   }

//   Future<void> _pause() => _audioRecorder.pause();

//   Future<void> _resume() => _audioRecorder.resume();

//   void _updateRecordState(RecordState recordState) {
//     setState(() => _recordState = recordState);

//     switch (recordState) {
//       case RecordState.pause:
//         _timer.cancel();
//         break;
//       case RecordState.record:
//         _startTimer();
//         break;
//       case RecordState.stop:
//         _timer.cancel();
//         _recordDuration = 0;
//         break;
//     }
//   }

//   Future<bool> _isEncoderSupported(AudioEncoder encoder) async {
//     final isSupported = await _audioRecorder.isEncoderSupported(
//       encoder,
//     );

//     if (!isSupported) {
//       debugPrint('${encoder.name} is not supported on this platform.');
//       debugPrint('Supported encoders are:');

//       for (final e in AudioEncoder.values) {
//         if (await _audioRecorder.isEncoderSupported(e)) {
//           debugPrint('- ${encoder.name}');
//         }
//       }
//     }

//     return isSupported;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.only(top: 10),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: <Widget>[
//             _buildRecordStopControl(),
//             const SizedBox(width: 20),
//             _buildPauseResumeControl(),
//             const SizedBox(width: 20),
//             _buildText(),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _timer.cancel();
//     _recordSub.cancel();
//     _amplitudeSub.cancel();
//     _audioRecorder.dispose();
//     super.dispose();
//   }

//   Widget _buildRecordStopControl() {
//     Icon icon;
//     Color color;

//     if (_recordState != RecordState.stop) {
//       icon = Icon(Icons.stop,
//           color: Colors.red,
//           size: MediaQuery.of(context).size.shortestSide > 570 ? 40 : 20);
//       color = Colors.red.withOpacity(0.1);
//     } else {
//       final theme = Theme.of(context);
//       icon = Icon(Icons.mic,
//           color: theme.primaryColor,
//           size: MediaQuery.of(context).size.shortestSide > 570 ? 40 : 20);
//       color = theme.primaryColor.withOpacity(0.1);
//     }

//     return ClipOval(
//       child: Material(
//         color: color,
//         child: InkWell(
//           child: SizedBox(
//               width: MediaQuery.of(context).size.shortestSide > 570 ? 60 : 40,
//               height: MediaQuery.of(context).size.shortestSide > 570 ? 60 : 40,
//               child: icon),
//           onTap: () {
//             (_recordState != RecordState.stop) ? _stop() : _start();
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildPauseResumeControl() {
//     if (_recordState == RecordState.stop) {
//       return const SizedBox.shrink();
//     }

//     Icon icon;
//     Color color;

//     if (_recordState == RecordState.record) {
//       icon = Icon(Icons.pause,
//           color: Colors.red,
//           size: MediaQuery.of(context).size.shortestSide > 570 ? 40 : 30);
//       color = Colors.red.withOpacity(0.1);
//     } else {
//       final theme = Theme.of(context);
//       icon = Icon(Icons.play_arrow,
//           color: Colors.red,
//           size: MediaQuery.of(context).size.shortestSide > 570 ? 40 : 30);
//       color = theme.primaryColor.withOpacity(0.1);
//     }

//     return ClipOval(
//       child: Material(
//         color: color,
//         child: InkWell(
//           child: SizedBox(
//               width: MediaQuery.of(context).size.shortestSide > 570 ? 60 : 40,
//               height: MediaQuery.of(context).size.shortestSide > 570 ? 60 : 40,
//               child: icon),
//           onTap: () {
//             (_recordState == RecordState.pause) ? _resume() : _pause();
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildText() {
//     if (_recordState != RecordState.stop) {
//       return _buildTimer();
//     }

//     return Text(
//       "Add instructions for direction..",
//       style: TextStyle(
//           fontSize: MediaQuery.of(context).size.shortestSide > 570 ? 17 : 13),
//     );
//   }

//   Widget _buildTimer() {
//     final String minutes = _formatNumber(_recordDuration ~/ 60);
//     final String seconds = _formatNumber(_recordDuration % 60);

//     return Text(
//       '$minutes : $seconds',
//       style: TextStyle(
//           color: Colors.red,
//           fontSize: MediaQuery.of(context).size.shortestSide > 570 ? 16 : 13),
//     );
//   }

//   String _formatNumber(int number) {
//     String numberStr = number.toString();
//     if (number < 10) {
//       numberStr = '0$numberStr';
//     }

//     return numberStr;
//   }

//   void _startTimer() {
//     _timer.cancel();

//     _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
//       setState(() => _recordDuration++);
//     });
//   }
// }
