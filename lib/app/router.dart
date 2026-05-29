import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../screens/game_screen.dart';
import '../screens/level_select_screen.dart';
import '../screens/main_menu_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/shop_screen.dart';
import '../screens/splash_screen.dart';

class AppRouter {
  const AppRouter._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static GoRouter create() {
    return GoRouter(
      navigatorKey: navigatorKey,
      initialLocation: '/',
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          name: 'splash',
          builder: (BuildContext context, GoRouterState state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/menu',
          name: 'menu',
          builder: (BuildContext context, GoRouterState state) => const MainMenuScreen(),
        ),
        GoRoute(
          path: '/levels',
          name: 'levels',
          builder: (BuildContext context, GoRouterState state) => const LevelSelectScreen(),
        ),
        GoRoute(
          path: '/game',
          name: 'game',
          builder: (BuildContext context, GoRouterState state) {
            final int levelId = int.tryParse(state.uri.queryParameters['level'] ?? '') ?? 1;
            return GameScreen(levelId: levelId);
          },
        ),
        GoRoute(
          path: '/settings',
          name: 'settings',
          builder: (BuildContext context, GoRouterState state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/shop',
          name: 'shop',
          builder: (BuildContext context, GoRouterState state) => const ShopScreen(),
        ),
      ],
    );
  }
}
