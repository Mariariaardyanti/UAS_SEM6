import 'package:flutter/material.dart';
import 'package:pasar_malam/core/providers/theme_provider.dart';
import 'package:pasar_malam/core/routes/app_router.dart';
import 'package:pasar_malam/features/auth/presentation/providers/auth_provider.dart';
import 'package:pasar_malam/features/cart/presentation/providers/cart_provider.dart';
import 'package:pasar_malam/features/dashboard/data/models/product_model.dart';
import 'package:pasar_malam/features/dashboard/presentation/providers/product_provider.dart';
import 'package:pasar_malam/features/order/presentation/providers/order_provider.dart';
import 'package:provider/provider.dart';

// ── Palet oren gemas, otomatis nyesuain terang/gelap ───────
class _Cute {
  final bool isDark;
  const _Cute(this.isDark);

  factory _Cute.of(BuildContext context) =>
      _Cute(Theme.of(context).brightness == Brightness.dark);

  // Latar
  Color get bg => isDark ? const Color(0xFF121212) : const Color(0xFFFFF7EF);
  Color get surface => isDark ? const Color(0xFF2C2C2C) : Colors.white;
  Color get surfaceAlt => isDark ? const Color(0xFF1E1E1E) : Colors.white;

  // Aksen lembut (badge, border kartu, dsb)
  Color get peach => isDark ? const Color(0xFF3A2A1E) : const Color(0xFFFFE8D6);
  Color get border => isDark ? const Color(0xFF4A3826) : const Color(0xFFFFE8D6);

  // Teks
  Color get textPrimary => isDark ? const Color(0xFFEEEEEE) : const Color(0xFF3B2A20);
  Color get textSecondary => isDark ? const Color(0xFFAAAAAA) : Colors.black54;
  Color get textHint => isDark ? const Color(0xFF888888) : Colors.black38;

  // Oren utama — tetap konsisten di dua mode biar brand-nya kebaca
  Color get orange => const Color(0xFFFF7A29);
  Color get orangeSoft => const Color(0xFFFFA351);
  // Sedikit dicerahkan di dark biar kontras enak di atas latar gelap
  Color get orangeDeep => isDark ? const Color(0xFFFFA35C) : const Color(0xFFE85D04);
  Color get yellowAccent => const Color(0xFFFFC15E);

  Color get shadow => isDark
      ? Colors.black.withValues(alpha: 0.35)
      : const Color(0xFFFF7A29).withValues(alpha: 0.10);
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

  final List<_CategoryItem> _categories = const [
    _CategoryItem(label: 'All', icon: Icons.apps_rounded),
    _CategoryItem(label: 'Running', icon: Icons.directions_run_rounded),
    _CategoryItem(label: 'Lifestyle', icon: Icons.style_rounded),
    _CategoryItem(label: 'Football', icon: Icons.sports_soccer_rounded),
    _CategoryItem(label: 'Volleyball', icon: Icons.sports_volleyball_rounded),
    _CategoryItem(label: 'Tennis', icon: Icons.sports_tennis_rounded),
    _CategoryItem(label: 'Badminton', icon: Icons.sports_rounded),
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
    return 'Rp. ${buffer.toString().split('').reversed.join()}';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final productProv = context.watch<ProductProvider>();
    final cute = _Cute.of(context);

    // ignore: unused_local_variable
    final _ = context.watch<OrderProvider>();

    return Scaffold(
      backgroundColor: cute.bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Body scroll ─────────────────────────────────
            Expanded(
              child: RefreshIndicator(
                color: cute.orange,
                onRefresh: () => productProv.fetchProducts(),
                child: CustomScrollView(
                  slivers: [
                    // ── Search Bar ─────────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                        child: _SearchBar(controller: _searchCtrl, onChanged: (_) => setState(() {})),
                      ),
                    ),

                    // ── Banner ─────────────────────────────
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: _BannerCard(),
                      ),
                    ),

                    // ── Categories ─────────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Kategori',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: cute.textPrimary,
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: Text(
                                'Lihat Semua',
                                style: TextStyle(
                                  color: cute.orangeDeep,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
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
                            final selected = _selectedCategory == cat.label;
                            return _CategoryChip(
                              item: cat,
                              selected: selected,
                              onTap: () => setState(() => _selectedCategory = cat.label),
                            );
                          },
                        ),
                      ),
                    ),

                    // ── For You label ─────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
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

