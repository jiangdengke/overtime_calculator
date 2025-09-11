import 'package:flutter/material.dart';

import '../../models/global_data.dart';
import '../../models/overtime_record.dart';
import 'day_records_dialog.dart';

/// 月历网格：展示每一天的加班总时长与状态。
class CalendarGrid extends StatelessWidget {
  final DateTime focusedMonth;
  final DateTime selectedDay;
  final ValueChanged<DateTime> onDaySelected;
  final ValueChanged<DateTime>? onDayDoubleTap;

  const CalendarGrid({
    super.key,
    required this.focusedMonth,
    required this.selectedDay,
    required this.onDaySelected,
    this.onDayDoubleTap,
  });

  @override
  Widget build(BuildContext context) {
    final global = GlobalData();
    final firstDay = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final startDay = firstDay.subtract(Duration(days: firstDay.weekday % 7));

    final days = <DateTime>[];
    for (int i = 0; i < 42; i++) {
      days.add(DateTime(startDay.year, startDay.month, startDay.day + i));
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.0,
      ),
      itemCount: days.length,
      itemBuilder: (context, index) {
        final day = days[index];
        final isCurrentMonth = day.month == focusedMonth.month;
        final now = DateTime.now();
        final isToday = day.year == now.year && day.month == now.month && day.day == now.day;
        final isSelected = day.year == selectedDay.year && day.month == selectedDay.month && day.day == selectedDay.day;
        final dayRecords = global.getRecordsByDate(day);
        final totalHours = global.getDayTotalHours(day);
        final isWeekend = day.weekday == 6 || day.weekday == 7;

        return GestureDetector(
          onTap: () => onDaySelected(day),
          onDoubleTap: onDayDoubleTap != null ? () => onDayDoubleTap!(day) : null,
          child: Container(
            margin: const EdgeInsets.all(1.0),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.blue.withOpacity(0.3)
                  : isToday
                      ? Colors.orange.withOpacity(0.3)
                      : null,
              borderRadius: BorderRadius.circular(8),
              border: isSelected ? Border.all(color: Colors.blue, width: 2) : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${day.day}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    color: !isCurrentMonth
                        ? Colors.grey[400]
                        : isWeekend
                            ? Colors.red[400]
                            : isToday
                                ? Colors.orange[800]
                                : Colors.black87,
                  ),
                ),
                if (totalHours > 0) ...[
                  const SizedBox(height: 2),
                  GestureDetector(
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => DayRecordsDialog(date: day),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: _getOvertimeColor(dayRecords),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${totalHours.toStringAsFixed(1)}h',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getOvertimeColor(List<OvertimeRecord> records) {
    if (records.isEmpty) return Colors.grey;
    final hasHoliday = records.any((r) => r.level == '节假日加班');
    final hasWeekend = records.any((r) => r.level == '周末加班');
    if (hasHoliday) return Colors.red;
    if (hasWeekend) return Colors.orange;
    return Colors.blue;
  }
}
