import 'package:flutter/material.dart';

class ScanQrScreen extends StatelessWidget {
  const ScanQrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ScanQrScreen')),
      body: const Center(child: Text('ScanQrScreen Content')),
    );
  }
}
