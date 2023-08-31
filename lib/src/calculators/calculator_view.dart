import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/default_app_bar.dart';

class RiskCalculator extends StatefulWidget {
  const RiskCalculator({super.key});

  @override
  State<RiskCalculator> createState() => _RiskCalculatorState();
}

class _RiskCalculatorState extends State<RiskCalculator> {
  late final TextEditingController _capitalController;
  late final TextEditingController _basisController;
  late final TextEditingController _entryPriceController;
  late final TextEditingController _stopLossController;
  late final TextEditingController _takeProfitController;
  late final TextEditingController _stopLossPipsController;
  late final TextEditingController _takeProfitPipsController;
  late final TextEditingController _riskController;

  bool _editable = false;
  bool _longOrder = true;

  // price iteration for each pips
  double _pipsIteration = 0.01;

  // minimum amount to buy certain assets, usually same amount as _pipsIteration
  final double _minimumLot = 0.01;

  // use 100 for forex, 1 for crypto
  final double lotSize = 100;

  double _rrr = 0.0;
  double _lot = 0.0;
  double _lossOnSL = 0.0;
  double _profitOnTP = 0.0;
  int _basis = 2;

  @override
  void initState() {
    super.initState();

    _capitalController = TextEditingController();
    _basisController = TextEditingController();
    _entryPriceController = TextEditingController();
    _stopLossPipsController = TextEditingController();
    _takeProfitPipsController = TextEditingController();
    _stopLossController = TextEditingController();
    _takeProfitController = TextEditingController();
    _riskController = TextEditingController(text: '1');

    SchedulerBinding.instance.addPostFrameCallback((_) {
      SharedPreferences.getInstance().then(
        (SharedPreferences prefs) {
          _capitalController.text = prefs.getString('capital') ?? '';
          _basisController.text = prefs.getString('basis') ?? '2';
          _basis = int.tryParse(_basisController.text) ?? 2;
          _entryPriceController.text = prefs.getString('entryPrice') ?? '';
          _stopLossPipsController.text = prefs.getString('stopLossPips') ?? '';
          _takeProfitPipsController.text =
              prefs.getString('takeProfitPips') ?? '';
          _stopLossController.text = prefs.getString('stopLoss') ?? '';
          _takeProfitController.text = prefs.getString('takeProfit') ?? '';
          _riskController.text = prefs.getString('risk') ?? '1';
          _longOrder = prefs.getString('_longOrder') == 'true';
          _calculate();
        },
      );
    });
  }

  @override
  void dispose() {
    _capitalController.dispose();
    _basisController.dispose();
    _entryPriceController.dispose();
    _stopLossPipsController.dispose();
    _takeProfitPipsController.dispose();
    _stopLossController.dispose();
    _takeProfitController.dispose();
    _riskController.dispose();

    super.dispose();
  }

  final OutlineInputBorder textFieldBorder =
      OutlineInputBorder(borderRadius: BorderRadius.circular(16.0));