                    // ── Product Grid ──────────────────────
                    switch (productProv.status) {
                      ProductStatus.loading || ProductStatus.initial =>
                        SliverFillRemaining(
                          child: Center(
                            child: CircularProgressIndicator(color: cute.orange),
                          ),
                        ),
                      ProductStatus.error => SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 12),
                                Text(
                                  productProv.error ?? 'Aduh, ada yang salah nih',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: cute.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: cute.orange,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 12),
                                  ),
                                  icon: const Icon(Icons.refresh_rounded),
                                  label: const Text('Coba Lagi'),
                                  onPressed: () => productProv.fetchProducts(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ProductStatus.loaded => () {
                          final items = _filteredProducts(productProv.products);
                          if (items.isEmpty) {
                            return SliverFillRemaining(
                              child: Center(
                                child: Text(
                                  '🔍 Produk tidak ditemukan',
                                  style: TextStyle(color: cute.textPrimary),
                                ),
                              ),
                            );
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

            // ── Bottom Navigation Bar ────────────────────
            _BottomNav(
              selectedIndex: _selectedNav,
              onTap: (i) {
                if (i == 1) {
                  // Cart → navigate to CartPage
                  Navigator.pushNamed(context, AppRouter.cart).then((_) {
                    if (context.mounted) {
                      context.read<CartProvider>().fetchCart();
                    }
                  });
                } else if (i == 3) {
                  // Account → logout dialog
                  _showLogoutDialog(context, auth);
                } else {
                  setState(() => _selectedNav = i);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return _AccountDialog(auth: auth);
      },
    );
  }
}

// ── Search Bar Widget ──────────────────────────────────────
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
        boxShadow: [
          BoxShadow(
            color: cute.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: TextStyle(color: cute.textPrimary),
        decoration: InputDecoration(
          hintText: 'Cari Tas favoritmu... ',
          hintStyle: TextStyle(color: cute.textHint, fontSize: 14),
          prefixIcon: Icon(Icons.search_rounded, color: cute.orange, size: 22),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 13),
        ),
      ),
    );
  }
}

// ── Banner Card Widget ─────────────────────────────────────
class _BannerCard extends StatelessWidget {
  const _BannerCard();

