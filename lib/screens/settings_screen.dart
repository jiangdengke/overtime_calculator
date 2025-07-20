import 'package:flutter/material.dart';
import '../models/global_data.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final GlobalData _globalData = GlobalData();

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

  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) {
        double tempBaseSalary = _globalData.baseSalary;
        double tempSocialRate = _globalData.socialInsuranceRate;
        double tempHousingRate = _globalData.housingFundRate;
        double tempCustomRate = _globalData.customHourlyRate;
        bool useCustomRate = tempCustomRate > 0;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            final calculatedRate = tempBaseSalary / (22 * 8);
            
            return AlertDialog(
              title: const Text('薪资设置'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(labelText: '底薪（元/月）'),
                      keyboardType: TextInputType.number,
                      controller: TextEditingController(text: tempBaseSalary.toString()),
                      onChanged: (value) {
                        tempBaseSalary = double.tryParse(value) ?? _globalData.baseSalary;
                        setDialogState(() {});
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // 时薪设置
                    Row(
                      children: [
                        Checkbox(
                          value: useCustomRate,
                          onChanged: (value) {
                            setDialogState(() {
                              useCustomRate = value ?? false;
                              if (!useCustomRate) tempCustomRate = 0;
                            });
                          },
                        ),
                        const Text('使用自定义时薪'),
                      ],
                    ),
                    if (useCustomRate) 
                      TextField(
                        decoration: const InputDecoration(labelText: '自定义时薪（元/小时）'),
                        keyboardType: TextInputType.number,
                        controller: TextEditingController(
                          text: tempCustomRate > 0 ? tempCustomRate.toString() : '',
                        ),
                        onChanged: (value) {
                          tempCustomRate = double.tryParse(value) ?? 0;
                        },
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          '计算时薪: ¥${calculatedRate.toStringAsFixed(2)}/小时',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    
                    const SizedBox(height: 16),
                    Text('五险比例: ${(tempSocialRate * 100).toStringAsFixed(1)}%'),
                    Slider(
                      value: tempSocialRate,
                      min: 0.0,
                      max: 0.3,
                      divisions: 30,
                      label: '${(tempSocialRate * 100).toStringAsFixed(1)}%',
                      onChanged: (value) {
                        setDialogState(() {
                          tempSocialRate = value;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    Text('住房公积金比例: ${(tempHousingRate * 100).toStringAsFixed(1)}%'),
                    Slider(
                      value: tempHousingRate,
                      min: 0.0,
                      max: 0.2,
                      divisions: 20,
                      label: '${(tempHousingRate * 100).toStringAsFixed(1)}%',
                      onChanged: (value) {
                        setDialogState(() {
                          tempHousingRate = value;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '总扣除比例: ${((tempSocialRate + tempHousingRate) * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('取消'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _globalData.updateSalarySettings(
                      tempBaseSalary, 
                      tempSocialRate, 
                      tempHousingRate,
                      useCustomRate ? tempCustomRate : 0,
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('保存'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final monthlySalary = _globalData.baseSalary;
    final socialAmount = monthlySalary * _globalData.socialInsuranceRate;
    final housingAmount = monthlySalary * _globalData.housingFundRate;
    final totalDeduction = socialAmount + housingAmount;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _showSettings,
            tooltip: '修改设置',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 基本薪资设置卡片
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    '基本薪资设置',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.attach_money),
                  title: const Text('底薪设置'),
                  subtitle: Text('¥${_globalData.baseSalary.toStringAsFixed(2)}/月'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showSettings,
                ),
                ListTile(
                  leading: const Icon(Icons.schedule),
                  title: const Text('时薪设置'),
                  subtitle: Text(
                    _globalData.customHourlyRate > 0 
                        ? '自定义: ¥${_globalData.customHourlyRate.toStringAsFixed(2)}/小时'
                        : '自动计算: ¥${_globalData.effectiveHourlyRate.toStringAsFixed(2)}/小时'
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showSettings,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 保险公积金卡片
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    '社保公积金设置',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.security),
                  title: const Text('五险'),
                  subtitle: Text('${(_globalData.socialInsuranceRate * 100).toStringAsFixed(1)}% (养老、医疗、失业、工伤、生育)'),
                  trailing: Text('¥${socialAmount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.red)),
                  onTap: _showSettings,
                ),
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('住房公积金'),
                  subtitle: Text('${(_globalData.housingFundRate * 100).toStringAsFixed(1)}%'),
                  trailing: Text('¥${housingAmount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.red)),
                  onTap: _showSettings,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.calculate, color: Colors.red),
                  title: const Text('总扣除金额'),
                  subtitle: Text('${(_globalData.totalInsuranceRate * 100).toStringAsFixed(1)}% 扣除'),
                  trailing: Text(
                    '¥${totalDeduction.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 关于信息卡片
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    '关于',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('版本'),
                  subtitle: Text('1.0.0'),
                ),
                const ListTile(
                  leading: Icon(Icons.description_outlined),
                  title: Text('说明'),
                  subtitle: Text('记录加班工时，计算加班费用和月度薪资'),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
