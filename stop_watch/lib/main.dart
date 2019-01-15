import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

void main() => runApp(stopWatch());

class stopWatch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.white,
        scaffoldBackgroundColor: Colors.white
      ),

      home: homePage(),
    );
  }
}

class homePage extends StatefulWidget {
  @override
  _homePageState createState() => _homePageState();
}

class _homePageState extends State<homePage> {

  Widget _buildTextButton(String title, bool bol, String function){
      return FlatButton(
        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
            color: bol ? Colors.black54 : Colors.white,
          ),
        ),
        onPressed: (){
          //Todo:
          if(function == "alarm"){
            //todo: add alarm fucntion
             }
          else if(function == "reset"){
            //todo: add reset function
          }
          else{
            //todo: add timer function
          }
        },
        splashColor: bol ? Colors.blue: Colors.white,
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        elevation: 0.0,

        title: Text(
          "Time".toUpperCase() +" Less.",
          style: TextStyle(
            fontWeight: FontWeight.w400,
            color: Colors.black54,
          ),
        ),
        centerTitle: true,
      ),

      body: Column(
        children: <Widget>[
          Expanded(
            child: springSlider(
              markCount: 12,
              posColor: Colors.blue[200],
              negColor: Colors.white54,
            ),
          ),
          //bottom navigation bar
          Container(
            color: Colors.blue[500],
            child: Row(
              children: <Widget>[
                Expanded(child: _buildTextButton("Alarm", false, "alarm"),),
                Expanded(child: _buildTextButton("timer", false, "timer"),),
              ],
            ),
          ),
        ],
      )
    );
  }
}


class springSlider extends StatefulWidget {
  final int markCount;
  final Color posColor;
  final Color negColor;

  springSlider({
   this.markCount,
   this.posColor,
   this.negColor,
});

  @override
  _springSliderState createState() => _springSliderState();
}

class _springSliderState extends State<springSlider> {

  Stopwatch watch = new Stopwatch();
  Timer time;

  String elapsedTime = '00 : 00 : 00 : 00';

  final double paddingTop = 50.0;
  final double paddindBottom = 50.0;

  double sliderPercent =0.80;

  double startY ;
  double startPercent;
  void _onPanStart(DragStartDetails detail){
    startY = detail.globalPosition.dy;
    startPercent = sliderPercent;
  }

  void _onPanUpdate(DragUpdateDetails detail){
    final dropDis = startY - detail.globalPosition.dy;
    final sliderHeight = context.size.height;
    final dragPercent = dropDis/ sliderHeight;


    setState(() {
      if(sliderPercent < 0.70 && sliderPercent > 0.60){
        startWatch();
      }
      else if(sliderPercent <= 0.60 && sliderPercent > 0.35){
        stopWatch();
      }
      else if(sliderPercent <= 0.35){
        resetWatch();
      }
      else if( sliderPercent > 0.65){
        stopWatch();
        resetWatch();
      }
      sliderPercent = (startPercent + dragPercent).clamp(0.30, 0.80);
    });
  }

