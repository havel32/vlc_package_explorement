// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:flutter/scheduler.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_vlc_player/flutter_vlc_player.dart';

// class FullScreenVideo extends StatefulWidget {
//   final VlcPlayerController _controller;

//   const FullScreenVideo({super.key, required VlcPlayerController controller})
//     : _controller = controller;
//   @override
//   State<FullScreenVideo> createState() => _FullScreenVideoState();
// }

// class _FullScreenVideoState extends State<FullScreenVideo>
//     with SingleTickerProviderStateMixin {
//   bool isVideoRotated = false;
//   final TransformationController _transformationController =
//       TransformationController();

//   late final AnimationController _animationController;

//   late Animation<Matrix4> _animation;
//   bool isEdgeless = false;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) => buildCompleteActions());

//     _animationController = AnimationController(
//       vsync: this,
//       duration: Duration(milliseconds: 200),
//     );

//     _animation =
//         Matrix4Tween(
//           begin: Matrix4.identity(),
//           end: Matrix4.identity(),
//         ).animate(
//           CurvedAnimation(
//             parent: _animationController,
//             curve: Curves.easeInOut,
//           ),
//         );

//     _animation.addListener(() {
//       _transformationController.value = _animation.value;
//     });
//     _animation.addStatusListener((status) {
//       if (status != AnimationStatus.completed) return;
//       setState(() {});
//     });
//     _transformationController.addListener(() {
//       final currentScale = _transformationController.value.getMaxScaleOnAxis();
//       if (currentScale != 1.0) {
//         isEdgeless = true;
//       } else {
//         isEdgeless = false;
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _transformationController.dispose();
//     super.dispose();
//   }

//   Future<void> changeOrientation() async {
//     await Future.microtask(() async {
//       await SystemChrome.setPreferredOrientations([
//         DeviceOrientation.landscapeLeft,
//         DeviceOrientation.landscapeRight,
//       ]);
//       await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
//     });
//   }

//   Future<void> buildCompleteActions() async {
//     await Future.delayed(Durations.short2);
//     await changeOrientation();
//     isVideoRotated = true;
//   }

//   @override
//   Widget build(BuildContext context) {
//     timeDilation = 1;
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Hero(
//         tag: 'video',
//         child: Stack(
//           children: [
//             InteractiveViewer(
//               transformationController: _transformationController,
//               minScale: 1.0,
//               maxScale: 4.0,
//               onInteractionEnd: (details) {
//                 double correctScaleValue = _transformationController.value
//                     .getMaxScaleOnAxis();
//                 log(correctScaleValue.toString());
//               },
//               child: Align(
//                 alignment: Alignment.center,
//                 child: AspectRatio(
//                   aspectRatio: widget._controller.value.aspectRatio,
//                   child: SizedBox(
//                     child: VlcPlayer(
//                       controller: widget._controller,
//                       aspectRatio: widget._controller.value.aspectRatio,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             // ),
//             Align(
//               alignment: Alignment.topCenter,
//               child: Text(_transformationController.value.dimension.toString()),
//             ),
//             Align(
//               alignment: Alignment.bottomRight,
//               child: Padding(
//                 padding: const EdgeInsets.only(right: 80),
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: Colors.black.withAlpha(150),
//                     borderRadius: BorderRadius.circular(18),
//                   ),
//                   child: IconButton(
//                     icon: const Icon(
//                       Icons.fullscreen_exit,
//                       color: Colors.white,
//                     ),
//                     onPressed: () async {
//                       await Future.microtask(() async {
//                         await SystemChrome.setPreferredOrientations([
//                           DeviceOrientation.portraitUp,
//                         ]);
//                         await SystemChrome.setEnabledSystemUIMode(
//                           SystemUiMode.edgeToEdge,
//                         );
//                       });
//                       await Future.delayed(Durations.medium2);
//                       if (context.mounted) Navigator.pop(context);
//                     },
//                   ),
//                 ),
//               ),
//             ),
//             Align(
//               alignment: Alignment.center,
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Colors.black.withAlpha(150),
//                   shape: BoxShape.circle,
//                 ),
//                 child: IconButton(
//                   onPressed: () {
//                     setState(() {
//                       widget._controller.value.isPlaying
//                           ? widget._controller.pause()
//                           : widget._controller.play();
//                     });
//                   },
//                   icon: Icon(Icons.play_arrow, color: Colors.white),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class FullScreenPage extends StatefulWidget {
  final VlcPlayerController controller;

  const FullScreenPage({super.key, required this.controller});

  @override
  State<FullScreenPage> createState() => _FullScreenPageState();
}

class _FullScreenPageState extends State<FullScreenPage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Hero(
          tag: 'vlc_player',
          child: VlcPlayer(
            controller: widget.controller,
            aspectRatio: 16 / 9,
            placeholder: const Center(child: CircularProgressIndicator()),
          ),
        ),
      ),
    );
  }
}
