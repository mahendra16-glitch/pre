// import 'dart:async';

// import 'package:audioplayers/audioplayers.dart' as ap;
// import 'package:audioplayers/audioplayers.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';

// class AudioPlayer extends StatefulWidget {
//   /// Path from where to play recorded audio
//   final String source;
//   final String type;

//   /// Callback when audio file should be removed
//   /// Setting this to null hides the delete button
//   final VoidCallback onDelete;

//   const AudioPlayer(
//       {@required this.source, @required this.onDelete, this.type});

//   @override
//   AudioPlayerState createState() => AudioPlayerState();
// }

// class AudioPlayerState extends State<AudioPlayer> {
//   double _controlSize = 40;
//   double _deleteBtnSize = 24;

//   final _audioPlayer = ap.AudioPlayer()..setReleaseMode(ReleaseMode.stop);
//   StreamSubscription<void> _playerStateChangedSubscription;
//   StreamSubscription<Duration> _durationChangedSubscription;
//   StreamSubscription<Duration> _positionChangedSubscription;
//   Duration _position;
//   Duration _duration;

//   @override
//   void initState() {
//     _playerStateChangedSubscription =
//         _audioPlayer.onPlayerComplete.listen((state) async {
//       await stop();
//     });
//     _positionChangedSubscription = _audioPlayer.onPositionChanged.listen(
//       (position) => setState(() {
//         _position = position;
//       }),
//     );
//     _durationChangedSubscription = _audioPlayer.onDurationChanged.listen(
//       (duration) => setState(() {
//         _duration = duration;
//       }),
//     );
//     if (widget.type == 'kds') {
//       print(widget.source);
//       _audioPlayer.setSourceUrl(widget.source);
//     } else {
//       _audioPlayer.setSource(_source);
//     }

//     super.initState();
//   }

//   @override
//   void dispose() {
//     _playerStateChangedSubscription.cancel();
//     _positionChangedSubscription.cancel();
//     _durationChangedSubscription.cancel();
//     _audioPlayer.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     _controlSize = MediaQuery.of(context).size.shortestSide > 570 ? 40 : 30;
//     _deleteBtnSize = MediaQuery.of(context).size.shortestSide > 570 ? 34 : 24;
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         return Padding(
//           padding: const EdgeInsets.only(top: 10),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Row(
//                 mainAxisSize: MainAxisSize.max,
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: <Widget>[
//                   _buildControl(),
//                   _buildSlider(constraints.maxWidth),
//                   if (widget.type != 'kds')
//                     IconButton(
//                       icon: Icon(Icons.delete,
//                           color: Color(0xFF73748D), size: _deleteBtnSize),
//                       onPressed: () {
//                         if (_audioPlayer.state == ap.PlayerState.playing) {
//                           stop().then((value) => widget.onDelete());
//                         } else {
//                           widget.onDelete();
//                         }
//                       },
//                     ),
//                 ],
//               ),
//               Text(
//                 _duration == null
//                     ? '0.0'
//                     : '${_duration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${(_duration.inSeconds.remainder(60).toString().padLeft(2, '0'))}',
//                 style: TextStyle(
//                     fontSize: MediaQuery.of(context).size.shortestSide > 570
//                         ? 16
//                         : 13),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildControl() {
//     Icon icon;
//     Color color;

//     if (_audioPlayer.state == ap.PlayerState.playing) {
//       icon = Icon(Icons.pause,
//           color: Colors.red,
//           size: MediaQuery.of(context).size.shortestSide > 570 ? 40 : 30);
//       color = Colors.red.withOpacity(0.1);
//     } else {
//       final theme = Theme.of(context);
//       icon = Icon(Icons.play_arrow,
//           color: theme.primaryColor,
//           size: MediaQuery.of(context).size.shortestSide > 570 ? 40 : 30);
//       color = theme.primaryColor.withOpacity(0.1);
//     }

//     return ClipOval(
//       child: Material(
//         color: color,
//         child: InkWell(
//           child: SizedBox(
//               width: MediaQuery.of(context).size.shortestSide > 570
//                   ? 60
//                   : _controlSize,
//               height: MediaQuery.of(context).size.shortestSide > 570
//                   ? 60
//                   : _controlSize,
//               child: icon),
//           onTap: () {
//             if (_audioPlayer.state == ap.PlayerState.playing) {
//               pause();
//             } else {
//               play();
//             }
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildSlider(double widgetWidth) {
//     bool canSetValue = false;
//     final duration = _duration;
//     final position = _position;

//     if (position != null) {
//       canSetValue = position.inMilliseconds > 0;
//       canSetValue &= position.inMilliseconds < duration.inMilliseconds;
//     }

//     double width = widgetWidth - _controlSize - _deleteBtnSize;
//     width -= _deleteBtnSize;

//     return SizedBox(
//       width: width,
//       child: Slider(
//         activeColor: Theme.of(context).primaryColor,
//         inactiveColor: Theme.of(context).colorScheme.secondary,
//         onChanged: (v) {
//           final position = v * duration.inMilliseconds;
//           _audioPlayer.seek(Duration(milliseconds: position.round()));
//         },
//         value: canSetValue
//             ? position.inMilliseconds / duration.inMilliseconds
//             : 0.0,
//       ),
//     );
//   }

//   Future<void> play() => _audioPlayer.play(_source);

//   Future<void> pause() async {
//     await _audioPlayer.pause();
//     setState(() {});
//   }

//   Future<void> stop() async {
//     await _audioPlayer.stop();
//     setState(() {});
//   }

//   Source get _source =>
//       kIsWeb ? ap.UrlSource(widget.source) : ap.DeviceFileSource(widget.source);
// }
