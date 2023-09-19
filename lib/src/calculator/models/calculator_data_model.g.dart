// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calculator_data_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CalculatorDataModelAdapter extends TypeAdapter<CalculatorDataModel> {
  @override
  final int typeId = 0;

  @override
  CalculatorDataModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CalculatorDataModel(
      entryPrice: fields[0] as String?,
      stopLoss: fields[1] as String?,
      stopLossPips: fields[2] as String?,
      takeProfit: fields[3] as String?,
      takeProfitPips: fields[4] as String?,
      lotSize: fields[5] as String?,
      risk: fields[6] as String?,
      reward: fields[7] as String?,
      basis: fields[8] as String?,
      capital: fields[9] as String?,
      longOrder: fields[10] as String?,
      tabName: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CalculatorDataModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.entryPrice)
      ..writeByte(1)
      ..write(obj.stopLoss)
      ..writeByte(2)
      ..write(obj.stopLossPips)
      ..writeByte(3)
      ..write(obj.takeProfit)
      ..writeByte(4)
      ..write(obj.takeProfitPips)
      ..writeByte(5)
      ..write(obj.lotSize)
      ..writeByte(6)
      ..write(obj.risk)
      ..writeByte(7)
      ..write(obj.reward)
      ..writeByte(8)
      ..write(obj.basis)
      ..writeByte(9)
      ..write(obj.capital)
      ..writeByte(10)
      ..write(obj.longOrder)
      ..writeByte(11)
      ..write(obj.tabName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CalculatorDataModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
