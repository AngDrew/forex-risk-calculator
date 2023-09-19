import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String entryPriceKey = 'entryPrice';
const String capitalKey = 'capital';
const String basisKey = 'basis';
const String stopLossPipsKey = 'stopLossPips';
const String takeProfitPipsKey = 'takeProfitPips';
const String stopLossKey = 'stopLoss';
const String takeProfitKey = 'takeProfit';
const String riskKey = 'risk';
const String longOrderKey = 'longOrder';

final calculatorViewModel = ChangeNotifierProvider.autoDispose(
  (ref) => CalculatorViewModel(),
);

class CalculatorViewModel extends ChangeNotifier {
  CalculatorViewModel() {
    init();
  }

  @override
  void dispose() {
    super.dispose();
    entryPriceController.dispose();
    stopLossController.dispose();
    stopLossPipsController.dispose();
    takeProfitController.dispose();
    takeProfitPipsController.dispose();
    lotSizeController.dispose();
    riskController.dispose();
    rewardController.dispose();
    basisController.dispose();
    capitalController.dispose();
  }

  TextEditingController entryPriceController = TextEditingController();
  TextEditingController stopLossController = TextEditingController();
  TextEditingController stopLossPipsController = TextEditingController();
  TextEditingController takeProfitController = TextEditingController();
  TextEditingController takeProfitPipsController = TextEditingController();
  TextEditingController lotSizeController = TextEditingController();
  TextEditingController riskController = TextEditingController();
  TextEditingController rewardController = TextEditingController();
  TextEditingController basisController = TextEditingController();
  TextEditingController capitalController = TextEditingController();

  // price iteration for each pips
  double pipsIteration = 0.01;

  // minimum amount to buy certain assets, usually same amount as pipsIteration
  final double minimumLot = 0.01;

  double rrr = 0.0;
  double lot = 0.0;
  double lossOnSL = 0.0;
  double profitOnTP = 0.0;
  int basis = 2;
  bool editable = false;
  // bool longOrder = true;

  bool _longOrder = true;

  set longOrder(bool value) {
    _longOrder = value;
    notifyListeners();
  }

  bool get longOrder => _longOrder;

  void init() {
    SharedPreferences.getInstance().then((SharedPreferences prefs) {
      capitalController.text = prefs.getString(capitalKey) ?? '';
      basisController.text = prefs.getString(basisKey) ?? '2';
      basis = int.tryParse(basisController.text) ?? 2;
      entryPriceController.text = prefs.getString(entryPriceKey) ?? '';
      stopLossPipsController.text = prefs.getString(stopLossPipsKey) ?? '';
      takeProfitPipsController.text = prefs.getString(takeProfitPipsKey) ?? '';
      stopLossController.text = prefs.getString(stopLossKey) ?? '';
      takeProfitController.text = prefs.getString(takeProfitKey) ?? '';
      riskController.text = prefs.getString(riskKey) ?? '1';
      longOrder = prefs.getString(longOrderKey) == 'true';

      onBasisChanged(basisController.text);
      calculate();
    });
  }

  void calculate() {
    final double capital = double.tryParse(capitalController.text) ?? 0.0;
    final double stopLossPips =
        double.tryParse(stopLossPipsController.text) ?? 0.0;
    final double takeProfitPips =
        double.tryParse(takeProfitPipsController.text) ?? 0.0;
    final double risk = (double.tryParse(riskController.text) ?? 0.0) / 100;

    // calculate lot size based on risk and stoploss level
    lot = (capital * risk) / stopLossPips;

    // round lot to pipsIteration decimal places
    lot = (lot / pipsIteration).round() * pipsIteration;
    if (lot < minimumLot) lot = minimumLot;
    lot = double.parse(lot.toStringAsFixed(2));

    lossOnSL = lot * stopLossPips;
    lossOnSL = double.parse(lossOnSL.toStringAsFixed(basis));

    profitOnTP = lot * takeProfitPips;
    profitOnTP = double.parse(profitOnTP.toStringAsFixed(basis));

    if (stopLossPips > 0) rrr = takeProfitPips / stopLossPips;
    if (rrr > 0) rrr = double.parse(rrr.toStringAsFixed(1));

    notifyListeners();
  }

