# Calorie Tracker Flutter App

A cross-platform (Android/iOS) mobile app to track daily calories consumed, with a local database and configurable data retention period.

## Features

### ✅ Core Features
- **Daily Calorie Tracking**: Add food entries with name and calorie values
- **Home Dashboard**: View daily summary with progress toward calorie goals
- **Food History**: Browse all past food entries grouped by date
- **Statistics**: View weekly and monthly calorie trends
- **Smart Settings**: 
  - Configurable daily calorie goals with quick presets
  - Data retention settings (30-365 days)
  - Clear all data option

### 📱 User Interface
- Material Design 3 with modern UI components
- Date navigation to view past days
- Quick calorie presets for common meal sizes
- Visual progress indicators with color-coded goals
- Intuitive add/edit/delete functionality

### 💾 Data Management
- SQLite local database for persistent storage
- SharedPreferences for user settings
- Automatic cleanup of old entries based on retention period
- Group entries by date for easy browsing

## Getting Started

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Android Studio / Xcode for emulators
- A physical device or emulator for testing

### Installation

1. **Clone or navigate to the project directory**
   ```bash
   cd calorie_tracker_flutter
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

   For specific platforms:
   ```bash
   flutter run -d android    # For Android
   flutter run -d ios        # For iOS (macOS only)
   ```

### Building for Production

**Android APK:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── models/
│   └── food_entry.dart         # Food entry data model
├── database/
│   └── database_helper.dart    # SQLite database operations
├── providers/
│   └── calorie_provider.dart   # State management with Provider
└── screens/
    ├── home_screen.dart        # Main dashboard
    ├── add_food_screen.dart    # Add new food entries
    ├── food_history_screen.dart # View all entries
    ├── statistics_screen.dart   # Weekly/monthly stats
    └── settings_screen.dart     # App settings
```

## How to Use

### Adding Food Entries
1. Tap the **+** button on the home screen
2. Enter the food name and calorie amount
3. Optionally adjust the date and time
4. Use quick presets for common meal sizes
5. Tap **Save Entry**

### Viewing Progress
- **Home Screen**: Shows today's total calories and progress
- **History**: View all past entries grouped by date
- **Statistics**: See weekly or monthly trends

### Adjusting Settings
1. Tap the settings icon in the top right
2. Modify your daily calorie goal
3. Adjust data retention period
4. Use quick presets for common goals

## Dependencies

- `provider`: State management
- `sqflite`: SQLite database
- `path_provider`: File system paths
- `shared_preferences`: User preferences storage
- `intl`: Date formatting

## Future Enhancements

- Meal categorization (breakfast, lunch, dinner, snacks)
- Barcode scanner for packaged foods
- Nutritional information (protein, carbs, fats)
- Charts and graphs for visual analytics
- Export data to CSV
- Cloud sync across devices
- Dark mode support

## License

This project is open source and available for personal and educational use.