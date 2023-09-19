import 'package:hive_flutter/hive_flutter.dart';

part 'calculator_data_model.g.dart';

@HiveType(typeId: 0)
class CalculatorDataModel extends HiveObject {
  CalculatorDataModel({
    this.entryPrice,
    this.stopLoss,
    this.stopLossPips,
    this.takeProfit,
    this.takeProfitPips,
    this.lotSize,
    this.risk,
    this.reward,
    this.basis,
    this.capital,
    this.longOrder,
    this.tabName,
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
  @HiveField(5)
  String? lotSize;
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
