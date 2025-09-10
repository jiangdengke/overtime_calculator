import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/overtime_record.dart';

/// 本地存储服务：使用 SharedPreferences 持久化应用数据。
///
/// - 使用命名空间化的键避免冲突。
/// - 加班记录采用 StringList 保存，每条记录一个 JSON 字符串，便于增量更新与可读性。
class LocalStorageService {
  static const _kRecordsKey = 'overtime.records.v1';
  static const _kBaseSalaryKey = 'settings.baseSalary.v1';
  static const _kSocialRateKey = 'settings.socialRate.v1';
  static const _kHousingRateKey = 'settings.housingRate.v1';
  static const _kCustomHourlyRateKey = 'settings.customHourlyRate.v1';
  static const _kUserEmailKey = 'auth.userEmail.v1';

  LocalStorageService._();
  static final LocalStorageService _instance = LocalStorageService._();
  factory LocalStorageService() => _instance;

  /// 加载所有已保存的加班记录。
  Future<List<OvertimeRecord>> loadRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_kRecordsKey) ?? const [];
    return list
        .map((s) => OvertimeRecord.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  /// 保存全量加班记录（覆盖原有列表）。
  Future<void> saveRecords(List<OvertimeRecord> records) async {
    final prefs = await SharedPreferences.getInstance();
    final list = records.map((r) => jsonEncode(r.toJson())).toList();
    await prefs.setStringList(_kRecordsKey, list);
  }

  /// 加载已保存的设置项。缺省值返回 null。
  Future<({double? baseSalary, double? socialRate, double? housingRate, double? customHourlyRate})>
      loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return (
      baseSalary: prefs.getDouble(_kBaseSalaryKey),
      socialRate: prefs.getDouble(_kSocialRateKey),
      housingRate: prefs.getDouble(_kHousingRateKey),
      customHourlyRate: prefs.getDouble(_kCustomHourlyRateKey),
    );
  }

  /// 持久化设置项。
  Future<void> saveSettings({
    required double baseSalary,
    required double socialRate,
    required double housingRate,
    required double customHourlyRate,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kBaseSalaryKey, baseSalary);
    await prefs.setDouble(_kSocialRateKey, socialRate);
    await prefs.setDouble(_kHousingRateKey, housingRate);
    await prefs.setDouble(_kCustomHourlyRateKey, customHourlyRate);
  }

  /// 持久化本地占位登录的邮箱（仅用于演示/本地功能）。
  Future<void> saveUserEmail(String? email) async {
    final prefs = await SharedPreferences.getInstance();
    if (email == null) {
      await prefs.remove(_kUserEmailKey);
    } else {
      await prefs.setString(_kUserEmailKey, email);
    }
  }

  Future<String?> loadUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kUserEmailKey);
  }
}
