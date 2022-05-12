import 'package:draw_app/draw.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyClass());
}

class MyClass extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Draw(),
    );
  }
}
