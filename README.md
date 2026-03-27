# storyo

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Google Sign-In on Android

Google Sign-In on Android requires a valid SHA-1/SHA-256 for the app's signing
key and an emulator/device with Google Play services.

- Add your **debug** and **release** SHA-1/SHA-256 fingerprints to the Firebase
  project (Project settings → Your apps → Android).
- Ensure `android/app/google-services.json` matches the Android package name.
- Use an emulator image with **Google Play** (or a physical device with Google
  Play services).

You can print the debug keystore SHA-1 like this:

```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```
