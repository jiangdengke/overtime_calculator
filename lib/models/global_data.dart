import 'package:flutter/material.dart';
import '../models/overtime_record.dart';
import '../services/local_storage_service.dart';
import '../services/cloud_sync_service.dart';
import '../services/auth_service.dart';

/// Application-wide state and business logic.
///
/// - Holds salary settings and overtime records
/// - Persists data locally via [LocalStorageService]
/// - Provides optional cloud sync hooks via [CloudSyncService]
class GlobalData extends ChangeNotifier {
  // 单例模式实现
  static final GlobalData _instance = GlobalData._internal();
  factory GlobalData() => _instance;
  GlobalData._internal();

  // 服务
  final LocalStorageService _storage = LocalStorageService();
  CloudSyncService _cloud = const NoopCloudSyncService();
  final AuthService _auth = AuthService();

  // 数据存储（使用强类型模型，而非 Map）
  List<OvertimeRecord> _records = [];
  double _baseSalary = 5000.0;
  double _socialInsuranceRate = 0.11; // 五险
  double _housingFundRate = 0.12; // 住房公积金
  double _customHourlyRate = 0; // 自定义时薪，0表示使用计算值

  // 数据访问器
  List<OvertimeRecord> get records => _records;
  double get baseSalary => _baseSalary;
  double get socialInsuranceRate => _socialInsuranceRate;
  double get housingFundRate => _housingFundRate;
  double get totalInsuranceRate => _socialInsuranceRate + _housingFundRate;
  double get customHourlyRate => _customHourlyRate;

  // 登录（本地占位）
  AuthService get auth => _auth;

  /// 初始化：加载本地缓存的数据和简单登录状态
  Future<void> init() async {
    await _auth.load();
    _records = await _storage.loadRecords();
    final settings = await _storage.loadSettings();
    _baseSalary = settings.baseSalary ?? _baseSalary;
    _socialInsuranceRate = settings.socialRate ?? _socialInsuranceRate;
    _housingFundRate = settings.housingRate ?? _housingFundRate;
    _customHourlyRate = settings.customHourlyRate ?? _customHourlyRate;
    notifyListeners();
  }

  /// 注入云同步实现（默认 Noop）
  void setCloudSyncService(CloudSyncService service) {
    _cloud = service;
  }

  // 数据操作方法
  /// 新增一条加班记录，并保存到本地
  void addRecord(OvertimeRecord record) {
    _records.add(record);
    _persistRecords();
  }

  /// 按索引删除一条加班记录，并保存到本地
  void removeRecord(int index) {
    if (index >= 0 && index < _records.length) {
      _records.removeAt(index);
      _persistRecords();
    }
  }

  /// 更新薪资设置（底薪、五险、公积金、自定义时薪），并保存到本地
  void updateSalarySettings(double baseSalary, double socialRate, double housingRate, double customRate) {
    _baseSalary = baseSalary;
    _socialInsuranceRate = socialRate;
    _housingFundRate = housingRate;
    _customHourlyRate = customRate;
    _persistSettings();
  }

  // 计算方法
  /// 计算有效时薪（优先使用自定义时薪，否则按底薪/22/8 计算）
  double get effectiveHourlyRate {
    // 如果用户设置了自定义时薪，则直接用自定义时薪
    // 否则用底薪/(22*8)自动计算（22个工作日、每天8小时）
    return _customHourlyRate > 0 ? _customHourlyRate : _baseSalary / (22 * 8);
  }

  /// 计算某日加班费用（= 小时数 × 倍数 × 有效时薪）
  double calculateDailyOvertime(double hours, double multiplier) {
    return hours * multiplier * effectiveHourlyRate;
  }

  /// 当月加班总金额
  double get monthlyOvertime {
    final now = DateTime.now();
    return _records.where((record) {
      final date = record.date;
      return date.year == now.year && date.month == now.month;
    }).fold<double>(0, (sum, record) {
      return sum + calculateDailyOvertime(record.hours, record.multiplier);
    });
  }

  /// 当月加班总时长（小时）
  double get totalHours {
    final now = DateTime.now();
    return _records.where((record) {
      final date = record.date;
      return date.year == now.year && date.month == now.month;
    }).fold<double>(0, (sum, record) => sum + record.hours);
  }

  // 数据筛选方法
  /// 当月所有加班记录列表
  List<OvertimeRecord> get monthlyRecords {
    final now = DateTime.now();
    return _records.where((record) {
      final date = record.date;
      return date.year == now.year && date.month == now.month;
    }).toList();
  }

  /// 获取指定日期的所有加班记录
  List<OvertimeRecord> getRecordsByDate(DateTime date) {
    return _records.where((record) {
      final recordDate = record.date;
      return recordDate.year == date.year && 
             recordDate.month == date.month && 
             recordDate.day == date.day;
    }).toList();
  }

  /// 获取指定月份的所有加班记录
  List<OvertimeRecord> getRecordsByMonth(DateTime month) {
    return _records.where((record) {
      final date = record.date;
      return date.year == month.year && date.month == month.month;
    }).toList();
  }

  /// 计算某日加班总时长
  double getDayTotalHours(DateTime date) {
    return getRecordsByDate(date).fold<double>(0, (sum, record) => sum + record.hours);
  }

  /// 手动触发云上传（需要登录）
  /// 手动触发云上传（需要已登录）
  Future<void> syncUp() async {
    if (!_auth.isLoggedIn) return;
    await _cloud.syncUp(
      userId: _auth.email!,
      records: _records,
      baseSalary: _baseSalary,
      socialRate: _socialInsuranceRate,
      housingRate: _housingFundRate,
      customHourlyRate: _customHourlyRate,
    );
  }

  /// 手动触发云下载（需要登录）
  /// 手动触发云下载（需要已登录）
  Future<void> syncDown() async {
    if (!_auth.isLoggedIn) return;
    final res = await _cloud.syncDown(userId: _auth.email!);
    if (res.records.isNotEmpty) {
      _records = res.records;
      await _storage.saveRecords(_records);
    }
    if (res.baseSalary != null ||
        res.socialRate != null ||
        res.housingRate != null ||
        res.customHourlyRate != null) {
      _baseSalary = res.baseSalary ?? _baseSalary;
      _socialInsuranceRate = res.socialRate ?? _socialInsuranceRate;
      _housingFundRate = res.housingRate ?? _housingFundRate;
      _customHourlyRate = res.customHourlyRate ?? _customHourlyRate;
      await _storage.saveSettings(
        baseSalary: _baseSalary,
        socialRate: _socialInsuranceRate,
        housingRate: _housingFundRate,
        customHourlyRate: _customHourlyRate,
      );
    }
    notifyListeners();
  }

  /// 持久化所有记录到本地并通知界面刷新
  Future<void> _persistRecords() async {
    await _storage.saveRecords(_records);
    notifyListeners();
  }

  /// 持久化当前设置到本地并通知界面刷新
  Future<void> _persistSettings() async {
    await _storage.saveSettings(
      baseSalary: _baseSalary,
      socialRate: _socialInsuranceRate,
      housingRate: _housingFundRate,
      customHourlyRate: _customHourlyRate,
    );
    notifyListeners();
  }
}
