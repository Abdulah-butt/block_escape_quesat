import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/level_model.dart';

class LevelLoader {
  LevelLoader._();

  static final LevelLoader instance = LevelLoader._();

  List<LevelModel> _levels = <LevelModel>[];
  String? _error;
  bool _loaded = false;

  List<LevelModel> get levels => List<LevelModel>.unmodifiable(_levels);
  String? get error => _error;
  bool get hasError => _error != null;

  Future<void> load() async {
    if (_loaded) {
      return;
    }
    try {
      final String raw = await rootBundle.loadString('data/levels.json');
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      _levels = decoded
          .map((dynamic item) => LevelModel.fromJson(item as Map<String, dynamic>))
          .toList(growable: false);
      final Box<dynamic> box = await Hive.openBox<dynamic>('levels_cache');
      await box.put('level_count', _levels.length);
      _error = null;
      _loaded = true;
    } catch (error) {
      _levels = <LevelModel>[];
      _error = 'Level unavailable, try again';
      _loaded = true;
    }
  }

  LevelModel? byId(int id) {
    for (final LevelModel level in _levels) {
      if (level.id == id) {
        return level;
      }
    }
    return null;
  }
}

