import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:timesget/all_translations.dart';
import 'package:timesget/styles/colors.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class VideoRecorderPage extends StatefulWidget {
  final List<CameraDescription> cameras;
  VideoRecorderPage(this.cameras);

  @override
  _VideoRecorderPageState createState() {
    return _VideoRecorderPageState();
  }
}

/// Returns a suitable camera icon for [direction].
IconData getCameraLensIcon(CameraLensDirection direction) {
  switch (direction) {
    case CameraLensDirection.back:
      return Icons.camera_rear;
    case CameraLensDirection.front:
      return Icons.camera_front;
    case CameraLensDirection.external:
      return Icons.camera;
  }
  throw ArgumentError('Unknown lens direction');
}

void logError(String code, String message) =>
    print('Error: $code\nError Message: $message');

class _VideoRecorderPageState extends State<VideoRecorderPage> {
  CameraController controller;
  String imagePath;
  String videoPath;
  VideoPlayerController videoController;
  VoidCallback videoPlayerListener;

  bool isBackCamera = true;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    onNewCameraSelected(widget.cameras
        .where((x) => x.lensDirection == CameraLensDirection.back)
        .first);
  }

  @override
  void dispose() {
    controller?.dispose();
    controller = null;
    videoController?.dispose();
    videoController = null;
    videoPlayerListener = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final h = mq.size.height;
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppColors.black,
        body: Stack(
          children: <Widget>[
            Container(
              height: h,
              child: videoController == null
                  ? _cameraPreview()
                  : _thumbnailWidget(),
            ),
            Positioned(
              top: 25.0,
              left: 25.0,
              child: InkWell(
                onTap: () {
                  Navigator.pop(context, null);
                },
                child: Icon(
                  Icons.close,
                  size: 40.0,
                  color: Colors.white,
                ),
              ),
            ),
            Positioned(
                left: 25.0,
                bottom: 20.0,
                width: mq.size.width - 50,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [_leftButton(), _rightButton()]))
          ],
        ));
  }

  Widget _leftButton() {
    if (videoPath != null && !controller.value.isRecordingVideo) {
      return _useVideoButton();
    }

    return controller != null &&
            controller.value.isInitialized &&
            controller.value.isRecordingVideo
        ? Container()
        : InkWell(
            onTap: _toggleCamera,
            child: Icon(Icons.cached, color: Colors.white, size: 50.0),
          );
  }

  Widget _rightButton() {
    if (controller == null || !controller.value.isInitialized) {
      return Container();
    }

    if (controller.value.isRecordingVideo) {
      return InkWell(
        onTap: onStopButtonPressed,
        child: Icon(Icons.stop, color: Colors.red, size: 50.0),
      );
    }

    if (!controller.value.isRecordingVideo && videoPath != null) {
      return InkWell(
        onTap: _recordAgain,
        child: Container(
            padding: EdgeInsets.all(10.0),
            child: Text(allTranslations.text('record_again'),
                style: TextStyle(
                    fontSize: 16.0,
                    color: AppColors.white,
                    fontWeight: FontWeight.w500))),
      );
    }

    return InkWell(
        onTap: onVideoRecordButtonPressed,
        child: Icon(Icons.play_arrow, color: AppColors.white, size: 50.0));
  }

  Widget _useVideoButton() {
    return InkWell(
      onTap: () {
        Navigator.pop(context, File(videoPath));
      },
      child: Container(
        padding: EdgeInsets.all(10.0),
        child: Text(allTranslations.text('use_video'),
            style: TextStyle(
                fontSize: 16.0,
                color: AppColors.white,
                fontWeight: FontWeight.w500)),
      ),
    );
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    if (controller == null || !controller.value.isInitialized) {
      return const Text(
        'Tap a camera',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      return AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: CameraPreview(controller),
      );
    }
  }

  Widget _cameraPreview() {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: Center(
          child: _cameraPreviewWidget(),
        ),
      ),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(
          color: controller != null && controller.value.isRecordingVideo
              ? Colors.redAccent
              : Colors.grey,
          width: 3.0,
        ),
      ),
    );
  }

  Widget _thumbnailWidget() {
    return Container(
      child: Center(
        child: AspectRatio(
            aspectRatio: videoController.value.size != null
                ? videoController.value.aspectRatio
                : 1.0,
            child: VideoPlayer(videoController)),
      ),
      decoration: BoxDecoration(border: Border.all(color: Colors.pink)),
    );
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void showInSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _recordAgain() async {
    onNewCameraSelected(widget.cameras
        .where((x) =>
            x.lensDirection ==
            (!isBackCamera
                ? CameraLensDirection.front
                : CameraLensDirection.back))
        .first);
  }

  Future<void> _toggleCamera() async {
    onNewCameraSelected(widget.cameras
        .where((x) =>
            x.lensDirection ==
            (isBackCamera
                ? CameraLensDirection.front
                : CameraLensDirection.back))
        .first);
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller.dispose();
    }
    if (videoController != null) {
      await videoController.pause();
      videoController.dispose();
    }

    controller = CameraController(cameraDescription, ResolutionPreset.medium);

    // If the controller is updated then update the UI.
    controller.addListener(() {
      if (mounted) setState(() {});
      if (controller.value.hasError) {
        showInSnackBar('Camera error ${controller.value.errorDescription}');
      }
    });

    try {
      await controller.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {
        videoPath = null;
        videoController = null;
        isBackCamera =
            cameraDescription.lensDirection == CameraLensDirection.back;
      });
    }
  }

  void onVideoRecordButtonPressed() {
    startVideoRecording().then((String filePath) {
      if (mounted) setState(() {});
      print(
          'Saving video to $filePath'); // if (filePath != null) showInSnackBar('Saving video to $filePath');
    });
  }

  void onStopButtonPressed() {
    stopVideoRecording().then((_) {
      if (mounted) setState(() {});
      print(
          'Video recorded to: $videoPath'); // showInSnackBar('Video recorded to: $videoPath');
    });
  }

  Future<String> startVideoRecording() async {
    if (!controller.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }

    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Movies/flutter_test';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.mp4';

    if (controller.value.isRecordingVideo) {
      // A recording is already started, do nothing.
      return null;
    }

    try {
      videoPath = filePath;
      await controller.startVideoRecording(filePath);
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
    return filePath;
  }

  Future<void> stopVideoRecording() async {
    if (!controller.value.isRecordingVideo) {
      return null;
    }

    try {
      await controller.stopVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }

    await _startVideoPlayer();
  }

  Future<void> _startVideoPlayer() async {
    final VideoPlayerController vcontroller =
        VideoPlayerController.file(File(videoPath));
    videoPlayerListener = () {
      if (videoController != null && videoController.value.size != null) {
        // Refreshing the state to update video player with the correct ratio.
        if (mounted) setState(() {});
        videoController.removeListener(videoPlayerListener);
      }
    };
    vcontroller.addListener(videoPlayerListener);
    await vcontroller.setLooping(true);
    await vcontroller.initialize();
    await videoController?.dispose();
    if (mounted) {
      setState(() {
        videoController = vcontroller;
      });
    }
    await vcontroller.play();
  }

  void _showCameraException(CameraException e) {
    logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }
}
