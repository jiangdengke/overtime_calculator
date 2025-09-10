import 'package:flutter/material.dart';

import '../../models/global_data.dart';
import '../common/stat_card.dart';

/// 报表页统计行：加班天数 / 总时长 / 平均日薪。
class ReportStatOverviewRow extends StatelessWidget {
  /// 全局数据（用于读取统计数据）。
  final GlobalData data;

  /// 当前月份的记录数量。
  final int days;

  /// 当前月份的总加班时长。
  final double totalHours;

  const ReportStatOverviewRow({
    super.key,
    required this.data,
    required this.days,
    required this.totalHours,
  });

  /// 构建统计卡片行。
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: StatCard(
            title: '加班天数',
            value: '${days}天',
            icon: Icons.event,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: StatCard(
            title: '总时长',
            value: '${totalHours.toStringAsFixed(1)}小时',
            icon: Icons.access_time,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: StatCard(
            title: '平均日薪',
            value: '¥${(data.baseSalary / 22).toStringAsFixed(2)}',
            icon: Icons.calculate,
            color: Colors.green,
          ),
        ),
      ],
    );
  }
}
