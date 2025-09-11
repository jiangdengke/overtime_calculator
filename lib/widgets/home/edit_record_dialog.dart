import 'package:flutter/material.dart';

import '../../models/overtime_record.dart';
import '../../models/global_data.dart';

/// 编辑加班记录的对话框（支持修改小时数/类型）。
class EditRecordDialog extends StatefulWidget {
  /// 原始记录
  final OvertimeRecord record;

  /// 保存回调（返回修改后的记录）
  final void Function(OvertimeRecord updated) onSave;

  const EditRecordDialog({super.key, required this.record, required this.onSave});

  @override
  State<EditRecordDialog> createState() => _EditRecordDialogState();
}

class _EditRecordDialogState extends State<EditRecordDialog> {
  late double _hours;
  late String _level;
  late double _multiplier;
  late final TextEditingController _hoursController;

  final Map<String, double> levelMultipliers = const {
    '平时加班': 1.5,
    '周末加班': 2.0,
    '节假日加班': 3.0,
  };

  /// 初始化：将原始记录的值填充到临时状态
  @override
  void initState() {
    super.initState();
    _hours = widget.record.hours;
    _level = widget.record.level;
    _multiplier = widget.record.multiplier;
    _hoursController = TextEditingController(text: _hours.toString());
  }

  @override
  void dispose() {
    _hoursController.dispose();
    super.dispose();
  }

  /// 构建对话框 UI
  @override
  Widget build(BuildContext context) {
    final global = GlobalData();
    final estimated = _hours > 0 ? global.calculateDailyOvertime(_hours, _multiplier) : 0.0;

    return AlertDialog(
      title: const Text('编辑加班记录'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${widget.record.date.year}-${widget.record.date.month.toString().padLeft(2, '0')}-${widget.record.date.day.toString().padLeft(2, '0')}'),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(labelText: '加班小时数', suffixText: '小时'),
              keyboardType: TextInputType.number,
              controller: _hoursController,
              onChanged: (v) => setState(() => _hours = double.tryParse(v) ?? 0),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _level,
              decoration: const InputDecoration(labelText: '加班类型'),
              items: levelMultipliers.entries
                  .map((e) => DropdownMenuItem(value: e.key, child: Text('${e.key} (${e.value}倍)')))
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _level = val;
                    _multiplier = levelMultipliers[val]!;
                  });
                }
              },
            ),
            if (estimated > 0) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('预计加班费'),
                  Text('¥${estimated.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                ],
              )
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
        FilledButton(
          onPressed: _hours > 0
              ? () {
                  widget.onSave(OvertimeRecord(
                    hours: _hours,
                    level: _level,
                    multiplier: _multiplier,
                    date: widget.record.date,
                  ));
                  Navigator.pop(context);
                }
              : null,
          child: const Text('保存'),
        ),
      ],
    );
  }
}
