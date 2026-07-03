import 'package:flutter/material.dart';
import 'package:pasar_malam/core/routes/app_router.dart';
import 'package:pasar_malam/features/auth/presentation/providers/auth_provider.dart';
import 'package:pasar_malam/features/cart/presentation/providers/cart_provider.dart';
import 'package:pasar_malam/features/dashboard/data/models/product_model.dart';
import 'package:pasar_malam/features/dashboard/presentation/providers/product_provider.dart';
import 'package:pasar_malam/features/order/presentation/providers/order_provider.dart';
import 'package:pasar_malam/features/profile/presentation/pages/profile_page.dart';
import 'package:provider/provider.dart';
import 'package:pasar_malam/features/favorite/presentation/providers/favorite_provider.dart';
import 'package:pasar_malam/features/favorite/presentation/pages/favorite_page.dart';

// ── Design tokens ──────────────────────────────────────────────────────────
// Palet oren gemas, otomatis nyesuain terang/gelap.
// Semua ukuran spasi/radius dipusatkan di sini biar tampilan konsisten.
class _Cute {
  final bool isDark;
  const _Cute(this.isDark);

  factory _Cute.of(BuildContext context) =>
      _Cute(Theme.of(context).brightness == Brightness.dark);

  // Latar
  Color get bg => isDark ? const Color(0xFF121212) : const Color(0xFFFFF7EF);
  Color get surface => isDark ? const Color(0xFF2C2C2C) : Colors.white;

  // Aksen lembut (badge, border kartu, dsb)
  Color get peach => isDark ? const Color(0xFF3A2A1E) : const Color(0xFFFFE8D6);
  Color get border => isDark ? const Color(0xFF4A3826) : const Color(0xFFFFE8D6);

  // Teks
  Color get textPrimary => isDark ? const Color(0xFFEEEEEE) : const Color(0xFF3B2A20);
  Color get textSecondary => isDark ? const Color(0xFFAAAAAA) : Colors.black54;
  Color get textHint => isDark ? const Color(0xFF888888) : Colors.black38;

  // Oren utama — tetap konsisten di dua mode biar brand-nya kebaca
  Color get orange => const Color(0xFFFF7A29);
  Color get orangeDeep => isDark ? const Color(0xFFFFA35C) : const Color(0xFFE85D04);
  Color get yellowAccent => const Color(0xFFFFC15E);

  Color get shadow => isDark
      ? Colors.black.withValues(alpha: 0.35)
      : const Color(0xFFFF7A29).withValues(alpha: 0.10);

  // Radius & spacing baku
  static const double radiusSm = 14;
  static const double radiusMd = 20;
  static const double radiusLg = 28;
  static const double gapSm = 8;
  static const double gapMd = 16;
  static const double gapLg = 24;

  // Shadow tipis, dipakai buat elemen kecil (chip, tombol ikon)
  List<BoxShadow> get cardShadow => [
        BoxShadow(color: shadow, blurRadius: 8, offset: const Offset(0, 2)),
      ];

  // Shadow super halus, khusus buat product card biar keliatan clean
  List<BoxShadow> get softShadow => [
        BoxShadow(color: shadow, blurRadius: 12, offset: const Offset(0, 4)),
      ];
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedNav = 0;
  String _selectedCategory = 'All';
  final _searchCtrl = TextEditingController();

  static const String _storeLogoUrl =
      'https://i.ibb.co.com/0VWk0BDJ/36581ebf-d1b2-4e22-8d18-b6b19368c6f3-removebg-preview.png';
  static const String _bannerUrl =
      'https://i.ibb.co.com/HDDrPZQW/82bc395f-954b-4c0f-a201-d934ac4a42da.png';

  final List<_CategoryItem> _categories = const [
    _CategoryItem(label: 'All', icon: Icons.apps_rounded),
    _CategoryItem(label: 'Ransel', icon: Icons.backpack_rounded),
    _CategoryItem(label: 'Selempang', icon: Icons.shopping_bag_outlined),
    _CategoryItem(label: 'Tote', icon: Icons.shopping_bag_rounded),
    _CategoryItem(label: 'Pinggang', icon: Icons.style_rounded),
    _CategoryItem(label: 'Laptop', icon: Icons.laptop_mac_rounded),
    _CategoryItem(label: 'Travel', icon: Icons.card_travel_rounded),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts();
      context.read<CartProvider>().fetchCart();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<ProductModel> _filteredProducts(List<ProductModel> products) {
    final query = _searchCtrl.text.toLowerCase();
    return products.where((p) {
      final matchCategory = _selectedCategory == 'All' ||
          p.category.toLowerCase() == _selectedCategory.toLowerCase();
      final matchSearch = query.isEmpty ||
          p.name.toLowerCase().contains(query) ||
          p.category.toLowerCase().contains(query);
      return matchCategory && matchSearch;
    }).toList();
  }

  String _formatPrice(double price) {
    final str = price.toInt().toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
      count++;
    }
    return 'Rp ${buffer.toString().split('').reversed.join()}';
  }

