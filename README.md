# swiftly_mobile

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


Installation without Android studio code:
Alright — here is the **complete, corrected, no-missing-pieces setup including NDK**, clean and production-safe.

---

# FULL ANDROID + FLUTTER SETUP (NO Android Studio)

## 1. Flutter SDK

[Flutter Windows Install Guide](https://docs.flutter.dev/get-started/install/windows?utm_source=chatgpt.com)

### Install path

```txt id="flutter1"
C:\flutter
```

### PATH

```txt id="flutter2"
C:\flutter\bin
```

---

# 2. Android SDK (manual setup)

[Android Command-line Tools](https://developer.android.com/studio?utm_source=chatgpt.com#command-line-tools-only)

[Android Platform Tools (ADB)](https://developer.android.com/tools/releases/platform-tools?utm_source=chatgpt.com)

---

## Folder structure

```txt id="android1"
C:\Android\
 ├── cmdline-tools\latest
 ├── platform-tools
 ├── platforms\android-34
 ├── build-tools\34.0.0
 ├── ndk\28.2.13676358
 └── licenses
```

---

## PATH variables (CRITICAL)

```txt id="path1"
C:\flutter\bin
C:\Android\cmdline-tools\latest\bin
C:\Android\platform-tools
```

---

## System variables

```txt id="env1"
ANDROID_HOME = C:\Android
ANDROID_NDK_HOME = C:\Android\ndk\28.2.13676358
```

---

# 3. Install SDK packages (NO Android Studio)

Run:

```bash id="sdk1"
sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0" "ndk;28.2.13676358"
```

---

# 4. NDK (IMPORTANT)

Android NDK

Installed via:

```bash id="ndk1"
sdkmanager "ndk;28.2.13676358"
```

Location:

```txt id="ndk2"
C:\Android\ndk\28.2.13676358
```

---

# 5. USB debugging setup (phone)

[Android Developer Options Guide](https://developer.android.com/studio/debug/dev-options?utm_source=chatgpt.com)

Steps:

* Enable Developer Options
* Enable USB debugging
* Select File Transfer (MTP)

---

# 6. Verification

Run:

```bash id="check1"
flutter doctor
```

```bash id="check2"
adb devices
```

---

# 7. Flutter run

```bash id="run1"
flutter pub get
flutter run
```

---

# FINAL CLEAN SUMMARY

You now have:

### Core SDKs

* Flutter → `C:\flutter`
* Android SDK → `C:\Android`

### Tools

* ADB → `platform-tools`
* Cmdline tools → `cmdline-tools\latest`

### Native layer

* NDK → `28.2.13676358`

### Environment

* PATH correctly set
* ANDROID_HOME set
* ANDROID_NDK_HOME set
