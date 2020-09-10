import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:io' as io;

import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

class RecordPage extends StatefulWidget {
  @override
  _RecordPageState createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  //record브랜치 오 여기서도 커밋이 되네? 이제 진짜 recorder 브랜치

  FlutterAudioRecorder _recorder;
  AudioPlayer player = AudioPlayer();
  AudioPlayerState playerState = AudioPlayerState.STOPPED;
  Recording _recording;
  Timer _t;
  IconData _buttonIcon = Icons.do_not_disturb_on;
  String _alert;

  bool _isAnswer = true;
  bool _isAnswerEmpty = true;
  bool _isFreeEmpty = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      _prepare();
    });
  }

  void _opt() async {

    switch (_recording.status) {
      case RecordingStatus.Initialized:
        {
          await _startRecording();
          break;
        }
      case RecordingStatus.Recording:
        {
          await _stopRecording();
          break;
        }
      case RecordingStatus.Stopped:
        {
          if (player.state == AudioPlayerState.PLAYING) {
            await player.stop();
          } else {
            await _play();

          }
          break;
        }

      default:
        break;
    }

    // 刷新按钮
    setState(() {
      _buttonIcon = _playerIcon(_recording.status,playerState);
    });
  }

  Future _init() async {
    String customPath = '/flutter_audio_recorder_';
    io.Directory appDocDirectory;
    if (io.Platform.isIOS) {
      appDocDirectory = await getApplicationDocumentsDirectory();
    } else {
      appDocDirectory = await getExternalStorageDirectory();
    }

    // can add extension like ".mp4" ".wav" ".m4a" ".aac"
    customPath = appDocDirectory.path +
        customPath +
        DateTime.now().millisecondsSinceEpoch.toString();

    // .wav <---> AudioFormat.WAV
    // .mp4 .m4a .aac <---> AudioFormat.AAC
    // AudioFormat is optional, if given value, will overwrite path extension when there is conflicts.

    _recorder = FlutterAudioRecorder(customPath,
        audioFormat: AudioFormat.WAV, sampleRate: 22050);
    await _recorder.initialized;
  }

  Future _prepare() async {
    var hasPermission = await FlutterAudioRecorder.hasPermissions;
    if (hasPermission) {
      await _init();
      var result = await _recorder.current();
      setState(() {
        _recording = result;
        _buttonIcon = _playerIcon(_recording.status,playerState);
        _alert = "";
      });
    } else {
      setState(() {
        _alert = "Permission Required.";
      });
    }
  }

  Future _startRecording() async {
    await _recorder.start();
    var current = await _recorder.current();
    setState(() {
      _recording = current;
    });

    _t = Timer.periodic(Duration(milliseconds: 10), (Timer t) async {
      var current = await _recorder.current();
      setState(() {
        _recording = current;
        _t = t;
      });
    });
  }

  Future _stopRecording() async {
    var result = await _recorder.stop();
    _t.cancel();

    setState(() {
      _recording = result;
    });
  }

  void _play() {
//    var result = player.play(_recording.path, isLocal: true);
    var result = player.play("https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3", isLocal: false);
    if(result == 1 ) {
      setState(() {
        playerState = AudioPlayerState.PLAYING;
        print('${player
            .state} 여기야!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
      });
    }
  }

  IconData _playerIcon(RecordingStatus recordStatus, AudioPlayerState playerState) {
    switch (recordStatus) {
      case RecordingStatus.Initialized:
        {
          return Icons.mic;
        }
      case RecordingStatus.Recording:
        {
          return Icons.stop;
        }
      case RecordingStatus.Stopped:
        {
          return checkPlayerState(playerState);
        }
      default:
        return Icons.mic;
    }
  }

  IconData checkPlayerState(AudioPlayerState playerState) {
    print("HI!!!!!!!!!!!!!!!!!!!");
    if (playerState == AudioPlayerState.PLAYING) {
      print("재생중니ㅣ까 멈춰로 바꿔주자ㅓ");
      return Icons.stop;
    }else {
      print("조까!!!!!!!!!");
      return Icons.play_arrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  child: Container(
                    child: Icon(Icons.arrow_back_ios),
                  ),
                ),
                Expanded(
                  child: Container(),
                )
              ],
            ),
            SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: Container(),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    MaterialButton(
                      onPressed: () {
                        setState(() {
                          _isAnswer = true;
                        });
                      },
                      color: _isAnswer ? Color(0xff878e9f) : Color(0xffe3e6ee),
                      shape: CircleBorder(),
                      elevation: 0,
                      child: Container(
                        height: 60,
                        width: 60,
                        padding: EdgeInsets.all(15),
                        decoration:
                            BoxDecoration(shape: BoxShape.circle, boxShadow: [
                          BoxShadow(
                            color: Color(0x0c000000),
                            offset: Offset(0, 15),
                            blurRadius: 45,
                            spreadRadius: 0,
                          ),
                        ]),
                        child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Icon(
                              Icons.volume_up,
                              color:
                                  _isAnswer ? Colors.white : Color(0xff979ba5),
                              size: 140,
                            )),
                      ),
                    ),
                    SizedBox(
                      height: 18,
                    ),
                    SizedBox(
                        height: 19,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '답변',
                            style: TextStyle(
                              color: _isAnswer
                                  ? Color(0xff424753)
                                  : Color(0xff8e99af),
                              fontSize: 16,
                              fontFamily: 'AppleSDGothicNeo',
                            ),
                          ),
                        )),
                  ],
                ),
                SizedBox(
                  width: 30,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isAnswer = false;
                        });
                      },
                      child: Container(
                        height: 60,
                        width: 60,
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isAnswer
                                ? Color(0xffe3e6ee)
                                : Color(0xff878e9f),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x0c000000),
                                offset: Offset(0, 15),
                                blurRadius: 45,
                                spreadRadius: 0,
                              ),
                            ]),
                        child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Icon(
                              Icons.volume_up,
                              color:
                                  _isAnswer ? Color(0xff979ba5) : Colors.white,
                              size: 40,
                            )),
                      ),
                    ),
                    SizedBox(
                      height: 18,
                    ),
                    SizedBox(
                        height: 19,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '자유',
                            style: TextStyle(
                              color: _isAnswer
                                  ? Color(0xff8e99af)
                                  : Color(0xff424753),
                              fontSize: 16,
                              fontFamily: 'AppleSDGothicNeo',
                            ),
                          ),
                        )),
                  ],
                ),
                SizedBox(
                  width: 20,
                )
              ],
            ),
            SizedBox(
              height: 50,
            ),
            Container(
                height: 70,
                child: _isAnswer
                    ? FittedBox(
                        child: Text(
                          '여자친구에게 서운할때는?',
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.8),
                            fontSize: 30,
                            fontFamily: 'AppleSDGothicNeo',
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      )
                    : FittedBox(
                        child: Text(
                          '2020.09.08 아현이의 속삭임 #1',
                          maxLines: 3,
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.5),
                            fontSize: 30,
                            fontFamily: 'AppleSDGothicNeo',
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      )),
            SizedBox(height: 50),
            Center(
              child: Container(
                width: 190,
                height: 190,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Color(0xffffacac).withOpacity(0.5), width: 3)),
                child: Stack(
                  children: [
                    Center(
                        child: SizedBox(
                            width: 175,
                            child: Divider(
                              thickness: 1,
                            ))),
                    Center(
                        child: SizedBox(
                            height: 175,
                            child: VerticalDivider(
                              thickness: 1,
                            ))),
                    Center(
                      child: MaterialButton(
                        splashColor: Color(0xffffacac),
                        onPressed: _opt,
                        color: Colors.white,
                        child: Container(
                          width: 160,
                          height: 160,
                          child: Center(
                            child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Icon(
                                  _buttonIcon,
                                  color: Color(0xffffacac),
                                  size: 80,
                                )),
                          ),
                        ),
                        shape: CircleBorder(),
                        elevation: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            SizedBox(
              height: 50,
              child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${_recording?.duration.toString().substring(2, 7) ?? " "}',
                    style: TextStyle(color: Colors.grey.withOpacity(0.5),fontSize: 50),
                  )),
            ),
            SizedBox(
              height: 40,
            ),
            ((_isAnswer && _recording.status == RecordingStatus.Stopped) ||
                    (!_isAnswer && !_isFreeEmpty))
                ? GestureDetector(
                    onTap: () {
//                      _buttonIcon = _playerIcon();
                      setState(() {
                        _prepare();
                      });
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      color: Color(0xff80ffacac),
//                      color: Color.fromRGBO(135, 142, 159, 1),
                      elevation: 8,
                      shadowColor: Color(0x33000000),
                      child: Container(
                        height: 60,
                        child: Center(
                            child: Text("다시 녹음",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontFamily: 'AppleSDGothicNeo',
                                  fontWeight: FontWeight.w700,
                                ))),
                      ),
                    ),
                  )
                : Card(
                    color: Colors.transparent,
                    child: SizedBox(
                      height: 60,
                    ),
                    elevation: 0,
                  ),
            SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: () {
                print("${player.state} ㅜㅜㅜㅜㅜㅜㅜㅜㅜㅜㅜㅜㅜㅜㅜㅜㅜㅜㅜㅜㅜㅜㅜㅜㅜㅜㅜㅜㅜㅜㅜㅜㅜㅜㅜㅜㅜㅜㅜㅜㅜㅜㅜㅜㅜㅜㅜㅜㅜㅜㅜㅜㅜㅜ");
                setState(() {
                  _isAnswerEmpty = !_isAnswerEmpty;
                });
              },
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                color: Color(0xffffacac),
                elevation: 8,
                shadowColor: Color(0x33000000),
                child: Container(
                  height: 60,
                  child: Center(
                      child: Text("확인",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontFamily: 'AppleSDGothicNeo',
                            fontWeight: FontWeight.w700,
                          ))),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


//Todo
//시작할때 7오류 왜나는지
//재생주일때 정지로 바뀌기
//답변/자유로 와리가리하기
//다시녹음하면 파일 지우기