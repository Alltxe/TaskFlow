# TaskFlow Mobile Application

A cross-platform mobile application built with Flutter for automated distribution of household tasks in small groups with gamification and executor rotation system.

## 📱 Overview

TaskFlow Mobile is the client-side application that provides an intuitive interface for users to manage household tasks, collaborate in groups, and earn rewards through gamification. The app connects to the TaskFlow backend server and supports Android, iOS, and Web platforms.

## ✨ Key Features

- **🔐 Authentication & User Management**
  - Secure login and registration
  - User profiles with avatars and statistics
  - Status management (Active/Away)

- **👥 Group Management**
  - Create and join groups
  - Invite members via shareable links
  - Configure rotation and approval modes
  - Admin and participant roles

- **✅ Task Management**
  - View, create, and edit tasks
  - Automated task rotation
  - Up-for-Grabs task pool
  - Task approval workflow
  - Recurring tasks support

- **🎮 Gamification**
  - Point system with multipliers
  - Reward catalog and redemption
  - Group leaderboards
  - Achievement tracking

- **🔔 Notifications**
  - In-app notifications
  - Push notifications
  - Notification preferences
  - Quiet hours support

- **📴 Offline Support**
  - Data caching
  - Offline mode with sync
  - Optimistic updates

## 🚀 Getting Started

### Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** (3.0.0 or higher) - [Install Flutter](https://flutter.dev/docs/get-started/install)
- **Dart SDK** (3.0.0 or higher) - Included with Flutter
- **Git** - For version control
- **IDE:** VS Code or Android Studio (recommended)

#### Platform-Specific Requirements

**For Android Development:**
- Android Studio (for Android SDK and emulator)
- Android SDK (API level 21 or higher)
- Java Development Kit (JDK) 11 or higher

**For iOS Development (macOS only):**
- Xcode (latest stable version)
- iOS Simulator
- CocoaPods (`sudo gem install cocoapods`)

**For Web Development:**
- Chrome browser (for debugging)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Alltxe/TaskFlow.git
   cd TaskFlow/mobile
   ```

2. **Verify Flutter installation**
   ```bash
   flutter doctor
   ```
   Resolve any issues reported by `flutter doctor` before proceeding.

3. **Install dependencies**
   ```bash
   flutter pub get
   ```

4. **Configure environment**
   - Create a `.env` file for environment-specific configuration (if needed)
   - Update API endpoint configuration in `lib/core/config/` (to be created in Phase 2)

### IDE Setup

#### VS Code (Recommended)

1. **Install VS Code Extensions:**
   - Flutter (Dart Code)
   - Dart (Dart Code)
   
   VS Code will prompt to install recommended extensions from `.vscode/extensions.json` when you open the project.

2. **Configure Settings:**
   - Project-specific settings are already configured in `.vscode/settings.json`
   - Includes auto-formatting on save, line length limits, and import organization

3. **Verify Setup:**
   - Open Command Palette (`Ctrl+Shift+P` or `Cmd+Shift+P`)
   - Run `Flutter: Run Flutter Doctor`

#### Android Studio

1. **Install Plugins:**
   - Flutter plugin
   - Dart plugin

2. **Configure Flutter SDK Path:**
   - File → Settings → Languages & Frameworks → Flutter
   - Set Flutter SDK path

### Setting Up Emulators/Simulators

#### Android Emulator

1. **Open Android Studio** → AVD Manager
2. **Create Virtual Device:**
   - Select device definition (e.g., Pixel 5)
   - Select system image (API 30+ recommended)
   - Configure device settings
3. **Start emulator:**
   ```bash
   flutter emulators --launch <emulator_id>
   ```

#### iOS Simulator (macOS only)

1. **Open Simulator:**
   ```bash
   open -a Simulator
   ```
2. **Select device:**
   - Hardware → Device → iOS 14.0+ → iPhone 13 (or any model)

#### Check Available Devices

```bash
flutter devices
```

### Running the App

1. **Start an emulator/simulator** or connect a physical device

2. **Run the app in debug mode:**
   ```bash
   flutter run
   ```

3. **Run on specific device:**
   ```bash
   # List available devices
   flutter devices
   
   # Run on specific device
   flutter run -d <device_id>
   
   # Examples:
   flutter run -d android          # Android emulator/device
   flutter run -d chrome           # Web browser
   flutter run -d macos            # macOS desktop
   ```

4. **Run in different modes:**
   ```bash
   flutter run --debug             # Debug mode (default)
   flutter run --profile           # Profile mode (performance profiling)
   flutter run --release           # Release mode (optimized)
   ```

5. **Hot Reload & Hot Restart:**
   - Press `r` in terminal for hot reload (preserves state)
   - Press `R` in terminal for hot restart (resets state)
   - Press `q` to quit

### Development

#### Code Quality

- **Format code:**
  ```bash
  flutter format .
  ```

- **Analyze code:**
  ```bash
  flutter analyze
  ```

- **Fix common issues:**
  ```bash
  dart fix --apply
  ```

#### Testing

- **Run all tests:**
  ```bash
  flutter test
  ```

- **Run tests with coverage:**
  ```bash
  flutter test --coverage
  ```

- **Run specific test file:**
  ```bash
  flutter test test/widget_test.dart
  ```

- **Run integration tests:**
  ```bash
  flutter test integration_test/
  ```

#### Debugging

- **Enable Dart DevTools:**
  ```bash
  flutter pub global activate devtools
  flutter pub global run devtools
  ```

- **Run with DevTools:**
  ```bash
  flutter run --dart-define=DART_DEVTOOLS_ENABLED=true
  ```

- **Debug in VS Code:**
  - Set breakpoints in code
  - Press `F5` or use Run → Start Debugging
  - Use debug configurations in `.vscode/launch.json`

#### Building for Release

- **Android APK:**
  ```bash
  flutter build apk --release
  # Output: build/app/outputs/flutter-apk/app-release.apk
  ```

- **Android App Bundle (Google Play):**
  ```bash
  flutter build appbundle --release
  # Output: build/app/outputs/bundle/release/app-release.aab
  ```

- **iOS (macOS only):**
  ```bash
  flutter build ios --release
  # Then open in Xcode for code signing and distribution
  ```

- **Web:**
  ```bash
  flutter build web --release
  # Output: build/web/
  ```

### Common Issues & Solutions

#### "Doctor found issues in 1 category"
- Run `flutter doctor -v` for detailed information
- Follow the instructions to resolve each issue

#### "Could not find a file named 'pubspec.yaml'"
- Ensure you're in the correct directory: `cd TaskFlow/mobile`

#### "Gradle build failed"
- Clean build cache: `flutter clean`
- Reinstall dependencies: `flutter pub get`
- Rebuild: `flutter run`

#### "Xcode build failed" (iOS)
- Update CocoaPods: `cd ios && pod install && cd ..`
- Clean build: `flutter clean`
- Ensure Xcode Command Line Tools are installed

#### Hot Reload not working
- Try hot restart: Press `R` in terminal
- Stop and restart the app
- Check for compilation errors in terminal

### Code Style & Linting

This project follows Flutter's recommended coding practices and additional custom rules defined in `analysis_options.yaml`:

- **Single quotes** for strings
- **Const constructors** where possible
- **Trailing commas** for better formatting
- **Final variables** preferred
- **100 character** line length limit

The linter will automatically check your code. Fix warnings and errors before committing:

```bash
flutter analyze
```

## 📁 Project Structure

```
lib/
├── core/                 # Core utilities and constants
│   ├── constants/       # App-wide constants
│   ├── errors/          # Error handling
│   ├── theme/           # Theme configuration
│   └── utils/           # Utility functions
├── data/                # Data layer
│   ├── models/          # Data models
│   ├── repositories/    # Repository implementations
│   └── datasources/     # Remote and local data sources
├── domain/              # Business logic layer
│   ├── entities/        # Business entities
│   └── usecases/        # Use cases
├── presentation/        # UI layer
│   ├── screens/         # App screens
│   ├── widgets/         # Reusable widgets
│   └── state/           # State management
└── main.dart            # App entry point

