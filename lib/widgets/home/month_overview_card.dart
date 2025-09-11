import 'package:flutter/material.dart';

import '../../models/global_data.dart';
import '../common/stat_card.dart';
import '../../screens/settings_screen.dart';

/// 月度概览卡片：展示“加班天数/加班时长/加班费”与时薪。
class MonthOverviewCard extends StatelessWidget {
  final GlobalData data;
  final DateTime now;

  const MonthOverviewCard({super.key, required this.data, required this.now});

  /// 构建组件 UI。
  @override
  Widget build(BuildContext context) {
    final notReady = data.effectiveHourlyRate == 0 && data.baseSalary == 0;
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${now.year}年${now.month}月概览', style: Theme.of(context).textTheme.titleLarge),
                Text(
                  notReady ? '时薪: 未设置' : '时薪: ¥${data.effectiveHourlyRate.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (notReady) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(child: Text('未完成基础设置，部分统计已隐藏。请前往设置完善底薪/时薪与比例。')),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      ),
                      child: const Text('去设置'),
                    ),
                  ],
                ),
              ),
            ] else ...[
            Row(
              children: [
                Expanded(
                  child: StatCard(title: '加班天数', value: '${data.monthlyOvertimeDays}天', icon: Icons.calendar_today, color: Colors.blue),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: StatCard(title: '加班时长', value: '${data.totalHours.toStringAsFixed(1)}h', icon: Icons.access_time, color: Colors.orange),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: StatCard(title: '加班费', value: '¥${data.monthlyOvertime.toStringAsFixed(0)}', icon: Icons.monetization_on, color: Colors.green),
                ),
              ],
            ),
            ],
          ],
        ),
      ),
    );
  }
}
