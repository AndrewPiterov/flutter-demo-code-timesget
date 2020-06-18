import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'dart:io';
import 'dart:async';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:timesget/all_translations.dart';
import 'package:timesget/components/buttons.dart';
import 'package:timesget/styles/colors.dart';
import 'package:timesget/styles/text_styles.dart';

class AudioRecordPage extends StatefulWidget {
  @override
  _AudioRecordPagetate createState() => new _AudioRecordPagetate();
}

class _AudioRecordPagetate extends State<AudioRecordPage> {
  bool _isRecording = false;
  bool _isPlaying = false;
  StreamSubscription _recorderSubscription;
  StreamSubscription _playerSubscription;
  FlutterSound flutterSound;

  final int maxSeconds = 10;
  int recordedSeconds = 0;

  String _recorderTxt = '00:00:00';

  String _recordedFilePath;

  @override
  void initState() {
    super.initState();
    flutterSound = new FlutterSound();
    flutterSound.setSubscriptionDuration(0.01);
  }

  int extractSeconds(String sec) {
    // 'mm:ss:SS'
    final parts = sec.split(':');
    final seconds = int.parse(parts[1]);
    return seconds;
  }

  void startRecorder() async {
    try {
      String path = await flutterSound.startRecorder(null);
      print('startRecorder: $path');

      _recorderSubscription = flutterSound.onRecorderStateChanged.listen((e) {
        final date =
            DateTime.fromMillisecondsSinceEpoch(e.currentPosition.toInt());
        final txt =
            DateFormat('mm:ss:SS', 'en_US').format(date).substring(0, 8);

        final s = extractSeconds(txt);
        if (s >= maxSeconds) {
          print('Reached max record seconds');
          stopRecorder();
        }

        setState(() {
          _recorderTxt = txt;
          recordedSeconds = s;
        });
      });

      this.setState(() {
        _recordedFilePath = null;
        _isRecording = true;
      });
    } catch (err) {
      print('startRecorder error: $err');
    }
  }

  void stopRecorder() async {
    try {
      final result = await flutterSound.stopRecorder();
      print('stopRecorder: $result');

      if (_recorderSubscription != null) {
        _recorderSubscription.cancel();
        _recorderSubscription = null;
      }

      setState(() {
        _isRecording = false;

        if (Platform.isAndroid) {
          _recordedFilePath = '/storage/emulated/0/default.mp4';
        } else if (Platform.isIOS) {
          final RegExp regexp = RegExp(
              '(\{){0,1}[0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12}(\}){0,1}');
          final guid = regexp.stringMatch(result);

          _recordedFilePath =
              '/var/mobile/Containers/Data/Application/$guid/tmp/sound.m4a';
        }
      });
    } catch (err) {
      print('stopRecorder error: $err');
    }
  }

  void startPlayer() async {
    String path = await flutterSound.startPlayer(null);
    await flutterSound.setVolume(1.0);
    print('startPlayer: $path');

    try {
      _playerSubscription = flutterSound.onPlayerStateChanged.listen((e) {
        if (e != null) {
          final date = new DateTime.fromMillisecondsSinceEpoch(
              e.currentPosition.toInt());
          var txt =
              DateFormat('mm:ss:SS', 'en_US').format(date).substring(0, 8);

          final s = extractSeconds(txt);
          if (s >= recordedSeconds) {
            // stopPlayer();
            print('Playing has reached record seconds');

            this.setState(() {
              this._isPlaying = false;
              this._recorderTxt = '00:00:00';
            });
          } else {
            this.setState(() {
              this._isPlaying = true;
              this._recorderTxt = txt;
            });
          }
        }
      });
    } catch (err) {
      print('error: $err');
    }
  }

  void stopPlayer() async {
    try {
      final result = await flutterSound.stopPlayer();
      print('stopPlayer: $result');
      if (_playerSubscription != null) {
        _playerSubscription.cancel();
        _playerSubscription = null;
      }

      this.setState(() {
        _isPlaying = false;
        _recorderTxt = '00:00:00';
      });
    } catch (err) {
      print('error: $err');
    }
  }

  void pausePlayer() async {
    String result = await flutterSound.pausePlayer();
    print('pausePlayer: $result');
  }

  void resumePlayer() async {
    String result = await flutterSound.resumePlayer();
    print('resumePlayer: $result');
  }

