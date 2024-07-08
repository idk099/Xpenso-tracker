// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budgetmodel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BudgetAdapter extends TypeAdapter<Budget> {
  @override
  final int typeId = 5;

  @override
  Budget read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Budget(
      totalBudget: fields[0] as double?,
      categoryBudgets: (fields[1] as Map).cast<String, double>(),
      month: fields[2] as int,
      year: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Budget obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.totalBudget)
      ..writeByte(1)
      ..write(obj.categoryBudgets)
      ..writeByte(2)
      ..write(obj.month)
      ..writeByte(3)
      ..write(obj.year);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BudgetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
