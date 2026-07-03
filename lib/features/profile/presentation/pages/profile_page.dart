import 'package:flutter/material.dart';
import 'package:pasar_malam/core/providers/theme_provider.dart';
import 'package:pasar_malam/core/routes/app_router.dart';
import 'package:pasar_malam/features/auth/presentation/providers/auth_provider.dart';
import 'package:pasar_malam/features/cart/presentation/providers/cart_provider.dart';
import 'package:provider/provider.dart';

// ── Palet hijau, otomatis nyesuain terang/gelap ────────────
// (mengikuti pola _Cute di DashboardPage, warna diganti hijau
// sesuai referensi desain)
class _Leaf {
  final bool isDark;
  const _Leaf(this.isDark);

  factory _Leaf.of(BuildContext context) =>
      _Leaf(Theme.of(context).brightness == Brightness.dark);

  // Background
  Color get bg => isDark ? const Color(0xFF121212) : const Color(0xFFFFF7EF);

  Color get surface => isDark ? const Color(0xFF2C2C2C) : Colors.white;
  // Border
  Color get border =>
    isDark ? const Color(0xFF4A3826) : const Color(0xFFFFE8D6);
  // Text
  Color get textPrimary =>
      isDark ? const Color(0xFFEEEEEE) : const Color(0xFF3B2A20);

  Color get textSecondary =>
      isDark ? const Color(0xFFAAAAAA) : Colors.black54;

  Color get textHint =>
      isDark ? const Color(0xFF888888) : Colors.black38;

  // Orange (sama seperti Dashboard)
  Color get green => const Color(0xFFFF7A29);

  Color get greenSoft => isDark
      ? const Color(0xFF3A2A1E)
      : const Color(0xFFFFE8D6);

  // Logout
  Color get danger => const Color(0xFFE85D04);

  Color get dangerSoft => isDark
      ? const Color(0xFF3A2A1E)
      : const Color(0xFFFFE8D6);

  Color get shadow => isDark
      ? Colors.black.withValues(alpha: 0.35)
      : const Color(0xFFFF7A29).withValues(alpha: 0.10);
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final leaf = _Leaf.of(context);

    return Scaffold(
      backgroundColor: leaf.bg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                children: [
                  // ── Avatar & info user ────────────────────
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: leaf.surface,
                            border: Border.all(color: leaf.green, width: 2),
                          ),
                          child: Icon(
                            Icons.person_rounded,
                            size: 40,
                            color: leaf.green,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          auth.firebaseUser?.displayName ?? 'User',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: leaf.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          auth.firebaseUser?.email ?? '',
                          style: TextStyle(
                            fontSize: 13,
                            color: leaf.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Menu list ──────────────────────────────
                  _MenuCard(
                    icon: Icons.local_mall_outlined,
                    label: 'Pesanan Saya',
                    leaf: leaf,
                    onTap: () => Navigator.pushNamed(context, AppRouter.myOrders),
                  ),
                  const SizedBox(height: 10),
                  _MenuCard(
                    icon: Icons.favorite_border_rounded,
                    label: 'Wishlist',
                    leaf: leaf,
                    onTap: () {
                      // TODO: sambungkan ke route wishlist saat tersedia
                    },
                  ),
                  const SizedBox(height: 10),
                  _MenuCard(
                    icon: Icons.location_on_outlined,
                    label: 'Alamat',
                    leaf: leaf,
                    onTap: () {
                      // TODO: sambungkan ke route alamat saat tersedia
                    },
                  ),
                  const SizedBox(height: 10),

                  // ── Dark mode toggle ───────────────────────
                  _DarkModeRow(leaf: leaf),

                  const SizedBox(height: 24),

                  // ── Tombol Keluar ──────────────────────────
                  _LogoutButton(leaf: leaf, auth: auth),
                ],
              ),
            ),
            _ProfileBottomNav(leaf: leaf),
          ],
        ),
      ),
    );
  }
}

// ── Menu Card ───────────────────────────────────────────────
class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final _Leaf leaf;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.label,
    required this.leaf,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: leaf.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: leaf.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: leaf.greenSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18, color: leaf.green),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: leaf.textPrimary,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: leaf.textHint, size: 22),
          ],
        ),
      ),
    );
  }
}

// ── Dark Mode Row ───────────────────────────────────────────
class _DarkModeRow extends StatelessWidget {
  final _Leaf leaf;

  const _DarkModeRow({required this.leaf});

  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();
    final isDark = themeProv.isDark;

    return Container(
      decoration: BoxDecoration(
        color: leaf.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: leaf.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: leaf.greenSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isDark ? Icons.dark_mode_outlined : Icons.wb_sunny_outlined,
              size: 18,
              color: leaf.green,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Dark Mode',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: leaf.textPrimary,
              ),
            ),
          ),
          Switch(
            value: isDark,
            activeColor: leaf.green,
            onChanged: (_) => context.read<ThemeProvider>().toggle(),
          ),
        ],
      ),
    );
  }
}

// ── Tombol Keluar ───────────────────────────────────────────
class _LogoutButton extends StatelessWidget {
  final _Leaf leaf;
  final AuthProvider auth;

  const _LogoutButton({required this.leaf, required this.auth});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          backgroundColor: leaf.greenSoft,
            side: BorderSide(
              color: leaf.green.withValues(alpha: .25),
            ),
            foregroundColor: leaf.green,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        icon: const Icon(Icons.logout_rounded, size: 18),
        label: const Text(
          'Keluar',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        onPressed: () async {
          await auth.logout();
          if (!context.mounted) return;
          Navigator.pushReplacementNamed(context, AppRouter.login);
        },
      ),
    );
  }
}

// ── Bottom Navigation (Sama seperti Dashboard) ─────────────
class _ProfileBottomNav extends StatelessWidget {
  final _Leaf leaf;

  const _ProfileBottomNav({required this.leaf});

  @override
  Widget build(BuildContext context) {
    final cartItemCount = context.watch<CartProvider>().itemCount;

    const items = [
      _NavEntry(icon: Icons.home_rounded, label: 'Home'),
      _NavEntry(icon: Icons.shopping_bag_rounded, label: 'Cart'),
      _NavEntry(icon: Icons.favorite_rounded, label: 'Favorite'),
      _NavEntry(icon: Icons.person_rounded, label: 'Account'),
    ];

    const selectedIndex = 3;

    return Container(
      decoration: BoxDecoration(
        color: leaf.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: leaf.shadow,
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
              final selected = i == selectedIndex;
              final isCart = i == 1;

              return GestureDetector(
                onTap: () {
                  if (i == 0) {
                    Navigator.pop(context);
                  } else if (i == 1) {
                    Navigator.pushNamed(context, AppRouter.cart);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFFFFE8D6)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Icon(
                              items[i].icon,
                              size: 22,
                              color: selected
                                  ? const Color(0xFFE85D04)
                                  : leaf.textHint,
                            ),
                            if (isCart && cartItemCount > 0)
                              Positioned(
                                right: -6,
                                top: -6,
                                child: Container(
                                  width: 16,
                                  height: 16,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFE85D04),
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
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.normal,
                          color: selected
                              ? const Color(0xFFE85D04)
                              : leaf.textHint,
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

class _NavEntry {
  final IconData icon;
  final String label;

  const _NavEntry({
    required this.icon,
    required this.label,
  });
}