  void seekToPlayer(int milliSecs) async {
    int secs = Platform.isIOS ? milliSecs / 1000 : milliSecs;

    String result = await flutterSound.seekToPlayer(secs);
    print('seekToPlayer: $result');
  }

  Widget _getPlayButton() {
    if (_recordedFilePath != null && !_isPlaying) {
      return FlatButton(
        onPressed: () {
          startPlayer();
        },
        padding: EdgeInsets.all(10.0),
        child: Icon(
          Icons.play_arrow,
          color: Colors.blueAccent,
          size: 30.0,
        ),
      );
    }

    if (_recordedFilePath != null && _isPlaying) {
      return FlatButton(
        onPressed: () {
          stopPlayer();
        },
        padding: EdgeInsets.all(8.0),
        child: Icon(
          Icons.stop,
          color: Colors.black,
        ),
      );
    }

    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: <Widget>[
        Column(
          children: <Widget>[
            Expanded(
              child: Container(),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 24.0, bottom: 16.0),
                  child: Text(
                    this._recorderTxt,
                    style: TextStyle(
                      fontSize: 48.0,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Container(
                  width: 56.0,
                  height: 56.0,
                  child: ClipOval(
                    child: FlatButton(
                      onPressed: () {
                        if (!this._isRecording) {
                          return this.startRecorder();
                        }
                        this.stopRecorder();
                      },
                      padding: EdgeInsets.all(8.0),
                      child: _isPlaying
                          ? Container()
                          : Icon(
                              this._isRecording ? Icons.stop : Icons.mic,
                              size: 50.0,
                              color:
                                  _isRecording ? Colors.red : AppColors.black,
                            ),
                    ),
                  ),
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
            ),
            Expanded(
              child: Container(),
            ),
            Container(
              padding: EdgeInsets.all(20.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppColoredButton(
                      null,
                      titleAsContent: Text(allTranslations.text('use_audio'),
                          style: TextStyle(
                              fontSize: AppTextStyles.fontSize14,
                              fontWeight: FontWeight.w500)),
                      w: 50.0,
                      isActive: _recordedFilePath != null,
                      onTap: () async {
                        final file = File(_recordedFilePath);
                        final isSuccess = await file.exists();
                        assert(isSuccess);
                        Navigator.pop(context, file);
                      },
                    ),
                    _getPlayButton(),
                    // AppColoredButton(
                    //   allTranslations.text('cancel'),
                    //   color: AppColors.yellow,
                    //   w: 100.0,
                    //   onTap: () {
                    //     Navigator.pop(context, null);
                    //   },
                    // ),
                  ]),
            )
          ],
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
              color: AppColors.black,
            ),
          ),
        ),
      ],
    )

        /*Column(
        children: [
          Expanded(child: Container()),
          Container(
              child: Column(children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 24.0, bottom: 16.0),
                  child: Text(
                    this._recorderTxt,
                    style: TextStyle(
                      fontSize: 48.0,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Container(
                  width: 56.0,
                  height: 56.0,
                  child: ClipOval(
                    child: FlatButton(
                      onPressed: () {
                        if (!this._isRecording) {
                          return this.startRecorder();
                        }
                        this.stopRecorder();
                      },
                      padding: EdgeInsets.all(8.0),
                      child: _isPlaying
                          ? Container()
                          : Icon(
                              this._isRecording ? Icons.stop : Icons.mic,
                              size: 50.0,
                              color:
                                  _isRecording ? Colors.red : AppColors.black,
                            ),
                    ),
                  ),
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
            )
          ])),
          Expanded(child: Center()),
          Container(
            padding: EdgeInsets.all(20.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppColoredButton(
                    allTranslations.text('use_audio'),
                    w: 100.0,
                    isActive: _recordedFilePath != null,
                    onTap: () async {
                      final file = File(_recordedFilePath);
                      final isSuccess = await file.exists();
                      assert(isSuccess);
                      Navigator.pop(context, file);
                    },
                  ),
                  _getPlayButton(),
                  AppColoredButton(
                    allTranslations.text('cancel'),
                    color: AppColors.yellow,
                    w: 100.0,
                    onTap: () {
                      Navigator.pop(context, null);
                    },
                  ),
                ]),
          )
        ],
      ),*/
        );
  }
}
