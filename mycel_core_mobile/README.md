# Mycel Core Mobile

Foundation layer for all Mycel-based mobile applications.

## Features

- **Entry Point**: Main application bootstrap that all projects use
- **Route Discovery**: Automatically merges routes from IAM and project modules
- **Session Management**: Authentication state with persistence
- **Theming**: Material 3 with light/dark mode support
- **Navigation**: Parameterized routing with navigation helpers

## Usage

### As a Submodule (Recommended)

```bash
# From project root
cd submodules/mycel_core/mycel_core_mobile
flutter run
```

### Standalone (Development)

```bash
cd mycel_core_mobile
flutter pub get
flutter run
```

## Project Structure

```
lib/
├── main.dart              # Entry point
├── app.dart               # MycelApp widget
├── routes.dart            # Default routes
├── navigation/
│   └── router.dart        # Navigation infrastructure
├── session/
│   └── session_manager.dart  # Auth state management
└── theme/
    └── mycel_theme.dart # Material 3 theming
```

## Providing Project Routes

Create a `routes.dart` in your project:

```dart
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/claims_screen.dart';

Map<String, WidgetBuilder> getRoutes() {
  return {
    '/': (context) => const HomeScreen(),
    '/claims': (context) => const ClaimsScreen(),
    '/claims/:id': (context) => const ClaimDetailScreen(),
  };
}
```
