import 'package:flutter/material.dart';
import 'package:pasar_malam/core/routes/app_router.dart';
import 'package:pasar_malam/features/order/data/models/order_model.dart';

// ── Orange theme accents (UI only) ─────────────────────────
const Color _kOrangePrimary = Color(0xFFFF7A00);
const Color _kOrangeDark = Color(0xFFE65100);
const Color _kBg = Color(0xFFFAFAFA);

class OrderSuccessPage extends StatelessWidget {
  final OrderModel order;

  const OrderSuccessPage({super.key, required this.order});

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

  String _paymentMethodLabel(String method) {
    switch (method) {
      case 'gopay':
        return 'GoPay';
      case 'bank_transfer':
        return 'Transfer Bank';
      case 'virtual_account':
        return 'Virtual Account';
      default:
        return method;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Menunggu Pembayaran';
      case 'processing':
        return 'Sedang Diproses';
      case 'shipped':
        return 'Dikirim';
      case 'delivered':
        return 'Diterima';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Status Pesanan',
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
        ),
        backgroundColor: _kOrangePrimary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 64,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Pesanan Berhasil!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: onSurface,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Order #${order.id}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: _kOrangeDark,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 28),

              // Info box
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF0F0F0)),
                  boxShadow: [
                    BoxShadow(
                      color: _kOrangePrimary.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _InfoRow(
                        label: 'Metode Pembayaran',
                        value: _paymentMethodLabel(order.paymentMethod),
                        icon: Icons.payment,
                        iconColor: _kOrangePrimary,
                      ),
                      const Divider(height: 20, color: Color(0xFFF0F0F0)),
                      _InfoRow(
                        label: 'Total Pembayaran',
                        value: _formatPrice(order.totalAmount),
                        icon: Icons.attach_money,
                        iconColor: Colors.green,
                        valueBold: true,
                      ),
                      const Divider(height: 20, color: Color(0xFFF0F0F0)),
                      _InfoRow(
                        label: 'Status',
                        value: _statusLabel(order.status),
                        icon: Icons.info_outline,
                        iconColor: Colors.orange,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Tombol Lihat Detail
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.receipt_long_outlined),
                  label: const Text('Lihat Detail Pesanan'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    side: const BorderSide(color: _kOrangePrimary, width: 1.5),
                    foregroundColor: _kOrangePrimary,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRouter.myOrders,
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // Tombol Kembali ke Beranda
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.home_outlined),
                  label: const Text('Kembali ke Beranda'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kOrangePrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRouter.dashboard,
                      (route) => false,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final bool valueBold;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.valueBold = false,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: onSurface.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: valueBold ? FontWeight.bold : FontWeight.w500,
                  color: onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}