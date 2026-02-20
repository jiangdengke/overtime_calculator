import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:overtime_calculator/main.dart';
import 'package:overtime_calculator/models/global_data.dart';

void main() {
  testWidgets('App boots to onboarding when not initialized', (WidgetTester tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});

    final data = GlobalData();
    await data.init();

    await tester.pumpWidget(
      ChangeNotifierProvider<GlobalData>.value(
        value: data,
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('欢迎使用加班工时薪资计算器'), findsOneWidget);
    expect(find.text('开始使用'), findsOneWidget);
  });
}
