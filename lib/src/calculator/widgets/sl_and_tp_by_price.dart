import 'package:flutter/material.dart';
import '../calculator.dart';

class SlAndTpByPrice extends StatelessWidget {
  const SlAndTpByPrice({
    super.key,
    required this.stateWatcher,
    required OutlineInputBorder textFieldBorder,
  }) : _textFieldBorder = textFieldBorder;

  final CalculatorViewModel stateWatcher;
  final OutlineInputBorder _textFieldBorder;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: TextField(
            controller: stateWatcher.stopLossController,
            decoration: InputDecoration(
              border: _textFieldBorder,
              labelText: 'Stop Loss',
            ),
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            onChanged: (String value) {
              stateWatcher.onSlChanged();
            },
            textInputAction: TextInputAction.next,
            readOnly: stateWatcher.editable,
            onSubmitted: (_) => stateWatcher.calculate(),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextField(
            controller: stateWatcher.takeProfitController,
            decoration: InputDecoration(
              border: _textFieldBorder,
              labelText: 'Take Profit',
            ),
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            onChanged: (String value) {
              stateWatcher.onTpChanged();
            },
            textInputAction: TextInputAction.next,
            readOnly: stateWatcher.editable,
            onSubmitted: (_) => stateWatcher.calculate(),
          ),
        ),
      ],
    );
  }
}