  @override
  Widget build(BuildContext context) {
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
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _capitalController,
                        decoration: InputDecoration(
                          border: textFieldBorder,
                          labelText: 'Capital',
                          prefixText: '\$',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (String value) => _cache('capital', value),
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => _calculate(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _riskController,
                        decoration: InputDecoration(
                          border: textFieldBorder,
                          labelText: 'Risk',
                          suffixText: '%',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (String value) {
                          String newValue = value;
                          if ((num.tryParse(value) ?? 0) > 100) {
                            _riskController.text = '100';
                            newValue = '100';
                          }
                          _cache('risk', newValue);
                          _calculate();
                        },
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => _calculate(),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: TextField(
                        controller: _basisController,
                        maxLength: 1,
                        decoration: InputDecoration(
                          border: textFieldBorder,
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
                        onSubmitted: (_) => _onBasisChanged(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: flexSize,
                      child: TextField(
                        controller: _entryPriceController,
                        decoration: InputDecoration(
                          border: textFieldBorder,
                          labelText: 'Entry Price',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (String value) {
                          _cache('entryPrice', value);
                          setState(() {
                            _editable = _entryPriceController.text.isEmpty;
                          });
                          _onSlPipsChanged();
                          _onTpPipsChanged();
                        },
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => _calculate(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SwitchListTile(
                        value: _longOrder,
                        focusNode: FocusNode(
                          skipTraversal: true,
                          descendantsAreTraversable: false,
                        ),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16.0)),
                        ),
                        onChanged: (bool value) {
                          setState(() {
                            _longOrder = value;
                          });

                          if (_entryPriceController.text.isNotEmpty) {
                            _onSlPipsChanged();
                          }
                          if (_entryPriceController.text.isNotEmpty) {
                            _onTpPipsChanged();
                          }

                          _cache('_longOrder', value.toString());

                          _calculate();
                        },
                        title: Builder(
                          builder: (BuildContext context) {
                            if (_longOrder) {
                              return const Text('Long');
                            } else {
                              return const Text('Short');
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // TP/SL with pips
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: _stopLossPipsController,
                        decoration: InputDecoration(
                          border: textFieldBorder,
                          labelText: 'Stop Loss (Pips)',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: false,
                        ),
                        onChanged: (String value) {
                          _cache('stopLossPips', value);
                          _onSlPipsChanged();
                        },
                        textInputAction: TextInputAction.next,
                        readOnly: _editable,
                        onSubmitted: (_) => _calculate(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _takeProfitPipsController,
                        decoration: InputDecoration(
                          border: textFieldBorder,
                          labelText: 'Take Profit (Pips)',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: false,
                        ),
                        onChanged: (String value) {
                          _cache('takeProfitPips', value);
                          _onTpPipsChanged();
                        },
                        textInputAction: TextInputAction.next,
                        readOnly: _editable,
                        onSubmitted: (_) => _calculate(),
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
                        controller: _stopLossController,
                        decoration: InputDecoration(
                          border: textFieldBorder,
                          labelText: 'Stop Loss',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (String value) {
                          _cache('stopLoss', value);
                          _onSlChanged();
                        },
                        textInputAction: TextInputAction.next,
                        readOnly: _editable,
                        onSubmitted: (_) => _calculate(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _takeProfitController,
                        decoration: InputDecoration(
                          border: textFieldBorder,
                          labelText: 'Take Profit',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (String value) {
                          _cache('takeProfit', value);
                          _onTpChanged();
                        },
                        textInputAction: TextInputAction.next,
                        readOnly: _editable,
                        onSubmitted: (_) => _calculate(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _calculate,
                  child: const Text('Calculate'),
                ),
                const SizedBox(height: 32),
                Text('Lot Size: $_lot',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8.0),
                Text(
                  'Loss on SL: \$$_lossOnSL',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Colors.deepOrange),
                ),
                Text(
                  'Profit on TP: \$$_profitOnTP',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Colors.lightGreen),
                ),
                Text('RRR: 1 : $_rrr',
                    style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
          ),
        );
      },
    );
  }

  void _cache(String key, String value) {
    SharedPreferences.getInstance().then(
      (SharedPreferences prefs) => prefs.setString(key, value),
    );
  }

  void _onBasisChanged() {
    final String value = _basisController.text;

    if (value.isEmpty || value == '0') return;
    setState(() {
      _basis = int.tryParse(value) ?? 2;
      _pipsIteration = 1 / pow(10, _basis).toDouble();
    });

    double entryPrice = double.tryParse(_entryPriceController.text) ?? 0.0;
    _entryPriceController.text = entryPrice.toStringAsFixed(_basis);
    _cache('entryPrice', entryPrice.toStringAsFixed(_basis));

    _onSlPipsChanged();
    _onTpPipsChanged();
    _cache('basis', value);

    _calculate();
  }

  _onSlChanged() {
    final double entryPrice =
        double.tryParse(_entryPriceController.text) ?? 0.0;
    final double stopLoss = double.tryParse(_stopLossController.text) ?? 0.0;
    double pips = (entryPrice - stopLoss) / _pipsIteration;
    if (!_longOrder) pips = (stopLoss - entryPrice) / _pipsIteration;
    final String pipsInString = pips.toInt().toString();

    _cache('stopLossPips', pipsInString);
    _cache('stopLoss', stopLoss.toStringAsFixed(_basis));

    _stopLossPipsController.text = pipsInString;
  }

  _onSlPipsChanged() {
    final double entryPrice =
        double.tryParse(_entryPriceController.text) ?? 0.0;
    final int stopLossPips = int.tryParse(_stopLossPipsController.text) ?? 0;
    final double stopLoss = stopLossPips * _pipsIteration;
    double price = entryPrice - stopLoss;
    if (!_longOrder) price = entryPrice + stopLoss;

    _cache('stopLoss', price.toStringAsFixed(_basis));
    _cache('stopLossPips', stopLossPips.toString());

    _stopLossController.text = price.toStringAsFixed(_basis);
  }

  _onTpChanged() {
    final double entryPrice =
        double.tryParse(_entryPriceController.text) ?? 0.0;
    final int takeProfit = int.tryParse(_takeProfitController.text) ?? 0;
    double pips = (takeProfit - entryPrice) / _pipsIteration;
    if (!_longOrder) pips = (entryPrice - takeProfit) / _pipsIteration;
    final String pipsInString = pips.toInt().toString();

    _cache('takeProfitPips', pipsInString);
    _cache('takeProfit', takeProfit.toStringAsFixed(_basis));

    _takeProfitPipsController.text = pipsInString;
  }

  _onTpPipsChanged() {
    final double entryPrice =
        double.tryParse(_entryPriceController.text) ?? 0.0;
    final double takeProfitPips =
        double.tryParse(_takeProfitPipsController.text) ?? 0.0;
    final double takeProfit = takeProfitPips * _pipsIteration;
    double price = entryPrice + takeProfit;
    if (!_longOrder) price = entryPrice - takeProfit;

    _cache('takeProfit', price.toStringAsFixed(_basis));
    _cache('takeProfitPips', takeProfitPips.toString());

    _takeProfitController.text = price.toStringAsFixed(_basis);
  }

  void _calculate() {
    final double capital = double.tryParse(_capitalController.text) ?? 0.0;
    final double stopLossPips =
        double.tryParse(_stopLossPipsController.text) ?? 0.0;
    final double takeProfitPips =
        double.tryParse(_takeProfitPipsController.text) ?? 0.0;
    final double risk = (double.tryParse(_riskController.text) ?? 0.0) / 100;

    // calculate _lot size based on risk and stoploss level
    _lot = (capital * risk) / stopLossPips;

    setState(() {
      // round _lot to _pipsIteration decimal places
      _lot = (_lot / _pipsIteration).round() * _pipsIteration;
      if (_lot < _minimumLot) _lot = _minimumLot;

      _lossOnSL = _lot * stopLossPips;
      _lossOnSL = double.parse(_lossOnSL.toStringAsFixed(_basis));

      _profitOnTP = _lot * takeProfitPips;
      _profitOnTP = double.parse(_profitOnTP.toStringAsFixed(_basis));

      if (stopLossPips > 0) _rrr = takeProfitPips / stopLossPips;
      if (_rrr > 0) _rrr = double.parse(_rrr.toStringAsFixed(_basis));
    });
  }
}
