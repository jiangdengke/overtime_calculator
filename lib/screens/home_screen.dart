import 'package:flutter/material.dart';
import '../models/global_data.dart';
import '../widgets/add_record_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalData _globalData = GlobalData();
  DateTime _focusedMonth = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _globalData.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    _globalData.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _addRecord([DateTime? selectedDate]) {
    showDialog(
      context: context,
      builder: (context) => AddRecordDialog(
        initialDate: selectedDate ?? _selectedDay,
        onSubmit: (h, l, m, d) {
          if (h > 0) {
            _globalData.addRecord({
              'hours': h,
              'level': l,
              'multiplier': m,
              'date': d,
            });
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text('工时记录'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // 月度概览卡片
          Card(
            margin: const EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${now.year}年${now.month}月概览',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        '时薪: ¥${_globalData.effectiveHourlyRate.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          '加班天数',
                          '${_globalData.monthlyRecords.length}天',
                          Icons.calendar_today,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          '加班时长',
                          '${_globalData.totalHours.toStringAsFixed(1)}h',
                          Icons.access_time,
                          Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          '加班费',
                          '¥${_globalData.monthlyOvertime.toStringAsFixed(0)}',
                          Icons.monetization_on,
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 日历视图
          Expanded(
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 月份导航
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
                            });
                          },
                          icon: const Icon(Icons.chevron_left),
                        ),
                        Text(
                          '${_focusedMonth.year}年${_focusedMonth.month}月',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
                            });
                          },
                          icon: const Icon(Icons.chevron_right),
                        ),
                      ],
                    ),
                    
                    // 星期标题
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: ['日', '一', '二', '三', '四', '五', '六'].map((day) => 
                          Expanded(
                            child: Center(
                              child: Text(
                                day,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: day == '日' || day == '六' ? Colors.red : Colors.grey[600],
                                ),
                              ),
                            ),
                          ),
                        ).toList(),
                      ),
                    ),

                    // 日历网格
                    Expanded(
                      child: _buildCalendarGrid(),
                    ),

                    // 选中日期的详情
                    if (_globalData.getRecordsByDate(_selectedDay).isNotEmpty)
                      Container(
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
                              '${_selectedDay.month}月${_selectedDay.day}日 加班详情',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            ..._globalData.getRecordsByDate(_selectedDay).map((record) => 
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('${record['level']} ${record['hours']}h'),
                                    Text(
                                      '¥${_globalData.calculateDailyOvertime(record['hours'] as double, record['multiplier'] as double).toStringAsFixed(2)}',
                                      style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ).toList(),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addRecord(),
        tooltip: '添加记录',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final startDay = firstDay.subtract(Duration(days: firstDay.weekday % 7));
    
    final days = <DateTime>[];
    for (int i = 0; i < 42; i++) {
      days.add(startDay.add(Duration(days: i)));
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.0,
      ),
      itemCount: days.length,
      itemBuilder: (context, index) {
        final day = days[index];
        final isCurrentMonth = day.month == _focusedMonth.month;
        final isToday = day.year == DateTime.now().year && 
                       day.month == DateTime.now().month && 
                       day.day == DateTime.now().day;
        final isSelected = day.year == _selectedDay.year && 
                          day.month == _selectedDay.month && 
                          day.day == _selectedDay.day;
        final dayRecords = _globalData.getRecordsByDate(day);
        final totalHours = _globalData.getDayTotalHours(day);
        final isWeekend = day.weekday == 6 || day.weekday == 7;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedDay = day;
            });
          },
          onDoubleTap: () => _addRecord(day),
          child: Container(
            margin: const EdgeInsets.all(1.0),
            decoration: BoxDecoration(
              color: isSelected 
                  ? Colors.blue.withOpacity(0.3)
                  : isToday 
                      ? Colors.orange.withOpacity(0.3)
                      : null,
              borderRadius: BorderRadius.circular(8),
              border: isSelected 
                  ? Border.all(color: Colors.blue, width: 2)
                  : null,
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
                  Container(
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
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getOvertimeColor(List<Map<String, dynamic>> records) {
    if (records.isEmpty) return Colors.grey;
    
    // 根据加班类型确定颜色，优先级：节假日 > 周末 > 平时
    bool hasHoliday = records.any((r) => r['level'] == '节假日加班');
    bool hasWeekend = records.any((r) => r['level'] == '周末加班');
    
    if (hasHoliday) return Colors.red;
    if (hasWeekend) return Colors.orange;
    return Colors.blue;
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          Text(title, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