  void _onPanEnd(DragEndDetails detail){
    setState(() {
      startY = null;
      startPercent = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(

      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,

      child: Stack(
        children: <Widget>[
          sliderMark(
            markCount: widget.markCount,
            markColor: widget.posColor,
            paddingTop: paddingTop,
            paddingBottom: paddindBottom,
            bgColor: Colors.white,
          ),
          sliderGoo(
            sliderPercent: sliderPercent,
            paddingTop: paddingTop,
            paddingBottom: paddindBottom,
            child: sliderMark(
              markCount: widget.markCount,
              markColor: widget.negColor,
              bgColor: Colors.blue[500],
              paddingTop: paddingTop,
              paddingBottom: paddindBottom,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 70.0, left: 20, right: 20,),
            child: Text(elapsedTime,
              style: TextStyle(
                fontSize: 40.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
                color: Colors.blue[500],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: paddingTop,
              bottom: paddindBottom,
            ),
            child: LayoutBuilder(builder: (
                BuildContext context,
                BoxConstraints constraints
              ){

              final height = constraints.maxHeight;
              final sliderY = height *(1.0 - sliderPercent);
              final pointNeeded = (100*(1.0 - sliderPercent)).round();
              final pointHave = 100 - pointNeeded;

                return Stack(
                  children: <Widget>[
                    Positioned(
                      left: 30.0,
                      top: sliderY -50,
                      child: FractionalTranslation(
                          translation: Offset(0.0, -1.0),
                          child:  null,
                      ),
                    ),
                    //todo: remove this part or replace with reset button
                    Positioned(
                      left: 30.0,
                      top: sliderY + 50,
                      child: points(
                        point: pointHave,
                        isAbove: false,
                        isPointNeed: false,
                        color: Colors.white,
                        slider: sliderPercent,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  updateTime(Timer timer){
    setState(() {
      elapsedTime = transformToMili(watch.elapsedMilliseconds);
    });
  }

  startWatch(){
    watch.start();
    time = new Timer.periodic(Duration(milliseconds: 10), updateTime);
    setTime();
  }

  stopWatch(){
    watch.stop();
    setTime();
  }
  resetWatch(){
    watch.reset();
    setTime();
  }

  setTime(){
    var timeSofar = watch.elapsedMilliseconds;
    setState(() {
      elapsedTime = transformToMili(timeSofar);
    });
  }

  transformToMili(int milisec){

    int hun = (milisec /10).truncate();
    int sec = (hun/ 100 ).truncate();
    int min = (sec/ 60).truncate();
    int hour = (min / 60).truncate();

    String hours = (min % 60).toString().padLeft(2, '0');
    String mint = (min % 60).toString().padLeft(2, '0');
    String secs = (sec % 60).toString().padLeft(2, '0');
    String huns = (hun % 100).toString().padLeft(2, '0');

    return "$hours : $mint : $secs : $huns";
  }
}

class sliderGoo extends StatelessWidget {

  final double sliderPercent;
  final double paddingTop;
  final double paddingBottom;
  final Widget child;

  sliderGoo({
   this.sliderPercent,
   this.paddingTop,
   this.paddingBottom,
   this.child,
});
  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: sliderCliper(
        sliderPercent: sliderPercent,
        paddingTop: paddingTop,
        paddingBottom: paddingBottom,
      ),
      child: child,
    );
  }
}



class sliderMark extends StatelessWidget {
  final int markCount;
  final Color markColor;
  final Color bgColor;
  final double paddingTop;
  final double paddingBottom;

  sliderMark({
    this.markCount,
    this.markColor,
    this.bgColor,
    this.paddingTop,
    this.paddingBottom,
});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: sliderMarkPainter(
        markCount: markCount,
        markColor: markColor,
        bgColor: bgColor,
        markThick: 4.0,
        paddingTop: paddingTop,
        paddingBottom: paddingBottom,
        paddingRight: 20.0,
      ),

      child: Container(
        //todo:
      ),
    );
  }
}

class sliderMarkPainter extends CustomPainter {

  final double largeMarkW = 30.0;
  final double smallMarkW = 10.0;

  final int markCount;
  final Color markColor;
  final Color bgColor;
  final double markThick;
  final double paddingTop;
  final double paddingBottom;
  final double paddingRight;

  final Paint bgPaint;
  final Paint markPaint;

  sliderMarkPainter({
   this.markCount,
    this.markColor,
    this.bgColor,
    this.markThick,
    this.paddingTop,
    this.paddingBottom,
    this.paddingRight,

}): markPaint = new Paint()
  ..color = markColor
  ..strokeWidth = markThick
  ..style = PaintingStyle.stroke
  ..strokeCap = StrokeCap.round,
  bgPaint = new Paint()
    ..color = bgColor
    ..style = PaintingStyle.fill;


  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint

    canvas.drawRect(
      Rect.fromLTWH(0.0, 0.0, size.width, size.height),
      bgPaint
    );

    final paintH = size.height - paddingTop - paddingBottom;
    final gap = paintH/(markCount -1);

    for(int i=0; i< markCount; ++i){
      double markW = smallMarkW;
      if(i==0 || i == markCount -1){
        markW = largeMarkW;
      }
      else if( i ==1 || i == markCount -2){
        markW = lerpDouble(smallMarkW, largeMarkW, .05);
      }

      final markY = i*gap + paddingTop;
      canvas.drawLine(
        Offset(size.width - markW - paddingRight, markY),
        Offset(size.width - paddingRight, markY),
        markPaint
      );
    }

  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}

class sliderCliper extends CustomClipper<Path>{
  final double sliderPercent;
  final double paddingTop;
  final double paddingBottom;

  sliderCliper({
   this.sliderPercent,
   this.paddingTop,
   this.paddingBottom,
});

  @override
  Path getClip(Size size) {
    // TODO: implement getClip

    Path rect = new Path();

    final top = paddingTop;
    final bottom = size.height;
    final height = (bottom - paddingBottom) - top;
    final percentFromB = 1.0 - sliderPercent;

    rect.addRect(
      Rect.fromLTRB(
        0.0,
        top + (percentFromB * height),
        size.width,
        bottom,
      ),
    );
    return rect;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    // TODO: implement shouldReclip
    return true;
  }

}

class points extends StatelessWidget {

  final int point;
  final bool isAbove;
  final bool isPointNeed;
  final Color color;
  final double slider;


  points({
    this.point,
    this.isAbove = true,
    this.isPointNeed = true,
    this.color,
    this.slider
});
  getText(){
    String actionText = "Start Watch \r\n at 70";

    if(slider < .70 && slider > .60){
      actionText = "Stop Watch \r\n at 60";
      return actionText.toUpperCase();
    }

    else if( slider <=0.40 && slider > .30){
      actionText = "Reset Watch \r\n at 35";
      return actionText.toUpperCase();
    }
    else{
      actionText = "Start Watch \r\n at 70";
      return actionText.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final percent = point/100.0;
    final textSize = 30.0 + (70.0 *percent);
    return Row(

      children: <Widget>[
        FractionalTranslation(
          translation: Offset(0.0, isAbove ? 0.10 : -0.10),
          child: Text(
            '$point',
            style: TextStyle(
              fontSize: textSize,
              color: color,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Text(getText(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
