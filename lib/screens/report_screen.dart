import 'package:flutter/material.dart';
import '../models/global_data.dart';
import '../models/overtime_record.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
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

  /// 导出当前过滤记录为 CSV 或 JSON，并弹窗展示可复制文本。
  void _export(BuildContext context, List<OvertimeRecord> list, String format) {
    if (format == 'csv') {
      final header = '日期,类型,倍数,小时数,金额';
      final rows = list.map((r) {
        final amount = GlobalData().calculateDailyOvertime(r.hours, r.multiplier).toStringAsFixed(2);
        final date = '${r.date.year}-${r.date.month.toString().padLeft(2, '0')}-${r.date.day.toString().padLeft(2, '0')}';
        return '$date,${r.level},${r.multiplier},${r.hours},$amount';
      }).join('\n');
      final content = '$header\n$rows';
      _showExportDialog(context, content, 'CSV');
    } else {
      final items = list.map((r) => {
            'date': r.date.toIso8601String(),
            'level': r.level,
            'multiplier': r.multiplier,
            'hours': r.hours,
          });
      final content = items.toList().toString();
      _showExportDialog(context, content, 'JSON');
    }
  }

  /// 弹出导出结果对话框，支持复制到剪贴板。
  void _showExportDialog(BuildContext context, String text, String title) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('导出$title'),
          content: SizedBox(
            width: 500,
            child: SelectableText(text),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: text));
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已复制到剪贴板')));
                }
              },
              child: const Text('复制'),
            ),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('关闭')),
          ],
        );
      },
    );
  }

  /// 构建报表页面 UI
  @override
  Widget build(BuildContext context) {
    final _globalData = context.watch<GlobalData>();
    // 根据过滤模式获取记录
    List<OvertimeRecord> filtered = _globalData.getRecordsByMonth(_selectedMonth);
    if (_filterMode == 'week') {
      filtered = _globalData.getRecordsByWeek(DateTime.now());
    } else if (_filterMode == 'range' && _rangeStart != null && _rangeEnd != null) {
      filtered = _globalData.getRecordsByRange(_rangeStart!, _rangeEnd!);
    }

    // 计算加班费与总时长
    double overtimeAmount = 0;
    for (final r in filtered) {
      overtimeAmount += _globalData.calculateDailyOvertime(r.hours, r.multiplier);
    }
    final totalHours = filtered.fold<double>(0, (s, r) => s + r.hours);
    final uniqueDays = _globalData.uniqueDayCountFor(filtered);

    return Scaffold(
      appBar: AppBar(
        title: const Text('月度报表'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 过滤模式选择 + 月份选择器
            Row(
              children: [
                ChoiceChip(
                  label: const Text('本月'),
                  selected: _filterMode == 'month',
                  onSelected: (_) => setState(() => _filterMode = 'month'),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('本周'),
                  selected: _filterMode == 'week',
                  onSelected: (_) => setState(() => _filterMode = 'week'),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('自定义'),
                  selected: _filterMode == 'range',
                  onSelected: (_) async {
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        _filterMode = 'range';
                        _rangeStart = picked.start;
                        _rangeEnd = picked.end;
                      });
                    }
                  },
                ),
                const Spacer(),
                if (_filterMode == 'month')
                  MonthSelector(
                    month: _selectedMonth,
                    onPrev: () => _changeMonth(-1),
                    onNext: () => _changeMonth(1),
                  ),
              ],
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

            // 导出（CSV / JSON）
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: filtered.isEmpty ? null : () => _export(context, filtered, 'csv'),
                  child: const Text('导出CSV'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: filtered.isEmpty ? null : () => _export(context, filtered, 'json'),
                  child: const Text('导出JSON'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 加班类型分布
            if (filtered.isNotEmpty)
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('加班类型分布', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        Expanded(child: OvertimeDistributionList(records: filtered)),
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
