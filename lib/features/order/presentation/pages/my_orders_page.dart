import 'package:flutter/material.dart';
import 'package:pasar_malam/features/order/data/models/order_model.dart';
import 'package:pasar_malam/features/order/presentation/providers/order_provider.dart';
import 'package:provider/provider.dart';

// ── Orange theme accents (UI only) ─────────────────────────
const Color _kOrangePrimary = Color(0xFFFF7A00);
const Color _kOrangeDark = Color(0xFFE65100);
const Color _kBg = Color(0xFFFAFAFA);

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().fetchMyOrders();
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

  String _formatDate(String createdAt) {
    if (createdAt.isEmpty) return '-';
    try {
      final dt = DateTime.parse(createdAt);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return createdAt;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        title: const Text(
          'Pesanan Saya',
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
        ),
        backgroundColor: _kOrangePrimary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProv, _) {
          if (orderProv.checkoutStatus == OrderStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(color: _kOrangePrimary),
            );
          }

          if (orderProv.checkoutStatus == OrderStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(orderProv.error ?? 'Terjadi kesalahan'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Coba Lagi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kOrangePrimary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => orderProv.fetchMyOrders(),
                  ),
                ],
              ),
            );
          }

          if (orderProv.orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 72,
                    color: _kOrangePrimary.withValues(alpha: 0.25),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada pesanan',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.5),
                        ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: _kOrangePrimary,
            onRefresh: () => orderProv.fetchMyOrders(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: orderProv.orders.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (ctx, i) => _OrderCard(
                order: orderProv.orders[i],
                formatPrice: _formatPrice,
                formatDate: _formatDate,
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Order Card ─────────────────────────────────────────────
class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final String Function(double) formatPrice;
  final String Function(String) formatDate;

  const _OrderCard({
    required this.order,
    required this.formatPrice,
    required this.formatDate,
  });

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
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
    final statusColor = _statusColor(order.status);

    return Container(
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: order id + status chip
            // Header
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Text(
      'Order #${order.id}',
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: _kOrangeDark,
      ),
    ),
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _statusLabel(order.status),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: statusColor,
        ),
      ),
    ),
  ],
),

const SizedBox(height: 6),

Text(
  formatDate(order.createdAt),
  style: TextStyle(
    fontSize: 12,
    color: onSurface.withValues(alpha: 0.5),
  ),
),

const Divider(height: 20),

// Produk
...order.items.map(
  (item) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        const Icon(
          Icons.shopping_bag_outlined,
          size: 18,
          color: _kOrangePrimary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
  item.productName,
  style: const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  ),
),
        ),
        Text("x${item.quantity}"),
      ],
    ),
  ),
),

const Divider(height: 20),

Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Text(
      '${order.items.length} item',
      style: TextStyle(
        fontSize: 13,
        color: onSurface.withValues(alpha: 0.7),
      ),
    ),
    Text(
      formatPrice(order.totalAmount),
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: _kOrangePrimary,
      ),
    ),
  ],
),
          ],
        ),
      ),
    );
  }
}