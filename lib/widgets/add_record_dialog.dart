import 'package:flutter/material.dart';
import '../models/global_data.dart';

class AddRecordDialog extends StatefulWidget {
  final Function(double, String, double, DateTime) onSubmit;
  final DateTime initialDate;

  const AddRecordDialog({
    super.key, 
    required this.onSubmit, 
    required this.initialDate
  });

  @override
  State<AddRecordDialog> createState() => _AddRecordDialogState();
}

class _AddRecordDialogState extends State<AddRecordDialog> {
  double hours = 0;
  String level = '平时加班';
  double multiplier = 1.5;
  late DateTime selectedDate;
  final _hoursController = TextEditingController();

  final Map<String, double> levelMultipliers = {
    '平时加班': 1.5,
    '周末加班': 2.0,
    '节假日加班': 3.0,
  };

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
    
    // 根据日期自动选择合适的加班类型
    if (selectedDate.weekday == 6 || selectedDate.weekday == 7) {
      level = '周末加班';
      multiplier = 2.0;
    }
  }

  @override
  void dispose() {
    _hoursController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final GlobalData globalData = GlobalData();
    final estimatedPay = hours > 0 ? globalData.calculateDailyOvertime(hours, multiplier) : 0.0;

    return AlertDialog(
      title: const Text('添加加班记录'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 日期选择
          ListTile(
            title: const Text('日期'),
            subtitle: Text(
              '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-'
              '${selectedDate.day.toString().padLeft(2, '0')} ${_getWeekday(selectedDate)}'
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (date != null) {
                setState(() {
                  selectedDate = date;
                  // 根据选择的日期自动调整加班类型
                  if (date.weekday == 6 || date.weekday == 7) {
                    if (level == '平时加班') {
                      level = '周末加班';
                      multiplier = 2.0;
                    }
                  }
                });
              }
            },
          ),
          
          // 小时数输入
          TextField(
            controller: _hoursController,
            decoration: const InputDecoration(
              labelText: '加班小时数',
              suffixText: '小时',
              hintText: '请输入加班时长',
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                hours = double.tryParse(value) ?? 0;
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          // 加班类型选择
          DropdownButtonFormField<String>(
            value: level,
            decoration: const InputDecoration(labelText: '加班类型'),
            items: levelMultipliers.entries.map((entry) {
              return DropdownMenuItem<String>(
                value: entry.key,
                child: Text('${entry.key} (${entry.value}倍)'),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  level = newValue;
                  multiplier = levelMultipliers[newValue]!;
                });
              }
            },
          ),
          
          // 预估加班费
          if (estimatedPay > 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('预计加班费:'),
                  Text(
                    '¥${estimatedPay.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: hours > 0
              ? () {
                  widget.onSubmit(hours, level, multiplier, selectedDate);
                  Navigator.pop(context);
                }
              : null,
          child: const Text('添加'),
        ),
      ],
    );
  }

  String _getWeekday(DateTime date) {
    final weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return weekdays[(date.weekday - 1) % 7];
  }
}
