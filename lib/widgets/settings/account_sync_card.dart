import 'package:flutter/material.dart';

/// 账户与云同步卡片：显示登录状态，提供登录/退出与上传/下载按钮。
class AccountSyncCard extends StatelessWidget {
  final bool isLoggedIn;
  final String? email;
  final VoidCallback onLoginTap;
  final VoidCallback onLogoutTap;
  final VoidCallback onSyncDownTap;
  final VoidCallback onSyncUpTap;

  const AccountSyncCard({
    super.key,
    required this.isLoggedIn,
    required this.email,
    required this.onLoginTap,
    required this.onLogoutTap,
    required this.onSyncDownTap,
    required this.onSyncUpTap,
  });

  /// 构建组件 UI。
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('账户与云同步', style: Theme.of(context).textTheme.titleLarge),
          ),
          if (isLoggedIn)
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: Text(email ?? ''),
              subtitle: const Text('已登录'),
              trailing: TextButton(onPressed: onLogoutTap, child: const Text('退出登录')),
            )
          else
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('未登录'),
              subtitle: const Text('登录后可启用云同步'),
              trailing: TextButton(onPressed: onLoginTap, child: const Text('登录')),
            ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('手动同步'),
                Wrap(
                  spacing: 8,
                  children: [
                    OutlinedButton(onPressed: isLoggedIn ? onSyncDownTap : null, child: const Text('下载')),
                    FilledButton(onPressed: isLoggedIn ? onSyncUpTap : null, child: const Text('上传')),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

