import 'package:flutter/material.dart';
import '../models/global_data.dart';
import '../services/auth_service.dart';
import 'package:provider/provider.dart';
import '../widgets/settings/account_sync_card.dart';
import '../widgets/settings/settings_salary_section.dart';
import '../widgets/settings/settings_insurance_section.dart';
import '../widgets/settings/settings_about_card.dart';
import '../widgets/settings/salary_edit_dialog.dart';
import '../widgets/settings/email_login_dialog.dart';

/// 设置页面：薪资/扣除设置、账户与同步、关于。
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final AuthService _auth;

  /// 初始化：获取登录服务引用
  @override
  void initState() {
    super.initState();
    _auth = GlobalData().auth;
  }

  /// 弹出邮箱输入对话框（本地占位登录）
  Future<String?> _promptEmail(BuildContext context) async {
    String? result;
    await showDialog(
      context: context,
      builder: (_) => EmailLoginDialog(onConfirm: (email) => result = email),
    );
    return result;
  }

  // 使用 Provider 自动刷新，无需手动监听

  /// 弹出薪资设置对话框
  void _showSettings() {
    final data = context.read<GlobalData>();
    showDialog(
      context: context,
      builder: (context) => SalaryEditDialog(
        baseSalary: data.baseSalary,
        socialRate: data.socialInsuranceRate,
        housingRate: data.housingFundRate,
        customHourlyRate: data.customHourlyRate,
        onSave: (b, s, h, c) => data.updateSalarySettings(b, s, h, c),
      ),
    );
  }

  /// 构建设置页面 UI
  @override
  Widget build(BuildContext context) {
    final data = context.watch<GlobalData>();
    final monthlySalary = data.baseSalary;
    final socialAmount = monthlySalary * data.socialInsuranceRate;
    final housingAmount = monthlySalary * data.housingFundRate;
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
          // 账户与同步（组件化）
          AccountSyncCard(
            isLoggedIn: _auth.isLoggedIn,
            email: _auth.email,
            onLoginTap: () async {
              final email = await _promptEmail(context);
              if (email != null && email.isNotEmpty) {
                await _auth.signInWithEmail(email);
                // Provider 会自动刷新界面
              }
            },
            onLogoutTap: () async {
              await _auth.signOut();
            },
            onSyncDownTap: () async {
              await data.syncDown();
              if (mounted) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('从云端下载完成（如已配置后端）')));
              }
            },
            onSyncUpTap: () async {
              await data.syncUp();
              if (mounted) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('上传到云端完成（如已配置后端）')));
              }
            },
          ),
          const SizedBox(height: 16),
          // 基本薪资设置（组件化）
          SettingsSalarySection(
            baseSalary: data.baseSalary,
            effectiveHourlyRate: data.effectiveHourlyRate,
            customHourlyRate: data.customHourlyRate,
            onEdit: _showSettings,
          ),
          const SizedBox(height: 16),

          // 保险公积金（组件化）
          SettingsInsuranceSection(
            monthlyBaseSalary: monthlySalary,
            socialRate: data.socialInsuranceRate,
            housingRate: data.housingFundRate,
            onEdit: _showSettings,
          ),
          const SizedBox(height: 16),

          // 关于（组件化）
          const SettingsAboutCard(),
        ],
      ),
    );
  }
}
