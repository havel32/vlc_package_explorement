import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:page_transition/page_transition.dart';
import 'package:player_for_vlc/full_screen_widget.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VLC Player Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

// Visibility(
//           visible: widget.showControls,
//           child: ColoredBox(
//             color: _playerControlsBgColor,
//             child: Row(
//               children: [
//                 IconButton(
//                   color: Colors.white,
//                   icon: _controller.value.isPlaying
//                       ? const Icon(Icons.pause_circle_outline)
//                       : const Icon(Icons.play_circle_outline),
//                   onPressed: _togglePlaying,
//                 ),
//                 Expanded(
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         position,
//                         style: const TextStyle(color: Colors.white),
//                       ),
//                       Expanded(
//                         child: Slider(
//                           activeColor: Colors.redAccent,
//                           inactiveColor: Colors.white70,
//                           value: sliderValue,
//                           max: !validPosition
//                               ? 1.0
//                               : _controller.value.duration.inSeconds.toDouble(),
//                           onChanged:
//                               validPosition ? _onSliderPositionChanged : null,
//                         ),
//                       ),
//                       Text(
//                         duration,
//                         style: const TextStyle(color: Colors.white),
//                       ),
//                     ],
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.fullscreen),
//                   color: Colors.white,
//                   // ignore: no_empty_block
//                   onPressed: () {},
//                 ),
//               ],
//             ),
//           ),
//         ),
class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('VLC Player Demo')),
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: Colors.blueAccent,
      //   onPressed: () {
      //     _toggleFullScreen();
      //     ScaffoldMessenger.of(
      //       context,
      //     ).showSnackBar(SnackBar(content: Text('full screen button pressed')));
      //   },
      //   child: Icon(Icons.fullscreen_rounded, color: Colors.white, size: 30),
      // ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: 240,
                width: MediaQuery.of(context).size.width,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Hero(tag: "vlc_player", child: VlcWidget()),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 240 + 30),
              child: Column(
                children: [
                  Text(
                    'Video VLC player is above',
                    style: TextStyle(color: Colors.blueAccent, fontSize: 16),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 16 / 9,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemBuilder: (context, index) {
                        return Container(
                          color: Colors.grey,
                          child: Center(
                            child: Text(
                              'Video ${index + 1}',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VlcWidget extends StatefulWidget {
  const VlcWidget({super.key});

  @override
  State<VlcWidget> createState() => _VlcWidgetState();
}

class _VlcWidgetState extends State<VlcWidget> with WidgetsBindingObserver {
  late final VlcPlayerController _videoPlayerController;
  final _networkCachingMs = 1000;
  final int _subtitlesFontSize = 17;
  bool showOverlay = false;

  Future<void> changeOrientation() async {
    await Future.microtask(() async {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    });
  }

  @override
  void initState() {
    super.initState();
    changeOrientation();
    WidgetsBinding.instance.addObserver(this);
    _videoPlayerController =
        VlcPlayerController.network(
          'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
          hwAcc: HwAcc.full,
          options: VlcPlayerOptions(
            advanced: VlcAdvancedOptions([
              VlcAdvancedOptions.networkCaching(_networkCachingMs),
            ]),
            subtitle: VlcSubtitleOptions([
              VlcSubtitleOptions.boldStyle(true),
              VlcSubtitleOptions.fontSize(_subtitlesFontSize),
              VlcSubtitleOptions.outlineColor(VlcSubtitleColor.yellow),
              VlcSubtitleOptions.outlineThickness(VlcSubtitleThickness.normal),
              VlcSubtitleOptions.color(VlcSubtitleColor.navy),
            ]),
            http: VlcHttpOptions([VlcHttpOptions.httpReconnect(true)]),
            rtp: VlcRtpOptions([VlcRtpOptions.rtpOverRtsp(true)]),
          ),
        )..addListener(() {
          setState(() {});
        });
    //_initializeController();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _videoPlayerController.stopRendererScanning();
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _videoPlayerController.play();
    } else if (state == AppLifecycleState.paused) {
      _videoPlayerController.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    final double videoPlayerWidth = MediaQuery.of(context).size.width - 16;
    final double videoPlayerHeight = 240;
    final double aspectRatio = videoPlayerWidth / videoPlayerHeight;
    final controlButtonSize = 48.0;
    return InkWell(
      onTap: () {
        setState(() {
          showOverlay = !showOverlay;
        });
      },
      child: Stack(
        children: [
          if (!_videoPlayerController.value.isInitialized)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "DEMO VIDEO",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  CircularProgressIndicator(color: Colors.white),
                ],
              ),
            ),
          AspectRatio(
            aspectRatio: aspectRatio,
            child: VlcPlayer(
              controller: _videoPlayerController,
              aspectRatio: aspectRatio,
              // aspectRatio: _videoPlayerController.value.aspectRatio,
              placeholder: const Center(child: CircularProgressIndicator()),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeIn,
            switchOutCurve: Curves.easeOut,
            reverseDuration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: showOverlay
                ? Stack(
                    children: [
                      Container(
                        color: Colors.black54,
                        alignment: Alignment.center,
                      ),
                      Center(
                        child: SizedBox(
                          width: videoPlayerWidth,
                          height: videoPlayerHeight,
                          child: VideoControlButton(
                            videoPlayerController: _videoPlayerController,
                            // showOverlay: showOverlay,
                          ),
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class VideoControlButton extends StatefulWidget {
  final VlcPlayerController _videoPlayerController;
  const VideoControlButton({
    super.key,
    required VlcPlayerController videoPlayerController,
    // , required this.showOverlay
  }) : _videoPlayerController = videoPlayerController;

  // final bool showOverlay;

  @override
  State<VideoControlButton> createState() => _VideoControlButtonState();
}

class _VideoControlButtonState extends State<VideoControlButton> {
  static const Duration _seekStepForward = Duration(seconds: 10);
  static const Duration _seekStepBackward = Duration(seconds: -10);

  void onPlayPause() {
    if (widget._videoPlayerController.value.isPlaying) {
      widget._videoPlayerController.pause();
    } else {
      widget._videoPlayerController.play();
    }
    setState(() {});
  }

  Future<void> onSeekTo(Duration seekStep) {
    return widget._videoPlayerController.seekTo(
      widget._videoPlayerController.value.position + seekStep,
    );
  }

  Future<void> onReplay() async {
    await widget._videoPlayerController.stop();
    await widget._videoPlayerController.play();
  }

  Widget chooseButton() {
    final double controlButtonSize = 48.0;
    final double controlButtonIconSize = controlButtonSize / 1.5;
    switch (widget._videoPlayerController.value.playingState) {
      case PlayingState.initialized:
      case PlayingState.buffering:
        return Container(
          width: controlButtonSize,
          height: controlButtonSize,
          decoration: BoxDecoration(
            color: Colors.black38,
            borderRadius: BorderRadius.circular(32),
          ),
          alignment: Alignment.center,
          child: const CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2.0,
          ),
        );
      case PlayingState.stopped:
      case PlayingState.paused:
        return Stack(
          children: [
            Center(
              child: InkWell(
                onTap: onPlayPause,
                child: Container(
                  width: controlButtonSize,
                  height: controlButtonSize,
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    widget._videoPlayerController.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: Colors.white,
                    size: controlButtonIconSize,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: _toggleFullScreen,
                  child: Container(
                    width: controlButtonSize,
                    height: controlButtonSize,
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(32),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.fullscreen,
                      color: Colors.white,
                      size: controlButtonIconSize,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      case PlayingState.playing:
        return Stack(
          children: [
            Center(
              child: InkWell(
                onTap: onPlayPause,
                child: Container(
                  width: controlButtonSize,
                  height: controlButtonSize,
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    widget._videoPlayerController.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: Colors.white,
                    size: controlButtonIconSize,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: _toggleFullScreen,
                  child: Container(
                    width: controlButtonSize,
                    height: controlButtonSize,
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(32),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.fullscreen,
                      color: Colors.white,
                      size: controlButtonIconSize,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );

      case PlayingState.ended:
        return InkWell(
          onTap: onReplay,
          child: Container(
            width: controlButtonSize,
            height: controlButtonSize,
            decoration: BoxDecoration(
              color: Colors.black38,
              borderRadius: BorderRadius.circular(32),
            ),
            alignment: Alignment.center,
            child: Icon(
              widget._videoPlayerController.value.isPlaying
                  ? Icons.pause
                  : Icons.play_arrow,
              color: Colors.white,
              size: controlButtonIconSize,
            ),
          ),
        );
      case PlayingState.error:
        return Center(
          child: FittedBox(
            child: IconButton(
              onPressed: onReplay,
              color: Colors.white,
              iconSize: controlButtonIconSize,
              icon: const Icon(Icons.replay),
            ),
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  void _toggleFullScreen() {
    context.pushTransition(
      type: PageTransitionType.fade,
      // duration: Durations.medium2,
      child: FullScreenPage(controller: widget._videoPlayerController),
    );
  }

  @override
  Widget build(BuildContext context) {
    return chooseButton();
  }
}
