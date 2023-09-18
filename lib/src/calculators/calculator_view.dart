import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:risk_calculator/src/calculators/vms/calculator_vm.dart';

import '../widgets/default_app_bar.dart';

class RiskCalculatorView extends ConsumerStatefulWidget {
  const RiskCalculatorView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _RiskCalculatorViewState();
}

class _RiskCalculatorViewState extends ConsumerState<RiskCalculatorView> {
  final OutlineInputBorder _textFieldBorder =
      OutlineInputBorder(borderRadius: BorderRadius.circular(16.0));

  @override
  Widget build(BuildContext context) {
    final stateWatcher = ref.watch(calculatorViewModel);

    return LayoutBuilder(
      builder: (context, constraints) {
        int flexSize = 3;
        if (constraints.maxWidth < 600) {
          flexSize = 1;
        }

        return GestureDetector(
          onTap: FocusScope.of(context).unfocus,
          child: Scaffold(
            appBar: const DefaultAppBar(),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                capitalRiskAndBasis(stateWatcher),
                const SizedBox(height: 16),
                entryPriceAndOrderSwitch(flexSize, stateWatcher),
                const SizedBox(height: 16),
                // TP/SL with pips
                Row(
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
                ),
                // TP/SL with price
                const SizedBox(height: 16),
                Row(
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
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: stateWatcher.calculate,
                  child: const Text('Calculate'),
                ),
                const SizedBox(height: 32),
                Text('Lot Size: ${stateWatcher.lot}',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8.0),
                Text(
                  'Loss on SL: \$${stateWatcher.lossOnSL}',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Colors.deepOrange),
                ),
                Text(
                  'Profit on TP: \$${stateWatcher.profitOnTP}',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Colors.lightGreen),
                ),
                Text('RRR: 1 : ${stateWatcher.rrr}',
                    style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
          ),
        );
      },
    );
  }

  Row entryPriceAndOrderSwitch(int flexSize, CalculatorViewModel stateWatcher) {
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
                builder: (BuildContext context) {
                  if (stateWatcher.longOrder) {
                    return const Text('Long');
                  } else {
                    return const Text('Short');
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Row capitalRiskAndBasis(CalculatorViewModel stateWatcher) {
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
            onChanged: (String value) => stateWatcher.cache(capitalKey, value),
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
                child: Icon(
                  Icons.info_rounded,
                ),
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
