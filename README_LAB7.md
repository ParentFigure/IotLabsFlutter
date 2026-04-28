# Lab 7: Custom Flutter flashlight plugin

Implemented changes:

- Added a separate Flutter plugin package: `packages/secret_flashlight`.
- Connected the plugin in the application through `pubspec.yaml`.
- Added the required static API: `SecretFlashlight.onLight()`.
- Kept all MethodChannel/native Android communication inside the plugin.
- Implemented Android torch toggling with `CameraManager.setTorchMode`.
- Added unsupported-platform handling in the app with a warning dialog.
- Added a hidden trigger: long-press the `Smart Lamp Dashboard` title in the home app bar.

For the lab requirement about GitHub dependency, after pushing the plugin to your GitHub profile, replace the local dependency in `pubspec.yaml` with:

```yaml
secret_flashlight:
  git:
    url: https://github.com/<your-github-username>/secret_flashlight.git
```
