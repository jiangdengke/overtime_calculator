import 'package:flutter/material.dart';

/// 薪资设置编辑对话框：编辑底薪、五险、公积金、自定义时薪。
class SalaryEditDialog extends StatefulWidget {
  /// 初始底薪（元/月）
  final double baseSalary;

  /// 初始五险比例（0.0~1.0）
  final double socialRate;

  /// 初始住房公积金比例（0.0~1.0）
  final double housingRate;

  /// 初始自定义时薪（0 表示不用自定义）
  final double customHourlyRate;

  /// 保存回调：返回底薪、五险、公积金、自定义时薪
  final void Function(double baseSalary, double socialRate, double housingRate, double customHourlyRate) onSave;

  const SalaryEditDialog({
    super.key,
    required this.baseSalary,
    required this.socialRate,
    required this.housingRate,
    required this.customHourlyRate,
    required this.onSave,
  });

  @override
  State<SalaryEditDialog> createState() => _SalaryEditDialogState();
}

class _SalaryEditDialogState extends State<SalaryEditDialog> {
  late double _baseSalary;
  late double _socialRate;
  late double _housingRate;
  late double _customHourlyRate;
  late bool _useCustomRate;
  late final TextEditingController _baseController;
  late final TextEditingController _customController;

  /// 初始化：根据传入参数设置临时状态
  @override
  void initState() {
    super.initState();
    _baseSalary = widget.baseSalary;
    _socialRate = widget.socialRate;
    _housingRate = widget.housingRate;
    _customHourlyRate = widget.customHourlyRate;
    _useCustomRate = _customHourlyRate > 0;
    _baseController = TextEditingController(text: _baseSalary.toString());
    _customController = TextEditingController(text: _customHourlyRate > 0 ? _customHourlyRate.toString() : '');
  }

  /// 计算自动时薪（底薪 / (22 工作日 * 8 小时)）
  double get _calculatedRate => _baseSalary / (22 * 8);

  /// 构建对话框 UI
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('薪资设置'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: '底薪（元/月）'),
              keyboardType: TextInputType.number,
              controller: _baseController,
              onChanged: (value) => setState(() => _baseSalary = double.tryParse(value) ?? 0),
            ),
            const SizedBox(height: 16),

            // 时薪设置
            Row(
              children: [
                Checkbox(
                  value: _useCustomRate,
                  onChanged: (value) {
                    setState(() {
                      _useCustomRate = value ?? false;
                      if (!_useCustomRate) _customHourlyRate = 0;
                    });
                  },
                ),
                const Text('使用自定义时薪'),
              ],
            ),
            if (_useCustomRate)
              TextField(
                decoration: const InputDecoration(labelText: '自定义时薪（元/小时）'),
                keyboardType: TextInputType.number,
                controller: _customController,
                onChanged: (value) => setState(() => _customHourlyRate = double.tryParse(value) ?? 0),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text('计算时薪: ¥${_calculatedRate.toStringAsFixed(2)}/小时', style: TextStyle(color: Colors.grey[600])),
              ),

            const SizedBox(height: 16),
            Text('五险比例: ${( _socialRate * 100).toStringAsFixed(1)}%'),
            Slider(
              value: _socialRate,
              min: 0.0,
              max: 0.3,
              divisions: 30,
              label: '${(_socialRate * 100).toStringAsFixed(1)}%',
              onChanged: (value) => setState(() => _socialRate = value),
            ),

            const SizedBox(height: 8),
            Text('住房公积金比例: ${( _housingRate * 100).toStringAsFixed(1)}%'),
            Slider(
              value: _housingRate,
              min: 0.0,
              max: 0.2,
              divisions: 20,
              label: '${(_housingRate * 100).toStringAsFixed(1)}%',
              onChanged: (value) => setState(() => _housingRate = value),
            ),

            const SizedBox(height: 8),
            Text('总扣除比例: ${(( _socialRate + _housingRate) * 100).toStringAsFixed(1)}%',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
        ElevatedButton(
          onPressed: () {
            widget.onSave(
              _baseSalary,
              _socialRate,
              _housingRate,
              _useCustomRate ? _customHourlyRate : 0,
            );
            Navigator.pop(context);
          },
          child: const Text('保存'),
        ),
      ],
    );
  }
}
