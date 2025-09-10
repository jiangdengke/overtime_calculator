import 'package:flutter/material.dart';

/// 星期标题行（周日到周六）。
class WeekdayHeader extends StatelessWidget {
  const WeekdayHeader({super.key});

  /// 构建组件 UI。
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: ['日', '一', '二', '三', '四', '五', '六']
            .map((day) => Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: day == '日' || day == '六' ? Colors.red : Colors.grey[600],
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

