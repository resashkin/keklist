import 'package:keklist/domain/services/analytics/analytics.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:collection/collection.dart';
import 'package:material_ui/material_ui.dart';
import 'package:gap/gap.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:keklist/domain/constants.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:keklist/presentation/core/widgets/glass_capsule_button.dart';
import 'package:keklist/presentation/core/widgets/kek_bottom_sheet.dart';

const _kOfferingId = 'lifetime_offer';

/// One-time tips (consumables in App Store Connect and Google Play), shown with these prices until the store answers.
const List<(String, String)> _kTips = [
  ('keklist_tip_1', r'$1'),
  ('keklist_tip_10', r'$10'),
  ('keklist_tip_100', r'$100'),
];

// ---------------------------------------------------------------------------
// Plan model
// ---------------------------------------------------------------------------

enum _PlanType { monthly, annual, lifetime }

class _Plan {
  final _PlanType type;
  final String label;
  final Package? package;

  const _Plan({required this.type, required this.label, this.package});

  String get priceString => package?.storeProduct.priceString ?? '—';
  bool get available => package != null;
}

// ---------------------------------------------------------------------------
// Widget
// ---------------------------------------------------------------------------

final class PaywallBottomSheet extends StatefulWidget {
  /// Only the one-time tips, for people who already have Pro.
  final bool tipsOnly;

  const PaywallBottomSheet({super.key, this.tipsOnly = false});

  static Future<bool> show(BuildContext context, {bool tipsOnly = false}) async {
    Analytics.paywallShown(tipsOnly: tipsOnly);
    final result = await KekSheet.show<bool>(
      context: context,
      builder: (_) => PaywallBottomSheet(tipsOnly: tipsOnly),
    );
    return result ?? false;
  }

  @override
  State<PaywallBottomSheet> createState() => _PaywallBottomSheetState();
}

final class _PaywallBottomSheetState extends State<PaywallBottomSheet> {
  List<_Plan> _plans = const [
    _Plan(type: _PlanType.monthly, label: '30 DAYS'),
    _Plan(type: _PlanType.annual, label: '1 YEAR'),
    _Plan(type: _PlanType.lifetime, label: 'LIFETIME'),
  ];
  _Plan? _selected;
  bool _loading = true;
  bool _purchasing = false;
  String? _error;
  Map<String, StoreProduct> _tipProducts = const {};
  String? _buyingTipId;

  @override
  void initState() {
    super.initState();
    _loadOfferings();
    _loadTips();
  }

  Future<void> _loadTips() async {
    try {
      final List<StoreProduct> products = await Purchases.getProducts(
        [for (final (String id, _) in _kTips) id],
        productCategory: ProductCategory.nonSubscription,
      );
      if (mounted) setState(() => _tipProducts = {for (final StoreProduct product in products) product.identifier: product});
    } catch (_) {}
  }

