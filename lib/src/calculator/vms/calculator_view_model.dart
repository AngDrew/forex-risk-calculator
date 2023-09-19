import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:risk_calculator/src/calculator/calculator.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    _openHiveBox().then((_) {
      SharedPreferences.getInstance().then((SharedPreferences prefs) {
        // load previous tab
        final int? tabIndex = prefs.getInt('tabIndex');

        if (tabIndex != null) {
          loadTab(tabIndex);
        }
        notifyListeners();
      });
    });
  }

  Box<CalculatorDataModel>? _tabsBox;

  Future<void> _openHiveBox() async {
    _tabsBox = await Hive.openBox('tabs');

    int length = tabLength();

    // create a new tab if there is no tab
    if (length < 1) {
      await newTab();
    }
  }

  CalculatorDataModel _defaultTabData = CalculatorDataModel(
    basis: '2',
    capital: '',
    entryPrice: '',
    longOrder: 'true',
    risk: '5',
    stopLoss: '',
    stopLossPips: '',
    takeProfit: '',
    takeProfitPips: '',
  );

  set defaultTabData(CalculatorDataModel value) {
    _defaultTabData = value;
  }

  CalculatorDataModel currentTabData = CalculatorDataModel(
    basis: '2',
    capital: '',
    entryPrice: '',
    longOrder: 'true',
    risk: '5',
    stopLoss: '',
    stopLossPips: '',
    takeProfit: '',
    takeProfitPips: '',
  );
  int currentTabIndex = 0;

  void loadTab(int tabIndex) {
    if (_tabsBox == null) return;

    CalculatorDataModel? data = _tabsBox?.getAt(tabIndex);

    if (data == null) return;

    currentTabData = data;
    currentTabIndex = tabIndex;
    SharedPreferences.getInstance().then((SharedPreferences prefs) {
      // save tab
      prefs.setInt('tabIndex', tabIndex);
    });

    capitalController.text = currentTabData.capital ?? '';
    basisController.text = currentTabData.basis ?? '2';
    basis = int.tryParse(basisController.text) ?? 2;
    entryPriceController.text = currentTabData.entryPrice ?? '';
    stopLossPipsController.text = currentTabData.stopLossPips ?? '';
    takeProfitPipsController.text = currentTabData.takeProfitPips ?? '';
    stopLossController.text = currentTabData.stopLoss ?? '';
    takeProfitController.text = currentTabData.takeProfit ?? '';
    riskController.text = currentTabData.risk ?? '1';
    longOrder = currentTabData.longOrder == 'true';

    onBasisChanged(basisController.text);
  }

  CalculatorDataModel? getDataOf(int index){
    return _tabsBox?.values.elementAt(index);
  }

  Future<void> saveTab(int tabIndex) async {
    await _tabsBox?.putAt(tabIndex, currentTabData);
  }

  Future<void> newTab() async {
    if (_defaultTabData == currentTabData) return;

    if (tabLength() == 0) {
      await _tabsBox?.add(_defaultTabData);
    } else {
      await saveTab(currentTabIndex);
      await _tabsBox?.add(_defaultTabData);
    }

    loadTab(tabLength() - 1);
  }

  Future<void> switchTabTo(int tabIndex) async {
    await saveTab(currentTabIndex);

    loadTab(tabIndex);
  }

  Future<void> deleteBox() async {
    await _tabsBox?.deleteFromDisk();
    init();
    notifyListeners();
  }

  int tabLength() {
    return _tabsBox?.length ?? 0;
  }

  void calculate() {
    final double capital = double.tryParse(capitalController.text) ?? 0.0;
    final double stopLossPips = double.tryParse(stopLossPipsController.text) ?? 0.0;
    final double takeProfitPips = double.tryParse(takeProfitPipsController.text) ?? 0.0;
    final double risk = (double.tryParse(riskController.text) ?? 0.0) / 100;

    // calculate lot size based on risk and stoploss level
    if (pipsIteration == 0 || stopLossPips == 0 || takeProfitPips == 0) return;

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
    cache(FieldId.entryPrice, entryPrice.toStringAsFixed(basis));

    onSlPipsChanged();
    onTpPipsChanged();
    cache(FieldId.basis, value);

    calculate();
  }

  void onRiskChanged(String value) {
    String newValue = value;
    if ((num.tryParse(value) ?? 0) > 100) {
      riskController.text = '100';
      newValue = '100';
    }

    cache(FieldId.risk, newValue);
    calculate();
  }

  void onSlChanged() {
    final double entryPrice = double.tryParse(entryPriceController.text) ?? 0.0;
    final double stopLoss = double.tryParse(stopLossController.text) ?? 0.0;
    double pips = (entryPrice - stopLoss) / pipsIteration;
    if (!longOrder) pips = (stopLoss - entryPrice) / pipsIteration;
    final String pipsInString = pips.toInt().toString();

    cache(FieldId.stopLossPips, pipsInString);
    cache(FieldId.stopLoss, stopLoss.toStringAsFixed(basis));

    stopLossPipsController.text = pipsInString;
  }

  void onSlPipsChanged() {
    final double entryPrice = double.tryParse(entryPriceController.text) ?? 0.0;
    final int stopLossPips = int.tryParse(stopLossPipsController.text) ?? 0;
    final double stopLoss = stopLossPips * pipsIteration;
    double price = entryPrice - stopLoss;
    if (!longOrder) price = entryPrice + stopLoss;

    cache(FieldId.stopLoss, price.toStringAsFixed(basis));
    cache(FieldId.stopLossPips, stopLossPips.toString());

    stopLossController.text = price.toStringAsFixed(basis);
  }

  void onTpChanged() {
    final double entryPrice = double.tryParse(entryPriceController.text) ?? 0.0;
    final double takeProfit = double.tryParse(takeProfitController.text) ?? 0.0;
    double pips = (takeProfit - entryPrice) / pipsIteration;
    if (!longOrder) pips = (entryPrice - takeProfit) / pipsIteration;
    final String pipsInString = pips.toInt().toString();

    cache(FieldId.takeProfitPips, pipsInString);
    cache(FieldId.takeProfit, takeProfit.toStringAsFixed(basis));

    takeProfitPipsController.text = pipsInString;
  }

  void onTpPipsChanged() {
    final double entryPrice = double.tryParse(entryPriceController.text) ?? 0.0;
    final int takeProfitPips = int.tryParse(takeProfitPipsController.text) ?? 0;
    final double takeProfit = takeProfitPips * pipsIteration;
    double price = entryPrice + takeProfit;
    if (!longOrder) price = entryPrice - takeProfit;

    cache(FieldId.takeProfit, price.toStringAsFixed(basis));
    cache(FieldId.takeProfitPips, takeProfitPips.toString());

    takeProfitController.text = price.toStringAsFixed(basis);
  }

  void onEntryPriceChanged(String value) {
    final double entryPrice = double.tryParse(value) ?? 0.0;
    editable = value.isEmpty;
    cache(FieldId.entryPrice, entryPrice.toStringAsFixed(basis));

    onSlPipsChanged();
    onTpPipsChanged();
  }

  void renameTab(String name) {
    cache(FieldId.name, name);
  }

  void cache(FieldId key, String value) {
    switch (key) {
      case FieldId.entryPrice:
        currentTabData.entryPrice = value;
        break;
      case FieldId.capital:
        currentTabData.capital = value;
        break;
      case FieldId.basis:
        currentTabData.basis = value;
        break;
      case FieldId.stopLossPips:
        currentTabData.stopLossPips = value;
        break;
      case FieldId.takeProfitPips:
        currentTabData.takeProfitPips = value;
        break;
      case FieldId.stopLoss:
        currentTabData.stopLoss = value;
        break;
      case FieldId.takeProfit:
        currentTabData.takeProfit = value;
        break;
      case FieldId.risk:
        currentTabData.risk = value;
        break;
      case FieldId.longOrder:
        currentTabData.longOrder = value;
        break;
      default:
    }

    saveTab(currentTabIndex);
  }

  void incrementValueByBasisPoint(TextEditingController textEditingController, {int? basisValue}) {
    basisValue ??= basis;
    textEditingController.text =
        ((double.tryParse(textEditingController.text) ?? 0.0) + pipsIteration)
            .toStringAsFixed(basisValue);
  }

  void decrementValueByBasisPoint(TextEditingController textEditingController, {int? basisValue}) {
    basisValue ??= basis;
    textEditingController.text =
        ((double.tryParse(textEditingController.text) ?? 0.0) - pipsIteration)
            .toStringAsFixed(basisValue);
  }
}
