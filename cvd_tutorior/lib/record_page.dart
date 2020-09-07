import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';

class RecordPage extends StatefulWidget {
  @override
  _RecordPageState createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {//record브랜치 오 여기서도 커밋이 되네? 이제 진짜 recorder 브랜치
  FlutterSoundRecorder soundRecorder = new FlutterSoundRecorder();
  FlutterSoundPlayer soundPlayer = new FlutterSoundPlayer();

  bool _isAnswer = true;
  bool _onRecording = false;
  bool _isAnswerEmpty = true;
  bool _isFreeEmpty = true;

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
                        animationDuration: Duration(seconds: 2),
                        onPressed: () {
                          setState(() {
                            _onRecording = !_onRecording;
                          });
                        },
                        color: Colors.white,
                        child: Container(
                          width: 160,
                          height: 160,
                          child: Center(
                            child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Icon(
                                  _onRecording ? Icons.stop : Icons.mic,
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
              height: 100,
//              child: FittedBox(
//
//              ),
            ),
            ((_isAnswer && !_isAnswerEmpty) || (!_isAnswer && !_isFreeEmpty))
                ? GestureDetector(
                    onTap: () {},
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
