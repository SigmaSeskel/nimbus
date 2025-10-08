import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends ChangeNotifier {
  static const _k = 'themeMode';
  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;

  ThemeNotifier() { _load(); }

  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    final v = sp.getString(_k);
    _mode = switch (v) { 'dark' => ThemeMode.dark, 'light' => ThemeMode.light, _ => ThemeMode.system };
    notifyListeners();
  }

  Future<void> set(ThemeMode m) async {
    _mode = m;
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_k, m == ThemeMode.dark ? 'dark' : m == ThemeMode.light ? 'light' : 'system');
    notifyListeners();
  }
}
