import 'package:hive_flutter/hive_flutter.dart';

import '../models/attached_file.dart';
import '../models/note.dart';

class StorageService {
  static const notesBoxName = 'notes_box';

  Future<void> init() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(AttachedFileAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(NoteAdapter());
    }

    await Hive.openBox<Note>(notesBoxName);
  }

  Box<Note> get notesBox => Hive.box<Note>(notesBoxName);
}
