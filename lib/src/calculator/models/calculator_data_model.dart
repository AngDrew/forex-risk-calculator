import 'package:hive_flutter/hive_flutter.dart';

part 'calculator_data_model.g.dart';

@HiveType(typeId: 0)
class CalculatorDataModel extends HiveObject {
  CalculatorDataModel({
    this.entryPrice = '',
    this.stopLoss = '',
    this.stopLossPips = '',
    this.takeProfit = '',
    this.takeProfitPips = '',
    this.risk = '5',
    this.reward = '',
    this.basis = '2',
    this.capital = '',
    this.longOrder = 'true',
    this.tabName = '',
  });

  @HiveField(0)
  String? entryPrice;
  @HiveField(1)
  String? stopLoss;
  @HiveField(2)
  String? stopLossPips;
  @HiveField(3)
  String? takeProfit;
  @HiveField(4)
  String? takeProfitPips;
  // @HiveField(5)
  @HiveField(6)
  String? risk;
  @HiveField(7)
  String? reward;
  @HiveField(8)
  String? basis;
  @HiveField(9)
  String? capital;
  @HiveField(10)
  String? longOrder;
  @HiveField(11)
  String? tabName;
}