  void _openCart() {
    Navigator.pushNamed(context, AppRouter.cart).then((_) {
      if (mounted) context.read<CartProvider>().fetchCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProv = context.watch<ProductProvider>();
    final cute = _Cute.of(context);

    // Memastikan OrderProvider ikut ter-watch tanpa dipakai langsung di sini.
    context.watch<OrderProvider>();

    return Scaffold(
      backgroundColor: cute.bg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                color: cute.orange,
                onRefresh: () => productProv.fetchProducts(),
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        // Sedikit ditambah jarak atas biar logo & nama toko turun dikit
                        padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
                        child: _StoreHeader(
                          logoUrl: _storeLogoUrl,
                          onCartTap: _openCart,
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, _Cute.gapMd, 16, _Cute.gapSm + 4),
                        child: _SearchBar(
                          controller: _searchCtrl,
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: _BannerCard(imageUrl: _bannerUrl),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, _Cute.gapLg, 16, 0),
                        child: _SectionHeader(
                          title: 'Kategori',
                          actionLabel: 'Lihat Semua',
                          onAction: () {},
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 44,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _categories.length,
                          separatorBuilder: (ctx, idx) => const SizedBox(width: 10),
                          itemBuilder: (_, i) {
                            final cat = _categories[i];
                            return _CategoryChip(
                              item: cat,
                              selected: _selectedCategory == cat.label,
                              onTap: () => setState(() => _selectedCategory = cat.label),
                            );
                          },
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, _Cute.gapLg, 16, 12),
                        child: Text(
                          'Buat Kamu',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: cute.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    switch (productProv.status) {
                      ProductStatus.loading || ProductStatus.initial => SliverFillRemaining(
                          child: Center(
                            child: CircularProgressIndicator(color: cute.orange),
                          ),
                        ),
                      ProductStatus.error => SliverFillRemaining(
                          child: _ErrorState(
                            message: productProv.error ?? 'Aduh, ada yang salah nih',
                            onRetry: () => productProv.fetchProducts(),
                          ),
                        ),
                      ProductStatus.loaded => () {
                          final items = _filteredProducts(productProv.products);
                          if (items.isEmpty) {
                            return const SliverFillRemaining(child: _EmptyState());
                          }
                          return SliverPadding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                            sliver: SliverGrid(
                              delegate: SliverChildBuilderDelegate(
                                (_, i) => _ProductCard(
                                  product: items[i],
                                  formatPrice: _formatPrice,
                                ),
                                childCount: items.length,
                              ),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.62,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                            ),
                          );
                        }(),
                    },
                  ],
                ),
              ),
            ),
            _BottomNav(
              selectedIndex: _selectedNav,
              onTap: (i) {
                switch (i) {
                  case 1:
                    _openCart();
                    break;
                  case 2:
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FavoritePage()),
                    );
                    break;
                  case 3:
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfilePage()),
                    );
                    break;
                  default:
                    setState(() => _selectedNav = i);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Store header ────────────────────────────────────────────────────────────
class _StoreHeader extends StatelessWidget {
  final String logoUrl;
  final VoidCallback onCartTap;
  const _StoreHeader({required this.logoUrl, required this.onCartTap});

  @override
  Widget build(BuildContext context) {
    final cute = _Cute.of(context);

    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(_Cute.radiusSm),
          child: Image.network(
            logoUrl,
            width: 46,
            height: 46,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return SizedBox(
                width: 46,
                height: 46,
                child: Center(
                  child: CircularProgressIndicator(strokeWidth: 2, color: cute.orange),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) => Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: cute.peach,
                borderRadius: BorderRadius.circular(_Cute.radiusSm),
              ),
              child: Icon(Icons.shopping_bag_rounded, color: cute.orangeDeep, size: 22),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tas Lucu Store',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: cute.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'Tas lucu buat semua gaya kamu',
                style: TextStyle(fontSize: 12, color: cute.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // Cart & notifikasi didekatkan jadi satu grup di kanan
        _CartButton(cute: cute, onTap: onCartTap),
        const SizedBox(width: 8),
        _NotificationButton(cute: cute),
      ],
    );
  }
}

