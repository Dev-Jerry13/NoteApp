import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/note.dart';
import '../providers/notes_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/note_card.dart';
import 'note_detail_screen.dart';
import 'note_editor_screen.dart';

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  final _searchController = TextEditingController();
  final _listKey = GlobalKey<AnimatedListState>();
  List<Note> _rendered = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final initial = context.read<NotesProvider>().notes;
      setState(() => _rendered = List.of(initial));
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _syncAnimatedList(List<Note> latest) {
    if (_rendered.length > latest.length) {
      for (int i = _rendered.length - 1; i >= latest.length; i--) {
        final removed = _rendered.removeAt(i);
        _listKey.currentState?.removeItem(
          i,
          (context, animation) => SizeTransition(
            sizeFactor: animation,
            child: NoteCard(note: removed, onTap: () {}),
          ),
        );
      }
    } else if (_rendered.length < latest.length) {
      for (int i = _rendered.length; i < latest.length; i++) {
        _rendered.insert(i, latest[i]);
        _listKey.currentState?.insertItem(i);
      }
    }

    _rendered = List.of(latest);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<NotesProvider, ThemeProvider>(
      builder: (context, notesProvider, themeProvider, _) {
        final notes = notesProvider.notes;
        _syncAnimatedList(notes);

        return Scaffold(
          appBar: AppBar(
            title: const Text('My Notes'),
            actions: [
              IconButton(
                onPressed: themeProvider.toggleDarkMode,
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  transitionBuilder: (child, animation) => RotationTransition(
                    turns: animation,
                    child: FadeTransition(opacity: animation, child: child),
                  ),
                  child: Icon(
                    themeProvider.isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    key: ValueKey(themeProvider.isDark),
                  ),
                ),
              ),
              PopupMenuButton<NoteSort>(
                icon: const Icon(Icons.sort_rounded),
                onSelected: notesProvider.setSort,
                itemBuilder: (_) => const [
                  PopupMenuItem(value: NoteSort.updatedDesc, child: Text('Updated date')),
                  PopupMenuItem(value: NoteSort.createdDesc, child: Text('Created date')),
                  PopupMenuItem(value: NoteSort.titleAsc, child: Text('Title A-Z')),
                ],
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: notesProvider.setQueryDebounced,
                    decoration: const InputDecoration(
                      hintText: 'Search notes',
                      prefixIcon: Icon(Icons.search_rounded),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Spacer(),
                    IconButton.filledTonal(
                      onPressed: notesProvider.toggleLayout,
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: Icon(
                          notesProvider.gridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
                          key: ValueKey(notesProvider.gridView),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    transitionBuilder: (child, animation) {
                      final offsetAnimation = Tween<Offset>(
                        begin: const Offset(0.08, 0),
                        end: Offset.zero,
                      ).animate(animation);
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(position: offsetAnimation, child: child),
                      );
                    },
                    child: notesProvider.gridView
                        ? GridView.builder(
                            key: const ValueKey('grid'),
                            itemCount: notes.length,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.88,
                            ),
                            itemBuilder: (_, index) {
                              final note = notes[index];
                              return Dismissible(
                                key: ValueKey(note.id),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 16),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.errorContainer,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Icon(Icons.delete_rounded),
                                ),
                                onDismissed: (_) => notesProvider.deleteNote(note.id),
                                child: NoteCard(
                                  note: note,
                                  onTap: () => Navigator.push(
                                    context,
                                    NoteDetailScreen.route(note),
                                  ),
                                ),
                              );
                            },
                          )
                        : AnimatedList(
                            key: _listKey,
                            initialItemCount: notes.length,
                            itemBuilder: (_, index, animation) {
                              final note = notes[index];
                              return SizeTransition(
                                sizeFactor: animation,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Dismissible(
                                    key: ValueKey(note.id),
                                    direction: DismissDirection.endToStart,
                                    background: Container(
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.only(right: 16),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.errorContainer,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Icon(Icons.delete_rounded),
                                    ),
                                    onDismissed: (_) => notesProvider.deleteNote(note.id),
                                    child: NoteCard(
                                      note: note,
                                      onTap: () => Navigator.push(
                                        context,
                                        NoteDetailScreen.route(note),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 500),
            curve: Curves.elasticOut,
            tween: Tween(begin: 0.9, end: 1),
            builder: (_, value, child) => Transform.scale(scale: value, child: child),
            child: FloatingActionButton.extended(
              onPressed: () => Navigator.of(context).push(NoteEditorScreen.route()),
              icon: const Icon(Icons.add_rounded),
              label: const Text('New Note'),
            ),
          ),
        );
      },
    );
  }
}
