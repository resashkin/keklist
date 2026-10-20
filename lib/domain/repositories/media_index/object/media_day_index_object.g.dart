// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_day_index_object.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MediaDayIndexObjectAdapter extends TypeAdapter<MediaDayIndexObject> {
  @override
  final typeId = 5;

  @override
  MediaDayIndexObject read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MediaDayIndexObject()
      ..dayIndex = (fields[0] as num).toInt()
      ..photoCount = (fields[1] as num).toInt()
      ..videoCount = (fields[2] as num).toInt()
      ..previewIds = fields[3] == null
          ? []
          : (fields[3] as List).cast<String>();
  }

  @override
  void write(BinaryWriter writer, MediaDayIndexObject obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.dayIndex)
      ..writeByte(1)
      ..write(obj.photoCount)
      ..writeByte(2)
      ..write(obj.videoCount)
      ..writeByte(3)
      ..write(obj.previewIds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaDayIndexObjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