class _CartButton extends StatelessWidget {
  final _Cute cute;
  final VoidCallback onTap;
  const _CartButton({required this.cute, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final itemCount = context.watch<CartProvider>().itemCount;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: cute.surface,
          shape: BoxShape.circle,
          border: Border.all(color: cute.border, width: 1.5),
          boxShadow: cute.cardShadow,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 20, color: cute.orangeDeep),
            if (itemCount > 0)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  decoration: BoxDecoration(
                    color: cute.orangeDeep,
                    shape: BoxShape.circle,
                    border: Border.all(color: cute.surface, width: 1.5),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    itemCount > 9 ? '9+' : '$itemCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  final _Cute cute;
  const _NotificationButton({required this.cute});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: cute.surface,
          shape: BoxShape.circle,
          border: Border.all(color: cute.border, width: 1.5),
          boxShadow: cute.cardShadow,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Icon(Icons.notifications_outlined, size: 20, color: cute.orangeDeep),
            Positioned(
              top: 8,
              right: 9,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: cute.surface, width: 1.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Search bar ───────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cute = _Cute.of(context);

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: cute.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cute.border, width: 1.5),
        boxShadow: cute.cardShadow,
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: TextStyle(color: cute.textPrimary),
        decoration: InputDecoration(
          hintText: 'Cari tas favoritmu...',
          hintStyle: TextStyle(color: cute.textHint, fontSize: 14),
          prefixIcon: Icon(Icons.search_rounded, color: cute.orange, size: 22),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  icon: Icon(Icons.close_rounded, color: cute.textHint, size: 18),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 13),
        ),
      ),
    );
  }
}

// ── Banner ───────────────────────────────────────────────────────────────
class _BannerCard extends StatelessWidget {
  final String imageUrl;
  const _BannerCard({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final cute = _Cute.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(_Cute.radiusMd + 4),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Image.network(
          imageUrl,
          width: double.infinity,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: cute.peach,
              alignment: Alignment.center,
              child: CircularProgressIndicator(color: cute.orange),
            );
          },
          errorBuilder: (context, error, stackTrace) => Container(
            color: cute.peach,
            alignment: Alignment.center,
            child: Icon(Icons.broken_image_rounded, size: 40, color: cute.orangeDeep),
          ),
        ),
      ),
    );
  }
}

// ── Section header (reused for "Kategori" etc.) ──────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final cute = _Cute.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: cute.textPrimary),
        ),
        TextButton(
          onPressed: onAction,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            actionLabel,
            style: TextStyle(color: cute.orangeDeep, fontWeight: FontWeight.w700, fontSize: 13),
          ),
        ),
      ],
    );
  }
}

// ── Category chip ────────────────────────────────────────────────────────
class _CategoryChip extends StatelessWidget {
  final _CategoryItem item;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({required this.item, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cute = _Cute.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? cute.orange : cute.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: selected ? cute.orange : cute.border, width: 1.5),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: cute.orange.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : const [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(item.icon, size: 16, color: selected ? Colors.white : cute.orangeDeep),
            const SizedBox(width: 6),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : cute.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty / error states ─────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final cute = _Cute.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded, size: 40, color: cute.textHint),
          const SizedBox(height: 8),
          Text('Produk tidak ditemukan', style: TextStyle(color: cute.textSecondary)),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final cute = _Cute.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline_rounded, size: 36, color: cute.orangeDeep),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w600, color: cute.textPrimary),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: cute.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Coba Lagi'),
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}

// ── Product card ─────────────────────────────────────────────────────────
// Didesain ulang biar lebih clean: shadow lebih tipis, tanpa border tebal,
// spacing lebih rapi, dan hierarki teks yang lebih jelas.
class _ProductCard extends StatelessWidget {
  final ProductModel product;
  final String Function(double) formatPrice;

  const _ProductCard({required this.product, required this.formatPrice});

