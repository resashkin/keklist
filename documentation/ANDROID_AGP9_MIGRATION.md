# Android Toolchain on Flutter 3.50 (Gradle 9, AGP 9)

## Overview
Flutter 3.50 refuses to build Android with Gradle below 9.3.1, AGP below 9.1.1 or Kotlin Gradle Plugin below 2.4.10.
The project moved to Gradle 9.5.0, AGP 9.3.1 and KGP 2.4.20. Builds need JDK 17–21: Gradle 9.5 does not run the
Kotlin DSL on JDK 25.

## Implementation Details
- `android/gradle/wrapper/gradle-wrapper.properties`: Gradle 9.5.0.
- `android/settings.gradle.kts`: AGP 9.3.1, KGP 2.4.20.
- `android/gradle.properties`: `android.builtInKotlin=false` and `android.newDsl=false` (added by the Flutter
  migrator) keep the classic Kotlin plugin, which most Flutter plugins still apply themselves.
- `android/app/build.gradle.kts`: `kotlinOptions` is an error on KGP 2.4; the JVM target lives in
  `kotlin { compilerOptions { … } }`.
- `android/build.gradle.kts`:
  - Library plugins that pin an old `compileSdk` (super_native_extensions pins 31) are raised to 36 in
    `finalizeDsl`; AGP 9 refuses a library compiled against an SDK lower than its dependencies need.
  - `file_picker` skips the Kotlin plugin on AGP 9, relying on built-in Kotlin, which is off here. Flutter sees the
    plugin's id in its script and doesn't apply it either, so the root build applies it with JVM target 17.
- `scripts/patch_cargokit_gradle9.sh`: cargokit (Rust build of irondash_engine_context and
  super_native_extensions) calls `Project.exec()`, removed in Gradle 9. The script patches the pub cache to use
  `ExecOperations`. Every Android fastlane lane runs it before building; run it by hand after `pub get` on a new
  machine.

## Edge Cases & Considerations
- Upgrading irondash_engine_context or super_native_extensions changes the pub cache path: update the versions in
  the patch script.
- When those plugins support Gradle 9 and AGP 9 themselves, drop the workarounds and consider
  `android.builtInKotlin=true`.
