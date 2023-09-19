import 'package:flutter/material.dart';
import '../calculator.dart';

class CapitalRiskAndBasis extends StatelessWidget {
  const CapitalRiskAndBasis({
    super.key,
    required OutlineInputBorder textFieldBorder,
    required this.stateWatcher,
  }) : _textFieldBorder = textFieldBorder;

  final OutlineInputBorder _textFieldBorder;
  final CalculatorViewModel stateWatcher;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 3,
          child: TextField(
            controller: stateWatcher.capitalController,
            decoration: InputDecoration(
              border: _textFieldBorder,
              labelText: 'capital',
              prefixText: '\$',
            ),
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            onChanged: (String value) => stateWatcher.cache(FieldId.capital, value),
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => stateWatcher.calculate(),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextField(
            controller: stateWatcher.riskController,
            decoration: InputDecoration(
              border: _textFieldBorder,
              labelText: 'Risk',
              suffixText: '%',
            ),
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            onChanged: stateWatcher.onRiskChanged,
            textInputAction: TextInputAction.next,
            onSubmitted: stateWatcher.onRiskChanged,
          ),
        ),
        const SizedBox(width: 16.0),
        Expanded(
          child: TextField(
            controller: stateWatcher.basisController,
            maxLength: 1,
            decoration: InputDecoration(
              border: _textFieldBorder,
              labelText: 'Basis',
              counterText: '',
              hintText: '1 - 9',
              suffix: const Tooltip(
                message: 'Basis is the number of decimal places '
                    'for the price of the asset. '
                    '\nFor example: EURJPY is 3, '
                    'BTCUSD is 1, XAUUSD is 2, EURGBP is 5, etc.',
                child: Icon(Icons.info_rounded),
              ),
            ),
            keyboardType: const TextInputType.numberWithOptions(
              decimal: false,
            ),
            textInputAction: TextInputAction.next,
            onChanged: stateWatcher.onBasisChanged,
            onSubmitted: stateWatcher.onBasisChanged,
          ),
        ),
      ],
    );
  }
}
