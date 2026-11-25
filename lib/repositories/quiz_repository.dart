import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/quiz_models.dart';

class QuizRepository {
  QuizRepository({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  static const String assetPath = 'assets/data/aptitudequiz.json';

  final AssetBundle _bundle;
  List<QuizQuestion>? _cache;

  Future<List<QuizQuestion>> loadAll() async {
    if (_cache != null) return _cache!;
    final raw = await _bundle.loadString(assetPath);
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      throw const FormatException('aptitudequiz.json must be a JSON array');
    }
    _cache = decoded
        .whereType<Map<String, dynamic>>()
        .map(QuizQuestion.fromJson)
        .toList(growable: false);
    return _cache!;
  }
}
