# TRAD CFS - Offline Exam Reviewer

A gamified offline exam reviewer app built with Flutter for the Caelum Financial Solutions licensing exam preparation.

---

## 📱 Features

- 122 questions across 13 levels
- Level unlock system with star ratings
- Mistake review and retry
- Progress tracking with accuracy stats
- Fully offline — no internet required

---

## 🚀 How to Run the Project

### Prerequisites
Make sure you have the following installed:
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (v3.0 or higher)
- [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/)
- Android SDK

### Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/your-repo-name.git
   cd your-repo-name
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   # On Chrome (web)
   flutter run -d chrome

   # On connected Android device
   flutter run -d <device-id>

   # To list connected devices
   flutter devices
   ```

---

## 📦 How to Build the APK

1. **Build the release APK**
   ```bash
   flutter build apk --release
   ```

2. **Find the APK file here:**
   ```
   build/app/outputs/flutter-apk/app-release.apk
   ```

3. **Install directly to connected Android phone via USB**
   ```bash
   flutter install
   ```

---

## 📲 How to Install APK on Android Phone

1. Transfer `app-release.apk` to your phone via USB, Google Drive, or any file sharing app
2. On your phone, go to **Settings → Security**
3. Enable **"Install from Unknown Sources"**
4. Open the APK file and tap **Install**

---

## 🛠️ Built With

- [Flutter](https://flutter.dev/) - UI Framework
- [Dart](https://dart.dev/) - Programming Language
- [Provider](https://pub.dev/packages/provider) - State Management
- [SharedPreferences](https://pub.dev/packages/shared_preferences) - Local Storage
- [Google Fonts](https://pub.dev/packages/google_fonts) - Nunito Font

---

## 👨‍💻 Developed by

ZWEI/CFS H.A
