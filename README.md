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
│   └── global_data.dart         # 全局数据管理
├── screens/
│   ├── home_screen.dart         # 主页（日历加班记录）
│   ├── report_screen.dart       # 月度报表
│   └── settings_screen.dart     # 设置页面
└── widgets/
    └── add_record_dialog.dart   # 添加加班记录对话框
```

## 打包APK

1. 连接安卓设备或启动模拟器
2. 运行 `flutter build apk --release`
3. 安装包路径：`build/app/outputs/flutter-apk/app-release.apk`
4. 可用 `adb install build/app/outputs/flutter-apk/app-release.apk` 安装到设备

## 运行环境

- Flutter 3.x
- 支持 Android/iOS/Windows/Mac/Web（推荐Android）

---

如需自定义包名、签名等请参考[Flutter官方文档](https://docs.flutter.dev/deployment/android)。
