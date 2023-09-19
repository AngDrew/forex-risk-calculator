import 'package:flutter/material.dart';

import '../calculator.dart';

class DeleteTabsButton extends StatelessWidget {
  const DeleteTabsButton({super.key, required this.stateWatcher});

  final CalculatorViewModel stateWatcher;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.delete_rounded),
      tooltip: 'Delete all tab',
      onPressed: () {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            content: const Text('Are you sure want to delete all tabs?'),
            actions: [
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  stateWatcher.deleteBox();
                  Navigator.of(context).pop();
                },
                child: const Text('Delete all'),
              ),
            ],
          ),
        );
      },
    );
  }
}
