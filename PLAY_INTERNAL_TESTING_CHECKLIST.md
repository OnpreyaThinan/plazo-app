# Play Internal Testing Checklist (Android + Firebase + Google Sign-In)

Date: 2026-04-18
Package name: com.plazo.app
Firebase project: plazo-c83e7
AAB path: build/app/outputs/bundle/release/app-release.aab

## Signing Fingerprints (from gradlew signingReport)
- Debug SHA-1: 58:B3:A4:31:F9:CE:14:D4:06:21:9F:72:6C:08:B7:B1:C9:A5:DC:F5
- Debug SHA-256: 6E:0F:F6:9D:75:3A:59:58:4F:BC:33:6D:BA:21:97:90:3B:EA:DC:F7:08:7E:40:19:22:E3:97:9E:EC:D8:A7:1C
- Upload (release) SHA-1: 9D:E0:5F:C4:A5:A4:D1:09:BA:70:8F:88:D7:A7:76:37:EE:48:CC:4B
- Upload (release) SHA-256: 14:77:CA:85:37:98:0D:4D:0C:0E:F9:8A:36:46:30:B3:98:59:AF:AE:74:AE:A9:1C:E2:01:AE:D3:1D:A2:37:09

## 1) Source Config Consistency (done)
- [x] APP_ID is `com.plazo.app` in android/gradle.properties
- [x] Android manifest package is `com.plazo.app`
- [x] MainActivity package is `com.plazo.app`
- [x] google-services.json package_name is `com.plazo.app`
- [x] AAB builds successfully in release mode

## 2) Firebase Console Checks (must do before broad rollout)
- [ ] In Firebase Console > Project Settings > Your Apps, confirm Android app package is `com.plazo.app`
- [ ] Add upload SHA-1 and SHA-256 (values above) in Firebase Android app settings
- [ ] Add SHA-1 and SHA-256 for Play App Signing certificate (from Play Console)
- [ ] Download fresh `google-services.json` after SHA changes and replace android/app/google-services.json

## 3) Play Console Checks
- [ ] Create/verify app with package `com.plazo.app`
- [ ] Upload `app-release.aab` to Internal testing track
- [ ] In Play Console > App integrity, copy App signing certificate SHA-1/SHA-256
- [ ] Add those fingerprints to Firebase Android app settings (in addition to upload key)

## 4) Runtime Verification (Internal Testers)
- [ ] Install app from Play Internal testing link (not sideload)
- [ ] Open app and sign in with Google account A (expect success)
- [ ] Sign out, sign in with Google account B (expect account picker and success)
- [ ] Verify FirebaseAuth currentUser has non-empty uid and email
- [ ] Verify user profile photo/displayName sync behavior in app is correct
- [ ] Confirm Firestore write/read works after Google Sign-In
- [ ] Confirm push token/session document updates still work

## 5) Failure Signals and Fixes
- Symptom: `ApiException: 10` or `DEVELOPER_ERROR`
  - Usually SHA mismatch between signing cert and Firebase Android app
  - Re-add SHA fingerprints and re-download `google-services.json`

- Symptom: Sign-in popup opens but login fails silently
  - Verify package name is exactly `com.plazo.app` in Firebase Android app
  - Ensure old app entry/package is not being used accidentally

- Symptom: Works on debug but fails from Play install
  - Missing Play App Signing certificate SHA in Firebase

## 6) Release Gate
Proceed to Closed/Production only when all items in sections 2-4 are complete.

## Quick Local Verifier
- Run from repo root: `./verify-google-signin-config.ps1`
- Expected pass condition: release SHA-1 appears in `google-services.json` Android `certificate_hash` list.
