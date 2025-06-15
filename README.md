# Xpenso Tracker 💰

**Xpenso Tracker** is a cross-platform Flutter app (Android, iOS, Web, Desktop) designed to help users easily track and manage their expenses and budgets.

---

## 🚀 Features

- **Add / Edit / Delete** expense entries (amount, category, date, notes)  
- View expenses by **daily**, **weekly**, and **monthly** summaries  
- **Customizable categories** and icons for expenses  
- **Cross-platform support**: Android, iOS, Web, Windows, macOS, Linux  
- **Local and cloud-synced storage** using Firebase  
- **User authentication** (via email/password)  
- **Responsive UI** – adapts seamlessly to mobile, tablet, and desktop screens

---

## 📦 Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/) ≥ 3.0  
- Android Studio / Xcode / Flutter-supported IDE  
- For web builds: Chrome or any Flutter-supported browser  
- Firebase project (optional for cloud sync & auth)

### Installation

1. Clone the repo:
   ```bash
   git clone https://github.com/sreehari156/Xpenso-tracker.git
   cd Xpenso-tracker

2. Install dependencies:
   ```bash
   flutter pub get

3.(Optional) Configure Firebase:
  - Set up a Firebase project
  - Add google-services.json (Android) and/or GoogleService-Info.plist (iOS)
  - Update firebase.json if necessary

4.Run the app:
  - Mobile: flutter run
  - Web: flutter run -d chrome
  - Desktop: flutter run -d windows (or macos / linux)

### Project Folder
/
├── android/      # Android-specific config
├── ios/          # iOS-specific config
├── web/          # Web deployment assets
├── linux/        # Linux desktop build config
├── macos/        # macOS desktop build config
├── windows/      # Windows desktop build config
├── lib/          # Core Flutter/Dart app code
├── test/         # Unit & widget tests
├── assets/       # Static assets (images, icons)
├── pubspec.yaml  # Main dependency manifest
├── firebase.json # Firebase hosting & config (if used)
└── README.md     # Project overview & instructions

---

## 🎯 Usage

1. Open the app and **sign up/log in**.
2. From the dashboard, tap the **“+”** button to create a new expense.
3. Fill in details: **amount**, **category**, **date**, **notes**, then save.
4. Browse the **expenses list** or check the **summary view**.
5. Manage categories via **Settings → Categories**.
6. *(If using Firebase)* Preferences and expenses will **sync across devices**.

---

## 👨‍💻 Authors

- [SayoojVP](https://github.com/SayoojVP)
- [Sreehari](https://github.com/sreehari156)
- [AnujithK](https://github.com/AnujithK)
- [SreerajVV](https://github.com/invis95)

