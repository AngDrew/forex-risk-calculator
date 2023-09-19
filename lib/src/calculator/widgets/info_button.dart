import 'package:flutter/material.dart';

class InfoButton extends StatelessWidget {
  const InfoButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: const Text('About'),
              content: const SelectableText(
                'This is a simple risk '
                'calculator for Forex. '
                '\nIt is not a financial advice. '
                'Use at your own risk.'
                '\nBy: github.com/AngDrew',
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
      icon: const Icon(Icons.info_rounded),
    );
  }
}
