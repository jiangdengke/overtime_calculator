import 'package:flutter/material.dart';

/// 设置页：关于卡片。
class SettingsAboutCard extends StatelessWidget {
  const SettingsAboutCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('关于', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          ),
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('版本'),
            subtitle: Text('1.0.7'),
          ),
          ListTile(
            leading: Icon(Icons.description_outlined),
            title: Text('说明'),
            subtitle: Text('记录加班工时，计算加班费用和月度薪资'),
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }
}
