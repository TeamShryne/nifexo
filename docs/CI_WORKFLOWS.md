# CI Workflows

## Overview

The repository includes two Android debug workflows under `.github/workflows/`.

- `android-debug.yml`
  Standard debug CI. Installs dependencies, runs widget tests, then builds a debug APK.
- `android-debug-fast.yml`
  Faster artifact-focused workflow. Uses Flutter, Gradle, and Dart caches aggressively and skips tests to reduce turnaround time.

## Why Two Workflows

Strictly speaking, two workflows are not required.

One well-cached debug workflow is usually enough.

The reason to keep both is operational clarity:

- the standard workflow is safer and better for normal CI validation
- the fast workflow is better when you only want a quick debug APK artifact

If the team prefers less CI surface area later, the fast workflow can be removed and the standard workflow can remain as the single source of truth.

## Cache Strategy

The fast workflow caches:

- Flutter SDK artifacts through `subosito/flutter-action`
- Gradle through `gradle/actions/setup-gradle`
- local Dart and Android intermediate directories through `actions/cache`

This improves repeat build times, but it does not guarantee instant builds from a cold runner.
