# Smart Class Check-in & Learning Reflection App

Course: 1305216 Mobile Application Development — Midterm Lab Exam

---

## Project Description

A Flutter mobile application that allows university students to:
- Check in to class using GPS location + QR code scanning
- Fill in a pre-class learning reflection form with mood tracking
- Check out after class with a post-class reflection
- View session history and weekly progress

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter (Dart) |
| QR Scanning | mobile_scanner ^5.1.1 |
| GPS | geolocator ^11.0.0 |
| Local Storage | sqflite ^2.3.3 |
| Unique IDs | uuid ^4.4.0 |
| Deployment | Firebase Hosting |

---

## Project Structure

```
lib/
├── main.dart                  # App entry point
├── theme.dart                 # Colors and theme config
├── db/
│   └── database_helper.dart   # SQLite database
└── screens/
    ├── login_screen.dart      # Login page
    ├── home_screen.dart       # Home with stats + nav
    ├── checkin_screen.dart    # Check-in flow
    ├── finish_screen.dart     # Finish class flow
    ├── history_screen.dart    # Session history list
    └── progress_screen.dart   # Mood chart + streak
```

---

## Setup Instructions

### 1. Prerequisites
- Flutter SDK >= 3.0.0
- Android Studio or VS Code
- Android device or emulator (API 21+)

### 2. Install dependencies
```bash
flutter pub get
```

### 3. Run the app
```bash
flutter run
```

### 4. Build for release
```bash
flutter build apk --release
```

---

## Firebase Configuration

### Deploy to Firebase Hosting
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Initialize (select Hosting)
firebase init

# Build Flutter Web
flutter build web

# Deploy
firebase deploy
```

### Firebase Hosting setup
- Build output directory: `build/web`
- The deployed URL will be: `https://YOUR-PROJECT-ID.web.app`

---

## Android Permissions Required

Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.INTERNET" />
```

---

## AI Usage Report

**Tools used:** Claude (Anthropic)

**What AI helped generate:**
- Initial Flutter UI scaffolding for all screens
- SQLite database schema and helper class
- GPS and QR code integration boilerplate
- Theme and color system setup

**What I modified / implemented myself:**
- Form validation logic and error handling
- Navigation flow between screens (check-in → finish → home)
- Session duration calculation
- Mood selector interaction states
- Data query logic for stats (avg mood, session count)
- Weekly mood chart data aggregation
- Attendance streak tile logic (14-day window)

---

## Screens

| Screen | Description |
|--------|-------------|
| Login | Student ID + password authentication |
| Home | Stats, last session, check-in button, bottom nav |
| Check-in | GPS + QR scan + reflection form + mood |
| Finish Class | QR scan + GPS + learned today + feedback |
| History | List of all past sessions with badges |
| Progress | Weekly mood bar chart + 14-day streak |
