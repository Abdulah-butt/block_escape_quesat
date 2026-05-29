import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../analytics/analytics_service.dart';
import '../app/router.dart';
import '../app/theme.dart';
import '../game/services/game_state_service.dart';
import '../game/services/level_loader.dart';
import '../game/services/progress_service.dart';
import '../utils/constants.dart';

class BlockEscapeQuestApp extends StatelessWidget {
  const BlockEscapeQuestApp({
    super.key,
    required this.progressService,
  });

  final ProgressService progressService;

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
        builder: (BuildContext context, Widget? child) => child ?? const SizedBox.shrink(),
      ),
    );
  }
}
