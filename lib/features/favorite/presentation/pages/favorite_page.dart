import 'package:flutter/material.dart';
import 'package:pasar_malam/core/routes/app_router.dart';
import 'package:pasar_malam/features/cart/presentation/providers/cart_provider.dart';
import 'package:pasar_malam/features/profile/presentation/pages/profile_page.dart';
import 'package:provider/provider.dart';

const Color _kOrange = Color(0xFFFF7A29);

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7EF),

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

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
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
                "Produk yang kamu tandai dengan ikon ❤️ akan muncul di sini.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: const _FavoriteBottomNav(),
    );
  }
}

class _FavoriteBottomNav extends StatelessWidget {
  const _FavoriteBottomNav();

  @override
  Widget build(BuildContext context) {
    final cartItemCount = context.watch<CartProvider>().itemCount;

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
        top: false,
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
                onTap: () =>
                    Navigator.pushNamed(context, AppRouter.cart),
                badge: cartItemCount,
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
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProfilePage(),
                    ),
                  );
                },
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
                size: 24,
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
                        fontWeight: FontWeight.bold,
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
              fontWeight:
                  selected ? FontWeight.w700 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}