  @override
  Widget build(BuildContext context) {
    final cute = _Cute.of(context);

    return Container(
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: cute.isDark
              ? const [Color(0xFFB84600), Color(0xFFE07A2E)]
              : [const Color(0xFFE85D04), cute.orangeSoft],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Stack(
        children: [
          // Lingkaran dekorasi background
          Positioned(
            right: 130,
            top: -20,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.10),
              ),
            ),
          ),
          Positioned(
            right: 40,
            bottom: -30,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cute.yellowAccent.withValues(alpha: 0.25),
              ),
            ),
          ),
          // Teks dan tombol
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '✨ Koleksi Baru!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Diskon hingga 50%\nuntuk transaksi pertamamu',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'BELANJA YUK!',
                      style: TextStyle(
                        color: cute.isDark ? const Color(0xFFB84600) : const Color(0xFFE85D04),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Gambar sepatu placeholder
          Positioned(
            right: 0,
            bottom: 0,
            top: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              child: Container(
                width: 160,
                alignment: Alignment.center,
                child: const Text('🏃', style: TextStyle(fontSize: 70)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Category Chip Widget ───────────────────────────────────
class _CategoryChip extends StatelessWidget {
  final _CategoryItem item;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cute = _Cute.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? cute.orange : cute.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? cute.orange : cute.border,
            width: 1.5,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: cute.orange.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              size: 16,
              color: selected ? Colors.white : cute.orangeDeep,
            ),
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

// ── Product Card Widget ────────────────────────────────────
class _ProductCard extends StatefulWidget {
  final ProductModel product;
  final String Function(double) formatPrice;

  const _ProductCard({required this.product, required this.formatPrice});

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool _isFavorite = false;

  void _showProductDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _ProductDetailSheet(
        product: widget.product,
        formatPrice: widget.formatPrice,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final cute = _Cute.of(context);

    return GestureDetector(
      onTap: () => _showProductDetail(context),
      child: Container(
        decoration: BoxDecoration(
          color: cute.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cute.border, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: cute.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Gambar produk ───────────────────────────
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(19),
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
                  // Heart button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => setState(() => _isFavorite = !_isFavorite),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: cute.surface,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(
                          _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          size: 16,
                          color: _isFavorite ? cute.orangeDeep : cute.textHint,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Info produk ────────────────────────────
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kategori
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: cute.peach,
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
                    const SizedBox(height: 4),
                    // Nama produk
                    Text(
                      p.name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: cute.textPrimary,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    // Rating
                    Row(
                      children: [
                        ...List.generate(
                          5,
                          (i) => Icon(
                            i < 4 ? Icons.star_rounded : Icons.star_half_rounded,
                            size: 13,
                            color: cute.yellowAccent,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '4.6',
                          style: TextStyle(fontSize: 11, color: cute.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Harga
                    Text(
                      widget.formatPrice(p.price),
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
        child: const Center(
          child: Text('🍡', style: TextStyle(fontSize: 32)),
        ),
      );
}

// ── Product Detail Bottom Sheet ────────────────────────────
class _ProductDetailSheet extends StatefulWidget {
  final ProductModel product;
  final String Function(double) formatPrice;

  const _ProductDetailSheet({
    required this.product,
    required this.formatPrice,
  });

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
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            // Drag handle
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
                  // Gambar produk
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: cute.border, width: 2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: p.imageUrl.isNotEmpty
                          ? Image.network(
                              p.imageUrl,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, err, stack) => Container(
                                height: 200,
                                color: cute.peach,
                              ),
                            )
                          : Container(
                              height: 200,
                              color: cute.peach,
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Kategori
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
                  // Nama
                  Text(
                    p.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: cute.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Harga
                  Text(
                    widget.formatPrice(p.price),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: cute.orangeDeep,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Deskripsi
                  Text(
                    p.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: cute.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Quantity stepper
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (_qty > 1) setState(() => _qty--);
                        },
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: cute.orange,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.remove_rounded, size: 18, color: Colors.white),
                        ),
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
                      GestureDetector(
                        onTap: () => setState(() => _qty++),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: cute.orange,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add_rounded, size: 18, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            // Tombol Tambah ke Keranjang
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cute.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 3,
                    shadowColor: cute.orange.withValues(alpha: 0.5),
                  ),
                  icon: cartProv.isAdding
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('', style: TextStyle(fontSize: 16)),
                  label: Text(
                    cartProv.isAdding ? 'Menambahkan...' : 'Tambah ke Keranjang',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  onPressed: cartProv.isAdding
                      ? null
                      : () async {
                          final success = await context
                              .read<CartProvider>()
                              .addToCart(p.id, _qty);
                          if (!context.mounted) return;
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? '${p.name} ditambahkan ke keranjang'
                                    : 'Gagal menambahkan ke keranjang',
                              ),
                              backgroundColor:
                                  success ? cute.orangeDeep : Colors.red,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
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

// ── Bottom Navigation Bar ──────────────────────────────────
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
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: cute.shadow,
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
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
                                    cartItemCount > 99
                                        ? '99+'
                                        : '$cartItemCount',
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

// ── Data classes ───────────────────────────────────────────
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

// ── Account Dialog (dengan Dark Mode Switch) ──────────────
class _AccountDialog extends StatelessWidget {
  final AuthProvider auth;

  const _AccountDialog({required this.auth});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDark;
    final cute = _Cute.of(context);

    return AlertDialog(
      backgroundColor: cute.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(
        'Akun',
        style: TextStyle(fontWeight: FontWeight.w800, color: cute.textPrimary),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar
          CircleAvatar(
            radius: 30,
            backgroundColor: cute.orange,
            child: Text(
              (auth.firebaseUser?.displayName ?? 'U')[0].toUpperCase(),
              style: const TextStyle(fontSize: 24, color: Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            auth.firebaseUser?.displayName ?? 'User',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: cute.textPrimary,
            ),
          ),
          Text(
            auth.firebaseUser?.email ?? '',
            style: TextStyle(color: cute.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 20),
          Divider(color: cute.border),
          const SizedBox(height: 4),

          // Dark mode toggle row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    size: 20,
                    color: isDark ? cute.yellowAccent : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isDark ? 'Mode Gelap' : 'Mode Terang',
                    style: TextStyle(fontSize: 14, color: cute.textPrimary),
                  ),
                ],
              ),
              Switch(
                value: isDark,
                activeColor: cute.orange,
                onChanged: (_) => context.read<ThemeProvider>().toggle(),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(foregroundColor: cute.orangeDeep),
          child: const Text('Tutup'),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.logout_rounded, size: 18),
          label: const Text('Logout'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: () async {
            Navigator.pop(context);
            await auth.logout();
            if (!context.mounted) return;
            // ignore: use_build_context_synchronously
            Navigator.pushReplacementNamed(context, AppRouter.login);
          },
        ),
      ],
    );
  }
}