import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:upgrader/upgrader.dart';

import '../analytics/analytics_service.dart';
import '../app/router.dart';
import '../app/theme.dart';
import '../game/services/game_state_service.dart';
import '../game/services/level_loader.dart';
import '../game/services/progress_service.dart';
import '../monetization/update_service.dart';
import '../utils/constants.dart';

class BlockEscapeQuestApp extends StatelessWidget {
  const BlockEscapeQuestApp({
    super.key,
    required this.progressService,
    required this.updateService,
  });

  final ProgressService progressService;
  final UpdateService updateService;

  @override
  Widget build(BuildContext context) {
    final GoRouter router = AppRouter.create();
    return MultiProvider(
      providers: <SingleChildWidget>[
        ChangeNotifierProvider<ProgressService>.value(value: progressService),
        ChangeNotifierProvider<GameStateService>(
          create: (BuildContext context) => GameStateService(
            levelLoader: LevelLoader.instance,
            progressService: progressService,
            analyticsService: const AnalyticsService(),
          ),
        ),
      ],
      child: MaterialApp.router(
        title: kGameTitle,
        theme: AppTheme.darkTheme(),
        routerConfig: router,
        debugShowCheckedModeBanner: false,
        builder: (BuildContext context, Widget? child) {
          return UpgradeAlert(
            upgrader: updateService.upgrader,
            navigatorKey: AppRouter.navigatorKey,
            barrierDismissible: false,
            showIgnore: false,
            showLater: false,
            shouldPopScope: () => false,
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}
