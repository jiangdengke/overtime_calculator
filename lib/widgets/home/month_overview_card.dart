import 'package:flutter/material.dart';

import '../../models/global_data.dart';
import '../common/stat_card.dart';

/// 月度概览卡片：展示“加班天数/加班时长/加班费”与时薪。
class MonthOverviewCard extends StatelessWidget {
  final GlobalData data;
  final DateTime now;

  const MonthOverviewCard({super.key, required this.data, required this.now});

  /// 构建组件 UI。
  @override
  Widget build(BuildContext context) {
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
                Text('时薪: ¥${data.effectiveHourlyRate.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 16),
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
        ),
      ),
    );
  }
}
