# AgriLink

This repository contains the AgriLink Flutter application — a multi-platform (mobile & web) app for farmers, buyers and transporters. The app uses Firebase for backend services and Cloudinary for image uploads.

**This README** explains how to set up the project locally, configure Firebase and Cloudinary for web and mobile, run and test the app, and troubleshoot common issues you may encounter.

**Important**: The web platform requires explicit `FirebaseOptions` (or a generated `firebase_options.dart`) and Cloudinary unsigned upload presets for client-side image uploads.

**Quick start**
- **Install prerequisites**: Flutter SDK (stable), Git, and platform SDKs for your targets (Android Studio/Xcode for mobile). 
- **Fetch dependencies**: run `flutter pub get` in the project root.
- **Run (web)**: `flutter run -d chrome`.

**Prerequisites**
- Flutter (stable channel) installed and on your PATH.
- Dart (bundled with Flutter).
- For Android builds: Android SDK + emulator or device.
- For iOS builds: Xcode and provisioning set up (macOS only).
- For web builds: a modern browser (Chrome recommended).

**Repository layout (key files)**
- `lib/main.dart`: App entrypoint, Firebase initialization and `MaterialApp` route registration.
- `lib/services/cloudinary_service.dart`: Cloudinary upload helper used by screens that upload images.
- `lib/models/user_model.dart`: App user model and serialization helpers.
- `lib/screens/`: App screens (onboarding, auth, farmer/buyer flows, etc.).
- `pubspec.yaml`: Flutter dependencies and asset declarations.

Setup
1. Clone the repo and open it in your IDE:
	- `git clone <repo-url>`
	- `cd agrilink` (or your local folder)
2. Get dependencies:
	- `flutter pub get`

Firebase configuration
1. Mobile (Android / iOS): use the Firebase console to create projects and add Android/iOS apps. Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) and place them per Firebase docs.
2. Web: the app requires `FirebaseOptions` at runtime. You have two options:
	- Use `flutterfire` CLI to generate `lib/firebase_options.dart` automatically: 
	  - Install: `dart pub global activate flutterfire_cli` (or follow docs)
	  - Configure: `flutterfire configure` and follow the prompts.
	  - The generated `firebase_options.dart` contains `DefaultFirebaseOptions.currentPlatform` used by `Firebase.initializeApp()`.
	- Or manually provide values in `lib/main.dart` for `FirebaseOptions` (only recommended temporarily). Replace the placeholder values with values from the Firebase console.

Cloudinary configuration (image uploads)
The app performs client-side (unsigned) uploads to Cloudinary via REST. For this to work:

1. Create an unsigned upload preset in your Cloudinary dashboard:
	- In Cloudinary Console > Settings > Upload > Upload presets, create a new preset and enable "Unsigned".
	- Note the preset name (e.g. `unsigned_upload`) and your Cloud name (e.g. `my-cloud-name`).
2. Configure the service in code (or environment):
	- Open `lib/services/cloudinary_service.dart`.
	- Update the default `cloudName` and `uploadPreset` values to match your Cloudinary account.

Common Cloudinary errors and fixes
- "Upload preset not found" (HTTP 400): the preset name used in the app doesn't exist or is not enabled as unsigned. Fix: create the unsigned preset in Cloudinary or update the preset name in the service.
- Web incompatibility: if you see errors about `dart:io` or `MultipartFile.fromPath`, ensure the code uses `XFile.readAsBytes()` and `MultipartFile.fromBytes()` (the repository already uses this approach for web compatibility).

Running the app
- Run for web (Chrome): `flutter run -d chrome`.
- Run for Android: `flutter run -d <device-id>` (or use Android Studio emulator).
- Build a release APK (Android): `flutter build apk --release`.

Testing
- Run unit/widget tests: `flutter test`.

Troubleshooting & tips
- FirebaseOptions null on web: the app will fail with "FirebaseOptions cannot be null when creating the default app" unless you provide web options. Use `flutterfire configure` to generate `firebase_options.dart` or add a `kIsWeb` branch in `main.dart` with real options.
- Missing asset files: `pubspec.yaml` declares Lottie animations under `assets/animations/`. Ensure the referenced files (for example `assets/animations/farming.json`) are present in that folder. If you removed them, either add the files or remove their declarations.
- Analyzer warnings: run `flutter analyze` to see lints and suggestions. Fix issues incrementally; many warnings are informational.
- Dependency conflicts: if `flutter pub get` fails due to package version conflicts, inspect `pubspec.yaml` for overlapping packages and resolve versions (the project uses `http` for REST uploads rather than a Cloudinary-specific package to avoid solver issues).

Development notes
- The app uses `XFile` from `image_picker` and reads bytes for cross-platform uploads (`XFile.readAsBytes()`).
- Client-side deletion of Cloudinary assets is not implemented — Cloudinary deletion requires API keys to be used server-side or a signed flow.

Where to look next
- `lib/services/cloudinary_service.dart`: edit `cloudName` and `uploadPreset` to match Cloudinary account.
- `lib/main.dart`: replace placeholder `FirebaseOptions` with `firebase_options.dart` generated by `flutterfire configure`.
- `assets/animations/`: add missing Lottie JSON files used by onboarding screens.

Need help?
- I can:
  - Generate a complete `firebase_options.dart` if you provide Firebase project IDs (or run `flutterfire configure` and I can help integrate the generated file).
  - Update `cloudinary_service.dart` preset name if you tell me the preset name and cloud name you created.
  - Add or remove asset entries from `pubspec.yaml` if you want to keep only the assets you have.

License
- This repo does not include an explicit license file. Add one if needed.

----
Generated by GitHub Copilot (GPT-5 mini) — ask me to run analyzer or update configuration next.
# AgriLink
