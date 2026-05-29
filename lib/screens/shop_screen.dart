import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../game/services/progress_service.dart';
import '../monetization/purchase_service.dart';
import '../utils/constants.dart';
import '../widgets/game_button.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProgressService progress = context.watch<ProgressService>();
    final PurchaseService purchaseService = PurchaseService();
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) {
          context.go('/menu');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Shop'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.go('/menu'),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(kPagePadding),
          children: <Widget>[
            _ShopCard(
              title: 'Remove Ads',
              subtitle: 'Placeholder price',
              trailing: const Text('\$1.99', style: TextStyle(color: kAccent, fontWeight: FontWeight.w800)),
              onPressed: () => purchaseService.buyRemoveAds(),
            ),
            const SizedBox(height: 12),
            _ShopCard(
              title: 'Coin Pack Small',
              subtitle: '100 coins',
              trailing: const Text('\$0.99', style: TextStyle(color: kAccent, fontWeight: FontWeight.w800)),
              onPressed: () => purchaseService.buyCoinPackSmall(),
            ),
            const SizedBox(height: 12),
            _ShopCard(
              title: 'Coin Pack Medium',
              subtitle: '500 coins',
              trailing: const Text('\$3.99', style: TextStyle(color: kAccent, fontWeight: FontWeight.w800)),
              onPressed: () => purchaseService.buyCoinPackMedium(),
            ),
            const SizedBox(height: 12),
            _ShopCard(
              title: 'Coin Pack Large',
              subtitle: '1200 coins',
              trailing: const Text('\$7.99', style: TextStyle(color: kAccent, fontWeight: FontWeight.w800)),
              onPressed: () => purchaseService.buyCoinPackLarge(),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: kSurface.withValues(alpha: 0.68),
                borderRadius: BorderRadius.circular(kCardRadius),
                border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
              ),
              child: const Opacity(
                opacity: 0.5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Coming Soon: Skins', style: TextStyle(color: kTextPrimary, fontWeight: FontWeight.w800)),
                    SizedBox(height: 8),
                    Text('Cosmetic themes and block skins.', style: TextStyle(color: kTextSecondary)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            GameButton(
              label: 'Restore Purchases',
              icon: Icons.restore_rounded,
              backgroundColor: kSurfaceLight,
              foregroundColor: kTextPrimary,
              onPressed: () => purchaseService.restorePurchases(),
            ),
            const SizedBox(height: 16),
            Text(
              'Coins available: ${progress.coins}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: kTextSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShopCard extends StatelessWidget {
  const _ShopCard({
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onPressed,
  });

  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(kCardRadius),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.shopping_bag_rounded, color: kAccent),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: const TextStyle(color: kTextPrimary, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: kTextSecondary)),
              ],
            ),
          ),
          trailing,
          const SizedBox(width: 12),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: kAccent,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: onPressed,
            child: const Text(
              'TODO',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
