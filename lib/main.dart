import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/notes_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/notes_list_screen.dart';
import 'services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storageService = StorageService();
  await storageService.init();

  runApp(NoteApp(storageService: storageService));
}

class NoteApp extends StatelessWidget {
  const NoteApp({super.key, required this.storageService});

  final StorageService storageService;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => NotesProvider(storageService.notesBox)),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          final light = ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.indigo,
            brightness: Brightness.light,
          );
          final dark = ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.indigo,
            brightness: Brightness.dark,
          );

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Note App',
            theme: light,
            darkTheme: dark,
            themeMode: themeProvider.themeMode,
            home: Builder(
              builder: (context) => AnimatedTheme(
                data: Theme.of(context),
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOut,
                child: const NotesListScreen(),
              ),
            ),
          );
        },
      ),
    );
  }
}
