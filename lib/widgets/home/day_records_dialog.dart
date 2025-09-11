import 'package:flutter/material.dart';

import '../../models/global_data.dart';
import '../../models/overtime_record.dart';
import 'edit_record_dialog.dart';

/// 某日的加班记录管理对话框（支持编辑/删除）。
class DayRecordsDialog extends StatelessWidget {
  /// 目标日期
  final DateTime date;

  const DayRecordsDialog({super.key, required this.date});

  /// 构建对话框 UI
  @override
  Widget build(BuildContext context) {
    final data = GlobalData();
    final list = data.getRecordsByDate(date);
    return AlertDialog(
      title: Text('${date.month}月${date.day}日 加班记录'),
      content: SizedBox(
        width: 400,
        child: list.isEmpty
            ? const Text('无记录')
            : ListView.separated(
                shrinkWrap: true,
                itemCount: list.length,
                separatorBuilder: (_, __) => const Divider(height: 8),
                itemBuilder: (context, i) {
                  final r = list[i];
                  final idx = data.records.indexOf(r);
                  final amount = data.calculateDailyOvertime(r.hours, r.multiplier).toStringAsFixed(2);
                  return ListTile(
                    dense: true,
                    title: Text('${r.level}  ${r.hours}h'),
                    subtitle: Text('¥$amount', style: const TextStyle(color: Colors.green)),
                    trailing: Wrap(
                      spacing: 8,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 18),
                          tooltip: '编辑',
                          onPressed: idx >= 0
                              ? () async {
                                  await showDialog(
                                    context: context,
                                    builder: (_) => EditRecordDialog(
                                      record: r,
                                      onSave: (updated) => data.updateRecordAtIndex(idx, updated),
                                    ),
                                  );
                                }
                              : null,
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 18),
                          tooltip: '删除',
                          onPressed: idx >= 0 ? () => data.removeRecord(idx) : null,
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('关闭')),
      ],
    );
  }
}

