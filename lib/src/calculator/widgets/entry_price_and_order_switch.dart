import 'package:flutter/material.dart';
import '../calculator.dart';

class EntryPriceAndOrderSwitch extends StatelessWidget {
  const EntryPriceAndOrderSwitch({
    super.key,
    required OutlineInputBorder textFieldBorder,
    required this.flexSize,
    required this.stateWatcher,
  }) : _textFieldBorder = textFieldBorder;

  final OutlineInputBorder _textFieldBorder;
  final int flexSize;
  final CalculatorViewModel stateWatcher;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          flex: flexSize,
          child: TextField(
            controller: stateWatcher.entryPriceController,
            decoration: InputDecoration(
              border: _textFieldBorder,
              labelText: 'Entry Price',
            ),
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            onChanged: (String value) {
              stateWatcher.editable =
                  stateWatcher.entryPriceController.text.isEmpty;

              stateWatcher.onSlPipsChanged();
              stateWatcher.onTpPipsChanged();
            },
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => stateWatcher.calculate(),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: FocusScope(
            parentNode: FocusNode(
              descendantsAreFocusable: false,
              descendantsAreTraversable: false,
            ),
            child: SwitchListTile(
              value: stateWatcher.longOrder,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16.0)),
              ),
              onChanged: (bool value) {
                stateWatcher.longOrder = value;
                stateWatcher.cache(longOrderKey, value.toString());

                if (stateWatcher.entryPriceController.text.isNotEmpty) {
                  stateWatcher.onSlPipsChanged();
                  stateWatcher.onTpPipsChanged();
                }

                stateWatcher.calculate();
              },
              title: Builder(
                builder: (_) {
                  if (stateWatcher.longOrder) {
                    return const Text('Long');
                  }

                  return const Text('Short');
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
