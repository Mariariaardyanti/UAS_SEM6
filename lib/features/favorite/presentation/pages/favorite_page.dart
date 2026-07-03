import 'package:flutter/material.dart';

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
    );
  }
}