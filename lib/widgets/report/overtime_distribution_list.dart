import 'package:flutter/material.dart';

import '../../models/overtime_record.dart';

/// 加班类型分布列表：按类型统计并展示占比进度条。
class OvertimeDistributionList extends StatelessWidget {
  final List<OvertimeRecord> records;
  const OvertimeDistributionList({super.key, required this.records});

  @override
  Widget build(BuildContext context) {
    // 统计所有类型（即便该月为 0 也展示，避免“展示不全”的观感）
    final levels = const ['平时加班', '周末加班', '节假日加班'];
    final distribution = <String, double>{for (final l in levels) l: 0};
    for (final r in records) {
      distribution[r.level] = (distribution[r.level] ?? 0) + r.hours;
    }

    final totalHours = distribution.values.fold<double>(0, (sum, h) => sum + h);

    return ListView(
      children: levels.map((key) {
        final value = distribution[key] ?? 0.0;
        final percentage = totalHours > 0 ? (value / totalHours) : 0.0;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(key),
                  Text('${value.toStringAsFixed(1)}h (${(percentage * 100).toStringAsFixed(1)}%)'),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: percentage,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation(_getLevelColor(key)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case '平时加班':
        return Colors.blue;
      case '周末加班':
        return Colors.orange;
      case '节假日加班':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
