# 加班工时薪资计算器

本项目是一个基于 Flutter 的加班工时与薪资计算应用，适用于记录每日加班、统计月度加班时长和加班费，并自动计算实际到手工资。

## 主要功能

- **日历视图加班记录**  
  以日历形式展示每月加班情况，已加班日期高亮显示并标注加班时长，支持点击/双击快速添加记录。

- **加班类型与时薪自定义**  
  支持平时加班、周末加班、节假日加班（可自定义倍数），可自定义时薪或按底薪自动计算。

- **月度报表统计**  
  自动统计本月加班天数、总时长、加班费、底薪、五险一金、住房公积金、实际到手工资，并以图表形式展示加班类型分布。

- **薪资与扣除设置**  
  可设置底薪、五险比例、住房公积金比例、自定义时薪，所有设置实时生效。

- **数据本地保存**  
  所有加班记录和设置均保存在本地，重启应用不会丢失。

## 目录结构

```
lib/
├── main.dart                     # 应用入口和导航
├── models/
│   ├── global_data.dart         # 全局数据管理（本地持久化 + 云同步钩子）
│   └── overtime_record.dart     # 加班记录模型（强类型 + JSON 序列化）
├── screens/
│   ├── home_screen.dart         # 主页（日历加班记录）
│   ├── report_screen.dart       # 月度报表
│   └── settings_screen.dart     # 设置页面
├── services/
│   ├── auth_service.dart        # 本地占位登录（邮箱），仅用于启用云同步入口
│   ├── cloud_sync_service.dart  # 云同步接口与默认空实现（需替换为真实后端）
│   └── local_storage_service.dart # 本地存储（SharedPreferences）
└── widgets/
    └── add_record_dialog.dart   # 添加加班记录对话框
```

## 打包APK

1. 连接安卓设备或启动模拟器
2. 运行 `flutter build apk --release`
3. 安装包路径：`build/app/outputs/flutter-apk/app-release.apk`
4. 可用 `adb install build/app/outputs/flutter-apk/app-release.apk` 安装到设备

## 持久化与云同步

- 本地存储：使用 `shared_preferences` 持久化加班记录与设置。
- 登录：提供“邮箱占位登录”，仅用于控制“云同步”入口（不含真实鉴权）。
- 云同步：预置 `CloudSyncService` 接口与 `NoopCloudSyncService` 默认实现，便于接入 Firebase/Supabase/自建后端。

接入步骤（示例）：

1. 选择后端（推荐 Firebase Firestore + Firebase Auth，或 Supabase）。
2. 新建类实现 `CloudSyncService` 中的 `syncUp/syncDown`，处理用户维度的数据读写与合并策略。
3. 在 `main.dart` 初始化时注入你的实现：`GlobalData().setCloudSyncService(MyCloudSync());`
4. 将 `AuthService` 替换为真实鉴权（例如 Firebase Auth），并在设置页中使用真实登录态。

## 运行环境

- Flutter 3.x
- 支持 Android/iOS/Windows/Mac/Web（推荐Android）

---

如需自定义包名、签名等请参考[Flutter官方文档](https://docs.flutter.dev/deployment/android)。
