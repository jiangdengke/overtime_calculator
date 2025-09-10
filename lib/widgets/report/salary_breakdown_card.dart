import 'package:flutter/material.dart';

/// 薪资明细卡片：展示底薪、加班费、税前总额、五险、公积金、到手等数据。
class SalaryBreakdownCard extends StatelessWidget {
  final int year;
  final int month;
  final double baseSalary;
  final double overtimeAmount;
  final double socialRate;
  final double housingRate;

  const SalaryBreakdownCard({
    super.key,
    required this.year,
    required this.month,
    required this.baseSalary,
    required this.overtimeAmount,
    required this.socialRate,
    required this.housingRate,
  });

  /// 构建组件 UI。
  @override
  Widget build(BuildContext context) {
    final totalSalary = baseSalary + overtimeAmount;
    final socialInsuranceAmount = totalSalary * socialRate;
    final housingFundAmount = totalSalary * housingRate;
    final netSalary = totalSalary - socialInsuranceAmount - housingFundAmount;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$year年${month}月薪资详情',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _row(context, label: '底薪', amount: baseSalary),
            _row(context, label: '加班费', amount: overtimeAmount, color: Colors.green),
            const Divider(),
            _row(context, label: '税前总薪资', amount: totalSalary, isTotal: true),
            const SizedBox(height: 8),
            _row(context,
                label: '五险 (${(socialRate * 100).toStringAsFixed(1)}%)',
                amount: socialInsuranceAmount,
                color: Colors.red,
                isDeduction: true),
            _row(context,
                label: '住房公积金 (${(housingRate * 100).toStringAsFixed(1)}%)',
                amount: housingFundAmount,
                color: Colors.red,
                isDeduction: true),
            const Divider(),
            _row(context,
                label: '实际到手',
                amount: netSalary,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  /// 构建一行标签 + 金额。
  Widget _row(
    BuildContext context, {
    required String label,
    required double amount,
    Color? color,
    TextStyle? style,
    bool isTotal = false,
    bool isDeduction = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(isDeduction ? '  - $label' : label, style: style),
          Text(
            '¥${amount.toStringAsFixed(2)}',
            style: style?.copyWith(color: color) ??
                TextStyle(color: color, fontWeight: isTotal ? FontWeight.bold : null),
          ),
        ],
      ),
    );
  }
}

