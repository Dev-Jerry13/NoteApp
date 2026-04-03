import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';

import '../models/attached_file.dart';

class AttachmentTile extends StatelessWidget {
  const AttachmentTile({
    super.key,
    required this.file,
    this.onRemove,
  });

  final AttachedFile file;
  final VoidCallback? onRemove;

  IconData _resolveIcon() {
    switch (file.extension) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'doc':
      case 'docx':
        return Icons.description_rounded;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image_rounded;
      default:
        return Icons.text_snippet_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(_resolveIcon()),
      title: Text(file.name),
      subtitle: Text(file.path),
      trailing: Wrap(
        spacing: 4,
        children: [
          IconButton(
            icon: const Icon(Icons.open_in_new_rounded),
            onPressed: () async {
              if (!File(file.path).existsSync()) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('File not found on disk')),
                  );
                }
                return;
              }
              await OpenFilex.open(file.path);
            },
          ),
          if (onRemove != null)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: onRemove,
            ),
        ],
      ),
    );
  }
}
