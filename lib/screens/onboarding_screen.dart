import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/global_data.dart';

/// 首次进入应用的设置引导页：设置底薪、五险、公积金、自定义时薪。
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late double _baseSalary;
  late double _socialRate;
  late double _housingRate;
  double _customHourlyRate = 0;
  bool _useCustomRate = false;

  late final TextEditingController _baseController;
  late final TextEditingController _customController;

  /// 初始化：从全局数据读取默认值作为占位
  @override
  void initState() {
    super.initState();
    final data = GlobalData();
    _baseSalary = data.baseSalary;
    _socialRate = data.socialInsuranceRate;
    _housingRate = data.housingFundRate;
    _customHourlyRate = data.customHourlyRate;
    _useCustomRate = _customHourlyRate > 0;
    _baseController = TextEditingController(text: _baseSalary.toString());
    _customController = TextEditingController(text: _customHourlyRate > 0 ? _customHourlyRate.toString() : '');
  }

  @override
  void dispose() {
    _baseController.dispose();
    _customController.dispose();
    super.dispose();
  }

  double get _calculatedRate => _baseSalary > 0 ? _baseSalary / (22 * 8) : 0;

  /// 保存设置并进入应用
  void _submit() {
    if (_baseSalary < 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('底薪不能小于 0')));
      return;
    }
    if (_useCustomRate && _customHourlyRate <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('自定义时薪需要大于 0')));
      return;
    }
    if (_baseSalary == 0 && !_useCustomRate) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请设置底薪或启用自定义时薪')));
      return;
    }
    final data = context.read<GlobalData>();
    data.updateSalarySettings(
      _baseSalary,
      _socialRate,
      _housingRate,
      _useCustomRate ? _customHourlyRate : 0,
    );
    data.completeInitialSetup();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text('欢迎使用加班费计算器', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('在开始之前，请完成基础设置：', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              Row(
                children: const [
                  Icon(Icons.info_outline, color: Colors.blueAccent),
                  SizedBox(width: 6),
                  Expanded(child: Text('可随时在“设置”中再次修改；未设置完整时，部分计算会隐藏。')),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(labelText: '底薪（元/月）'),
                keyboardType: TextInputType.number,
                controller: _baseController,
                onChanged: (v) => setState(() => _baseSalary = double.tryParse(v) ?? 0),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Checkbox(
                    value: _useCustomRate,
                    onChanged: (val) => setState(() {
                      _useCustomRate = val ?? false;
                      if (!_useCustomRate) _customHourlyRate = 0;
                    }),
                  ),
                  const Text('使用自定义时薪'),
                ],
              ),
              if (_useCustomRate)
                TextField(
                  decoration: const InputDecoration(labelText: '自定义时薪（元/小时）'),
                  keyboardType: TextInputType.number,
                  controller: _customController,
                  onChanged: (v) => setState(() => _customHourlyRate = double.tryParse(v) ?? 0),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('计算时薪: ¥${_calculatedRate.toStringAsFixed(2)}/小时', style: TextStyle(color: Colors.grey[600])),
                ),
              const SizedBox(height: 16),
              Text('五险比例: ${( _socialRate * 100).toStringAsFixed(1)}%'),
              Slider(
                value: _socialRate,
                min: 0.0,
                max: 0.3,
                divisions: 60, // 0.5% 步进
                label: '${(_socialRate * 100).toStringAsFixed(1)}%',
                onChanged: (value) => setState(() => _socialRate = value),
              ),
              const SizedBox(height: 8),
              Text('住房公积金比例: ${( _housingRate * 100).toStringAsFixed(1)}%'),
              Slider(
                value: _housingRate,
                min: 0.0,
                max: 0.2,
                divisions: 40, // 0.5% 步进
                label: '${(_housingRate * 100).toStringAsFixed(1)}%',
                onChanged: (value) => setState(() => _housingRate = value),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // 跳过：仅标记完成，不写入具体数值（保持默认 0）；
                        // 应用会在 UI 中引导用户尽快完成设置。
                        context.read<GlobalData>().completeInitialSetup();
                      },
                      child: const Text('稍后再说'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _submit,
                      child: const Text('开始使用'),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
