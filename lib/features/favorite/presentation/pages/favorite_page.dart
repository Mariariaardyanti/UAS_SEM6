import 'package:flutter/material.dart';
import 'package:pasar_malam/core/routes/app_router.dart';
import 'package:pasar_malam/features/cart/presentation/providers/cart_provider.dart';
import 'package:pasar_malam/features/favorite/presentation/providers/favorite_provider.dart';
import 'package:provider/provider.dart';

const Color _kOrange = Color(0xFFFF7A29);

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    final favProv = context.watch<FavoriteProvider>();
    final favorites = favProv.favorites;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7EF),

      // ── APP BAR ─────────────────────────────
      appBar: AppBar(
        title: const Text(
          "Produk Favorit",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: _kOrange,
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      // ── BODY ────────────────────────────────
      body: favorites.isEmpty
          ? _emptyState()
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.72,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: favorites.length,
              itemBuilder: (context, i) {
                final p = favorites[i];

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // ── IMAGE ─────────────────────
                      Expanded(
                        flex: 5,
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                              child: Image.network(
                                p.imageUrl,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),

                            // ── REMOVE FAVORITE ─────────
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () {
                                  context
                                      .read<FavoriteProvider>()
                                      .remove(p.id); // ❗ FIX: jangan toString
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.favorite_rounded,
                                    size: 16,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ── INFO ──────────────────────
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              p.category,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Rp ${p.price}",
                              style: const TextStyle(
                                color: _kOrange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            ),

      // ── BOTTOM NAV (SAMA KAYAK DASHBOARD) ───
      bottomNavigationBar: _BottomNav(),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border_rounded,
            size: 90,
            color: Colors.orange.shade300,
          ),
          const SizedBox(height: 20),
          const Text(
            "Belum Ada Produk Favorit",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Produk yang kamu tandai ❤️ akan muncul di sini.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── BOTTOM NAVIGATION ─────────────────────────
class _BottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<CartProvider>().itemCount;

    const selectedIndex = 2;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            blurRadius: 16,
            color: Colors.black12,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [

              _item(
                context,
                icon: Icons.home_rounded,
                label: "Home",
                selected: selectedIndex == 0,
                onTap: () => Navigator.pop(context),
              ),

              _item(
                context,
                icon: Icons.shopping_bag_rounded,
                label: "Cart",
                selected: selectedIndex == 1,
                badge: cartCount,
                onTap: () => Navigator.pushNamed(context, AppRouter.cart),
              ),

              _item(
                context,
                icon: Icons.favorite_rounded,
                label: "Favorite",
                selected: selectedIndex == 2,
                onTap: () {},
              ),

              _item(
                context,
                icon: Icons.person_rounded,
                label: "Account",
                selected: selectedIndex == 3,
                onTap: () => Navigator.pushNamed(context, AppRouter.profile),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
    int? badge,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                icon,
                color: selected ? _kOrange : Colors.grey,
              ),

              if (badge != null && badge > 0)
                Positioned(
                  right: -6,
                  top: -6,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      badge > 99 ? "99+" : "$badge",
                      style: const TextStyle(
                        fontSize: 9,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: selected ? _kOrange : Colors.grey,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}