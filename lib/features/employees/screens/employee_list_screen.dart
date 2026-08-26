import 'package:flutter/material.dart';

class EmployeeListScreen extends StatelessWidget {
  const EmployeeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('EmployeeListScreen')),
      body: const Center(child: Text('EmployeeListScreen Content')),
    );
  }
}
