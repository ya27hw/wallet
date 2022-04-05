// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'classes.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NetworkAdapter extends TypeAdapter<Network> {
  @override
  final int typeId = 0;

  @override
  Network read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Network(
      fields[0] as String,
      fields[1] as String,
      fields[2] as String,
      fields[3] as String,
      fields[4] as String,
      fields[5] as String,
      fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Network obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.unit)
      ..writeByte(1)
      ..write(obj.rpcURL)
      ..writeByte(2)
      ..write(obj.stableCoinAddress)
      ..writeByte(3)
      ..write(obj.nativeTokenAddress)
      ..writeByte(4)
      ..write(obj.swapRouterAddress)
      ..writeByte(5)
      ..write(obj.networkName)
      ..writeByte(6)
      ..write(obj.chainID);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NetworkAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
