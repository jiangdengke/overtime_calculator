/// 加班记录模型，集中提供 JSON 序列化/反序列化。
///
/// 为了可维护性，避免在界面层直接使用 Map，统一用强类型模型承载数据结构与转换。
class OvertimeRecord {
  /// 当天加班小时数。
  final double hours;

  /// 加班级别标签，例如：'平时加班' / '周末加班' / '节假日加班'。
  final String level;

  /// 本条记录的计薪倍数（1.5 / 2.0 / 3.0 等）。
  final double multiplier;

  /// 记录对应的日期（忽略具体时分秒）。
  final DateTime date;

  OvertimeRecord({
    required this.hours,
    required this.level,
    required this.multiplier,
    required this.date,
  });

  /// 序列化为 JSON 可编码的 Map。
  Map<String, dynamic> toJson() => {
        'hours': hours,
        'level': level,
        'multiplier': multiplier,
        'date': date.toIso8601String(),
      };

  /// 从 JSON Map 反序列化构建对象。
  factory OvertimeRecord.fromJson(Map<String, dynamic> json) {
    return OvertimeRecord(
      hours: (json['hours'] as num).toDouble(),
      level: json['level'] as String,
      multiplier: (json['multiplier'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
    );
  }
}
