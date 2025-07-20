import 'package:flutter/material.dart';
import '../models/global_data.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final GlobalData _globalData = GlobalData();
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _globalData.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    _globalData.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _changeMonth(int delta) {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year, 
        _selectedMonth.month + delta,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // 获取选定月份的记录
    final monthRecords = _globalData.getRecordsByMonth(_selectedMonth);
    
    // 计算月度加班费
    double monthlyOvertime = 0;
    for (final record in monthRecords) {
      monthlyOvertime += _globalData.calculateDailyOvertime(
        record['hours'] as double, 
        record['multiplier'] as double
      );
    }
    
    // 计算总薪资和税后薪资
    final totalSalary = _globalData.baseSalary + monthlyOvertime;
    final socialInsuranceAmount = totalSalary * _globalData.socialInsuranceRate;
    final housingFundAmount = totalSalary * _globalData.housingFundRate;
    final netSalary = totalSalary - socialInsuranceAmount - housingFundAmount;
    
    // 计算总加班时长
    final totalHours = monthRecords.fold<double>(
      0, (sum, record) => sum + (record['hours'] as double)
    );

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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => _changeMonth(-1),
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(
                  '${_selectedMonth.year}年${_selectedMonth.month}月',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                  onPressed: () => _changeMonth(1),
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 薪资详情卡片
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_selectedMonth.year}年${_selectedMonth.month}月薪资详情', 
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                    ),
                    const SizedBox(height: 16),
                    _buildSalaryRow('底薪', _globalData.baseSalary),
                    _buildSalaryRow('加班费', monthlyOvertime, color: Colors.green),
                    const Divider(),
                    _buildSalaryRow('税前总薪资', totalSalary, isTotal: true),
                    const SizedBox(height: 8),
                    _buildSalaryRow(
                      '五险 (${(_globalData.socialInsuranceRate * 100).toStringAsFixed(1)}%)', 
                      socialInsuranceAmount, 
                      color: Colors.red, 
                      isDeduction: true
                    ),
                    _buildSalaryRow(
                      '住房公积金 (${(_globalData.housingFundRate * 100).toStringAsFixed(1)}%)', 
                      housingFundAmount, 
                      color: Colors.red, 
                      isDeduction: true
                    ),
                    const Divider(),
                    _buildSalaryRow(
                      '实际到手', 
                      netSalary, 
                      style: const TextStyle(
                        fontWeight: FontWeight.bold, 
                        color: Colors.green, 
                        fontSize: 16
                      )
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 统计卡片
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('工时统计', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatColumn('加班天数', '${monthRecords.length}天'),
                        _buildStatColumn('总时长', '${totalHours.toStringAsFixed(1)}小时'),
                        _buildStatColumn('平均日薪', '¥${(_globalData.baseSalary / 22).toStringAsFixed(2)}'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
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
                        Expanded(child: _buildOvertimeDistribution(monthRecords)),
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

  Widget _buildSalaryRow(String label, double amount, {
    Color? color, 
    TextStyle? style, 
    bool isTotal = false, 
    bool isDeduction = false
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            isDeduction ? '  - $label' : label, 
            style: style
          ),
          Text(
            '¥${amount.toStringAsFixed(2)}',
            style: style?.copyWith(color: color) ?? TextStyle(
              color: color, 
              fontWeight: isTotal ? FontWeight.bold : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value, 
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
        ),
        Text(
          label, 
          style: const TextStyle(color: Colors.grey)
        ),
      ],
    );
  }

  Widget _buildOvertimeDistribution(List<Map<String, dynamic>> records) {
    final distribution = <String, double>{};
    
    // 统计各类型加班时长
    for (final record in records) {
      final level = record['level'] as String;
      distribution[level] = (distribution[level] ?? 0) + (record['hours'] as double);
    }

    if (distribution.isEmpty) {
      return const Center(child: Text('无数据'));
    }

    // 计算总时长
    final totalHours = distribution.values.fold<double>(0, (sum, hours) => sum + hours);

    // 绘制分布图表
    return ListView(
      children: distribution.entries.map((entry) {
        final percentage = totalHours > 0 ? (entry.value / totalHours) : 0.0;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(entry.key),
                  Text('${entry.value.toStringAsFixed(1)}h (${(percentage * 100).toStringAsFixed(1)}%)'),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: percentage,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation(_getLevelColor(entry.key)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case '平时加班': return Colors.blue;
      case '周末加班': return Colors.orange;
      case '节假日加班': return Colors.red;
      default: return Colors.grey;
    }
  }
}
