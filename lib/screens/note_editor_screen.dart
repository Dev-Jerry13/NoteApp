import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/attached_file.dart';
import '../models/note.dart';
import '../providers/notes_provider.dart';
import '../services/file_service.dart';
import '../widgets/attachment_tile.dart';

class NoteEditorScreen extends StatefulWidget {
  const NoteEditorScreen({super.key, this.existing});

  final Note? existing;

  static Route<void> route([Note? note]) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => NoteEditorScreen(existing: note),
      transitionsBuilder: (_, animation, __, child) {
        final slide = Tween(begin: const Offset(0, 0.08), end: Offset.zero).animate(animation);
        return FadeTransition(opacity: animation, child: SlideTransition(position: slide, child: child));
      },
      transitionDuration: const Duration(milliseconds: 320),
    );
  }

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _fileService = FileService();

  List<AttachedFile> _attachments = [];
  Timer? _autosaveDebounce;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final note = widget.existing;
    if (note != null) {
      _titleController.text = note.title;
      _contentController.text = note.content;
      _attachments = List.of(note.attachments);
    }

    _titleController.addListener(_handleAutoSave);
    _contentController.addListener(_handleAutoSave);
  }

  void _handleAutoSave() {
    if (!_isEditing) return;
    _autosaveDebounce?.cancel();
    _autosaveDebounce = Timer(const Duration(milliseconds: 600), () async {
      final existing = widget.existing;
      if (existing == null) return;
      final draft = existing.copyWith(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        attachments: _attachments,
        updatedAt: DateTime.now(),
      );
      await context.read<NotesProvider>().autoSaveNote(draft);
    });
  }

  @override
  void dispose() {
    _autosaveDebounce?.cancel();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await context.read<NotesProvider>().upsertNote(
      id: widget.existing?.id,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      attachments: _attachments,
    );

    if (mounted) Navigator.pop(context);
  }

  void _removeAttachment(AttachedFile file) {
    setState(() {
      _attachments = _attachments.where((f) => f.path != file.path).toList();
    });
    _handleAutoSave();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Note' : 'Add Note'),
        actions: [
          TextButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              style: Theme.of(context).textTheme.headlineSmall,
              decoration: const InputDecoration(
                hintText: 'Title',
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _contentController,
              minLines: 12,
              maxLines: null,
              decoration: const InputDecoration(
                hintText: 'Write your note...',
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Text('Attachments', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                IconButton.filledTonal(
                  onPressed: () async {
                    try {
                      final attachment = await _fileService.pickAndPersistFile();
                      if (attachment == null) return;
                      setState(() => _attachments = [..._attachments, attachment]);
                      _handleAutoSave();
                    } catch (_) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Unable to attach file.')),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.attach_file_rounded),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_attachments.isEmpty)
              Text(
                'No files attached yet.',
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else
              ..._attachments.map(
                (f) => AttachmentTile(
                  file: f,
                  onRemove: () => _removeAttachment(f),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
