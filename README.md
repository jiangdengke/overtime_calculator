# 加班费计算器 (Overtime Pay Calculator)

基于 Flutter 的加班工时与薪资计算应用：记录每日加班，统计月度加班时长与加班费，并计算到手工资。数据默认保存在本地（SharedPreferences），预留云同步接口（当前为空实现）。

## 功能

- 日历视图：按月展示每日加班汇总；双击日期快速新增记录
- 记录管理：编辑/删除记录；可选择“同日同类型合并”避免重复计数
- 月度报表：加班天数（按日期去重）、总时长、类型分布、薪资明细
- 设置：底薪、五险、公积金、自定义时薪即时生效；邮箱登录与云同步为占位能力

## 界面预览

| 主页（日历） | 月度报表 | 设置 |
| --- | --- | --- |
| ![home](docs/screenshots/home.png) | ![report](docs/screenshots/report.png) | ![settings](docs/screenshots/settings.png) |

## 快速开始

```bash
flutter pub get
flutter run
flutter test
flutter analyze
```

## 构建发布（Android）

按 ABI 拆分构建（仅包含 arm64-v8a 与 armeabi-v7a）：

```bash
flutter build apk --release --target-platform android-arm,android-arm64 --split-per-abi
```

产物位于 `build/app/outputs/flutter-apk/`。

## 项目结构

```
lib/
├── main.dart                       # 应用入口（Provider 注入 + 初始化）
├── models/                         # 数据模型与全局状态
├── services/                       # 本地存储/鉴权/云同步接口
├── screens/                        # 页面（Home/Report/Settings/Onboarding）
└── widgets/                        # 通用与领域组件（common/home/report/settings）
test/                               # 自动化测试（*_test.dart）
docs/                               # 截图与资源
```

## 贡献

欢迎提交 Issue / PR。提交前建议运行 `flutter test` 与 `flutter analyze`，并参考 `AGENTS.md` 的约定。

## 许可证

本项目基于 Apache-2.0 许可证开源，详见 [LICENSE](LICENSE)。

## 鸣谢

感谢 JetBrains 为开源项目提供 IDE 授权（`docs/screenshots/jetbrains.svg`）。
