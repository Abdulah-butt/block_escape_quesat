import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/app.dart';
import 'game/services/level_loader.dart';
import 'game/services/progress_service.dart';
import 'monetization/update_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  final ProgressService progressService = ProgressService();
  await progressService.init();
  await LevelLoader.instance.load();
  await UpdateService.instance.initialize();

  runApp(
    BlockEscapeQuestApp(
      progressService: progressService,
      updateService: UpdateService.instance,
    ),
  );
}
