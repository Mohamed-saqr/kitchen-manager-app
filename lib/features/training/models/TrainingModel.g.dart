// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'TrainingModel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TrainingModelAdapter extends TypeAdapter<TrainingModel> {
  @override
  final int typeId = 1;

  @override
  TrainingModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TrainingModel(
      title: fields[0] as String,
      desc: fields[1] as String,
      progress: fields[2] as double,
      contentType: fields[3] as String,
      url: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, TrainingModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.desc)
      ..writeByte(2)
      ..write(obj.progress)
      ..writeByte(3)
      ..write(obj.contentType)
      ..writeByte(4)
      ..write(obj.url);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrainingModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
