import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  final Function(String) onThemeChanged;
  final String? selectedTheme; // 👈 اضافه شد برای حفظ حالت انتخاب

  const SettingsPage({
    required this.onThemeChanged,
    this.selectedTheme, // 👈 اضافه شد
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('تنظیمات')),
      body: Column(
        children: [
          ListTile(
            title: Text('ظاهر کودکانه'),
            leading: Radio<String>(
              value: 'kid',
              groupValue: selectedTheme, // 👈 اصلاح شد
              onChanged: (val) {
                if (val != null) onThemeChanged(val);
              },
            ),
          ),
          ListTile(
            title: Text('ظاهر بزرگسال'),
            leading: Radio<String>(
              value: 'adult',
              groupValue: selectedTheme, // 👈 اصلاح شد
              onChanged: (val) {
                if (val != null) onThemeChanged(val);
              },
            ),
          ),
        ],
      ),
    );
  }
}
