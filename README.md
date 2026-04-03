# NoteApp (Flutter)

A cross-platform Note Taking Mobile Application built with Flutter and focused on smooth animations + modern Material 3 UI.

## Features

- Create, edit, delete, and view notes
- Note model includes:
  - title
  - content
  - created timestamp
  - updated timestamp
- Local storage only (no backend) with **Hive**
- File attachments per note using **file_picker**
  - supported: `.txt`, `.pdf`, `.doc`, `.docx`, `.jpg`, `.jpeg`, `.png`
  - attachments can be added and removed while editing a note
- Search with debounce
- Sort by updated date, created date, title
- Grid/List toggle with animated transitions
- Auto-save while typing (for existing notes)
- Dark mode toggle with smooth animated transition
- Delete confirmation dialog
- Export note to `.txt`
- Swipe to delete in lists/grids

## Architecture

```text
lib/
  models/
  services/
  providers/
  screens/
  widgets/
```

## Tech Stack

- Flutter (latest stable recommended)
- Dart (null safety)
- Provider (state management)
- Hive + hive_flutter (local DB)
- file_picker
- path_provider
- open_filex

## Animations & Transitions Used

- **Page transitions (Fade + Slide):** custom `PageRouteBuilder` for detail/editor screens.
- **Hero animation:** note card to note detail (`Hero(tag: note-id)`).
- **AnimatedContainer:** animated search/input container style changes.
- **AnimatedList:** smooth insert/remove list updates in list layout mode.
- **AnimatedSwitcher:** layout toggle icons and theme icon transitions.
- **TweenAnimationBuilder:** spring-like FAB entrance scale animation.
- **Ripple feedback:** `InkWell` and Material surfaces for taps.
- **Theme transition:** `AnimatedTheme` for smooth dark/light mode changes.

## Setup Instructions

1. Install Flutter SDK (stable channel).
2. In project root:

```bash
flutter pub get
flutter run
```

## Notes on Storage and File Handling

- Notes are persisted in a Hive box: `notes_box`.
- Attached files are copied into app documents directory (`attachments/`) so they remain available after restart.
- Exported notes are written to app documents `exports/` folder.

## Performance Considerations

- Provider-based granular rebuilds with `Consumer`.
- Debounced search input to reduce filter churn.
- Uses const constructors where possible.
- Lazy `GridView.builder` and animated list rendering.
