import 'package:flutter/material.dart';

class OwnerHomePage extends StatelessWidget {
  const OwnerHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Owner Home')),
      body: const Center(child: Text('Welcome Owner!')),
    );
  }
}

