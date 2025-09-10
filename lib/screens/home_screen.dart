import 'package:flutter/material.dart';
import '../models/global_data.dart';
import 'package:provider/provider.dart';
import '../models/overtime_record.dart';
import '../widgets/add_record_dialog.dart';
import '../widgets/common/stat_card.dart';
import '../widgets/common/month_selector.dart';
import '../widgets/home/weekday_header.dart';
import '../widgets/home/calendar_grid.dart';
import '../widgets/home/overtime_details_panel.dart';
import '../widgets/home/month_overview_card.dart';

/// 首页：日历 + 月度概览。
///
/// 已拆分为更小的组件，便于维护与复用：
/// - 统计卡片：widgets/common/stat_card.dart
/// - 月份选择器：widgets/common/month_selector.dart
/// - 星期标题：widgets/home/weekday_header.dart
/// - 日历网格：widgets/home/calendar_grid.dart
/// - 选中日期详情：widgets/home/overtime_details_panel.dart
/// - 月度概览卡片：widgets/home/month_overview_card.dart
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _focusedMonth = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  // 使用 Provider 自动刷新，无需手动监听

  /// 弹出添加记录对话框，支持传入选中日期
  void _addRecord([DateTime? selectedDate]) {
    final data = context.read<GlobalData>();
    showDialog(
      context: context,
      builder: (context) => AddRecordDialog(
        initialDate: selectedDate ?? _selectedDay,
        onSubmit: (h, l, m, d) {
          if (h > 0) {
            data.addRecord(
              OvertimeRecord(
                hours: h,
                level: l,
                multiplier: m,
                date: DateTime(d.year, d.month, d.day),
              ),
            );
          }
        },
      ),
    );
  }

  /// 构建首页 UI
  @override
  Widget build(BuildContext context) {
    final data = context.watch<GlobalData>();
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text('工时记录'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // 月度概览卡片（组件化）
          MonthOverviewCard(data: data, now: now),

          // 日历视图
          Expanded(
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 月份导航（组件化）
                    MonthSelector(
                      month: _focusedMonth,
                      onPrev: () => setState(() => _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1)),
                      onNext: () => setState(() => _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1)),
                    ),
                    
                    // 星期标题（组件化）
                    const WeekdayHeader(),

                    // 日历网格
                    Expanded(
                       child: CalendarGrid(
                         focusedMonth: _focusedMonth,
                         selectedDay: _selectedDay,
                         onDaySelected: (day) => setState(() => _selectedDay = day),
                         onDayDoubleTap: (day) => _addRecord(day),
                       ),
                     ),

                     // 选中日期的详情
                     OvertimeDetailsPanel(selectedDay: _selectedDay),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addRecord(),
        tooltip: '添加记录',
        child: const Icon(Icons.add),
      ),
    );
  }

  // 其余 UI 细节已拆分到独立组件中（见上方说明）。
}
