// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'email.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EmailAdapter extends TypeAdapter<Email> {
  @override
  final int typeId = 2;

  @override
  Email read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Email(
      id: fields[0] as int,
      address: fields[1] as String,
      privateComment: fields[2] as String?,
      goto: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Email obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.address)
      ..writeByte(2)
      ..write(obj.privateComment)
      ..writeByte(3)
      ..write(obj.goto);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmailAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Email _$EmailFromJson(Map<String, dynamic> json) => Email(
      id: json['id'] as int,
      address: json['address'] as String,
      privateComment: json['private_comment'] as String?,
      goto: json['goto'] as String,
    );

Map<String, dynamic> _$EmailToJson(Email instance) => <String, dynamic>{
      'id': instance.id,
      'address': instance.address,
      'private_comment': instance.privateComment,
      'goto': instance.goto,
    };
