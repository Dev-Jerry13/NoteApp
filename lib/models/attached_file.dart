import 'package:hive/hive.dart';

class AttachedFile {
  AttachedFile({
    required this.path,
    required this.name,
    required this.extension,
    required this.addedAt,
  });

  final String path;
  final String name;
  final String extension;
  final DateTime addedAt;
}

class AttachedFileAdapter extends TypeAdapter<AttachedFile> {
  @override
  final int typeId = 0;

  @override
  AttachedFile read(BinaryReader reader) {
    final fieldCount = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < fieldCount; i++) reader.readByte(): reader.read(),
    };

    return AttachedFile(
      path: fields[0] as String,
      name: fields[1] as String,
      extension: fields[2] as String,
      addedAt: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, AttachedFile obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.path)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.extension)
      ..writeByte(3)
      ..write(obj.addedAt);
  }
}
