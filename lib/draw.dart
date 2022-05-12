import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class Draw extends StatefulWidget {
  const Draw({Key? key}) : super(key: key);

  @override
  State<Draw> createState() => _DrawState();
}

class _DrawState extends State<Draw> {
  Color selectedColor = Colors.black;
  Color pickerColor = Colors.black;
  double strokeWidth = 3.0;
  double opacity = 1.0;
  bool showBottomList = false;
  StrokeCap strokeCap = (Platform.isAndroid) ? StrokeCap.butt : StrokeCap.round;
  SelectedMode selectedMode = SelectedMode.StrokeWidth;
  List<DrawingPoints?> points = [];
  List<Color> colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.amber,
    Colors.black,
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            RenderBox? renderBox = context.findRenderObject() as RenderBox?;
            points.add(
              DrawingPoints(
                points: renderBox!.globalToLocal(details.globalPosition),
                paint: Paint()
                  ..strokeCap = strokeCap
                  ..isAntiAlias = true
                  ..color = selectedColor.withOpacity(opacity)
                  ..strokeWidth = strokeWidth,
              ),
            );
          });
        },
        onPanStart: (details) {
          setState(() {
            RenderBox? renderBox = context.findRenderObject() as RenderBox?;
            points.add(
              DrawingPoints(
                points: renderBox!.globalToLocal(details.globalPosition),
                paint: Paint()
                  ..strokeCap = strokeCap
                  ..isAntiAlias = true
                  ..color = selectedColor.withOpacity(opacity)
                  ..strokeWidth = strokeWidth,
              ),
            );
          });
        },
        onPanEnd: (details) {
          setState(() {
            points.add(null);
          });
        },
        child: CustomPaint(
          size: Size.infinite,
          painter: DrawingPainters(
            pointsList: points,
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: Colors.tealAccent,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notes),
                    onPressed: () {
                      setState(() {
                        if (selectedMode == SelectedMode.StrokeWidth) {
                          showBottomList = !showBottomList;
                          selectedMode = SelectedMode.StrokeWidth;
                        }
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.opacity),
                    onPressed: () {
                      setState(() {
                        if (selectedMode == SelectedMode.Opacity) {
                          showBottomList = !showBottomList;
                          selectedMode = SelectedMode.Opacity;
                        }
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.color_lens),
                    onPressed: () {
                      setState(() {
                        if (selectedMode != SelectedMode.Color) {
                          showBottomList = !showBottomList;
                          selectedMode = SelectedMode.Color;
                        }
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        showBottomList = false;
                        points.clear();
                      });
                    },
                  ),
                ],
              ),
              Visibility(
                child: (selectedMode == SelectedMode.Color)
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: getcolorList(),
                      )
                    : Slider(
                        value: (selectedMode == SelectedMode.StrokeWidth)
                            ? strokeWidth
                            : opacity,
                        max: (selectedMode == SelectedMode.StrokeWidth)
                            ? 50.0
                            : 1.0,
                        min: 0.0,
                        onChanged: (val) {
                          if (selectedMode == SelectedMode.StrokeWidth) {
                            strokeWidth = val;
                          } else {
                            opacity = val;
                          }
                        },
                      ),
                visible: showBottomList,
              ),
            ],
          ),
        ),
      ),
    );
  }

  getcolorList() {
    List<Widget> listWidget = [];
    for (Color color in colors) {
      listWidget.add(colorCircle(color));
    }
    Widget colorPicker = GestureDetector(
      onTap: () {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Pick a Color"),
                content: SingleChildScrollView(
                  reverse: true,
                  child: ColorPicker(
                    pickerColor: pickerColor,
                    onColorChanged: (Color value) {
                      pickerColor = value;
                    },
                    showLabel: true,
                    colorPickerWidth: 0.8,
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text(
                      "Got it ",
                    ),
                    onPressed: () {
                      setState(() {
                        selectedColor = pickerColor;
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            });
      },
      child: ClipOval(
        child: Container(
          padding: const EdgeInsets.only(
            bottom: 20.0,
          ),
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white,
                Colors.black,
                Colors.red,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
    );
    listWidget.add(colorPicker);
    return listWidget;
  }

  Widget colorCircle(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedColor = color;
        });
      },
      child: Container(
        width: 35,
        height: 35,
        color: color,
      ),
    );
  }
}

class DrawingPainters extends CustomPainter {
  List<DrawingPoints?> pointsList = [];
  List<Offset> offsetPoints = [];
  DrawingPainters({required this.pointsList});

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < pointsList.length - 1; i++) {
      if (pointsList[i] != null && pointsList[i + 1] != null) {
        canvas.drawLine(pointsList[i]!.points, pointsList[i + 1]!.points,
            pointsList[i]!.paint);
      } else if (pointsList[i] != null && pointsList[i + 1] == null) {
        offsetPoints.clear();
        offsetPoints.add(pointsList[i]!.points);
        offsetPoints.add(Offset(
          pointsList[i]!.points.dx + 0.1,
          pointsList[i]!.points.dy + 0.1,
        ));
        canvas.drawPoints(PointMode.points, offsetPoints, pointsList[i]!.paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class DrawingPoints {
  Paint paint;
  Offset points;

  DrawingPoints({required this.paint, required this.points});
}

enum SelectedMode {
  StrokeWidth,
  Opacity,
  Color,
}
