class SettingsPage extends StatelessWidget {
  final Function(String) onThemeChanged;
  final String selectedTheme; // 👈 اضافه شد

  const SettingsPage({
    super.key,
    required this.onThemeChanged,
    required this.selectedTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تنظیمات')),
      body: Column(
        children: [
          ListTile(
            title: const Text('ظاهر کودکانه'),
            leading: Radio<String>(
              value: kidThemeKey,
              groupValue: selectedTheme,
              onChanged: (val) {
                if (val != null) onThemeChanged(val);
              },
            ),
          ),
          ListTile(
            title: const Text('ظاهر بزرگسال'),
            leading: Radio<String>(
              value: adultThemeKey,
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
