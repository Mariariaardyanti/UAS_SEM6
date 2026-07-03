import 'package:flutter/material.dart';
import 'package:pasar_malam/core/routes/app_router.dart';
import 'package:pasar_malam/features/cart/data/models/cart_model.dart';
import 'package:pasar_malam/features/cart/presentation/providers/cart_provider.dart';
import 'package:provider/provider.dart';

// ── Palet oren gemas  ─────────────────────────────────────
class _CuteColors {
  static const Color orange = Color(0xFFFF7A29);
  static const Color orangeSoft = Color(0xFFFFA351);
  static const Color orangeDeep = Color(0xFFE85D04);
  static const Color peach = Color(0xFFFFE8D6);
  static const Color cream = Color(0xFFFFF7EF);
  static const Color yellowAccent = Color(0xFFFFC15E);
}

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().fetchCart();
    });
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

  Future<void> _confirmClearCart(BuildContext context, CartProvider cartProv) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Kosongkan Keranjang?',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Semua barang lucu di keranjangmu bakal dihapus, lho~',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: TextButton.styleFrom(
              foregroundColor: _CuteColors.orangeDeep,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _CuteColors.orangeDeep,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus Semua'),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      await cartProv.clearCart();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _CuteColors.cream,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _CuteColors.orange,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
        ),
        title: Row(
          children: const [
            Text(
              'Keranjang Belanjaku',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cartProv, _) {
              final hasItems =
                  cartProv.cart != null && cartProv.cart!.items.isNotEmpty;
              if (!hasItems) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.cleaning_services_rounded, size: 20),
                    tooltip: 'Hapus Semua',
                    onPressed: () => _confirmClearCart(context, cartProv),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProv, _) {
          if (cartProv.status == CartStatus.loading ||
              cartProv.status == CartStatus.initial) {
            return const Center(
              child: CircularProgressIndicator(color: _CuteColors.orange),
            );
          }

          if (cartProv.status == CartStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 12),
                  Text(
                    cartProv.error ?? 'Aduh, ada yang salah nih',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _CuteColors.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Coba Lagi'),
                    onPressed: () => cartProv.fetchCart(),
                  ),
                ],
              ),
            );
          }

          final cart = cartProv.cart;
          if (cart == null || cart.items.isEmpty) {
            return _EmptyCartView();
          }

          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  color: _CuteColors.orange,
                  onRefresh: () => cartProv.fetchCart(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.items.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 14),
                    itemBuilder: (ctx, i) => _CartItemCard(
                      item: cart.items[i],
                      formatPrice: _formatPrice,
                      onRemove: () => cartProv.removeItem(cart.items[i].id),
                      onDecrease: () {
                        final qty = cart.items[i].quantity - 1;
                        if (qty <= 0) {
                          cartProv.removeItem(cart.items[i].id);
                        } else {
                          cartProv.updateItem(cart.items[i].id, qty);
                        }
                      },
                      onIncrease: () => cartProv.updateItem(
                        cart.items[i].id,
                        cart.items[i].quantity + 1,
                      ),
                    ),
                  ),
                ),
              ),
              _CartBottomBar(
                total: cart.total,
                formatPrice: _formatPrice,
                onCheckout: () {
                  Navigator.pushNamed(context, AppRouter.checkout);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Empty Cart View ────────────────────────────────────────
class _EmptyCartView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: const BoxDecoration(
              color: _CuteColors.peach,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🧺', style: TextStyle(fontSize: 64)),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Waduh, keranjangnya kosong~',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: _CuteColors.orangeDeep,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Yuk isi dengan jajanan favoritmu! ',
            style: TextStyle(
              fontSize: 13,
              color: Colors.black.withValues(alpha: 0.45),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: _CuteColors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 3,
            ),
            icon: const Icon(Icons.storefront_rounded),
            label: const Text(
              'Mulai Belanja',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

// ── Cart Item Card ─────────────────────────────────────────
class _CartItemCard extends StatelessWidget {
  final CartItemModel item;
  final String Function(double) formatPrice;
  final VoidCallback onRemove;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  const _CartItemCard({
    required this.item,
    required this.formatPrice,
    required this.onRemove,
    required this.onDecrease,
    required this.onIncrease,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _CuteColors.peach, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _CuteColors.orange.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar produk
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: _CuteColors.peach, width: 2),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: item.product.imageUrl.isNotEmpty
                    ? Image.network(
                        item.product.imageUrl,
                        width: 78,
                        height: 78,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => _placeholder(context),
                      )
                    : _placeholder(context),
              ),
            ),
            const SizedBox(width: 12),
            // Info produk
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _CuteColors.peach,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                item.product.category,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: _CuteColors.orangeDeep,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.product.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Colors.black87,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: onRemove,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: Colors.black45,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatPrice(item.product.price),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black.withValues(alpha: 0.45),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Quantity control
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                        decoration: BoxDecoration(
                          color: _CuteColors.peach,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: [
                            _QtyButton(icon: Icons.remove_rounded, onTap: onDecrease),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                '${item.quantity}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: _CuteColors.orangeDeep,
                                ),
                              ),
                            ),
                            _QtyButton(icon: Icons.add_rounded, onTap: onIncrease),
                          ],
                        ),
                      ),
                      // Subtotal
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _CuteColors.orange,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          formatPrice(item.subtotal),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(BuildContext context) => Container(
        width: 78,
        height: 78,
        color: _CuteColors.peach,
      );
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        decoration: const BoxDecoration(
          color: _CuteColors.orange,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 15, color: Colors.white),
      ),
    );
  }
}

// ── Cart Bottom Bar ────────────────────────────────────────
class _CartBottomBar extends StatelessWidget {
  final double total;
  final String Function(double) formatPrice;
  final VoidCallback onCheckout;

  const _CartBottomBar({
    required this.total,
    required this.formatPrice,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1FFF7A29),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Total Belanja',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.black45,
                    ),
                  ),
                  Text(
                    formatPrice(total),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: _CuteColors.orangeDeep,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _CuteColors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 3,
                    shadowColor: _CuteColors.orange.withValues(alpha: 0.5),
                  ),
                  onPressed: onCheckout,
                  label: const Text(
                    'Checkout Yuk!',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}