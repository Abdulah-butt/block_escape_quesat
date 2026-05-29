import 'package:upgrader/upgrader.dart';

class UpdateService {
  UpdateService._();

  static final UpdateService instance = UpdateService._();

  final Upgrader upgrader = Upgrader(
    durationUntilAlertAgain: Duration.zero,
    debugDisplayAlways: false,
    debugLogging: false,
  );

  Future<void> initialize() async {
    await upgrader.initialize();
  }
}
