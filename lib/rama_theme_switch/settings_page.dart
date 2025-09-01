import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  final Function(String) onThemeChanged;
  final String selectedTheme;

  const SettingsPage({
    super.key,
    required this.onThemeChanged,
    this.selectedTheme = 'kid', // مقدار پیش‌فرض
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'تنظیمات',
          style: TextStyle(fontFamily: 'B-Koodak'), // فونت فارسی
        ),
      ),
      body: Column(
        children: [
          ListTile(
            title: const Text(
              'ظاهر کودکانه',
              style: TextStyle(fontFamily: 'B-Koodak'),
            ),
            leading: Radio<String>(
              value: 'kid',
              groupValue: selectedTheme,
              onChanged: (val) {
                if (val != null) onThemeChanged(val);
              },
            ),
          ),
          ListTile(
            title: const Text(
              'ظاهر بزرگسال',
              style: TextStyle(fontFamily: 'B-Koodak'),
            ),
            leading: Radio<String>(
              value: 'adult',
              groupValue: selectedTheme,
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
