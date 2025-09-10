import 'package:flutter/material.dart';

/// 邮箱登录对话框（本地占位登录）。
class EmailLoginDialog extends StatefulWidget {
  /// 确认回调，返回输入的邮箱（非空才有效）。
  final void Function(String email) onConfirm;

  const EmailLoginDialog({super.key, required this.onConfirm});

  @override
  State<EmailLoginDialog> createState() => _EmailLoginDialogState();
}

class _EmailLoginDialogState extends State<EmailLoginDialog> {
  final TextEditingController _controller = TextEditingController();

  /// 构建对话框 UI
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('登录'),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(
          labelText: '邮箱（本地占位登录）',
          hintText: '请输入邮箱',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () {
            final email = _controller.text.trim();
            if (email.isNotEmpty) {
              widget.onConfirm(email);
              Navigator.pop(context);
            }
          },
          child: const Text('确认'),
        ),
      ],
    );
  }
}

