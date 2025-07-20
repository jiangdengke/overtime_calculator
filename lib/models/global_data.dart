import 'package:flutter/material.dart';

class GlobalData extends ChangeNotifier {
  // 单例模式实现
  static final GlobalData _instance = GlobalData._internal();
  factory GlobalData() => _instance;
  GlobalData._internal();

  // 数据存储
  List<Map<String, dynamic>> _records = [];
  double _baseSalary = 5000.0;
  double _socialInsuranceRate = 0.11; // 五险
  double _housingFundRate = 0.12; // 住房公积金
  double _customHourlyRate = 0; // 自定义时薪，0表示使用计算值

  // 数据访问器
  List<Map<String, dynamic>> get records => _records;
  double get baseSalary => _baseSalary;
  double get socialInsuranceRate => _socialInsuranceRate;
  double get housingFundRate => _housingFundRate;
  double get totalInsuranceRate => _socialInsuranceRate + _housingFundRate;
  double get customHourlyRate => _customHourlyRate;

  // 数据操作方法
  void addRecord(Map<String, dynamic> record) {
    _records.add(record);
    notifyListeners();
  }

  void removeRecord(int index) {
    if (index >= 0 && index < _records.length) {
      _records.removeAt(index);
      notifyListeners();
    }
  }

  void updateSalarySettings(double baseSalary, double socialRate, double housingRate, double customRate) {
    _baseSalary = baseSalary;
    _socialInsuranceRate = socialRate;
    _housingFundRate = housingRate;
    _customHourlyRate = customRate;
    notifyListeners();
  }

  // 计算方法
  double get effectiveHourlyRate {
    // 如果用户设置了自定义时薪，则直接用自定义时薪
    // 否则用底薪/(22*8)自动计算（22个工作日、每天8小时）
    return _customHourlyRate > 0 ? _customHourlyRate : _baseSalary / (22 * 8);
  }

  double calculateDailyOvertime(double hours, double multiplier) {
    return hours * multiplier * effectiveHourlyRate;
  }

  double get monthlyOvertime {
    final now = DateTime.now();
    return _records.where((record) {
      final date = record['date'] as DateTime;
      return date.year == now.year && date.month == now.month;
    }).fold<double>(0, (sum, record) {
      return sum + calculateDailyOvertime(record['hours'], record['multiplier']);
    });
  }

  double get totalHours {
    final now = DateTime.now();
    return _records.where((record) {
      final date = record['date'] as DateTime;
      return date.year == now.year && date.month == now.month;
    }).fold<double>(0, (sum, record) => sum + (record['hours'] as double));
  }

  // 数据筛选方法
  List<Map<String, dynamic>> get monthlyRecords {
    final now = DateTime.now();
    return _records.where((record) {
      final date = record['date'] as DateTime;
      return date.year == now.year && date.month == now.month;
    }).toList();
  }

  List<Map<String, dynamic>> getRecordsByDate(DateTime date) {
    return _records.where((record) {
      final recordDate = record['date'] as DateTime;
      return recordDate.year == date.year && 
             recordDate.month == date.month && 
             recordDate.day == date.day;
    }).toList();
  }

  List<Map<String, dynamic>> getRecordsByMonth(DateTime month) {
    return _records.where((record) {
      final date = record['date'] as DateTime;
      return date.year == month.year && date.month == month.month;
    }).toList();
  }

  double getDayTotalHours(DateTime date) {
    return getRecordsByDate(date).fold<double>(0, (sum, record) => sum + (record['hours'] as double));
  }
}