  void onBasisChanged(String value) {
    if (value.isEmpty) return;

    basis = int.tryParse(value) ?? 2;

    if (basis > 9) {
      basis = 9;
    } else if (basis < 1) {
      basis = 1;
    }

    pipsIteration = 1 / pow(10, basis).toDouble();

    double entryPrice = double.tryParse(entryPriceController.text) ?? 0.0;
    entryPriceController.text = entryPrice.toStringAsFixed(basis);
    cache(entryPriceKey, entryPrice.toStringAsFixed(basis));

    onSlPipsChanged();
    onTpPipsChanged();
    cache(basisKey, value);

    calculate();
  }

  void onRiskChanged(String value) {
    String newValue = value;
    if ((num.tryParse(value) ?? 0) > 100) {
      riskController.text = '100';
      newValue = '100';
    }

    cache(riskKey, newValue);
    calculate();
  }

  void onSlChanged() {
    final double entryPrice = double.tryParse(entryPriceController.text) ?? 0.0;
    final double stopLoss = double.tryParse(stopLossController.text) ?? 0.0;
    double pips = (entryPrice - stopLoss) / pipsIteration;
    if (!longOrder) pips = (stopLoss - entryPrice) / pipsIteration;
    final String pipsInString = pips.toInt().toString();

    cache(stopLossPipsKey, pipsInString);
    cache(stopLossKey, stopLoss.toStringAsFixed(basis));

    stopLossPipsController.text = pipsInString;
  }

  void onSlPipsChanged() {
    final double entryPrice = double.tryParse(entryPriceController.text) ?? 0.0;
    final int stopLossPips = int.tryParse(stopLossPipsController.text) ?? 0;
    final double stopLoss = stopLossPips * pipsIteration;
    double price = entryPrice - stopLoss;
    if (!longOrder) price = entryPrice + stopLoss;

    cache(stopLossKey, price.toStringAsFixed(basis));
    cache(stopLossPipsKey, stopLossPips.toString());

    stopLossController.text = price.toStringAsFixed(basis);
  }

  void onTpChanged() {
    final double entryPrice = double.tryParse(entryPriceController.text) ?? 0.0;
    final double takeProfit = double.tryParse(takeProfitController.text) ?? 0.0;
    double pips = (takeProfit - entryPrice) / pipsIteration;
    if (!longOrder) pips = (entryPrice - takeProfit) / pipsIteration;
    final String pipsInString = pips.toInt().toString();

    cache(takeProfitPipsKey, pipsInString);
    cache(takeProfitKey, takeProfit.toStringAsFixed(basis));

    takeProfitPipsController.text = pipsInString;
  }

  void onTpPipsChanged() {
    final double entryPrice = double.tryParse(entryPriceController.text) ?? 0.0;
    final int takeProfitPips = int.tryParse(takeProfitPipsController.text) ?? 0;
    final double takeProfit = takeProfitPips * pipsIteration;
    double price = entryPrice + takeProfit;
    if (!longOrder) price = entryPrice - takeProfit;

    cache(takeProfitKey, price.toStringAsFixed(basis));
    cache(takeProfitPipsKey, takeProfitPips.toString());

    takeProfitController.text = price.toStringAsFixed(basis);
  }

  void cache(String key, String value) {
    SharedPreferences.getInstance().then(
      (SharedPreferences prefs) => prefs.setString(key, value),
    );
  }

  void incrementValueByBasisPoint(
    TextEditingController textEditingController, {
    int? basisValue,
  }) {
    basisValue ??= basis;
    textEditingController.text =
        ((double.tryParse(textEditingController.text) ?? 0.0) + pipsIteration)
            .toStringAsFixed(basisValue);
  }

  void decrementValueByBasisPoint(
    TextEditingController textEditingController, {
    int? basisValue,
  }) {
    basisValue ??= basis;
    textEditingController.text =
        ((double.tryParse(textEditingController.text) ?? 0.0) - pipsIteration)
            .toStringAsFixed(basisValue);
  }
}