  Future<void> _buyTip(StoreProduct product) async {
    setState(() => _buyingTipId = product.identifier);
    try {
      await Purchases.purchase(PurchaseParams.storeProduct(product));
      Analytics.tipPurchased(product.identifier);
      if (mounted) _showThanks();
    } on PurchasesError catch (e) {
      if (e.code != PurchasesErrorCode.purchaseCancelledError && mounted) _showError(e.message);
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _buyingTipId = null);
    }
  }

  void _showThanks() {
    Haptics.vibrate(HapticsType.success);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const AutoSizeText('💛', textAlign: TextAlign.center, style: TextStyle(fontSize: 44), maxLines: 1),
        content: const Text('Thank you for supporting keklist!', textAlign: TextAlign.center),
        actions: [TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('OK'))],
      ),
    );
  }

  Package? _find(List<Package> all, _PlanType type) => switch (type) {
    _PlanType.monthly => all.firstWhereOrNull((p) => p.packageType == PackageType.monthly),
    _PlanType.annual => all.firstWhereOrNull((p) => p.packageType == PackageType.annual),
    _PlanType.lifetime => all.firstWhereOrNull(
      (p) =>
          p.packageType == PackageType.lifetime ||
          p.identifier.toLowerCase().contains('lifetime') ||
          p.storeProduct.identifier.toLowerCase().contains('lifetime'),
    ),
  };

  Future<void> _loadOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      final offering = offerings.all[_kOfferingId] ?? offerings.current;
      final all = offering?.availablePackages ?? [];

      final plans = [
        _Plan(type: _PlanType.monthly, label: '30 DAYS', package: _find(all, _PlanType.monthly)),
        _Plan(type: _PlanType.annual, label: '1 YEAR', package: _find(all, _PlanType.annual)),
        _Plan(type: _PlanType.lifetime, label: 'LIFETIME', package: _find(all, _PlanType.lifetime)),
      ];

      setState(() {
        _plans = plans;
        _selected = plans.firstWhereOrNull((p) => p.available);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _purchase() async {
    final pkg = _selected?.package;
    if (pkg == null) return;
    setState(() => _purchasing = true);
    try {
      await Purchases.purchase(PurchaseParams.package(pkg));
      Analytics.proPurchased(pkg.storeProduct.identifier);
      if (mounted) Navigator.of(context).pop(true);
    } on PurchasesError catch (e) {
      if (e.code != PurchasesErrorCode.purchaseCancelledError && mounted) {
        _showError(e.message);
      }
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _purchasing = false);
    }
  }

  Future<void> _restore() async {
    setState(() => _purchasing = true);
    try {
      final info = await Purchases.restorePurchases();
      if (mounted) {
        if (info.entitlements.active.isNotEmpty) {
          Navigator.of(context).pop(true);
        } else {
          _showError('No active subscriptions found.');
        }
      }
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _purchasing = false);
    }
  }

  void _showError(String message) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        content: AutoSizeText(message, maxLines: 3),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const AutoSizeText('OK', maxLines: 1),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTips(ThemeData theme, {required String title}) => [
    AutoSizeText(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600), maxLines: 1),
    const Gap(4),
    AutoSizeText(
      'A one-time tip',
      style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant),
      maxLines: 1,
    ),
    const Gap(12),
    Row(
      spacing: 12,
      children: [
        for (final (String id, String fallbackPrice) in _kTips)
          Expanded(
            child: _TipCard(
              price: _tipProducts[id]?.priceString ?? fallbackPrice,
              isBuying: _buyingTipId == id,
              onTap: _tipProducts[id] == null || _buyingTipId != null || _purchasing
                  ? null
                  : () => _buyTip(_tipProducts[id]!),
            ),
          ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (widget.tipsOnly) {
      return KekSheetScaffold(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AutoSizeText('💛', style: TextStyle(fontSize: 48), maxLines: 1),
              const Gap(12),
              ..._buildTips(theme, title: 'Support keklist'),
            ],
          ),
        ),
      );
    }
    return KekSheetScaffold(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AutoSizeText('🤝', style: TextStyle(fontSize: 48), maxLines: 1),
                  const Gap(12),
                  const AutoSizeText(
                    'keklist PRO',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    maxLines: 1,
                  ),
                  const Gap(8),
                  AutoSizeText(
                    'Unlock all features',
                    style: TextStyle(fontSize: 15, color: theme.colorScheme.onSurfaceVariant),
                    maxLines: 1,
                  ),
                    const Gap(8),
                    const Gap(12),
                    const _FeatureList(),
                    const Gap(28),
                    if (_loading)
                      const CircularProgressIndicator()
                    else if (_error != null)
                      AutoSizeText(_error!, style: const TextStyle(color: Colors.redAccent), maxLines: 3)
                    else ...[
                      Row(
                        spacing: 12,
                        children: _plans.map((plan) {
                          final isSelected = _selected == plan;
                          return Expanded(
                            child: _PlanCard(
                              plan: plan,
                              isSelected: isSelected,
                              onTap: plan.available
                                  ? () {
                                      Haptics.vibrate(HapticsType.light);
                                      setState(() => _selected = plan);
                                    }
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                      const Gap(20),
                      GlassCapsuleButton(
                        height: 52,
                        isExpanded: true,
                        onTap: (_purchasing || _selected?.available != true) ? null : _purchase,
                        child: _purchasing
                            ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : AutoSizeText(
                                _selected != null ? 'Subscribe · ${_selected!.priceString}' : 'Subscribe',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                maxLines: 1,
                              ),
                      ),
                      const Gap(24),
                      GestureDetector(
                        onTap: _purchasing ? null : _restore,
                        child: AutoSizeText(
                          'Restore purchases',
                          style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant),
                          maxLines: 1,
                        ),
                      ),
                      const Gap(16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _LegalLink(label: 'Privacy Policy', url: KeklistConstants.privacyURL),
                          AutoSizeText(
                            '  ·  ',
                            style: TextStyle(fontSize: 12, color: theme.colorScheme.outlineVariant),
                            maxLines: 1,
                          ),
                          _LegalLink(label: 'Terms of Use', url: KeklistConstants.termsOfUseURL),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
    );
  }
}

// ---------------------------------------------------------------------------
// Feature list
// ---------------------------------------------------------------------------

class _FeatureList extends StatelessWidget {
  const _FeatureList();

  @override
  Widget build(BuildContext context) {
    const features = [
      ('☀️', 'weather per each day'),
      ('☁️', 'access to online features'),
      ('🙂', 'support our project'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: features
          .map(
            (f) => Row(
              children: [
                AutoSizeText(f.$1, style: const TextStyle(fontSize: 16), maxLines: 1),
                const SizedBox(width: 10),
                AutoSizeText(
                  f.$2,
                  style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  maxLines: 1,
                ),
              ],
            ),
          )
          .toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// Plan card
// ---------------------------------------------------------------------------

class _PlanCard extends StatelessWidget {
  final _Plan plan;
  final bool isSelected;
  final VoidCallback? onTap;

  const _PlanCard({required this.plan, required this.isSelected, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // The selected card gets a full-strength border and a tint; the others only a faint hairline.
    final borderColor = isSelected ? cs.onSurface : cs.onSurface.withValues(alpha: 0.12);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: isSelected ? cs.onSurface.withValues(alpha: 0.06) : null,
          border: Border.all(color: borderColor, width: isSelected ? 2.5 : 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: AspectRatio(
          aspectRatio: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AutoSizeText(
                plan.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: isSelected ? cs.onSurface : cs.onSurfaceVariant,
                ),
                maxLines: 1,
              ),
              const Gap(8),
              AutoSizeText(
                plan.priceString,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? cs.onSurface : cs.onSurfaceVariant,
                ),
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A one-time tip: a heart and the price; it buys at once on tap.
class _TipCard extends StatelessWidget {
  final String price;
  final bool isBuying;
  final VoidCallback? onTap;

  const _TipCard({required this.price, required this.isBuying, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Opacity(
      opacity: onTap == null && !isBuying ? 0.45 : 1.0,
      child: Material(
        color: cs.onSurface.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 72,
            child: isBuying
                ? const Center(child: SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2)))
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const AutoSizeText('💛', style: TextStyle(fontSize: 20), maxLines: 1),
                      const Gap(4),
                      AutoSizeText(price, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold), maxLines: 1),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _LegalLink extends StatelessWidget {
  final String label;
  final String url;

  const _LegalLink({required this.label, required this.url});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
      child: AutoSizeText(
        label,
        style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.outline),
        maxLines: 1,
      ),
    );
  }
}
