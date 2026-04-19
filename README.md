# JobFlow

A clean, minimal job application tracker built with Flutter. Track every application from first click to offer, with a full activity history and at-a-glance stats — all in a dark, focused UI designed for desktop.

> 📱 Mobile support is currently in progress.

---

## Features

- **Active board** — view and manage all open applications in one place. Filter by status, search by company or role, and drag to reorder manually
- **Status tracking** — move applications through Applied → Interviewing → Offered → Rejected with a single tap
- **Pin & prioritise** — pin important applications to keep them at the top of your list
- **Archive** — archive closed applications to keep your board clean without losing the data
- **Activity history** — every status change, note edit, and new application is logged. View as a global activity feed or grouped by job
- **Stats** — response rate, offer rate, and a breakdown by status at a glance
- **Notes** — attach inline notes to any application, editable directly from the card
- **Sort & filter** — sort by date, company name, status, or pin priority. Manual drag order is preserved after reordering

---

## Tech stack

| Layer | Choice |
|---|---|
| Framework | Flutter 3.x |
| State management | Provider (`ChangeNotifier`) |
| Architecture | Single `JobProvider` with in-memory state |
| Persistence | In-memory (local persistence coming soon) |
| Platforms | Windows, macOS, Linux · iOS/Android in progress |

The project follows a straightforward structure — one provider manages all job state, screens consume it via `context.watch`, and mutations go through clearly named methods (`addJob`, `updateStatus`, `archiveJob`, etc.). No backend, no dependencies beyond `provider` and standard Flutter packages.

---

## Project structure

```
lib/
├── main.dart
├── models/
│   └── job.dart            # JobApplication, HistoryEntry, AppStatus
├── providers/
│   └── job_provider.dart   # All state and business logic
├── screens/
│   ├── home_screen.dart    # Shell with sidebar navigation
│   ├── active_screen.dart  # Main board with drag reorder
│   ├── archive_screen.dart # Archived applications
│   ├── history_screen.dart # Activity feed + per-job timeline
│   └── stats_screen.dart   # Summary statistics
└── widgets/
    └── job_card.dart       # Reusable application card
```

---

## Getting started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.0 or higher
- Dart 3.0+

### Run locally

```bash
# Clone the repo
git clone https://github.com/your-username/jobflow.git
cd jobflow

# Install dependencies
flutter pub get

# Run on desktop
flutter run -d windows   # or macos / linux

# Run on mobile (in progress)
flutter run -d android
flutter run -d ios
```

### Build for release

```bash
# Windows
flutter build windows

# macOS
flutter build macos

# Linux
flutter build linux
```

---

## Roadmap

- [ ] Local persistence (SharedPreferences or SQLite)
- [ ] Mobile layout (iOS & Android)
- [ ] Export to CSV
- [ ] Reminder / follow-up notifications
- [ ] Dark/light theme toggle

---

## License

MIT