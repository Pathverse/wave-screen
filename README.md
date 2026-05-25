# wave-screen

[![Deploy Example To GitHub Pages](https://github.com/Pathverse/wave-screen/actions/workflows/deploy-example-pages.yml/badge.svg)](https://github.com/Pathverse/wave-screen/actions/workflows/deploy-example-pages.yml)

`wave_screen` is a Flutter package for animated wave-driven UI surfaces. It currently exports three main pieces:

- `Wave` for standalone animated wave treatments.
- `WaveScreen` for layered screen backgrounds and surface styling.
- `WaveSkeletonizer` for geometry-aware loading states, including the tide-pool style ping-pong effect used in the example app.

## Package Exports

The public entrypoint is [lib/wave_screen.dart](lib/wave_screen.dart), which exports:

- [lib/src/wave/wave.dart](lib/src/wave/wave.dart)
- [lib/src/screen/screen.dart](lib/src/screen/screen.dart)
- [lib/src/skeletonizer.dart](lib/src/skeletonizer.dart)

## Run The Example Locally

From the repository root:

```bash
cd example
flutter pub get
flutter run -d chrome
```

## GitHub Pages Example

The example app in [example](example) is deployed to GitHub Pages through [.github/workflows/deploy-example-pages.yml](.github/workflows/deploy-example-pages.yml).

- Trigger: push to `main` or manual `workflow_dispatch`
- Build target: `example/build/web`
- Published URL: `https://pathverse.github.io/wave-screen/`

Before the first deployment, set the repository Pages source to `GitHub Actions` in the GitHub repository settings.

## Development Notes

- The example depends on the local package by path, so build and deployment should always run from [example/pubspec.yaml](example/pubspec.yaml).
- The Pages workflow passes `--base-href "/wave-screen/"` so the Flutter web build serves correctly from the repository subpath.

