import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CameraPage extends StatelessWidget {
  const CameraPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 50,
        centerTitle: true,
        shadowColor: Colors.black.withOpacity(.5),
        title: const Text(
          'NOT READY',
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
    );
  }
}