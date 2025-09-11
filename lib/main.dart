import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/report_screen.dart';
import 'screens/settings_screen.dart';

import 'models/global_data.dart';
import 'package:provider/provider.dart';
import 'screens/onboarding_screen.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  // 在使用本地存储前，确保 Flutter 绑定已初始化。
  WidgetsFlutterBinding.ensureInitialized();
  await GlobalData().init();
  runApp(
    // 使用 Provider 提供全局状态（沿用单例实例）
    ChangeNotifierProvider<GlobalData>.value(
      value: GlobalData(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalData>(
      builder: (context, data, _) {
        return MaterialApp(
          title: '加班工时薪资计算器',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          home: data.isInitialized ? const MainScreen() : const OnboardingScreen(),
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    ReportScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: '工时记录',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment),
            label: '月度报表',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '设置',
          ),
        ],
      ),
    );
  }
}