  void _showProductDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(_Cute.radiusLg)),
      ),
      builder: (_) => _ProductDetailSheet(product: product, formatPrice: formatPrice),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = product;
    final cute = _Cute.of(context);

    return GestureDetector(
      onTap: () => _showProductDetail(context),
      child: Container(
        decoration: BoxDecoration(
          color: cute.surface,
          borderRadius: BorderRadius.circular(_Cute.radiusMd),
          boxShadow: cute.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(_Cute.radiusMd),
                    ),
                    child: p.imageUrl.isNotEmpty
                        ? Image.network(
                            p.imageUrl,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, stack) => _imagePlaceholder(cute),
                          )
                        : _imagePlaceholder(cute),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Consumer<FavoriteProvider>(
                      builder: (context, favProv, _) {
                        final isFav = favProv.isFavorite(p.id);
                        return GestureDetector(
                          onTap: () => favProv.toggle(p),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              size: 15,
                              color: isFav ? Colors.red : cute.textHint,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    left: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        p.category,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: cute.orangeDeep,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      p.name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: cute.textPrimary,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        Icon(Icons.star_rounded, size: 14, color: cute.yellowAccent),
                        const SizedBox(width: 2),
                        Text('4.6', style: TextStyle(fontSize: 11, color: cute.textSecondary)),
                      ],
                    ),
                    Text(
                      formatPrice(p.price),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: cute.orangeDeep,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder(_Cute cute) => Container(
        width: double.infinity,
        height: double.infinity,
        color: cute.peach,
        child: const Center(child: Text('🍡', style: TextStyle(fontSize: 32))),
      );
}

// ── Product detail sheet ─────────────────────────────────────────────────
class _ProductDetailSheet extends StatefulWidget {
  final ProductModel product;
  final String Function(double) formatPrice;

  const _ProductDetailSheet({required this.product, required this.formatPrice});

  @override
  State<_ProductDetailSheet> createState() => _ProductDetailSheetState();
}

class _ProductDetailSheetState extends State<_ProductDetailSheet> {
  int _qty = 1;

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final cartProv = context.watch<CartProvider>();
    final cute = _Cute.of(context);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: cute.bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(_Cute.radiusLg)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: cute.peach,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding: const EdgeInsets.all(20),
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(_Cute.radiusMd),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: cute.border, width: 2),
                        borderRadius: BorderRadius.circular(_Cute.radiusMd),
                      ),
                      child: p.imageUrl.isNotEmpty
                          ? Image.network(
                              p.imageUrl,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, err, stack) =>
                                  Container(height: 200, color: cute.peach),
                            )
                          : Container(height: 200, color: cute.peach),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: cute.peach,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      p.category,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: cute.orangeDeep,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    p.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: cute.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.formatPrice(p.price),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: cute.orangeDeep,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    p.description,
                    style: TextStyle(fontSize: 13, color: cute.textSecondary, height: 1.5),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _QtyButton(
                        icon: Icons.remove_rounded,
                        color: cute.orange,
                        onTap: () {
                          if (_qty > 1) setState(() => _qty--);
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          '$_qty',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: cute.textPrimary,
                          ),
                        ),
                      ),
                      _QtyButton(
                        icon: Icons.add_rounded,
                        color: cute.orange,
                        onTap: () => setState(() => _qty++),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cute.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    elevation: 3,
                    shadowColor: cute.orange.withValues(alpha: 0.5),
                  ),
                  icon: cartProv.isAdding
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.shopping_bag_outlined, size: 18),
                  label: Text(
                    cartProv.isAdding ? 'Menambahkan...' : 'Tambah ke Keranjang',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                  onPressed: cartProv.isAdding
                      ? null
                      : () async {
                          final success =
                              await context.read<CartProvider>().addToCart(p.id, _qty);
                          if (!context.mounted) return;
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? '${p.name} ditambahkan ke keranjang'
                                    : 'Gagal menambahkan ke keranjang',
                              ),
                              backgroundColor: success ? cute.orangeDeep : Colors.red,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _QtyButton({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, size: 18, color: Colors.white),
      ),
    );
  }
}

// ── Bottom navigation ─────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const items = [
      _NavItem(icon: Icons.home_rounded, label: 'Home'),
      _NavItem(icon: Icons.shopping_bag_rounded, label: 'Cart'),
      _NavItem(icon: Icons.favorite_rounded, label: 'Favorite'),
      _NavItem(icon: Icons.person_rounded, label: 'Account'),
    ];

    final cartItemCount = context.watch<CartProvider>().itemCount;
    final cute = _Cute.of(context);

    return Container(
      decoration: BoxDecoration(
        color: cute.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(_Cute.radiusLg)),
        boxShadow: [
          BoxShadow(color: cute.shadow, blurRadius: 16, offset: const Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final selected = selectedIndex == i;
              final isCart = i == 1;
              return GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: selected ? cute.peach : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Icon(
                              items[i].icon,
                              size: 22,
                              color: selected ? cute.orangeDeep : cute.textHint,
                            ),
                            if (isCart && cartItemCount > 0)
                              Positioned(
                                right: -6,
                                top: -6,
                                child: Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: cute.orangeDeep,
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    cartItemCount > 99 ? '99+' : '$cartItemCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        items[i].label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
                          color: selected ? cute.orangeDeep : cute.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ── Data classes ─────────────────────────────────────────────────────────
class _CategoryItem {
  final String label;
  final IconData icon;
  const _CategoryItem({required this.label, required this.icon});
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}