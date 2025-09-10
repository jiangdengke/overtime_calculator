import 'package:flutter/material.dart';

import '../../models/global_data.dart';
import '../../models/overtime_record.dart';

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
          ...dayRecords.map((OvertimeRecord record) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${record.level} ${record.hours}h'),
                    Text(
                      '¥${global.calculateDailyOvertime(record.hours, record.multiplier).toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
