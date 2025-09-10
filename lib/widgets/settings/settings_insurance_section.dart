import 'package:flutter/material.dart';

/// 设置页：社保与住房公积金卡片，附总扣除金额。
class SettingsInsuranceSection extends StatelessWidget {
  final double monthlyBaseSalary;
  final double socialRate;
  final double housingRate;
  final VoidCallback onEdit;

  const SettingsInsuranceSection({
    super.key,
    required this.monthlyBaseSalary,
    required this.socialRate,
    required this.housingRate,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final socialAmount = monthlyBaseSalary * socialRate;
    final housingAmount = monthlyBaseSalary * housingRate;
    final totalDeduction = socialAmount + housingAmount;

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('社保公积金设置', style: Theme.of(context).textTheme.titleLarge),
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('五险'),
            subtitle: Text('${(socialRate * 100).toStringAsFixed(1)}% (养老、医疗、失业、工伤、生育)'),
            trailing: Text('¥${socialAmount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.red)),
            onTap: onEdit,
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('住房公积金'),
            subtitle: Text('${(housingRate * 100).toStringAsFixed(1)}%'),
            trailing: Text('¥${housingAmount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.red)),
            onTap: onEdit,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.calculate, color: Colors.red),
            title: const Text('总扣除金额'),
            subtitle: Text('${((socialRate + housingRate) * 100).toStringAsFixed(1)}% 扣除'),
            trailing: Text('¥${totalDeduction.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
