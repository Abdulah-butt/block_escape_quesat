import 'package:flutter/foundation.dart';

class AnalyticsService {
  const AnalyticsService();

  void logLevelStart(int levelId) =>
      debugPrint('[Analytics] level_start: $levelId');

  void logLevelComplete(int levelId, int moves, int stars) =>
      debugPrint('[Analytics] level_complete: id=$levelId moves=$moves stars=$stars');

  void logAdWatched(String adType, String placement) =>
      debugPrint('[Analytics] ad_watched: $adType at $placement');

  void logPurchaseStarted(String productId) =>
      debugPrint('[Analytics] purchase_started: $productId');

  void logPurchaseCompleted(String productId) =>
      debugPrint('[Analytics] purchase_completed: $productId');
}

