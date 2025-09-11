import 'package:flutter/material.dart';

import '../../models/global_data.dart';
import '../../models/overtime_record.dart';
import 'edit_record_dialog.dart';

/// 选中日期的加班详情面板。
class OvertimeDetailsPanel extends StatelessWidget {
  final DateTime selectedDay;

  const OvertimeDetailsPanel({super.key, required this.selectedDay});

  @override
  Widget build(BuildContext context) {
    final global = GlobalData();
    final dayRecords = global.getRecordsByDate(selectedDay);
    if (dayRecords.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 16.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${selectedDay.month}月${selectedDay.day}日 加班详情',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...dayRecords.map((OvertimeRecord record) {
            final idx = global.records.indexOf(record);
            final amount = global
                .calculateDailyOvertime(record.hours, record.multiplier)
                .toStringAsFixed(2);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text('${record.level}  ${record.hours}h'),
                subtitle:
                    Text('¥$amount', style: const TextStyle(color: Colors.green)),
                trailing: Wrap(
                  spacing: 8,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 18),
                      tooltip: '编辑',
                      onPressed: idx >= 0
                          ? () {
                              showDialog(
                                context: context,
                                builder: (_) => EditRecordDialog(
                                  record: record,
                                  onSave: (updated) =>
                                      global.updateRecordAtIndex(idx, updated),
                                ),
                              );
                            }
                          : null,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18),
                      tooltip: '删除',
                      onPressed:
                          idx >= 0 ? () => global.removeRecord(idx) : null,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
