import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io' as io;

import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

class RecordPage extends StatefulWidget {
  @override
  _RecordPageState createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {

  double _stickWidth=4;
  double _stickMargin = 4;
  double _maxHeight = 150;
  double _minHeight = 10;
  int counter=0;
  double _width=384;
  int stickAmount;
  List<double> _stickHeights = new List<double>();

  FlutterAudioRecorder _recorder;
  AudioPlayer player = AudioPlayer();
  AudioPlayerState playerState = AudioPlayerState.STOPPED;
  Recording _recording;
  Timer _t;
  IconData _buttonIcon = Icons.more_horiz;

  bool _isAnswer = true;
  bool _isAnswerEmpty = true;
  bool _isFreeEmpty = true;

  List<FlSpot> dataSpot = new List<FlSpot>();
  List<FlSpot> fakeSpot =
  new List<FlSpot>.generate(100, (index) => FlSpot(index.toDouble(), 0));

  @override
  void initState() {
    super.initState();
    stickAmount = ((_width - 60) / (_stickWidth+_stickMargin)).toInt();
    _stickHeights = List<double>.generate(stickAmount, (index) => 10);
    Future.microtask(() {
      //제스터 디텍터같은 이벤트큐 생성되기 이전에 준비작업.
      _prepare();
    });
    dataSpot.add(FlSpot(0, 0));
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
//            _recording.status = RecordingStatus.Paused;
          await _recorder.pause();
          _t.cancel();
          break;
        }
      case RecordingStatus.Paused:
        {
          await _recorder.resume();
          _t = Timer.periodic(Duration(milliseconds: 100), (Timer t) async {
            var current = await _recorder.current();
            setState(() {
              _recording = current;
              if(counter>stickAmount/2){
                _stickHeights.removeAt(0);
                _stickHeights.insert((stickAmount/2).toInt(), levelToHeight(current.metering.averagePower));
              }else {
                _stickHeights[counter]=levelToHeight(current.metering.averagePower);
              }
              _t = t;
            });
            counter++;
          });
          break;
        }
      case RecordingStatus.Stopped:
        {
          if (player.state == AudioPlayerState.PLAYING) {
            playerState = AudioPlayerState.STOPPED;
            await player.stop();
          } else {
            await _play();
          }
          break;
        }

      default:
        break;
    }
    var result = await _recorder.current();
    setState(() {
      _recording = result;
      _buttonIcon = _playerIcon(_recording.status, playerState);
    });
  }

  Future _init() async {
    //경로설정, 레코더 생성
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
        DateTime
            .now()
            .millisecondsSinceEpoch
            .toString() + ".mp4";

    // .wav <---> AudioFormat.WAV
    // .mp4 .m4a .aac <---> AudioFormat.AAC
    // AudioFormat is optional, if given value, will overwrite path extension when there is conflicts.

    _recorder = FlutterAudioRecorder(customPath,
        audioFormat: AudioFormat.AAC, sampleRate: 8000);
    await _recorder.initialized;
  }

  Future _prepare() async {
    var hasPermission = await FlutterAudioRecorder.hasPermissions;
    if (hasPermission) {
      await _init();
      var result = await _recorder.current();
      setState(() {
        _recording = result;
        _buttonIcon = _playerIcon(_recording.status, playerState);
//        _alert = "";
      });
    } else {
      setState(() {
//        _alert = "Permission Required.";
      });
    }

    player.onPlayerCompletion.listen((event) {
      setState(() {
        playerState = player.state;
        _buttonIcon = _playerIcon(_recording.status, playerState);
      });
    });

    player.onPlayerStateChanged.listen((event) {
      setState(() {
        playerState = player.state;
        _buttonIcon = _playerIcon(_recording.status, playerState);
      });
    });
  }


  Future _startRecording() async {
    await _recorder.start();
    var current = await _recorder.current();
    setState(() {
      _recording = current;
    });
    _t = Timer.periodic(Duration(milliseconds: 100), (Timer t) async {
      var current = await _recorder.current();
      setState(() {
        _recording = current;
        if(counter>stickAmount/2){
          _stickHeights.removeAt(0);
          _stickHeights.insert((stickAmount/2).toInt(), levelToHeight(current.metering.averagePower));
        }else {
          _stickHeights[counter]=levelToHeight(current.metering.averagePower);
        }
        _t = t;
      });
      counter++;
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
    var result = player.play(_recording.path, isLocal: true);
//    var result = player.play("https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3", isLocal: false);
  }

  IconData _playerIcon(RecordingStatus recordStatus,
      AudioPlayerState playerState) {
    // 녹음상태와 재생상태를 확인해 적절한 아이콘데이터를 리턴
    switch (recordStatus) {
      case RecordingStatus.Initialized:
        {
          return Icons.mic;
        }
      case RecordingStatus.Recording:
        {
          return Icons.pause;
        }
      case RecordingStatus.Stopped:
        {
          return checkPlayerState(playerState);
        }
      case RecordingStatus.Paused:
        {
          return Icons.mic;
        }
      default:
        return Icons.mic;
    }
  }

  IconData checkPlayerState(AudioPlayerState playerState) {
    if (playerState == AudioPlayerState.PLAYING) {
      return Icons.stop;
    } else {
      return Icons.play_arrow;
    }
  }
  double levelToHeight(double level){
    if(level < -30) {
      return _minHeight;
    }else{
      return _maxHeight + level * ((_maxHeight - _minHeight ) -30 ) / 30 ;
    }
  }
  @override
  Widget build(BuildContext context) {

    return SingleChildScrollView(
      child: SafeArea(
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
                        color:
                        _isAnswer ? Color(0xff878e9f) : Color(0xffe3e6ee),
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
                                color: _isAnswer
                                    ? Colors.white
                                    : Color(0xff979ba5),
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
                                color: _isAnswer
                                    ? Color(0xff979ba5)
                                    : Colors.white,
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
                height: 30,
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
              SizedBox(height: 40),
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
                      _recording == null
                          ? "..."
                          : '${_recording.duration.toString().substring(2, 7)}',
                      style: TextStyle(
                          color: Colors.grey.withOpacity(0.5), fontSize: 50),
                    )),
              ),
              recordVisualizer(),
              SizedBox(
                height: 40,
              ),
              (_recording?.status == RecordingStatus.Stopped)
                  ? GestureDetector(
                onTap: () {
                  setState(() {
                    _prepare();
                    _stickHeights = List<double>.generate(stickAmount, (index) => 10);
                    counter = 0;
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
//                  Directory(_recording.path).delete(recursive: true);
                  _stopRecording();
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
      ),
    );
  }

  Widget recordVisualizer() {
    return Container(
      child: Row(
          children: List<Row>.generate(_stickHeights.length, (index) =>
          Row(
            children: [
              Container(
               width:_stickWidth,
               height: _stickHeights[index],
               decoration: BoxDecoration(
//                 color: (index < (stickAmount/2).toInt())?Color(0xffffacac):Colors.grey.withOpacity(0.2),
                 color: (counter < stickAmount/2)
                          ?(index<counter)?Color(0xffffacac):Colors.grey.withOpacity(0.2)
                          :(index <= stickAmount/2)?Color(0xffffacac):Colors.grey.withOpacity(0.2),
                 borderRadius: BorderRadius.all(Radius.circular(_stickWidth/2))
               ),
              ),
              SizedBox(width: _stickMargin,height: _maxHeight)
            ],
          )
        )
      ),
    );
  }

}

//Todo

//답변/자유로 와리가리하기
//다시녹음하면 파일 지우기

//그래프 중간선, xy 숫자 지우기
//x축 길이 설정하기
//오른쪽 끝 남기는게 좋을 것 같은데 어떻게?
