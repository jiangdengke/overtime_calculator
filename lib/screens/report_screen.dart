import 'package:flutter/material.dart';
import '../models/global_data.dart';
import '../models/overtime_record.dart';
import 'package:provider/provider.dart';
import '../widgets/common/month_selector.dart';
import '../widgets/report/salary_breakdown_card.dart';
import '../widgets/report/overtime_distribution_list.dart';
import '../widgets/report/stat_overview_row.dart';

/// 月度报表页面：展示所选月份的薪资明细与加班分布。

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  DateTime _selectedMonth = DateTime.now();
  // 过滤模式：month（本月）/ week（本周）/ range（自定义）
  String _filterMode = 'month';
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  // 使用 Provider 自动刷新，无需手动监听

  /// 切换月份
  void _changeMonth(int delta) {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year, 
        _selectedMonth.month + delta,
      );
    });
  }

  // 导出与“本周/自定义”已移除，仅保留“本月”。

  /// 构建报表页面 UI
  @override
  Widget build(BuildContext context) {
    final _globalData = context.watch<GlobalData>();
    // 仅本月记录
    final monthRecords = _globalData.getRecordsByMonth(_selectedMonth);

    // 计算加班费与总时长
    double overtimeAmount = 0;
    for (final r in monthRecords) {
      overtimeAmount += _globalData.calculateDailyOvertime(r.hours, r.multiplier);
    }
    final totalHours = monthRecords.fold<double>(0, (s, r) => s + r.hours);
    final uniqueDays = _globalData.uniqueDayCountFor(monthRecords);

    return Scaffold(
      appBar: AppBar(
        title: const Text('月度报表'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 月份选择器
            MonthSelector(
              month: _selectedMonth,
              onPrev: () => _changeMonth(-1),
              onNext: () => _changeMonth(1),
            ),
            const SizedBox(height: 16),

            // 薪资详情卡片（组件化）
            SalaryBreakdownCard(
              year: _selectedMonth.year,
              month: _selectedMonth.month,
              baseSalary: _globalData.baseSalary,
              overtimeAmount: overtimeAmount,
              socialRate: _globalData.socialInsuranceRate,
              housingRate: _globalData.housingFundRate,
            ),
            const SizedBox(height: 16),

            // 统计卡片（组件化行）
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('工时统计', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    ReportStatOverviewRow(
                      data: _globalData,
                      days: uniqueDays,
                      totalHours: totalHours,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            const SizedBox(height: 16),

            // 加班类型分布
            if (monthRecords.isNotEmpty)
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('加班类型分布', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        Expanded(child: OvertimeDistributionList(records: monthRecords)),
                      ],
                    ),
                  ),
                ),
              )
            else
              const Expanded(
                child: Center(
                  child: Text('暂无数据\n请先添加加班记录', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