test/                    # Unit and widget tests
integration_test/        # Integration tests
assets/                  # Images, fonts, etc.
```

## 📚 Documentation

Comprehensive documentation is available in the `.docs/` folder:

- **[Product Requirements Document (PRD)](.docs/PRD.md)** - Complete feature specifications and requirements
- **[Development Roadmap](.docs/ROADMAP.md)** - Development phases, timeline, and progress tracking

## 🛠️ Tech Stack

- **Framework:** Flutter 3.x
- **Language:** Dart 3.x
- **State Management:** [TBD - Provider/Bloc/Riverpod]
- **API Client:** graphql_flutter
- **Local Storage:** Hive / SQLite
- **Secure Storage:** flutter_secure_storage
- **Navigation:** go_router
- **Notifications:** firebase_messaging / flutter_local_notifications
- **Image Handling:** cached_network_image, image_picker

## 🧪 Testing

- **Unit Tests:** Testing business logic and repositories
- **Widget Tests:** Testing UI components
- **Integration Tests:** Testing complete user flows
- **Target Coverage:** >70%

Current status: Testing infrastructure to be set up in Phase 2

## 📊 Current Status

**Phase:** 1 of 14 - Foundation & Project Setup ✅ Complete

**Next Steps:**
- Design system setup (colors, typography, themes)
- State management selection and configuration
- GraphQL client integration
- Authentication flow implementation

See [ROADMAP.md](.docs/ROADMAP.md) for detailed progress and timeline.

## 🤝 Contributing

This is part of the TaskFlow monorepo. Please refer to the main project guidelines for contribution standards.

## 📄 License

See [LICENSE.md](../LICENSE.md) in the root directory.

## 🔗 Related Projects

- **Backend:** [../backend](../backend) - NestJS GraphQL API server
- **Frontend:** [../frontend](../frontend) - Web admin dashboard
- **Shared:** [../shared](../shared) - Shared TypeScript types and utilities

## 📞 Support

For issues, questions, or feature requests, please create an issue in the main repository.

---

**Built with ❤️ using Flutter**
