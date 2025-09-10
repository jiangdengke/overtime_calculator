import '../models/overtime_record.dart';

/// 云同步服务接口（抽象）。
///
/// 这是一个占位接口：当用户登录并触发“云同步”时被调用。
/// 你可以基于 Firebase / Supabase / 自建后端 实现并注入到应用中。
abstract class CloudSyncService {
  /// 将本地数据上传到云端。
  Future<void> syncUp({
    required String userId,
    required List<OvertimeRecord> records,
    required double baseSalary,
    required double socialRate,
    required double housingRate,
    required double customHourlyRate,
  });

  /// 从云端下载数据。
  Future<({
    List<OvertimeRecord> records,
    double? baseSalary,
    double? socialRate,
    double? housingRate,
    double? customHourlyRate,
  })> syncDown({
    required String userId,
  });
}

/// 默认空实现：未配置后端时使用，不进行任何网络操作。
class NoopCloudSyncService implements CloudSyncService {
  const NoopCloudSyncService();

  @override
  Future<void> syncUp({
    required String userId,
    required List<OvertimeRecord> records,
    required double baseSalary,
    required double socialRate,
    required double housingRate,
    required double customHourlyRate,
  }) async {
    // 空实现：不做任何事。可在此替换为真实网络调用。
  }

  @override
  Future<({
    List<OvertimeRecord> records,
    double? baseSalary,
    double? socialRate,
    double? housingRate,
    double? customHourlyRate,
  })> syncDown({required String userId}) async {
    // 返回空数据（占位）。
    return (
      records: <OvertimeRecord>[],
      baseSalary: null,
      socialRate: null,
      housingRate: null,
      customHourlyRate: null,
    );
  }
}
