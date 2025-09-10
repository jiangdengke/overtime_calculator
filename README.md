# 加班工时薪资计算器

一个基于 Flutter 的加班工时与薪资计算应用：记录每日加班、统计月度加班时长与加班费，并计算实际到手工资。内置本地持久化与登录占位，支持后续接入云同步。

## 主要功能

- 日历视图记录：按月展示加班情况，点击/双击快速添加记录。
- 加班类型与时薪：平时/周末/节假日（支持倍数），可自定义时薪或按底薪自动计算。
- 月度报表：统计当月加班天数/总时长/加班费/底薪/五险/公积金/到手，并展示类型分布。
- 设置面板：底薪、五险、公积金、自定义时薪即时生效。
- 本地持久化：记录与设置保存于本地，重启不丢失。
- 登录占位与云同步接口：本地邮箱登录用于开启同步入口，云同步接口可替换为真实后端。

## 技术栈与分层

- 框架：Flutter 3.x
- 状态管理：Provider（全局 `GlobalData` 作为 `ChangeNotifier`）
- 本地存储：SharedPreferences
- 分层约定：
  - models：数据模型与全局状态（`OvertimeRecord`、`GlobalData`）
  - services：本地存储/鉴权/云同步接口
  - screens：页面（按路由）
  - widgets：可复用 UI 组件（按领域分子包 common/home/report/settings）

## 目录结构

```
lib/
├── main.dart                       # 应用入口（Provider 注入 + 初始化）
├── models/
│   ├── global_data.dart            # 全局数据（本地持久化 + 云同步钩子 + 计算逻辑）
│   └── overtime_record.dart        # 加班记录模型（强类型 + JSON 序列化）
├── services/
│   ├── auth_service.dart           # 本地占位登录（仅邮箱）
│   ├── cloud_sync_service.dart     # 云同步接口 + 默认空实现
│   └── local_storage_service.dart  # SharedPreferences 本地存储
├── screens/
│   ├── home_screen.dart            # 主页（日历）— 已拆分多个小部件
│   ├── report_screen.dart          # 报表— 组件化统计/分布
│   └── settings_screen.dart        # 设置— 组件化+编辑对话框
└── widgets/
    ├── add_record_dialog.dart      # 添加记录对话框
    ├── common/
    │   ├── month_selector.dart     # 月份选择器
    │   └── stat_card.dart          # 统计卡片
    ├── home/
    │   ├── calendar_grid.dart      # 日历网格
    │   ├── month_overview_card.dart# 月度概览卡
    │   └── weekday_header.dart     # 星期标题
    ├── report/
    │   ├── overtime_distribution_list.dart # 类型分布列表
    │   ├── salary_breakdown_card.dart      # 薪资明细卡
    │   └── stat_overview_row.dart          # 统计行
    └── settings/
        ├── account_sync_card.dart  # 账户与同步卡
        ├── email_login_dialog.dart # 邮箱登录对话框
        ├── salary_edit_dialog.dart # 薪资设置对话框
        ├── settings_about_card.dart
        ├── settings_insurance_section.dart
        └── settings_salary_section.dart
```

## 本地持久化与云同步

- 本地持久化：`LocalStorageService` 使用 SharedPreferences 保存记录（StringList/每条 JSON）与设置（Double）。
- 登录占位：`AuthService` 保存邮箱到本地，仅用于显示“云同步”入口。
- 云同步：`CloudSyncService` 定义 `syncUp/syncDown`；默认 `NoopCloudSyncService` 不做网络调用。
- 接入后端（示例）：
  1. 选择后端（Firebase/Supabase/自建 REST）。
  2. 实现 `CloudSyncService`（读写用户维度数据，设计合并策略）。
  3. 在 `main.dart`/初始化后注入：`GlobalData().setCloudSyncService(MyCloudSync())`。
  4. 将 `AuthService` 替换为真实鉴权（Firebase Auth 等），设置页使用真实登录态。

## 开发与运行

- 环境要求：Flutter 3.x、Android SDK（或 Xcode/iOS 工具链）
- 安装依赖：`flutter pub get`
- 运行调试：`flutter run -d <设备ID>`（支持热重载）

### Android 打包与安装

- 标准打包：`flutter build apk --release`
- 分 ABI 打包（推荐）：`flutter build apk --release --split-per-abi`
- 输出路径：`build/app/outputs/flutter-apk/`
- 安装到手机：`adb install -r build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`

如遇网络卡顿（Gradle 拉包慢）：
- 使用国内镜像（工程已内置阿里云/华为云/腾讯云镜像与 Flutter 本地 maven 仓库）：
  - `android/settings.gradle.kts` 与 `android/build.gradle.kts` 已添加本地 engine 仓库：`$FLUTTER_SDK/bin/cache/artifacts/engine/android`
  - Gradle Wrapper 使用腾讯云镜像
- 配置 Flutter 镜像（在当前终端或写入 shell 配置）：
  - `export PUB_HOSTED_URL=https://mirrors.tuna.tsinghua.edu.cn/dart-pub`
  - `export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn`
- 使用代理（可写入 `android/gradle.properties`）：
  - `systemProp.http.proxyHost=127.0.0.1`
  - `systemProp.http.proxyPort=7890`
  - `systemProp.https.proxyHost=127.0.0.1`
  - `systemProp.https.proxyPort=7890`
- 刷新依赖并构建（查看更详细日志）：
  - `cd android && ./gradlew --stop && ./gradlew --no-daemon --refresh-dependencies assembleRelease --info --stacktrace`

### iOS 构建（简述）

- 打开 `ios/Runner.xcworkspace`，在 Xcode 配置 Team/Bundle ID 后真机运行。
- 首次可能需要：`cd ios && pod install`。
- 发布：Xcode Archive 分发或 `flutter build ipa`（需签名配置）。

## 代码规范与注释

- 代码注释：全项目中文注释；每个文件、每个方法、难点逻辑均有中文说明。
- 风格约定：遵循 `flutter_lints`；保持小组件化、强类型模型、单一职责。
- 状态管理：统一使用 Provider（`ChangeNotifierProvider` 提供 `GlobalData`）。

## 常见问题（FAQ）

- Gradle 构建时找不到 `io.flutter:*` 依赖？
  - 工程已在 `settings.gradle.kts`/`build.gradle.kts` 添加 Flutter 本地 maven 仓库：`$FLUTTER_SDK/bin/cache/artifacts/engine/android`。
  - 若你的 Flutter 路径不在 `local.properties` 的 `flutter.sdk`，请先确保 `flutter doctor -v` 正常，或执行 `flutter precache`。
- 构建卡在下载插件仓库？
  - 已加入阿里云/华为云/腾讯云镜像；仍慢可使用代理或直接用 Android Studio 的代理。

## 规划与扩展

- 接入真实登录与云同步（Firebase/Supabase/自建）。
- 导出/导入 JSON 用于备份和迁移。
- 更丰富的筛选、编辑与撤销/恢复功能。

---

如需我为你接入具体后端、增加导出/导入、或统一更严格的注释模板/代码风格，请提出需求。参考资料：Flutter 官方部署文档 https://docs.flutter.dev/deployment/android

