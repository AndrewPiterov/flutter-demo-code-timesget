import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:timesget/all_translations.dart';
import 'package:timesget/services/app_tooltip.dart';
import 'package:timesget/styles/colors.dart';
import 'package:path_provider/path_provider.dart';

const _pageName = "photo_picker_page";
String _translate(String key) {
  return allTranslations.concatText([_pageName, key]);
}

class PhotoPickerPage extends StatefulWidget {
  final List<CameraDescription> cameras;
  PhotoPickerPage(this.cameras);

  @override
  PhotoPickerState createState() {
    return new PhotoPickerState();
  }
}

class PhotoPickerState extends State<PhotoPickerPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  CameraController controller;
  bool isBackCamera = true;

  File imageChoosed;

  String imagePath;

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

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
        children: [
          Container(height: h, child: _cameraPreviewWidget()),
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
                  children: [
                    InkWell(
                        child: Container(
                          padding: EdgeInsets.all(10.0),
                          child: imageChoosed == null && imagePath == null
                              ? Icon(Icons.image,
                                  size: 50.0, color: Colors.white)
                              : Text(
                                  allTranslations.text(_translate('use')),
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500),
                                ),
                        ),
                        onTap: () async {
                          if (imageChoosed == null && imagePath == null) {
                            final tempImage = await ImagePicker.pickImage(
                                source: ImageSource.gallery);
                            setState(() {
                              imageChoosed = tempImage;
                            });
                          } else {
                            Navigator.pop(
                                context, imageChoosed ?? File(imagePath));
                          }
                        }),
                    imageChoosed == null && imagePath == null
                        ? InkWell(
                            child: Icon(Icons.camera_alt,
                                size: 50.0, color: Colors.white),
                            onTap: () async {
                              onTakePictureButtonPressed();
                            })
                        : Container(),
                    InkWell(
                        child: Container(
                          padding: EdgeInsets.all(10.0),
                          child: imageChoosed == null && imagePath == null
                              ? Icon(Icons.cached,
                                  size: 50.0, color: Colors.white)
                              : Text(
                                  allTranslations.text(_translate('pic_again')),
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500),
                                ),
                        ),
                        onTap: () {
                          if (imageChoosed == null && imagePath == null) {
                            _toggleCamera();
                          } else {
                            setState(() {
                              imageChoosed = null;
                              imagePath = null;
                            });
                          }
                        })
                  ])),
        ],
      ),
    );
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    if (imageChoosed != null || imagePath != null) {
      return Image.file(
        imageChoosed ?? File(imagePath),
        fit: BoxFit.cover,
      );
    } else if (controller != null && controller.value.isInitialized) {
      return AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: CameraPreview(controller),
      );
    } else {
      return Center();
    }
  }

  _toggleCamera() {
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
        isBackCamera =
            cameraDescription.lensDirection == CameraLensDirection.back;
      });
    }
  }

  void onTakePictureButtonPressed() {
    takePicture().then((filePath) {
      if (mounted) {
        setState(() {
          imagePath = filePath;
        });
        // ? if (filePath != null) showInSnackBar('Picture saved to $filePath');
      }
    });
  }

  Future<String> takePicture() async {
    if (!controller.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures/flutter_test';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.jpg';

    if (controller.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      await controller.takePicture(filePath);
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
    return filePath;
  }

  void showInSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  }

  void _showCameraException(CameraException e) {
    logError(e.code, e.description);
    // showInSnackBar('Error: ${e.code}\n${e.description}');
    AppNotification().show(context, buildOverlay(_translate('check')));
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
