import 'package:flutter/material.dart';
import '../calculator.dart';

class SlAndTpByPips extends StatelessWidget {
  const SlAndTpByPips({
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
            controller: stateWatcher.stopLossPipsController,
            decoration: InputDecoration(
              border: _textFieldBorder,
              labelText: 'Stop Loss (Pips)',
            ),
            keyboardType: const TextInputType.numberWithOptions(
              decimal: false,
            ),
            onChanged: (String value) {
              stateWatcher.onSlPipsChanged();
            },
            textInputAction: TextInputAction.next,
            readOnly: stateWatcher.editable,
            onSubmitted: (_) => stateWatcher.calculate(),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextField(
            controller: stateWatcher.takeProfitPipsController,
            decoration: InputDecoration(
              border: _textFieldBorder,
              labelText: 'Take Profit (Pips)',
            ),
            keyboardType: const TextInputType.numberWithOptions(
              decimal: false,
            ),
            onChanged: (String value) {
              stateWatcher.onTpPipsChanged();
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
