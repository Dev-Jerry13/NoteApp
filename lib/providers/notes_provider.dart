import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../models/attached_file.dart';
import '../models/note.dart';

enum NoteSort { updatedDesc, titleAsc, createdDesc }

class NotesProvider extends ChangeNotifier {
  NotesProvider(this._notesBox);

  final Box<Note> _notesBox;
  final Uuid _uuid = const Uuid();

  String _query = '';
  NoteSort _sort = NoteSort.updatedDesc;
  bool _gridView = false;
  Timer? _debounce;

  String get query => _query;
  NoteSort get sort => _sort;
  bool get gridView => _gridView;

  List<Note> get notes {
    final raw = _notesBox.values.toList();
    final filtered = raw.where((n) {
      if (n.isArchived) return false;
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return n.title.toLowerCase().contains(q) || n.content.toLowerCase().contains(q);
    }).toList();

    switch (_sort) {
      case NoteSort.updatedDesc:
        filtered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      case NoteSort.titleAsc:
        filtered.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      case NoteSort.createdDesc:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return filtered;
  }

  void setQueryDebounced(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _query = value;
      notifyListeners();
    });
  }

  void setSort(NoteSort value) {
    _sort = value;
    notifyListeners();
  }

  void toggleLayout() {
    _gridView = !_gridView;
    notifyListeners();
  }

  Future<void> upsertNote({
    String? id,
    required String title,
    required String content,
    List<AttachedFile> attachments = const [],
    bool isArchived = false,
  }) async {
    final now = DateTime.now();

    if (id == null) {
      final note = Note(
        id: _uuid.v4(),
        title: title,
        content: content,
        createdAt: now,
        updatedAt: now,
        attachments: attachments,
        isArchived: isArchived,
      );
      await _notesBox.put(note.id, note);
    } else {
      final existing = _notesBox.get(id);
      if (existing == null) return;
      final updated = existing.copyWith(
        title: title,
        content: content,
        updatedAt: now,
        attachments: attachments,
        isArchived: isArchived,
      );
      await _notesBox.put(id, updated);
    }

    notifyListeners();
  }

  Future<void> deleteNote(String id) async {
    await _notesBox.delete(id);
    notifyListeners();
  }

  Future<void> archiveNote(String id) async {
    final note = _notesBox.get(id);
    if (note == null) return;
    await _notesBox.put(id, note.copyWith(isArchived: true, updatedAt: DateTime.now()));
    notifyListeners();
  }

  Future<void> autoSaveNote(Note draft) async {
    await _notesBox.put(draft.id, draft.copyWith(updatedAt: DateTime.now()));
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
