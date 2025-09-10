import 'package:flutter/material.dart';

/// 设置页：基本薪资与时薪卡片。
class SettingsSalarySection extends StatelessWidget {
  final double baseSalary;
  final double effectiveHourlyRate;
  final double customHourlyRate;
  final VoidCallback onEdit;

  const SettingsSalarySection({
    super.key,
    required this.baseSalary,
    required this.effectiveHourlyRate,
    required this.customHourlyRate,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('基本薪资设置', style: Theme.of(context).textTheme.titleLarge),
          ),
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: const Text('底薪设置'),
            subtitle: Text('¥${baseSalary.toStringAsFixed(2)}/月'),
            trailing: const Icon(Icons.chevron_right),
            onTap: onEdit,
          ),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text('时薪设置'),
            subtitle: Text(customHourlyRate > 0
                ? '自定义: ¥${customHourlyRate.toStringAsFixed(2)}/小时'
                : '自动计算: ¥${effectiveHourlyRate.toStringAsFixed(2)}/小时'),
            trailing: const Icon(Icons.chevron_right),
            onTap: onEdit,
          ),
        ],
      ),
    );
  }
}
