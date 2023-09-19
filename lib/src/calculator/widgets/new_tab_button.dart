import 'package:flutter/material.dart';

import '../calculator.dart';

class NewTabButton extends StatelessWidget {
  const NewTabButton({super.key, required this.stateWatcher});

  final CalculatorViewModel stateWatcher;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.add_rounded),
      onPressed: () {
        stateWatcher.newTab().then((_) {
          stateWatcher.switchTabTo(stateWatcher.tabLength() - 1);
        });
      },
    );
  }
}
