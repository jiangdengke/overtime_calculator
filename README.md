# demo

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# 打包Flutter项目为APK

1. **确保已连接安卓设备或已安装安卓模拟器。**

2. **在项目根目录下执行：**
   ```bash
   flutter build apk --release
   ```

3. **打包完成后，APK文件位置：**
   ```
   build/app/outputs/flutter-apk/app-release.apk
   ```

4. **可用adb安装到设备：**
   ```bash
   adb install build/app/outputs/flutter-apk/app-release.apk
   ```

> 如需自定义包名、签名等，请参考官方文档：[Flutter 打包APK](https://docs.flutter.dev/deployment/android)
