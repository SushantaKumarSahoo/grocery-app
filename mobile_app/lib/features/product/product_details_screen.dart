import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_ext.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/product_card.dart';
import '../../core/widgets/qty_stepper.dart';
import '../../core/widgets/tappable.dart';
import '../../data/models/product.dart';
import '../../providers/cart_provider.dart';
import '../../providers/catalog_provider.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;
  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late double _qty;
  String? _packaging;
  bool _descriptionExpanded = false;
  bool _adding = false;
  final _notesCtrl = TextEditingController();
  late Future<List<Product>> _relatedFuture;

  @override
  void initState() {
    super.initState();
    _qty = widget.product.minOrderQty;
    final options = widget.product.packagingOptions;
    _packaging = options.isNotEmpty ? options.first : null;
    _relatedFuture = context
        .read<CatalogProvider>()
        .productsForCategory(widget.product.categoryName)
        .then((list) => list.where((p) => p.id != widget.product.id).take(10).toList());
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  double get _step => widget.product.unit.toLowerCase() == 'piece' ? 50 : 5;

  List<double> get _quickPicks {
    final moq = widget.product.minOrderQty;
    final picks = {moq, moq * 2, moq * 5};
    return picks.toList()..sort();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final total = p.price * _qty;
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 340,
            pinned: true,
            elevation: 0,
            backgroundColor: colors.bg,
            surfaceTintColor: Colors.transparent,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: _GlassButton(
                icon: Icons.arrow_back_rounded,
                onTap: () => context.pop(),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'product-image-${p.id}',
                    child: p.imageUrl.isEmpty
                        ? Container(
                            color: AppColors.primaryLight,
                            child: const Icon(Icons.inventory_2_rounded,
                                size: 72, color: AppColors.primary),
                          )
                        : Image.network(
                            p.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Container(
                              color: AppColors.primaryLight,
                              child: const Icon(Icons.image_not_supported_rounded,
                                  size: 72, color: AppColors.primary),
                            ),
                          ),
                  ),
                  // Scrim so the sheet below reads as a continuous surface.
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.55, 1.0],
                          colors: [
                            Colors.transparent,
                            colors.bg.withValues(alpha: 0.9),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colors.border,
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (p.categoryName.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: colors.isDark ? 0.22 : 0.10),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        p.categoryName.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.secondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          p.name,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: colors.textPrimary,
                            height: 1.15,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: (p.inStock ? AppColors.success : AppColors.error)
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: p.inStock ? AppColors.success : AppColors.error,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              p.inStock ? 'In Stock' : 'Out of Stock',
                              style: TextStyle(
                                color: p.inStock ? AppColors.success : AppColors.error,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: AppColors.heroGradient,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '₹${p.price.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 26,
                                ),
                              ),
                              TextSpan(
                                text: ' / ${p.unit}',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: const Text(
                            'BULK PRICING',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.06, end: 0),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _StatChip(
                        icon: Icons.inventory_2_outlined,
                        label: 'MOQ',
                        value: '${p.minOrderQty.toStringAsFixed(0)} ${p.unit}',
                        color: AppColors.secondary,
                        index: 0,
                      ),
                      const SizedBox(width: 10),
                      _StatChip(
                        icon: Icons.warehouse_outlined,
                        label: 'Stock',
                        value: '${p.stock.toStringAsFixed(0)} ${p.unit}',
                        color: AppColors.accent,
                        index: 1,
                      ),
                      const SizedBox(width: 10),
                      _StatChip(
                        icon: Icons.inventory_outlined,
                        label: 'Packs',
                        value: p.packagingOptions.isEmpty
                            ? '—'
                            : '${p.packagingOptions.length}',
                        color: AppColors.primary,
                        index: 2,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text('Description',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15, color: colors.textPrimary)),
                  const SizedBox(height: 8),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    alignment: Alignment.topLeft,
                    child: Text(
                      p.description,
                      maxLines: _descriptionExpanded ? null : 3,
                      overflow: _descriptionExpanded ? null : TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 13.5,
                        height: 1.55,
                      ),
                    ),
                  ),
                  if (p.description.length > 120)
                    GestureDetector(
                      onTap: () => setState(() => _descriptionExpanded = !_descriptionExpanded),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          _descriptionExpanded ? 'Show less' : 'Read more',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                    ),
                  if (p.packagingOptions.isNotEmpty) ...[
                    const SizedBox(height: 22),
                    Text('Packaging Options',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15, color: colors.textPrimary)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: p.packagingOptions.map((option) {
                        final selected = option == _packaging;
                        return Tappable(
                          onTap: () => setState(() => _packaging = option),
                          pressedScale: 0.94,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              gradient: selected ? AppColors.primaryGradient : null,
                              color: selected ? null : colors.bg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selected ? Colors.transparent : colors.border,
                              ),
                              boxShadow: selected
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primary.withValues(alpha: 0.3),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.inventory_2_rounded,
                                  size: 14,
                                  color: selected ? Colors.white : colors.textMuted,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  option,
                                  style: TextStyle(
                                    color: selected ? Colors.white : colors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.bg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Quantity',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: colors.textPrimary)),
                            QtyStepper(
                              value: _qty,
                              min: p.minOrderQty,
                              step: _step,
                              onChanged: (v) => setState(() => _qty = v),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _quickPicks.map((q) {
                            final selected = _qty == q;
                            return Tappable(
                              onTap: () => setState(() => _qty = q),
                              pressedScale: 0.94,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? AppColors.primary.withValues(alpha: 0.14)
                                      : colors.card,
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(
                                    color: selected ? AppColors.primary : colors.border,
                                  ),
                                ),
                                child: Text(
                                  '${q.toStringAsFixed(0)} ${p.unit}',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: selected ? AppColors.primary : colors.textSecondary,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text('Notes (optional)',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15, color: colors.textPrimary)),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: colors.bg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: colors.border),
                    ),
                    child: TextField(
                      controller: _notesCtrl,
                      maxLines: 3,
                      style: TextStyle(color: colors.textPrimary, fontSize: 13.5),
                      decoration: InputDecoration(
                        hintText: 'Any special requirement, e.g. brand preference...',
                        hintStyle: TextStyle(color: colors.textMuted, fontSize: 13),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  _RelatedProductsSection(future: _relatedFuture),
                  const SizedBox(height: 20),
                  _TrustFooter(colors: colors),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
        decoration: BoxDecoration(
          color: colors.card,
          boxShadow: [
            BoxShadow(
              color: colors.shadow,
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Subtotal',
                        style: TextStyle(fontSize: 11.5, color: colors.textMuted)),
                    Text(
                      '₹${total.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: PrimaryButton(
                  label: p.inStock ? 'Add to Bulk Order' : 'Out of Stock',
                  icon: Icons.add_shopping_cart_rounded,
                  loading: _adding,
                  onPressed: p.inStock
                      ? () async {
                          setState(() => _adding = true);
                          context.read<CartProvider>().addItem(
                                p,
                                _qty,
                                packaging: _packaging,
                                notes: _notesCtrl.text.trim(),
                              );
                          final messenger = ScaffoldMessenger.of(context);
                          final router = GoRouter.of(context);
                          await Future.delayed(220.ms);
                          if (!mounted) return;
                          messenger.showSnackBar(
                            SnackBar(
                              behavior: SnackBarBehavior.floating,
                              content: Text('${p.name} added to bulk order'),
                            ),
                          );
                          router.pop();
                        }
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _GlassButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.28),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final int index;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: colors.bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 15, color: color),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              label,
              style: TextStyle(fontSize: 9.5, color: colors.textMuted, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (80 * index).ms, duration: 280.ms)
        .slideY(begin: 0.15, end: 0, delay: (80 * index).ms, duration: 280.ms);
  }
}

class _RelatedProductsSection extends StatelessWidget {
  final Future<List<Product>> future;
  const _RelatedProductsSection({required this.future});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return FutureBuilder<List<Product>>(
      future: future,
      builder: (context, snapshot) {
        final items = snapshot.data ?? [];
        if (snapshot.connectionState != ConnectionState.done || items.isEmpty) {
          return const SizedBox.shrink();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You might also need',
                style: TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 15, color: colors.textPrimary)),
            const SizedBox(height: 12),
            SizedBox(
              height: 214,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, i) {
                  final p = items[i];
                  return SizedBox(
                    width: 148,
                    child: ProductCard(
                      product: p,
                      useHero: false,
                      onTap: () {
                        context.push('/product/${p.id}', extra: p);
                      },
                    ),
                  )
                      .animate()
                      .fadeIn(delay: (60 * i).ms, duration: 280.ms)
                      .slideX(begin: 0.1, end: 0, delay: (60 * i).ms, duration: 280.ms);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TrustFooter extends StatelessWidget {
  final SemanticColors colors;
  const _TrustFooter({required this.colors});

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.verified_user_outlined, 'Verified Supplier'),
      (Icons.request_quote_outlined, 'Transparent Quotation'),
      (Icons.local_shipping_outlined, 'Bulk Delivery'),
    ];
    return Row(
      children: items
          .map(
            (item) => Expanded(
              child: Column(
                children: [
                  Icon(item.$1, size: 20, color: colors.textMuted),
                  const SizedBox(height: 6),
                  Text(
                    item.$2,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10, color: colors.textMuted, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
