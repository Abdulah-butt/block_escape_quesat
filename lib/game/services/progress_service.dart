import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProgressService extends ChangeNotifier {
  ProgressService();

  static const String _kCoins = 'coins';
  static const String _kSound = 'sound_enabled';
  static const String _kMusic = 'music_enabled';
  static const String _kVibration = 'vibration_enabled';
  static const String _kHighestUnlocked = 'highest_unlocked_level';
  static const String _kStarsMap = 'stars_map';
  static const String _kLastPlayed = 'last_played_level';
  static const String _kCompletions = 'total_completions';

  SharedPreferences? _prefs;
  int _coins = 0;
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  bool _vibrationEnabled = true;
  int _highestUnlockedLevel = 1;
  int _lastPlayedLevelId = 1;
  int _totalCompletions = 0;
  final Map<int, int> _starsByLevel = <int, int>{};

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _coins = _prefs!.getInt(_kCoins) ?? 0;
    _soundEnabled = _prefs!.getBool(_kSound) ?? true;
    _musicEnabled = _prefs!.getBool(_kMusic) ?? true;
    _vibrationEnabled = _prefs!.getBool(_kVibration) ?? true;
    _highestUnlockedLevel = _prefs!.getInt(_kHighestUnlocked) ?? 1;
    _lastPlayedLevelId = _prefs!.getInt(_kLastPlayed) ?? 1;
    _totalCompletions = _prefs!.getInt(_kCompletions) ?? 0;
    final String? rawStars = _prefs!.getString(_kStarsMap);
    if (rawStars != null && rawStars.isNotEmpty) {
      final Map<String, dynamic> decoded =
          jsonDecode(rawStars) as Map<String, dynamic>;
      decoded.forEach((String key, dynamic value) {
        _starsByLevel[int.parse(key)] = (value as num).toInt();
      });
    }
    notifyListeners();
  }

  int get coins => _coins;
  bool get soundEnabled => _soundEnabled;
  bool get musicEnabled => _musicEnabled;
  bool get vibrationEnabled => _vibrationEnabled;
  int get highestUnlockedLevel => _highestUnlockedLevel;
  int get lastPlayedLevelId => _lastPlayedLevelId;
  int get totalCompletions => _totalCompletions;

  int starsForLevel(int levelId) => _starsByLevel[levelId] ?? 0;
  bool isLevelUnlocked(int levelId) => levelId <= _highestUnlockedLevel;

  Future<void> setSoundEnabled(bool value) async {
    _soundEnabled = value;
    await _prefs?.setBool(_kSound, value);
    notifyListeners();
  }

  Future<void> setMusicEnabled(bool value) async {
    _musicEnabled = value;
    await _prefs?.setBool(_kMusic, value);
    notifyListeners();
  }

  Future<void> setVibrationEnabled(bool value) async {
    _vibrationEnabled = value;
    await _prefs?.setBool(_kVibration, value);
    notifyListeners();
  }

  Future<void> setLastPlayedLevel(int levelId) async {
    _lastPlayedLevelId = levelId;
    await _prefs?.setInt(_kLastPlayed, levelId);
  }

  Future<void> addCoins(int value) async {
    _coins = (_coins + value).clamp(0, 999999).toInt();
    await _prefs?.setInt(_kCoins, _coins);
    notifyListeners();
  }

  Future<void> spendCoins(int value) async {
    _coins = (_coins - value).clamp(0, 999999).toInt();
    await _prefs?.setInt(_kCoins, _coins);
    notifyListeners();
  }

  Future<void> completeLevel(int levelId, int stars, int earnedCoins) async {
    final int currentStars = _starsByLevel[levelId] ?? 0;
    if (stars > currentStars) {
      _starsByLevel[levelId] = stars;
    }
    if (levelId >= _highestUnlockedLevel) {
      _highestUnlockedLevel = levelId + 1;
    }
    _totalCompletions++;
    _coins = (_coins + earnedCoins).clamp(0, 999999).toInt();
    await _prefs?.setInt(_kHighestUnlocked, _highestUnlockedLevel);
    await _prefs?.setInt(_kCompletions, _totalCompletions);
    await _prefs?.setInt(_kCoins, _coins);
    await _prefs?.setString(_kStarsMap, jsonEncode(_starsByLevel.map((int key, int value) => MapEntry<String, int>(key.toString(), value))));
    await _prefs?.setInt(_kLastPlayed, levelId);
    notifyListeners();
  }
}
